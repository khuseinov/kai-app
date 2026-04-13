# План: Zero UI Swipe Input

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Удалить последнюю кнопку с главного экрана (FAB клавиатуры) и реализовать вызов панели ввода текста с помощью жеста "смахнуть вверх" (Swipe Up).

**Architecture:** 
1. В `ChatScreen` удаляем `FloatingActionButton`.
2. Расширяем возможности `GestureDetector`, который оборачивает экран. Добавляем обработчик `onVerticalDragEnd`.
3. Если пользователь делает резкий смах вверх (отрицательная скорость по оси Y), мы программно вызываем `showModalBottomSheet` с нашим `ChatInputBar`.
4. Это сделает интерфейс абсолютно чистым (Zero UI), оставив только взаимодействие через жесты (Тап для голоса, Свайп вверх для текста).

**Tech Stack:** Flutter

---

### Task 1: Реализация Swipe-to-Input в ChatScreen

**Files:**
- Modify: `lib/features/chat/presentation/chat_screen.dart`

- [ ] **Step 1: Удалить FloatingActionButton**
Удалить свойство `floatingActionButton` из `Scaffold` в `ChatScreen`.

- [ ] **Step 2: Добавить обработчик свайпа в GestureDetector**
Добавить `onVerticalDragEnd` в существующий `GestureDetector`.
Если `details.primaryVelocity! < -300` (смах вверх), вызывать функцию открытия `BottomSheet`.

```dart
// Пример логики открытия:
  void _showInputSheet() {
    // Останавливаем голосовой ввод, если он был активен
    if (_isListening) {
      setState(() { _isListening = false; });
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: context.kaiColors.background,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ChatInputBar(
          controller: _textController,
          isLoading: ref.read(chatNotifierProvider).isLoading,
          onSend: (text) {
            ref.read(chatNotifierProvider.notifier).sendMessage(text);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
```

- [ ] **Step 3: Commit**
```bash
git add lib/features/chat/presentation/chat_screen.dart
git commit -m "feat: replace keyboard FAB with swipe-up gesture for zero ui"
```