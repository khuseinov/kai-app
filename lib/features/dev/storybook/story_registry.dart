import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/atoms/atoms.dart';
import '../../../design_system/molecules/molecules.dart';
import '../../../design_system/organisms/organisms.dart';
import '../../../design_system/primitives/primitives.dart';
import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

// ── Story model ───────────────────────────────────────────────────────────────

enum StoryLayer { primitives, atoms, molecules, organisms }

class Story {
  const Story({
    required this.layer,
    required this.name,
    required this.importPath,
    required this.canonFile,
    this.canonSelector = '',
    this.description = '',
    this.variants = const [],
    required this.build,
  });

  final StoryLayer layer;
  final String name;

  /// Barrel import path — use this in Dart code.
  /// e.g. `package:kai_app/design_system/atoms/atoms.dart`
  final String importPath;

  /// Canonical HTML reference file inside `new-design/`.
  /// e.g. `new-design/components.html`
  final String canonFile;

  /// Primary CSS selector(s) that represent this component in [canonFile].
  /// e.g. `.bub.kai`  — empty string when no direct selector exists.
  final String canonSelector;

  /// One-sentence description of what this component does and when to use it.
  final String description;

  /// Named constructor / visual variant strings for this component.
  final List<String> variants;

  final WidgetBuilder build;
}

// ── Registry ──────────────────────────────────────────────────────────────────

