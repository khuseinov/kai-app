import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';
import '../../logic/chat_notifier.dart';

/// Kai-invoked surface: shown briefly when Kai records a new fact about
/// the user (backend marks message with `specialMode == 'M'`).
///
/// Surfaces a single snackbar via [maybeShow] — never permanent chrome.
/// Tap → opens memory screen so user can review/edit/delete what Kai stored.
class MemoryToast {
  static final _shownIds = <String>{};

  static void maybeShow(BuildContext context, WidgetRef ref) {
    final state = ref.read(chatNotifierProvider);
    final m = _latestMemorize(state.messages);
    if (m == null || _shownIds.contains(m.id)) return;
    _shownIds.add(m.id);

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.surface,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(Icons.bookmark_outlined, size: 16, color: colors.oceanPrimary),
            const SizedBox(width: KaiSpacing.xs),
            Expanded(
              child: Text(
                'Kai запомнил это',
                style: typography.bodyMedium.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Открыть память',
          textColor: colors.oceanPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.push('/personal-context');
          },
        ),
      ),
    );
  }

  static ChatMessage? _latestMemorize(List<ChatMessage> messages) {
    for (final m in messages.reversed) {
      if (!m.isUser && m.specialMode?.toUpperCase() == 'M') return m;
    }
    return null;
  }
}
