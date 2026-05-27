import 'package:flutter/material.dart';

import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../molecules/nav_item.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Full-screen swipe-from-left drawer skeleton.
///
/// This is a StatelessWidget; gesture handling for opening lives in the screen
/// host (Phase 5). Closing is via [onClose] or the swipe-left gesture handled
/// internally.
///
/// Layout (top → bottom):
/// - Top bar: close button + "Kai" title
/// - New chat button
/// - Search box (read-only placeholder)
/// - Sessions list or empty state
/// - Apps section (Память, Настройки)
/// - Account anchor (pinned at bottom)
class NavPanel extends StatelessWidget {
  const NavPanel({
    this.onClose,
    this.onNewChat,
    this.sessions = const [],
    this.activeSessions,
    this.onSessionTap,
    super.key,
  });

  final VoidCallback? onClose;
  final VoidCallback? onNewChat;

  /// Each session map must contain 'id', 'title', and 'date' keys.
  final List<Map<String, String>> sessions;

  /// The session id that is currently active (for highlighting).
  final String? activeSessions;

  final ValueChanged<String>? onSessionTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Right-to-left swipe: velocity.x is negative
        if ((details.primaryVelocity ?? 0) < -200) {
          onClose?.call();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: tokens.colors.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(onClose: onClose, tokens: tokens),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KaiSpace.s4,
                  vertical: KaiSpace.s2,
                ),
                child: KaiButton.ink1(
                  onPressed: onNewChat,
                  label: 'Новый чат',
                  icon: KaiIconName.plus,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KaiSpace.s4,
                  vertical: KaiSpace.s2,
                ),
                child: _SearchBox(tokens: tokens),
              ),
              // Sessions label
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KaiSpace.s4,
                  KaiSpace.s4,
                  KaiSpace.s4,
                  KaiSpace.s2,
                ),
                child: Text(
                  'ЧАТЫ',
                  style: KaiType.micro(color: tokens.colors.ink4),
                ),
              ),
              Expanded(child: _SessionsList(
                sessions: sessions,
                activeSessions: activeSessions,
                onSessionTap: onSessionTap,
                tokens: tokens,
              )),
              _AppsSection(tokens: tokens),
              _AccountAnchor(tokens: tokens),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.tokens});

  final VoidCallback? onClose;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s4,
        vertical: KaiSpace.s4,
      ),
      child: Row(
        children: [
          // Close button: 28px circle
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tokens.colors.surface2,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: KaiIcon(
                  KaiIconName.close,
                  size: 16,
                  color: tokens.colors.ink2,
                ),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          KaiText.h3('Kai', color: tokens.colors.ink1),
        ],
      ),
    );
  }
}

// ─── Search box ───────────────────────────────────────────────────────────────

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.tokens});

  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s4,
        vertical: KaiSpace.s2 + 2,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: KaiRadius.brPill,
      ),
      child: Row(
        children: [
          KaiIcon(KaiIconName.search, size: 16, color: tokens.colors.ink4),
          const SizedBox(width: KaiSpace.s2),
          Text(
            'Поиск',
            style: KaiType.body(color: tokens.colors.ink4),
          ),
        ],
      ),
    );
  }
}

// ─── Sessions list ────────────────────────────────────────────────────────────

class _SessionsList extends StatelessWidget {
  const _SessionsList({
    required this.sessions,
    required this.activeSessions,
    required this.onSessionTap,
    required this.tokens,
  });

  final List<Map<String, String>> sessions;
  final String? activeSessions;
  final ValueChanged<String>? onSessionTap;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: KaiText.body('Нет чатов', color: tokens.colors.ink4),
      );
    }
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final id = session['id'] ?? '';
        final title = session['title'] ?? '';
        final isActive = id == activeSessions;
        return NavItem(
          label: title,
          active: isActive,
          onTap: onSessionTap == null ? null : () => onSessionTap!(id),
        );
      },
    );
  }
}

// ─── Apps section ─────────────────────────────────────────────────────────────

class _AppsSection extends StatelessWidget {
  const _AppsSection({required this.tokens});

  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KaiSpace.s4,
            KaiSpace.s4,
            KaiSpace.s4,
            KaiSpace.s2,
          ),
          child: Text(
            'ПРИЛОЖЕНИЯ',
            style: KaiType.micro(color: tokens.colors.ink4),
          ),
        ),
        const NavItem(
          label: 'Память',
          icon: KaiIconName.heart,
          active: false,
        ),
        const NavItem(
          label: 'Настройки',
          icon: KaiIconName.settings,
          active: false,
        ),
      ],
    );
  }
}

// ─── Account anchor ───────────────────────────────────────────────────────────

class _AccountAnchor extends StatelessWidget {
  const _AccountAnchor({required this.tokens});

  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KaiSpace.s4),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tokens.colors.surface2,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: KaiIcon(
                KaiIconName.person,
                size: 18,
                color: tokens.colors.ink3,
              ),
            ),
          ),
          const SizedBox(width: KaiSpace.s3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiText.body('Anonymous', color: tokens.colors.ink1),
              Text(
                'Free',
                style: KaiType.micro(color: tokens.colors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