final List<Story> kStories = [
  // ── Primitives ──────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiIcon',
    importPath: 'package:kai_app/design_system/primitives/primitives.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: '.icon-grid svg',
    description:
        'SVG icon primitive — renders a tinted icon from assets/icons/ '
        'using a KaiIconName enum value.',
    variants: ['KaiIcon(name, size, color)'],
    build: (_) => const _KaiIconStory(),
  ),
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiSurface',
    importPath: 'package:kai_app/design_system/primitives/primitives.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: '.surface-demo',
    description:
        'Themed container primitive — wraps any child with a token-driven '
        'BoxDecoration (color, radius, border, shadow).',
    variants: ['color', 'border: true', 'shadow: KaiShadow.*', 'radius: KaiRadius.*'],
    build: (_) => const _KaiSurfaceStory(),
  ),
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiGradientBar',
    importPath: 'package:kai_app/design_system/primitives/primitives.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.k-who::before',
    description:
        'Tide-gradient rounded pill — used as the Kai "who" glyph (16×4) '
        'and toast tide-bar (10×2.5). Supports a gentle pulse animation.',
    variants: ['static', 'pulse: true', 'width/height custom'],
    build: (_) => const _KaiGradientBarStory(),
  ),

  // ── Atoms ────────────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiText',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: '.type-scale',
    description:
        'Typed text atom with ten named constructors mapping to the full '
        'KaiType scale. Display-tier constructors support gradient: true.',
    variants: [
      'hero', 'display', 'h1', 'h2', 'h3',
      'lead', 'body', 'small', 'micro', 'mono',
    ],
    build: (_) => const _KaiTextStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiButton',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.btn-grid .btn',
    description:
        'Four-variant button atom covering every action weight in the system: '
        'primary tide, solid ink, ghost outline, and text link.',
    variants: ['tide', 'ink', 'ghost', 'text'],
    build: (_) => const _KaiButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiIconButton',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.icon-btn',
    description:
        'Icon-only button with three surface variants — use surface for '
        'compose attachment slots, transparent for mic, bare for sheet actions.',
    variants: ['surface', 'transparent', 'bare'],
    build: (_) => const _KaiIconButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiSendButton',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.compose .send',
    description:
        'Circular send button with a four-state lifecycle (ready / disabled / '
        'sending / streaming); the primary CTA in every compose island.',
    variants: ['ready', 'disabled', 'sending', 'streaming'],
    build: (_) => const _KaiSendButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiInput',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.compose textarea',
    description:
        'Text field atom — line variant for search boxes, pill variant for '
        'the compose-island textarea.',
    variants: ['line', 'pill'],
    build: (_) => const _KaiInputStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiToggle',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.toggle',
    description:
        'Pill switch atom — 34×20 track, accent when on, surface3 when off. '
        'Used in settings rows for boolean preferences.',
    variants: ['on', 'off', 'disabled (onChanged: null)'],
    build: (_) => const _KaiToggleStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiChip',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.chip',
    description:
        'Status pill (non-interactive, mono-uppercase) and choice chip '
        '(selectable filter). Three tone variants for status.',
    variants: [
      'status neutral', 'status done', 'status active',
      'choice selected', 'choice unselected',
    ],
    build: (_) => const _KaiChipStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiBadge',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/nav.html',
    canonSelector: '.mem-dot',
    description:
        'Notification badge — dot variant for the memory indicator, count '
        'variant (with 99+ cap) for numeric notification counts.',
    variants: ['dot', 'count(n)'],
    build: (_) => const _KaiBadgeStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiAvatar',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.acc-hero .avatar',
    description:
        'Circular avatar filled with the tide corner gradient. Shows an '
        'optional single initial letter at center.',
    variants: ['KaiAvatar()', 'initial: "R"', 'size: 56'],
    build: (_) => const _KaiAvatarStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiTideCurve',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/tide-states.html',
    canonSelector: '.tide-curve',
    description:
        'Kai\'s living tide curve — the brand mark. Eight states (idle, '
        'listening, thinking, responding, success, error, memory, sleep), '
        'each with distinct stroke, opacity, and animation behaviour.',
    variants: [
      'idle', 'listening', 'thinking', 'responding',
      'success', 'error', 'memory', 'sleep',
    ],
    build: (_) => const _KaiTideCurveStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiDivider',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: 'hr, .divider',
    description:
        'Hairline 1px divider in the theme line color. Horizontal fills '
        'available width; vertical fills available height.',
    variants: ['horizontal', 'vertical'],
    build: (_) => const _KaiDividerStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiSheetShell',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.sheet',
    description:
        'Bottom-sheet chrome — 24px top-corner radius, drag indicator, '
        'border-top in line color. Wraps any sheet content.',
    variants: ['KaiSheetShell(child: ...)'],
    build: (_) => const _KaiSheetShellStory(),
  ),

  // ── Molecules ────────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiUserBubble',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.bub.user',
    description:
        'Right-aligned pill bubble for user messages. Surface-2 background, '
        '13.5px Manrope, asymmetric 18/4 radii.',
    variants: ['KaiUserBubble(text: ...)'],
    build: (_) => const _KaiUserBubbleStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiKaiBubble',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.bub.kai',
    description:
        'Left-aligned Kai response bubble with inline citation parsing, '
        'streaming caret, source list, and thumb-up/down reactions.',
    variants: ['normal', 'streaming: true', 'with sources', 'with reactions'],
    build: (_) => const _KaiKaiBubbleStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSystemBubble',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.bub.system',
    description:
        'Full-width system note injected into the chat feed for memory '
        'updates, warnings, or errors. Three semantic tones.',
    variants: ['neutral', 'warning', 'negative'],
    build: (_) => const _KaiSystemBubbleStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiComposeIsland',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.sheet.compose-sheet .compose',
    description:
        'Pill-shaped chat input bar with growing textarea, optional mic '
        'button, and send button lifecycle states.',
    variants: [
      'KaiComposeIsland(controller, onSend)',
      'onMicTap: ...',
      'sendState: KaiSendState.*',
    ],
    build: (_) => const _KaiComposeIslandStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSourceCard',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.src-list .src-row',
    description:
        'Source-citation card shown under Kai messages — displays URL, title, '
        'snippet, index chip, and freshness badge.',
    variants: ['fresh: true', 'fresh: false', 'with snippet', 'without snippet'],
    build: (_) => const _KaiSourceCardStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiCareBlock',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/edge-states.html',
    canonSelector: '.care-block',
    description:
        'Crisis care block (C3 in-conversation pattern) — coral left-border '
        'block with heading, body, hotline resources, and closing. Never a takeover.',
    variants: [
      'KaiCareBlock(heading, body, resources, closing)',
    ],
    build: (_) => const _KaiCareBlockStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiAlertCard',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/notifications-chat.html',
    canonSelector: '.alert-card',
    description:
        'Proactive alert card injected into the chat feed — two-zone layout '
        '(coloured header + body), four severity types.',
    variants: ['urgent', 'warning', 'positive', 'neutral'],
    build: (_) => const _KaiAlertCardStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiToast',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.toast',
    description:
        'Pill toast notification — dark island style, four types. Memory '
        'variant uses tide gradient fill.',
    variants: ['neutral', 'positive', 'negative', 'memory'],
    build: (_) => const _KaiToastStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiActionSheet',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.sheet.actions',
    description:
        'Quick-action bottom sheet presented via showKaiActionSheet(). '
        'List of KaiActionItem rows with icon, title, optional meta, danger flag.',
    variants: [
      'KaiActionSheet(items: [KaiActionItem(...)])',
      'danger: true row',
    ],
    build: (_) => const _KaiActionSheetStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSegmentedControl',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.seg',
    description:
        'Segmented pill control for mutually-exclusive option sets (e.g. '
        'theme: auto / light / dark). Index-based selection.',
    variants: [
      'KaiSegmentedControl(options, selectedIndex, onSelected)',
    ],
    build: (_) => const _KaiSegmentedControlStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSettingsRow',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.row',
    description:
        'Settings list row with leading icon, title, optional subtitle, '
        'and a trailing widget slot. Danger variant turns text coral.',
    variants: [
      'normal', 'danger: true',
      'trailing: KaiToggle', 'trailing: KaiIcon(chevRight)',
    ],
    build: (_) => const _KaiSettingsRowStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiAccountHero',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.acc-hero',
    description:
        'Account card for the top of the settings screen — shows tide '
        'avatar, name, email, and optional plan badge.',
    variants: [
      'KaiAccountHero(name, email, initial)',
      'planLabel: "Pro"',
    ],
    build: (_) => const _KaiAccountHeroStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiNavItem',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/nav.html',
    canonSelector: '.chat-row',
    description:
        'Side-panel nav row with leading icon, label, and trailing widget. '
        'Active state shows accent-wash background and left accent border.',
    variants: ['inactive', 'active: true', 'trailing: KaiBadge.dot()'],
    build: (_) => const _KaiNavItemStory(),
  ),

  // ── Organisms ────────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiChatList',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/room.html',
    canonSelector: '.chat',
    description:
        'Scrollable chat message list composing all message types. Six '
        'RoomFrame variants control visual mode (empty/live/panel/compose/streaming/error).',
    variants: ['empty', 'live', 'panel', 'compose', 'streaming', 'error'],
    build: (_) => const _KaiChatListStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiNavPanel',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/nav.html',
    canonSelector: '.panel',
    description:
        'Full-screen side navigation panel — trip folders, session list '
        'grouped by date, account anchor, memory and settings links.',
    variants: [
      'KaiNavPanel(strings: KaiNavStrings.russian, trips, sessions, ...)',
    ],
    build: (_) => const _KaiNavPanelStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiEdgeStateBlock',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/edge-states.html',
    canonSelector: '.edge-state',
    description:
        'Composable edge-state block for offline, error, rate-limit, and '
        'crisis surfaces. Each surface has a distinct CTA button style.',
    variants: ['offline', 'error', 'rateLimit', 'crisis'],
    build: (_) => const _KaiEdgeStateBlockStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiOnboardingCard',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/onboarding.html',
    canonSelector: '.ob',
    description:
        'Four-step onboarding card (welcome/tide/gestures/context). Step 0 '
        'uses tide CTA; steps 1–3 use solid ink-1 button.',
    variants: ['step 0 (welcome)', 'step 1 (tide)', 'step 2 (gestures)', 'step 3 (context)'],
    build: (_) => const _KaiOnboardingCardStory(),
  ),

  // ── Unbuilt screens — spec-preview stories ───────────────────────────────────

  Story(
    layer: StoryLayer.organisms,
    name: 'Voice Screen (canon)',
    importPath: 'new-design/voice.html',
    canonFile: 'new-design/voice.html',
    canonSelector: '.voice-screen',
    description:
        'Voice mode surface — always dark (#08080A), never responds to theme. '
        'Karaoke word-reveal + transcript timeline. Not yet built in Dart.',
    variants: ['waiting', 'listening', 'speaking-karaoke', 'transcript'],
    build: (ctx) => const _VoiceCanonPreview(),
  ),

  Story(
    layer: StoryLayer.organisms,
    name: 'Memory Screen (canon)',
    importPath: 'new-design/memory.html',
    canonFile: 'new-design/memory.html',
    canonSelector: '.memory-screen',
    description:
        'Memory management screen — facts grouped by category, searchable. '
        'Forget (danger) rows, memory hero card, toggle per-category. '
        'Not yet built in Dart.',
    variants: ['default', 'search active', 'fact expanded', 'category collapsed'],
    build: (ctx) => const _MemoryCanonPreview(),
  ),

  Story(
    layer: StoryLayer.organisms,
    name: 'Trip Detail Screen (canon)',
    importPath: 'new-design/trip-detail.html',
    canonFile: 'new-design/trip-detail.html',
    canonSelector: '.trip-screen',
    description:
        'Trip detail — hero card (glyph + name + stats + budget bar), facts grid, '
        'chat items, source list, Q&A chips, "Ask about this" CTA. '
        'Not yet built in Dart.',
    variants: ['default', 'scrolled', 'chat tab'],
    build: (ctx) => const _TripDetailCanonPreview(),
  ),

  Story(
    layer: StoryLayer.organisms,
    name: 'KaiForkCard (canon)',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/fork.html',
    canonSelector: '.fc',
    description:
        'Multi-country comparison card — in-chat molecule with two-column layout '
        'comparing trip options. Visa chips (8px w600 r999), rating dots (5×5px), '
        'budget rows, country headers (~65px). Not yet built in Dart.',
    variants: ['normal', 'win column highlighted'],
    build: (ctx) => const _ForkCardCanonPreview(),
  ),
];

