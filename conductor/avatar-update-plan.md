# План: Обновление Аватара и имени Kai

## Цель
Заменить имя с KAI (все заглавные) на Kai и изменить стандартную иконку-звездочку (sparkle) на что-то более абстрактное и органичное (например, `Icons.blur_on`), чтобы аватар ИИ выглядел как сгусток энергии или мыслящее ядро.

## Архитектура
1. `MessageBubble`: Имя отправителя 'KAI' меняется на 'Kai'. Иконка `Icons.auto_awesome` меняется на `Icons.blur_on` (или аналогичную).
2. `ChatLoadingIndicator`: Аналогично меняется иконка `Icons.auto_awesome` на `Icons.blur_on`.
3. `ChatInputBar`: Подсказка (hint text) меняется со "Спросите KAI..." на "Спросите Kai...".

---

### Задача 1: Заменить иконку и имя

**Файлы:**
- `lib/features/chat/presentation/widgets/message_bubble.dart`
- `lib/features/chat/presentation/widgets/chat_loading_indicator.dart`
- `lib/features/chat/presentation/widgets/chat_input_bar.dart`

- Найти все строки с `'KAI'` и заменить их на `'Kai'`.
- Найти все `Icons.auto_awesome` и заменить на `Icons.blur_on` или `Icons.lens_blur` (более мягкие, абстрактные иконки, передающие "силу ИИ", а не просто "магию").