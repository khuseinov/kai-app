# План: Глубокий аудит и исправление багов

## Цель
Исправить баг с тапом по экрану, отвязать анимацию волны от текстовой загрузки, исправить имя на "Kai", выбрать более органичную иконку (или убрать ее), и внедрить Markdown для красивого форматирования ответов в стиле Anthropic.

## Архитектура
1.  **Исправление логики `ChatScreen`**: Вернуть вызов микрофона по тапу на экран (убрать блокировку `FeatureFlags.voiceEnabled` для этого прототипа) и обновить `_voiceStateFromChat`, чтобы волна ("Думает") появлялась *только* если мы находимся в режиме прослушивания (`_isListening`).
2.  **Аватар и имя**: Изменить "KAI" на "Kai". Убрать иконку сферы/искры и использовать абстрактную элегантную иконку (например, `Icons.insights` или чистый градиентный круг без иконки). 
3.  **Форматирование**: Добавить `flutter_markdown` в `MessageBubble`, чтобы ответы отображались с правильной структурой (заголовки, списки, жирный текст), как у топовых ИИ.

---

### Задача 1: Исправление багов состояний (Свайп и Волна)

**Файлы:**
- `lib/features/chat/presentation/chat_screen.dart`

- В обработчике `GestureDetector.onTap` убрать `if (FeatureFlags.voiceEnabled)` и просто переключать состояние `_isListening = !_isListening`.
- В функции `_voiceStateFromChat` добавить условие: возвращать `KaiVoiceState.thinking`, только если `_isListening == true`. Иначе возвращать `idle`.

### Задача 2: Обновление аватара, имени и добавление Markdown

**Файлы:**
- `lib/features/chat/presentation/widgets/message_bubble.dart`
- `lib/features/chat/presentation/widgets/chat_loading_indicator.dart`

- Поменять `'KAI'` на `'Kai'` в `MessageBubble` и других местах.
- Изменить `Icons.lens_blur` на `Icons.insights` (или просто пустой контейнер).
- Использовать `MarkdownBody` (из пакета `flutter_markdown`) вместо обычного `Text` для поля `message.content` в ответах ИИ.