// ── Shared section header ─────────────────────────────────────────────────────

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: KaiType.micro(color: c.ink3)),
        const SizedBox(height: KaiSpace.s3),
        child,
      ],
    );
  }
}


// ── Unbuilt screen spec previews ──────────────────────────────────────────────

/// Voice Screen spec-preview.
///
/// Always dark bg (#08080A) — never responds to theme.
/// Shows key computed values from the Playwright audit so agents know exactly
/// what to build when implementing the voice screen.
class _VoiceCanonPreview extends StatelessWidget {
  const _VoiceCanonPreview();

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF08080A); // voice screen bg — always dark
    const white32 = Color(0x52FFFFFF); // rgba(255,255,255,0.32) NEXT words
    const white40 = Color(0x66FFFFFF); // rgba(255,255,255,0.40) timestamps
    const white25 = Color(0x40FFFFFF); // rgba(255,255,255,0.25) hint labels
    const karaokeNowBg = Color(0x47F4B589); // tide-3 @ 0.28 opacity
    const karaokeNowText = KaiTide.stop3; // tide-3 warm horizon

    return StorySection(
      title: 'Voice Screen — spec values (NOT YET BUILT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOT YET BUILT banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s3),
            decoration: BoxDecoration(
              color: const Color(0x1FD69E3E), // warning wash (dark)
              borderRadius: KaiRadius.br2,
              border: Border.all(
                color: const Color(0xFFD69E3E).withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'NOT YET BUILT — canon: new-design/voice.html',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
                color: Color(0xFFD69E3E),
              ),
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Dark surface preview
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: KaiRadius.br3,
            ),
            padding: const EdgeInsets.all(KaiSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // bg label
                const Text(
                  'bg: #08080A — ALWAYS DARK, never theme-aware',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    color: white40,
                  ),
                ),
                const SizedBox(height: KaiSpace.s4),

                // Karaoke row
                Wrap(
                  spacing: KaiSpace.s2,
                  runSpacing: KaiSpace.s2,
                  children: [
                    // NOW word
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: const BoxDecoration(
                        color: karaokeNowBg,
                        borderRadius: KaiRadius.br1,
                      ),
                      child: const Text(
                        'NOW',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: karaokeNowText,
                        ),
                      ),
                    ),
                    // NEXT words
                    ...['next', 'words', 'here'].map(
                      (w) => Text(
                        w,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: white32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KaiSpace.s3),

                // Spec notes
                const _SpecNote('Karaoke NOW: bg rgba(244,181,137,0.28) = tide-3@0.28, r4, pad 1/5, 16px w500 white'),
                const _SpecNote('Karaoke NEXT: color rgba(255,255,255,0.32), same font'),
                const SizedBox(height: KaiSpace.s2),
                const _SpecNote('Transcript events: pad 9/22/9/52'),
                const _SpecNote('Timestamp: 8.5px w500, rgba(white,0.4) = Color(0x66FFFFFF)'),
                const _SpecNote('Hint labels: 9px, rgba(white,0.25) = Color(0x40FFFFFF)'),
                const SizedBox(height: KaiSpace.s2),

                // Hint label demo
                const Text(
                  'tap to speak / swipe',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9,
                    color: white25,
                  ),
                ),
                const SizedBox(height: KaiSpace.s2),
                // Timestamp demo
                const Text(
                  '0:04',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                    color: white40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: KaiSpace.s3),
          const _SpecNote('Dart components to reuse: KaiTideCurve (voice state), KaiButton.ink (stop), KaiText'),
          const _SpecNote('NEW widgets needed: VoiceKaraoke, VoiceTranscriptRow, VoiceHintLabel'),
        ],
      ),
    );
  }
}

/// Memory Screen spec-preview.
class _MemoryCanonPreview extends StatelessWidget {
  const _MemoryCanonPreview();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return StorySection(
      title: 'Memory Screen — spec values (NOT YET BUILT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s3),
            decoration: BoxDecoration(
              color: c.warningWash,
              borderRadius: KaiRadius.br2,
              border: Border.all(color: c.warning.withValues(alpha: 0.4)),
            ),
            child: KaiText.micro(
              'NOT YET BUILT — canon: new-design/memory.html',
              color: c.warning,
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Memory hero card demo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: KaiRadius.br4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaiText.small('Путешествия', color: c.ink1),
                const SizedBox(height: 2),
                KaiText.micro('3 воспоминания', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const _SpecNote('Memory hero: r16 pad14; title 14px w600 ink1; sub 11px ink3'),

          const SizedBox(height: KaiSpace.s3),

          // Fact item demo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: KaiRadius.br8,
              border: Border.all(color: c.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaiText.small(
                    'Предпочитает прямые рейсы без пересадок',
                    color: c.ink1),
                const SizedBox(height: 2),
                KaiText.micro('из chat · 2 дня назад', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const _SpecNote('.fact-item: r8, pad 9/11; body 13px ink1; source 9.5px ink3'),

          const SizedBox(height: KaiSpace.s3),

          // Forget row demo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: c.negativeWash,
              borderRadius: KaiRadius.br8,
            ),
            child: KaiText.small('Забыть это воспоминание', color: c.negative),
          ),
          const SizedBox(height: KaiSpace.s2),
          const _SpecNote('"Forget" row: r8, pad 11/12, negative color'),

          const SizedBox(height: KaiSpace.s3),
          const _SpecNote('Search bar: 12.5px ink3, r10, pad 9/12, bg surface-2 = KaiInput.line'),
          const _SpecNote('Fact groups: bg surface-2, r12, pad 4px'),
          const _SpecNote('Toggle: KaiToggle — positive (green = on)'),
          const _SpecNote('App bar: ttl 13px w600; ic-btn: circle bg surface-2'),
          const SizedBox(height: KaiSpace.s3),
          const _SpecNote('Dart components to reuse: KaiInput.line, KaiToggle, KaiButton.ink(fullWidth), KaiAvatar'),
          const _SpecNote('NEW widgets needed: MemoryFactGroup, MemoryFactItem, MemoryHero'),
        ],
      ),
    );
  }
}

