import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/root.dart';
import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';
import '../../../design_system/atoms/atoms.dart';
import 'story_registry.dart';

// ── Layout breakpoint ─────────────────────────────────────────────────────────

const _kSidebarWidth = 260.0;
const _kPropsWidth = 280.0;
const _kBreakpoint = 720.0;
const _kWideBreakpoint = 1100.0;
const _kFrameWidth = 390.0;

// ── StorybookScreen ───────────────────────────────────────────────────────────

/// Adaptive Storybook shell: sidebar + canvas + knobs.
///
/// Wide (≥720): persistent sidebar in a Row.
/// Narrow (<720): sidebar lives in a Drawer opened by a hamburger in the AppBar.
class StorybookScreen extends ConsumerStatefulWidget {
  const StorybookScreen({super.key});

  @override
  ConsumerState<StorybookScreen> createState() => _StorybookScreenState();
}

class _StorybookScreenState extends ConsumerState<StorybookScreen> {
  int _selectedIndex = 0;
  bool _deviceFrame = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Story get _activeStory => kStories[_selectedIndex];

  void _selectStory(int index) {
    setState(() => _selectedIndex = index);
    // Close drawer if it was open (narrow layout)
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final themeMode = ref.watch(themeModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kBreakpoint;

        final sidebar = _StorybookSidebar(
          selectedIndex: _selectedIndex,
          onSelect: _selectStory,
        );

        final canvas = _StorybookCanvas(
          story: _activeStory,
          deviceFrame: _deviceFrame,
        );

        final knobActions = <Widget>[
          // Device frame toggle
          IconButton(
            tooltip:
                _deviceFrame ? 'Full-width canvas' : 'Phone frame (390px)',
            icon: Icon(
              _deviceFrame
                  ? Icons.phone_android
                  : Icons.phone_android_outlined,
              color: _deviceFrame ? c.accent : c.ink2,
            ),
            onPressed: () => setState(() => _deviceFrame = !_deviceFrame),
          ),
          // Theme toggle
          IconButton(
            tooltip: 'Toggle light/dark',
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: c.ink2,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
        ];

        if (isWide) {
          // Wide: persistent sidebar + canvas + optional props panel
          final isExtraWide = constraints.maxWidth >= _kWideBreakpoint;
          final propsPanel = _StoryPropsPanel(story: _activeStory);

          return Scaffold(
            backgroundColor: c.bg,
            appBar: AppBar(
              backgroundColor: c.bg,
              foregroundColor: c.ink1,
              surfaceTintColor: Colors.transparent,
              title: KaiText.h3(_activeStory.name),
              actions: knobActions,
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: _kSidebarWidth, child: sidebar),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: c.line,
                ),
                Expanded(child: canvas),
                if (isExtraWide) ...[
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: c.line,
                  ),
                  SizedBox(width: _kPropsWidth, child: propsPanel),
                ],
              ],
            ),
          );
        }

        // Narrow: Drawer sidebar — key on Scaffold so we can openDrawer()
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: c.bg,
          appBar: AppBar(
            backgroundColor: c.bg,
            foregroundColor: c.ink1,
            surfaceTintColor: Colors.transparent,
            title: const KaiText.h3('Storybook'),
            leading: IconButton(
              icon: Icon(Icons.menu, color: c.ink2),
              tooltip: 'Stories',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            actions: knobActions,
          ),
          drawer: Drawer(
            backgroundColor: c.bg,
            child: SafeArea(child: sidebar),
          ),
          body: canvas,
        );
      },
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _StorybookSidebar extends StatelessWidget {
  const _StorybookSidebar({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    // Group stories by layer
    final grouped = <StoryLayer, List<(int, Story)>>{};
    for (var i = 0; i < kStories.length; i++) {
      final story = kStories[i];
      grouped.putIfAbsent(story.layer, () => []).add((i, story));
    }

    final items = <Widget>[];

    // Header
    items.add(
      const Padding(
        padding: EdgeInsets.fromLTRB(
            KaiSpace.s4, KaiSpace.s5, KaiSpace.s4, KaiSpace.s4),
        child: KaiText.h3('Storybook'),
      ),
    );
    items.add(KaiDivider(color: c.line));
    items.add(const SizedBox(height: KaiSpace.s2));

    for (final layer in StoryLayer.values) {
      final entries = grouped[layer];
      if (entries == null || entries.isEmpty) continue;

      // Section header
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
              KaiSpace.s4, KaiSpace.s4, KaiSpace.s4, KaiSpace.s2),
          child: Text(
            _layerLabel(layer),
            style: KaiType.micro(color: c.ink3),
          ),
        ),
      );

      // Story rows
      for (final (index, story) in entries) {
        final isActive = index == selectedIndex;
        items.add(
          _SidebarRow(
            label: story.name,
            isActive: isActive,
            onTap: () => onSelect(index),
          ),
        );
      }
    }

    items.add(const SizedBox(height: KaiSpace.s5));

    return Material(
      color: c.bg,
      child: ListView(children: items),
    );
  }

  String _layerLabel(StoryLayer layer) {
    switch (layer) {
      case StoryLayer.primitives:
        return 'PRIMITIVES';
      case StoryLayer.atoms:
        return 'ATOMS';
      case StoryLayer.molecules:
        return 'MOLECULES';
      case StoryLayer.organisms:
        return 'ORGANISMS';
    }
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Material(
      color: isActive ? c.accentWash : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KaiSpace.s4,
            vertical: KaiSpace.s3,
          ),
          child: Row(
            children: [
              if (isActive)
                Container(
                  width: 3,
                  height: 16,
                  decoration: const BoxDecoration(
                    gradient: KaiTide.gradient,
                    borderRadius: KaiRadius.brPill,
                  ),
                )
              else
                const SizedBox(width: 3),
              const SizedBox(width: KaiSpace.s3),
              Expanded(
                child: Text(
                  label,
                  style: KaiType.small(
                    color: isActive ? c.accent : c.ink2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Canvas ────────────────────────────────────────────────────────────────────

class _StorybookCanvas extends StatelessWidget {
  const _StorybookCanvas({
    required this.story,
    required this.deviceFrame,
  });

  final Story story;
  final bool deviceFrame;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    Widget storyContent = Builder(
      key: ValueKey(story.name),
      builder: story.build,
    );

    if (deviceFrame) {
      storyContent = Center(
        child: Container(
          width: _kFrameWidth,
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: KaiRadius.br4,
            border: Border.all(color: c.line, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: KaiRadius.br4,
            child: storyContent,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KaiSpace.s6),
      child: storyContent,
    );
  }
}

// ── Props Panel ───────────────────────────────────────────────────────────────

/// Right-side properties panel showing component metadata for the active story.
///
/// Shows: name, NOT-YET-BUILT banner (when applicable), import path,
/// canon file + selector, description, and variants list.
///
/// Displayed on wide layouts (≥1100px) as a fixed-width right column.
class _StoryPropsPanel extends StatelessWidget {
  const _StoryPropsPanel({required this.story});

  final Story story;

  bool get _isUnbuilt =>
      story.name.contains('[TODO]') ||
      story.name.contains('(canon)') ||
      story.description.contains('Not yet built') ||
      story.description.contains('Not yet implemented');

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KaiSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Component name
          Text(
            story.name,
            style: KaiType.h3(color: c.ink1),
          ),
          const SizedBox(height: KaiSpace.s3),

          // NOT YET BUILT banner
          if (_isUnbuilt) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: KaiSpace.s3,
                vertical: KaiSpace.s2,
              ),
              decoration: BoxDecoration(
                color: c.warningWash,
                borderRadius: KaiRadius.br2,
                border: Border.all(
                  color: c.warning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  KaiText.micro(
                    'NOT YET BUILT',
                    color: c.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: KaiSpace.s3),
          ],

          // Import path
          _PropSection(
            label: 'IMPORT',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KaiSpace.s2),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br2,
                border: Border.all(color: c.line),
              ),
              child: Text(
                story.importPath,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                  color: c.ink2,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Canon file + selector
          if (story.canonFile.isNotEmpty) ...[
            const SizedBox(height: KaiSpace.s3),
            _PropSection(
              label: 'CANON',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.canonFile,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      color: c.accent,
                      height: 1.5,
                    ),
                  ),
                  if (story.canonSelector.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      story.canonSelector,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        color: c.ink3,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Description
          if (story.description.isNotEmpty) ...[
            const SizedBox(height: KaiSpace.s3),
            _PropSection(
              label: 'DESCRIPTION',
              child: Text(
                story.description,
                style: KaiType.small(color: c.ink2),
              ),
            ),
          ],

          // Variants
          if (story.variants.isNotEmpty) ...[
            const SizedBox(height: KaiSpace.s3),
            _PropSection(
              label: 'VARIANTS',
              child: Wrap(
                spacing: KaiSpace.s2,
                runSpacing: KaiSpace.s2,
                children: story.variants.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KaiSpace.s2,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: KaiRadius.br1,
                      border: Border.all(color: c.line),
                    ),
                    child: Text(
                      v,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        color: c.ink2,
                        height: 1.4,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PropSection extends StatelessWidget {
  const _PropSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KaiType.micro(color: c.ink3)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
