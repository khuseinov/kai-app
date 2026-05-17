# BUG: Когнитивный индикатор не виден во время стриминга

**Дата:** 2026-05-17  
**Репо:** `kai-app` (Flutter)  
**Статус:** OPEN — requires fix  
**Severity:** P1 — ключевая UX-фича невидима

---

## Симптомы

Пользователь отправляет сообщение → Кай отвечает текстом нормально → но **под аватаром Кай
ничего не появляется**: ни шаги `слушаю...` / `ищу источники...`, ни tool-лейблы
`сверяю визы...`, ни spinner. Текст сообщения приходит корректно. Только индикатор не виден.

Так же не видны:
- Шаги когнитивного цикла (PEOVUCARG)
- Tool-specific лейблы (visa_checker → `сверяю визы...` и т.д.)
- Любая анимация "Kai thinking"

---

## Что уже сделано и работает

### Backend (kai-agent) ✅

Проверено на VPS через SSE-probe (curl localhost:8000/chat/stream):

1. Для travel-запроса «Нужна ли виза в ОАЭ?» backend эмитит **6 state events**:
   ```
   event: state  data: {"step": "P", "label": "perceiving"}
   event: state  data: {"step": "E", "label": "enacting"}
   event: state  data: {"step": "V", "label": "valuing"}
   event: state  data: {"step": "C", "label": "critiquing"}
   event: state  data: {"step": "G", "label": "aligning"}
   event: state  data: {"step": "U", "label": "updating"}
   ```
2. Для простого «Привет» — один event `step: E` (FAST path — so by design).
3. DSML-маркеры отфильтрованы (BUG-DSML-LEAK-1 зафиксирован в `5abca87`).
4. Nginx `/chat/stream` имеет `proxy_buffering off`, `gzip off`, `X-Accel-Buffering: no` — всё правильно.

### Flutter — код на диске ✅

`chat_message.freezed.dart` содержит `cognitiveStatus` и `currentStep` в `copyWith`.

`chat_remote_source.dart:85-89` правильно парсит `event: state`:
```dart
} else if (currentEvent == 'state') {
  yield ChatStreamEvent.state(
    step: json['step'] as String? ?? '',
    label: json['label'] as String? ?? '',
  );
}
```

`chat_repository.dart:77-81` правильно обновляет state:
```dart
state: (step, label) async {
  responseMessage = responseMessage.copyWith(
    currentStep: step,
    cognitiveStatus: label,
  );
  onUpdate(responseMessage);
},
```

`message_bubble.dart:193-201` render gate:
```dart
if (message.cognitiveStatus != null &&
    message.cognitiveStatus!.isNotEmpty &&
    message.status != 'sent') ...[
  KaiCognitiveStatus(
    currentStep: message.cognitiveStatus!,
    step: message.currentStep,
  ),
```

`kai_cognitive_status.dart` русские лейблы — правильные.

---

## Корневая причина

**Flutter frame batching** — Riverpod StateNotifier уведомляет о каждом `state =`,
но Flutter рендерит только один раз за frame (~16ms). Если все SSE-события
(state × 6 + message tokens × N + done) приходят в TCP-буфер за ~200-500ms
(DeepSeek V4 Flash очень быстр), `await for` обрабатывает их без реальных async-пауз
между итерациями.

Последовательность в одном "кадре" Flutter:
```
state E  → cognitiveStatus="enacting", status="typing"  → state=... (rebuild queued)
state V  → cognitiveStatus="valuing"                    → state=... (rebuild queued)
...
done     → cognitiveStatus=null, status="sent"           → state=... (rebuild queued)
```
Flutter рендерит только **последнее состояние** (status="sent", cognitiveStatus=null).
Render gate `message.status != 'sent'` → False → индикатор не показывается.

Это объясняет почему backend работает, parse работает, код правильный — но визуально
ничего не видно.

---

## Как воспроизвести

1. `flutter run` в `kai-app` (любой target)
2. Отправить «Нужна ли виза в ОАЭ?»
3. Наблюдать: текст ответа появляется, но под аватаром Кай ничего не мелькает

---

## Решение (три варианта, рекомендуется Fix A)

### Fix A — минимальная задержка после state events (быстро, надёжно)

**Файл:** `lib/features/chat/data/chat_repository.dart`

В `state` обработчик добавить `await Future.delayed` чтобы дать Flutter отрендерить
кадр перед обработкой следующего события:

```dart
state: (step, label) async {
  responseMessage = responseMessage.copyWith(
    currentStep: step,
    cognitiveStatus: label,
  );
  onUpdate(responseMessage);
  // BUG-STREAM-FRAME-1: give Flutter ≥1 frame to render the step indicator
  // before processing the next SSE event. Without this pause, DeepSeek
  // delivers all events in ~200ms and the indicator is set+cleared within
  // a single frame, making it invisible to the user.
  await Future.delayed(const Duration(milliseconds: 80));
},
```

80ms = ~5 frames at 60fps. Per-step overhead: 6 steps × 80ms = 480ms extra latency.
Acceptable for a travel query that takes 3-10s total.

### Fix B — минимальная длительность отображения (более правильно)

Сделать `KaiCognitiveStatus` `StatefulWidget` с `Timer` — показывать каждый шаг минимум 1 секунду даже если `done` пришёл раньше.

**Файл:** `lib/core/design/components/kai_cognitive_status.dart`

```dart
class KaiCognitiveStatus extends StatefulWidget {
  final String currentStep;
  final String? step;
  const KaiCognitiveStatus({super.key, required this.currentStep, this.step});
  @override State<KaiCognitiveStatus> createState() => _KaiCognitiveStatusState();
}

class _KaiCognitiveStatusState extends State<KaiCognitiveStatus> {
  late String _displayStep;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _displayStep = widget.currentStep;
  }

  @override
  void didUpdateWidget(KaiCognitiveStatus old) {
    super.didUpdateWidget(old);
    if (widget.currentStep != old.currentStep) {
      _holdTimer?.cancel();
      setState(() => _displayStep = widget.currentStep);
      // Hold this step visible for at least 700ms
      _holdTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _displayStep = widget.currentStep);
      });
    }
  }

  @override
  void dispose() { _holdTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // render using _displayStep instead of widget.currentStep
    ...
  }
}
```

### Fix C — изменить render gate (самый простой, но менее точный)

Вместо проверки `status != 'sent'` — проверять `content.isEmpty` (показывать пока
контент не пришёл):

```dart
if (message.cognitiveStatus != null &&
    message.cognitiveStatus!.isNotEmpty &&
    message.content.isEmpty) ...[
```

Но это скрывает индикатор как только первый токен ответа пришёл — слишком рано.

---

## Дополнительный баг: receiveTimeout слишком мало

**Файл:** `lib/core/config/env_config.dart`

```dart
static Duration get receiveTimeout => switch (current) {
  Environment.dev => const Duration(seconds: 130),
  _ => const Duration(seconds: 90),
};
```

130s — недостаточно для KAI-FT (CPU inference до 1800s по CLAUDE.md). Нужно:
```dart
static Duration get receiveTimeout => switch (current) {
  Environment.dev => const Duration(seconds: 1800),  // KAI-FT CPU timeout
  _ => const Duration(seconds: 300),
};
```

Это не мешает текущим DeepSeek-запросам (быстрые), но нужно для будущего KAI-FT.

---

## Файлы для изменений

| Файл | Изменение |
|------|-----------|
| `lib/features/chat/data/chat_repository.dart` | Fix A: добавить `await Future.delayed(const Duration(milliseconds: 80))` в `state` handler |
| `lib/core/config/env_config.dart` | Увеличить `receiveTimeout` до 1800s dev / 300s prod |

Опционально (Fix B):
| `lib/core/design/components/kai_cognitive_status.dart` | StatefulWidget с Timer |

---

## Проверка после фикса

1. Запустить приложение: `flutter run`
2. Отправить «Нужна ли виза в ОАЭ?»
3. Ожидаемо: под аватаром мелькают `слушаю...` → `ищу источники...` → `сверяю визы...` → ... → `почти готов...` в течение ~1-2с каждый шаг
4. После ответа: индикатор исчезает, текст отображается
5. Отправить «Привет» — один быстрый flash `ищу источники...` (FAST path, OK)

---

## Контекст

- Backend repo: `kai-agent` → `src/api/stream.py` (SSE pipeline)
- Cognitive cycle: PEOVUCARG (Perceive/Enact/Value/Observe/Critique/Anticipate/Reflect/Goal_align/Update)
- State events emitted by: `src/cognitive/orchestrator.py` `_step_emit` callback → `asyncio.Queue` → SSE yield
- VPS: 78.17.13.214 (DeepSeek primary, KAI-FT fallback)
- Все backend SSE-проверки: PASS (2026-05-17)