/// Trip Detail Screen spec-preview.
class _TripDetailCanonPreview extends StatelessWidget {
  const _TripDetailCanonPreview();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return StorySection(
      title: 'Trip Detail Screen — spec values (NOT YET BUILT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s3),
            decoration: BoxDecoration(
              color: c.warningWash,
              borderRadius: KaiRadius.br2,
              border: Border.all(color: c.warning.withValues(alpha: 0.4)),
            ),
            child: KaiText.micro(
              'NOT YET BUILT — canon: new-design/trip-detail.html',
              color: c.warning,
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Trip hero demo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s4),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(KaiRadius.r4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Glyph (tide-corner gradient circle)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: KaiTide.gradientCorner,
                        borderRadius: KaiRadius.brPill,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Т',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: KaiSpace.s3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Токио 2026',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: c.ink1,
                          ),
                        ),
                        KaiText.micro('апр — май 2026', color: c.ink3),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const _SpecNote('.trip-hero: r16, pad 16; glyph 13px w700 white, r11 = KaiAvatar(size:~36)'),
          const _SpecNote('Trip name: 16px w600; sub: 11px ink3'),
          const _SpecNote('Stats: .stat .n 16px w600; .stat .l 9px w500 ink3'),
          const _SpecNote('Budget bar: r999, bg surface-3, colored segments'),

          const SizedBox(height: KaiSpace.s3),

          // Facts grid demo
          Wrap(
            spacing: KaiSpace.s2,
            runSpacing: KaiSpace.s2,
            children: [
              _FactCard(label: 'Виза', value: 'Нет', c: c),
              _FactCard(label: 'Дней', value: '12', c: c),
              _FactCard(label: 'Бюджет', value: '120k ₽', c: c),
            ],
          ),
          const SizedBox(height: KaiSpace.s2),
          const _SpecNote('.fact: bg surface-2, r12, pad 4; .fact .k 11px ink3; .fact .v 11.5px w500 ink1'),

          const SizedBox(height: KaiSpace.s3),

          // Chat item demo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: c.accentWash,
              borderRadius: KaiRadius.br2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Визовые требования',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.accent,
                  ),
                ),
                const SizedBox(height: 2),
                KaiText.micro('Для туристической визы нужен...', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const _SpecNote('.chat-item: r10, pad 9/10, bg accent-wash; title 12px w600 accent; preview 10.5px ink3'),

          const SizedBox(height: KaiSpace.s3),
          const _SpecNote('"Ask about this" button: 13px w600 white bg ink1 r12 pad11 = KaiButton.ink(fullWidth:true)'),
          const _SpecNote('Q&A chips: bg surface-2, r10, pad 9/6'),
          const _SpecNote('App bar ic-btn: circle bg surface-2 ~32×32; title 13px w600 ink1'),
          const SizedBox(height: KaiSpace.s3),
          const _SpecNote('Dart components to reuse: KaiAvatar, KaiButton.ink, KaiSourceCard, KaiInput.line'),
          const _SpecNote('NEW widgets needed: TripHeroCard, TripFactGrid, TripBudgetBar, TripChatItem'),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.label,
    required this.value,
    required this.c,
  });
  final String label;
  final String value;
  final KaiColorTokens c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: KaiRadius.br12,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: c.ink3,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: c.ink1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fork Card spec-preview.
class _ForkCardCanonPreview extends StatelessWidget {
  const _ForkCardCanonPreview();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return StorySection(
      title: 'KaiForkCard — spec values (NOT YET BUILT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s3),
            decoration: BoxDecoration(
              color: c.warningWash,
              borderRadius: KaiRadius.br2,
              border: Border.all(color: c.warning.withValues(alpha: 0.4)),
            ),
            child: KaiText.micro(
              'NOT YET BUILT — canon: new-design/fork.html  .fc',
              color: c.warning,
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Two-column demo skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ForkColumn(
                  country: 'Япония',
                  price: '145,000 ₽',
                  delta: '+12%',
                  positive: false,
                  c: c,
                ),
              ),
              const SizedBox(width: KaiSpace.s3),
              Expanded(
                child: _ForkColumn(
                  country: 'Таиланд',
                  price: '89,000 ₽',
                  delta: '-8%',
                  positive: true,
                  c: c,
                  winner: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),

          const _SpecNote('CSS: .fc, .fc-h, .fc-cols, .fc-col, .fc-id, .fc-country'),
          const _SpecNote('.fc-country header: ~65px wide'),
          const _SpecNote('Visa chips: 8px w600, r999, pad 2/6, negative-wash/neutral'),
          const _SpecNote('Rating dots: 5×5px circles, positive/neutral/negative colors'),
          const _SpecNote('.fc-badge, .fc-sw, .fc-score (5-dot rating)'),
          const SizedBox(height: KaiSpace.s3),

          // Visa chip demo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.negativeWash,
                  borderRadius: KaiRadius.brPill,
                ),
                child: Text(
                  'VISA',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: c.negative,
                  ),
                ),
              ),
              const SizedBox(width: KaiSpace.s2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.surface2,
                  borderRadius: KaiRadius.brPill,
                  border: Border.all(color: c.line),
                ),
                child: Text(
                  'БЕЗВИЗ',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: c.ink2,
                  ),
                ),
              ),
              const SizedBox(width: KaiSpace.s4),
              // Rating dots
              Row(
                children: [
                  _RatingDot(color: c.positive),
                  const SizedBox(width: 3),
                  _RatingDot(color: c.positive),
                  const SizedBox(width: 3),
                  _RatingDot(color: c.positive),
                  const SizedBox(width: 3),
                  _RatingDot(color: c.warning),
                  const SizedBox(width: 3),
                  _RatingDot(color: c.line),
                ],
              ),
              const SizedBox(width: KaiSpace.s2),
              KaiText.micro('рейтинг 4/5', color: c.ink3),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),
          const _SpecNote('Dart to reuse: KaiSourceCard layout pattern, KaiText, KaiTide.gradientCorner'),
          const _SpecNote('NEW: KaiForkCard, ForkColumn, ForkVisaChip, ForkRatingDots'),
        ],
      ),
    );
  }
}

class _ForkColumn extends StatelessWidget {
  const _ForkColumn({
    required this.country,
    required this.price,
    required this.delta,
    required this.positive,
    required this.c,
    this.winner = false,
  });
  final String country;
  final String price;
  final String delta;
  final bool positive;
  final KaiColorTokens c;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KaiSpace.s3),
      decoration: BoxDecoration(
        color: winner ? c.accentWash : c.surface2,
        borderRadius: KaiRadius.br3,
        border: winner ? Border.all(color: c.accentLine) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            country,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.ink1,
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: winner ? c.accent : c.ink1,
            ),
          ),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: positive ? c.positive : c.negative,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingDot extends StatelessWidget {
  const _RatingDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: KaiRadius.brPill,
      ),
    );
  }
}

/// Inline spec annotation — monospace muted text.
class _SpecNote extends StatelessWidget {
  const _SpecNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '· $text',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9,
          color: c.ink3,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Primitives ────────────────────────────────────────────────────────────────

class _KaiIconStory extends StatelessWidget {
  const _KaiIconStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiIcon (${KaiIconName.values.length} icons)',
      child: Wrap(
        spacing: KaiSpace.s4,
        runSpacing: KaiSpace.s4,
        children: KaiIconName.values.map((n) {
          final isNew =
              n == KaiIconName.thumbUp || n == KaiIconName.thumbDown;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIcon(n, size: 24, color: isNew ? c.accent : null),
              const SizedBox(height: 4),
              KaiText.micro(
                n.assetName,
                color: isNew ? c.accent : c.ink3,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _KaiSurfaceStory extends StatelessWidget {
  const _KaiSurfaceStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiSurface',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiSurface(
            color: c.surface,
            radius: KaiRadius.br4,
            border: true,
            padding: const EdgeInsets.all(KaiSpace.s4),
            child: const KaiText.small('surface + border + br4'),
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiSurface(
            color: c.surface2,
            radius: KaiRadius.br3,
            padding: const EdgeInsets.all(KaiSpace.s4),
            shadow: KaiShadow.button,
            child: const KaiText.small('surface2 + shadow + br3'),
          ),
        ],
      ),
    );
  }
}

class _KaiGradientBarStory extends StatelessWidget {
  const _KaiGradientBarStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiGradientBar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KaiGradientBar(),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('static (16×4)'),
            ],
          ),
          SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiGradientBar(pulse: true),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('pulse: true'),
            ],
          ),
          SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiGradientBar(width: 10, height: 2.5),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('toast size 10×2.5'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Atoms ─────────────────────────────────────────────────────────────────────

class _KaiTextStory extends StatelessWidget {
  const _KaiTextStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiText (all 10 styles)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiText.hero('Hero 72'),
          KaiText.display('Display 56'),
          KaiText.h1('H1 36 · gradient', gradient: true),
          KaiText.h2('H2 24'),
          KaiText.h3('H3 18'),
          SizedBox(height: KaiSpace.s2),
          KaiText.lead('Lead 20 — the quick brown fox'),
          KaiText.body('Body 16 — the quick brown fox'),
          KaiText.small('Small 14 — secondary copy'),
          KaiText.micro('MICRO 12'),
          KaiText.mono('mono.code() = 12'),
        ],
      ),
    );
  }
}

class _KaiButtonStory extends StatelessWidget {
  const _KaiButtonStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiButton (all variants)',
      child: Wrap(
        spacing: KaiSpace.s3,
        runSpacing: KaiSpace.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          KaiButton.tide(onPressed: () {}, label: 'Tide normal'),
          KaiButton.tide(
            onPressed: () {},
            label: 'Tide glow',
            emphasis: KaiButtonEmphasis.glow,
          ),
          const KaiButton.tide(onPressed: null, label: 'Tide disabled'),
          KaiButton.ink(onPressed: () {}, label: 'Ink'),
          KaiButton.ghost(onPressed: () {}, label: 'Ghost neutral'),
          KaiButton.ghost(
            onPressed: () {},
            label: 'Ghost warning',
            tone: KaiButtonTone.warning,
          ),
          KaiButton.ghost(
            onPressed: () {},
            label: 'Ghost negative',
            tone: KaiButtonTone.negative,
          ),
          KaiButton.ghost(
            onPressed: () {},
            label: 'Ghost pill',
            pill: true,
          ),
          KaiButton.text(onPressed: () {}, label: 'Text neutral'),
          KaiButton.text(
            onPressed: () {},
            label: 'Text accent',
            tone: KaiButtonTone.accent,
          ),
          KaiButton.text(
            onPressed: () {},
            label: 'Text negative',
            tone: KaiButtonTone.negative,
          ),
        ],
      ),
    );
  }
}

class _KaiIconButtonStory extends StatelessWidget {
  const _KaiIconButtonStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiIconButton (surface / transparent / bare)',
      child: Wrap(
        spacing: KaiSpace.s4,
        runSpacing: KaiSpace.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIconButton.surface(onPressed: () {}, icon: KaiIconName.mic),
              const SizedBox(height: 4),
              KaiText.micro('surface', color: c.ink3),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIconButton.transparent(
                  onPressed: () {}, icon: KaiIconName.mic),
              const SizedBox(height: 4),
              KaiText.micro('transparent', color: c.ink3),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIconButton.bare(onPressed: () {}, icon: KaiIconName.close),
              const SizedBox(height: 4),
              KaiText.micro('bare', color: c.ink3),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const KaiIconButton.bare(onPressed: null, icon: KaiIconName.lock),
              const SizedBox(height: 4),
              KaiText.micro('disabled', color: c.ink3),
            ],
          ),
        ],
      ),
    );
  }
}

class _KaiSendButtonStory extends ConsumerStatefulWidget {
  const _KaiSendButtonStory();

  @override
  ConsumerState<_KaiSendButtonStory> createState() =>
      _KaiSendButtonStoryState();
}

class _KaiSendButtonStoryState extends ConsumerState<_KaiSendButtonStory> {
  KaiSendState _state = KaiSendState.ready;

  void _cycle() {
    setState(() {
      const vals = KaiSendState.values;
      _state = vals[(vals.indexOf(_state) + 1) % vals.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiSendButton (4 states — tap to cycle)',
      child: Row(
        children: [
          KaiSendButton(state: _state, onPressed: _cycle),
          const SizedBox(width: KaiSpace.s4),
          KaiButton.ghost(
            onPressed: _cycle,
            label: 'state: ${_state.name}',
          ),
        ],
      ),
    );
  }
}

class _KaiInputStory extends StatefulWidget {
  const _KaiInputStory();

  @override
  State<_KaiInputStory> createState() => _KaiInputStoryState();
}

class _KaiInputStoryState extends State<_KaiInputStory> {
  final _lineCtrl = TextEditingController();
  final _pillCtrl = TextEditingController();

  @override
  void dispose() {
    _lineCtrl.dispose();
    _pillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiInput (line + pill)',
      child: Column(
        children: [
          KaiInput.line(
            controller: _lineCtrl,
            placeholder: 'Line input — search…',
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiInput.pill(
            controller: _pillCtrl,
            placeholder: 'Pill input — compose…',
            maxLines: 4,
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiInput.line(
            controller: TextEditingController(text: 'disabled field'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _KaiToggleStory extends StatefulWidget {
  const _KaiToggleStory();

  @override
  State<_KaiToggleStory> createState() => _KaiToggleStoryState();
}

class _KaiToggleStoryState extends State<_KaiToggleStory> {
  bool _on = true;
  bool _off = false;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiToggle (on / off / disabled)',
      child: Row(
        children: [
          KaiToggle(value: _on, onChanged: (v) => setState(() => _on = v)),
          const SizedBox(width: KaiSpace.s4),
          KaiToggle(value: _off, onChanged: (v) => setState(() => _off = v)),
          const SizedBox(width: KaiSpace.s4),
          const KaiToggle(value: true, onChanged: null),
          const SizedBox(width: KaiSpace.s3),
          KaiText.small('disabled', color: c.ink3),
        ],
      ),
    );
  }
}

class _KaiChipStory extends StatelessWidget {
  const _KaiChipStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiChip (status: done/active/neutral; choice: sel/unsel)',
      child: Wrap(
        spacing: KaiSpace.s3,
        runSpacing: KaiSpace.s3,
        children: [
          KaiChip.status('done', tone: KaiChipTone.done),
          KaiChip.status('active', tone: KaiChipTone.active),
          KaiChip.status('neutral'),
          KaiChip.choice('Selected', selected: true),
          KaiChip.choice('Unselected', selected: false),
        ],
      ),
    );
  }
}

class _KaiBadgeStory extends StatelessWidget {
  const _KaiBadgeStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiBadge (dot + count)',
      child: Row(
        children: [
          KaiBadge.dot(),
          SizedBox(width: KaiSpace.s4),
          KaiBadge.count(5),
          SizedBox(width: KaiSpace.s4),
          KaiBadge.count(99),
          SizedBox(width: KaiSpace.s4),
          KaiBadge.count(150),
        ],
      ),
    );
  }
}

class _KaiAvatarStory extends StatelessWidget {
  const _KaiAvatarStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiAvatar (sizes + initial)',
      child: Row(
        children: [
          KaiAvatar(),
          SizedBox(width: KaiSpace.s4),
          KaiAvatar(initial: 'R'),
          SizedBox(width: KaiSpace.s4),
          KaiAvatar(size: 56, initial: 'K'),
          SizedBox(width: KaiSpace.s4),
          KaiAvatar(size: 32),
        ],
      ),
    );
  }
}

class _KaiTideCurveStory extends StatefulWidget {
  const _KaiTideCurveStory();

  @override
  State<_KaiTideCurveStory> createState() => _KaiTideCurveStoryState();
}

class _KaiTideCurveStoryState extends State<_KaiTideCurveStory> {
  int _index = 0;
  bool _autoCycling = false;
  Timer? _autoCycle;

  @override
  void dispose() {
    _autoCycle?.cancel();
    super.dispose();
  }

  void _toggleAuto() {
    setState(() => _autoCycling = !_autoCycling);
    if (_autoCycling) {
      _autoCycle = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % KaiTide.all.length);
      });
    } else {
      _autoCycle?.cancel();
      _autoCycle = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final tideState = KaiTide.all[_index];
    return StorySection(
      title: 'KaiTideCurve — ${tideState.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 28, child: KaiTideCurve(state: tideState)),
          const SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiButton.ghost(
                onPressed: () => setState(
                    () => _index = (_index + 1) % KaiTide.all.length),
                label: 'next state',
              ),
              const SizedBox(width: KaiSpace.s3),
              KaiButton.ghost(
                onPressed: _toggleAuto,
                label: _autoCycling ? 'auto: on' : 'auto: off',
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),
          Wrap(
            spacing: KaiSpace.s3,
            runSpacing: KaiSpace.s4,
            children: KaiTide.all.map((s) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 20,
                    child: KaiTideCurve(state: s),
                  ),
                  const SizedBox(height: 2),
                  KaiText.micro(s.name, color: c.ink3),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _KaiDividerStory extends StatelessWidget {
  const _KaiDividerStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiDivider (horizontal + vertical)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KaiDivider(),
          const SizedBox(height: KaiSpace.s3),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                KaiText.small('left', color: c.ink2),
                const SizedBox(width: KaiSpace.s3),
                const KaiDivider.vertical(),
                const SizedBox(width: KaiSpace.s3),
                KaiText.small('right', color: c.ink2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KaiSheetShellStory extends StatelessWidget {
  const _KaiSheetShellStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiSheetShell (inline demo)',
      child: KaiSheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KaiText.h3('Sheet child content'),
            SizedBox(height: KaiSpace.s2),
            KaiText.body('Drag handle + border-radius top.'),
          ],
        ),
      ),
    );
  }
}

// ── Molecules ─────────────────────────────────────────────────────────────────

class _KaiUserBubbleStory extends StatelessWidget {
  const _KaiUserBubbleStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiUserBubble',
      child: KaiUserBubble(
        text: 'Привет, Kai! Расскажи мне о визе в Японию.',
      ),
    );
  }
}

class _KaiKaiBubbleStory extends StatelessWidget {
  const _KaiKaiBubbleStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiKaiBubble (with citation [1] + streaming)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiKaiBubble(
            text: 'Для туристической визы в Японию [1] нужны: загранпаспорт, '
                'фото, выписка из банка и маршрут поездки.',
            sourcesLabel: '1 источник · только что проверено',
            sources: const [
              KaiSourceCard(
                url: 'mofa.go.jp',
                title: 'Visa — Ministry of Foreign Affairs of Japan',
                snippet: 'Requirements for tourist visas to Japan…',
                index: 1,
                fresh: true,
              ),
            ],
            onThumbUp: () {},
            onThumbDown: () {},
          ),
          const SizedBox(height: KaiSpace.s4),
          const KaiKaiBubble(
            text: 'Ищу информацию',
            streaming: true,
          ),
        ],
      ),
    );
  }
}

class _KaiSystemBubbleStory extends StatelessWidget {
  const _KaiSystemBubbleStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiSystemBubble (3 tones)',
      child: Column(
        children: [
          KaiSystemBubble(
            'Kai обновил воспоминание о ваших планах на поездку.',
            tone: KaiSystemTone.neutral,
          ),
          SizedBox(height: KaiSpace.s3),
          KaiSystemBubble(
            'Внимание — сайт не обновлялся 6 месяцев.',
            bold: 'Внимание —',
            tone: KaiSystemTone.warning,
          ),
          SizedBox(height: KaiSpace.s3),
          KaiSystemBubble(
            'Ошибка сети при загрузке источника.',
            tone: KaiSystemTone.negative,
          ),
        ],
      ),
    );
  }
}

class _KaiComposeIslandStory extends StatefulWidget {
  const _KaiComposeIslandStory();

  @override
  State<_KaiComposeIslandStory> createState() => _KaiComposeIslandStoryState();
}

class _KaiComposeIslandStoryState extends State<_KaiComposeIslandStory> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiComposeIsland',
      child: KaiComposeIsland(
        controller: _ctrl,
        onSend: () {},
        onMicTap: () {},
      ),
    );
  }
}

class _KaiSourceCardStory extends StatelessWidget {
  const _KaiSourceCardStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiSourceCard',
      child: Column(
        children: [
          KaiSourceCard(
            url: 'booking.com',
            title: 'Hotels in Tokyo — Booking.com',
            snippet: 'Find the best deals on hotels in Tokyo, Japan.',
            index: 1,
            fresh: true,
          ),
          SizedBox(height: KaiSpace.s3),
          KaiSourceCard(
            url: 'tripadvisor.com',
            title: 'Things to Do in Tokyo',
            index: 2,
          ),
        ],
      ),
    );
  }
}

class _KaiCareBlockStory extends StatelessWidget {
  const _KaiCareBlockStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiCareBlock',
      child: KaiCareBlock(
        heading: 'Я здесь для тебя.',
        body: 'Если тебе сейчас тяжело — ты не один. '
            'Поговори с кем-то, кто поможет.',
        resources: [
          KaiCareResource(
              label: 'Телефон доверия', number: '8-800-2000-122'),
          KaiCareResource(label: 'Кризисный чат', number: '112'),
        ],
        closing: 'Ты в порядке — просто дыши.',
      ),
    );
  }
}

class _KaiAlertCardStory extends StatelessWidget {
  const _KaiAlertCardStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiAlertCard (all 4 types)',
      child: Column(
        children: [
          KaiAlertCard(
            type: KaiAlertType.urgent,
            title: 'Требуется немедленное внимание',
            body: 'Виза истекает через 3 дня.',
            time: '9:41',
            cta: 'Продлить визу',
            onCtaTap: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiAlertCard(
            type: KaiAlertType.warning,
            title: 'Предупреждение о погоде',
            body: 'Ожидается дождь в районе маршрута.',
            time: '10:15',
            cta: 'Посмотреть прогноз',
            onCtaTap: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiAlertCard(
            type: KaiAlertType.positive,
            title: 'Бронирование подтверждено',
            body: 'Ваш отель в Токио забронирован на 3 ночи.',
            time: '11:00',
            cta: 'Посмотреть детали',
            onCtaTap: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          const KaiAlertCard(
            type: KaiAlertType.neutral,
            title: 'Напоминание о поездке',
            body: 'Через 5 дней вылет в Токио.',
            time: '12:30',
          ),
        ],
      ),
    );
  }
}

class _KaiToastStory extends StatelessWidget {
  const _KaiToastStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiToast (all 4 types, inline)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KaiToast(
            type: KaiToastType.neutral,
            label: 'Скопировано в буфер',
          ),
          const SizedBox(height: KaiSpace.s3),
          const KaiToast(
            type: KaiToastType.positive,
            label: 'Воспоминание сохранено',
            showCountdown: true,
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiToast(
            type: KaiToastType.negative,
            label: 'Не удалось отправить',
            actionLabel: 'Повторить',
            onAction: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiToast(
            type: KaiToastType.memory,
            label: 'Kai запомнил это',
            actionLabel: 'Открыть',
            onAction: () {},
          ),
        ],
      ),
    );
  }
}

class _KaiActionSheetStory extends StatelessWidget {
  const _KaiActionSheetStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiActionSheet + KaiMessageDetailSheet (modal triggers)',
      child: Row(
        children: [
          KaiButton.ghost(
            label: 'Action sheet',
            onPressed: () {
              showKaiActionSheet(
                context,
                items: [
                  KaiActionItem(
                    icon: KaiIconName.copy,
                    title: 'Скопировать',
                    meta: '⌘C',
                    onTap: () {},
                  ),
                  KaiActionItem(
                    icon: KaiIconName.retry,
                    title: 'Повторить запрос',
                    onTap: () {},
                  ),
                  KaiActionItem(
                    icon: KaiIconName.trash,
                    title: 'Удалить сообщение',
                    danger: true,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: KaiSpace.s3),
          KaiButton.ghost(
            label: 'Detail sheet',
            onPressed: () {
              showKaiMessageDetailSheet(
                context,
                sources: const [
                  KaiDetailSource(
                    number: 1,
                    url: 'mofa.go.jp',
                    freshness: KaiSourceFreshness.fresh,
                  ),
                  KaiDetailSource(
                    number: 2,
                    url: 'japan-guide.com',
                    freshness: KaiSourceFreshness.stale,
                    freshnessLabel: '5d',
                  ),
                ],
                actions: [
                  KaiDetailAction(
                    icon: KaiIconName.copy,
                    label: 'Скопировать',
                    onTap: () {},
                  ),
                  KaiDetailAction(
                    icon: KaiIconName.heart,
                    label: 'Сохранить',
                    style: KaiDetailActionStyle.primary,
                    onTap: () {},
                  ),
                  KaiDetailAction(
                    icon: KaiIconName.trash,
                    label: 'Удалить',
                    style: KaiDetailActionStyle.danger,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KaiSegmentedControlStory extends StatefulWidget {
  const _KaiSegmentedControlStory();

  @override
  State<_KaiSegmentedControlStory> createState() =>
      _KaiSegmentedControlStoryState();
}

class _KaiSegmentedControlStoryState
    extends State<_KaiSegmentedControlStory> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiSegmentedControl',
      child: KaiSegmentedControl(
        options: const ['Авто', 'Светлая', 'Тёмная'],
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _KaiSettingsRowStory extends StatefulWidget {
  const _KaiSettingsRowStory();

  @override
  State<_KaiSettingsRowStory> createState() => _KaiSettingsRowStoryState();
}

class _KaiSettingsRowStoryState extends State<_KaiSettingsRowStory> {
  bool _toggle = true;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiSettingsRow + KaiSettingsGroup',
      child: Column(
        children: [
          KaiSettingsGroup(
            label: 'внешний вид',
            children: [
              KaiSettingsRow(
                icon: KaiIconName.palette,
                title: 'Тема',
                subtitle: 'системная',
                trailing: KaiToggle(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
                onTap: () {},
              ),
              KaiSettingsRow(
                icon: KaiIconName.motion,
                title: 'Уменьшить анимацию',
                subtitle: 'прилив становится статичным',
                trailing:
                    KaiIcon(KaiIconName.chevRight, size: 14, color: c.ink3),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s4),
          KaiSettingsGroup(
            danger: true,
            children: [
              KaiSettingsRow(
                icon: KaiIconName.trash,
                title: 'Удалить мои данные',
                danger: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KaiAccountHeroStory extends StatelessWidget {
  const _KaiAccountHeroStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiAccountHero',
      child: KaiAccountHero(
        name: 'Rustam K.',
        email: 'rustam.wize@gmail.com',
        initial: 'R',
        planLabel: 'Pro',
      ),
    );
  }
}

class _KaiNavItemStory extends StatelessWidget {
  const _KaiNavItemStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiNavItem (inactive + active + with badge)',
      child: Column(
        children: [
          KaiNavItem(
            label: 'Поездка в Токио',
            icon: KaiIconName.folder,
            onTap: () {},
          ),
          KaiNavItem(
            label: 'Текущий чат',
            icon: KaiIconName.memory,
            active: true,
            onTap: () {},
          ),
          const KaiNavItem(
            label: 'Память',
            icon: KaiIconName.memory,
            trailing: KaiBadge.dot(),
          ),
        ],
      ),
    );
  }
}

// ── Organisms ─────────────────────────────────────────────────────────────────

class _KaiChatListStory extends StatefulWidget {
  const _KaiChatListStory();

  @override
  State<_KaiChatListStory> createState() => _KaiChatListStoryState();
}

class _KaiChatListStoryState extends State<_KaiChatListStory> {
  RoomFrame _frame = RoomFrame.live;

  static final _messages = <Map<String, dynamic>>[
    {'role': 'user', 'content': 'Привет, Kai! Расскажи про визу в Японию.'},
    {
      'role': 'kai',
      'content':
          'Для туристической визы нужны загранпаспорт, фото и выписка из банка.',
      'sourcesLabel': '2 источника',
    },
    {'role': 'system', 'content': 'Kai обновил воспоминание о поездке.'},
    {
      'role': 'alert',
      'alertType': 'warning',
      'content': 'Погода на маршруте изменилась',
      'body': 'Ожидается дождь в Токио на следующей неделе.',
      'time': '10:15',
    },
    {'role': 'user', 'content': 'А сколько стоит перелёт?'},
    {'role': 'kai', 'content': 'Прямые рейсы Москва→Токио от 45 000 ₽.'},
  ];

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiChatList — frame picker',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: KaiSpace.s2,
            runSpacing: KaiSpace.s2,
            children: RoomFrame.values.map((f) {
              return KaiButton.ghost(
                onPressed: () => setState(() => _frame = f),
                label: f.name,
                tone: _frame == f
                    ? KaiButtonTone.accent
                    : KaiButtonTone.neutral,
              );
            }).toList(),
          ),
          const SizedBox(height: KaiSpace.s4),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: KaiRadius.br3,
              child: ColoredBox(
                color: c.bg,
                child: KaiChatList(
                  frame: _frame,
                  messages:
                      _frame == RoomFrame.empty ? const [] : _messages,
                  partialContent: _frame == RoomFrame.streaming
                      ? 'Ищу информацию о рейсах…'
                      : null,
                  onRetry: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KaiNavPanelStory extends StatelessWidget {
  const _KaiNavPanelStory();

  static final _trips = <TripInfo>[
    const TripInfo(
      id: 'trip-1',
      title: 'Токио 2026',
      subtitle: 'апр — май 2026',
      initial: 'Т',
      chatCount: 4,
    ),
    const TripInfo(
      id: 'trip-2',
      title: 'Бали',
      subtitle: 'июнь 2026',
      initial: 'Б',
      chatCount: 2,
    ),
  ];

  static final _sessions = <SessionPreview>[
    SessionPreview(
      id: 'session-1',
      title: 'Виза в Японию',
      timeLabel: '9:41',
      createdAt: DateTime.now(),
    ),
    SessionPreview(
      id: 'session-2',
      title: 'Отели в Токио',
      timeLabel: '10:15',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SessionPreview(
      id: 'session-3',
      title: 'Маршрут по Бали',
      timeLabel: '12 мая',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiNavPanel',
      child: SizedBox(
        height: 520,
        child: ClipRRect(
          borderRadius: KaiRadius.br3,
          child: KaiNavPanel(
            strings: KaiNavStrings.russian,
            onClose: () {},
            onNewChat: () {},
            trips: _trips,
            sessions: _sessions,
            activeSessionId: 'session-1',
            onSessionTap: (_) {},
            onTripTap: (_) {},
            accountInitial: 'R',
            accountName: 'Rustam K.',
            accountPlan: 'Pro',
            hasUnseenMemory: true,
            onMemoryTap: () {},
            onSettingsTap: () {},
            pinnedTrip: _trips.first,
          ),
        ),
      ),
    );
  }
}

class _KaiEdgeStateBlockStory extends StatelessWidget {
  const _KaiEdgeStateBlockStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiEdgeStateBlock (all 4 surfaces)',
      child: Column(
        children: [
          KaiEdgeStateBlock(surface: KaiEdgeSurface.offline, onRetry: () {}),
          const SizedBox(height: KaiSpace.s4),
          KaiEdgeStateBlock(surface: KaiEdgeSurface.error, onRetry: () {}),
          const SizedBox(height: KaiSpace.s4),
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.rateLimit,
            onPlans: () {},
            countdown: const Duration(seconds: 42),
          ),
          const SizedBox(height: KaiSpace.s4),
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        ],
      ),
    );
  }
}

class _KaiOnboardingCardStory extends StatefulWidget {
  const _KaiOnboardingCardStory();

  @override
  State<_KaiOnboardingCardStory> createState() =>
      _KaiOnboardingCardStoryState();
}

class _KaiOnboardingCardStoryState extends State<_KaiOnboardingCardStory> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiOnboardingCard (steps 0–3)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: KaiSpace.s2,
            runSpacing: KaiSpace.s2,
            children: List.generate(4, (i) {
              return KaiButton.ghost(
                onPressed: () => setState(() => _step = i),
                label: 'Step $i',
                tone: _step == i
                    ? KaiButtonTone.accent
                    : KaiButtonTone.neutral,
              );
            }),
          ),
          const SizedBox(height: KaiSpace.s4),
          SizedBox(
            height: 480,
            child: ClipRRect(
              borderRadius: KaiRadius.br3,
              child: ColoredBox(
                color: c.bg,
                child: KaiOnboardingCard(
                  stepIndex: _step,
                  onNext: () => setState(() {
                    if (_step < 3) _step++;
                  }),
                  onComplete: () => setState(() => _step = 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
