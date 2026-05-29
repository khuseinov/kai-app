import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/root.dart';
import '../../../design_system/atoms/atoms.dart';
import '../../../design_system/molecules/kai_segmented_control.dart';
import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';
import 'story_registry.dart';

// ── Layout constants ──────────────────────────────────────────────────────────

const _kSidebarWidth = 260.0;
const _kPropsWidth = 280.0;
const _kBreakpoint = 720.0;
const _kWideBreakpoint = 1100.0;
const _kFrameWidth = 390.0;

// ── Background-surface cycle ──────────────────────────────────────────────────

/// Three backgrounds the canvas can be viewed on: bg → surface → surface2.
const _kBgCount = 3;

Color _bgColor(KaiColorTokens c, int index) => switch (index) {
      1 => c.surface,
      2 => c.surface2,
      _ => c.bg,
    };

String _bgLabel(int index) => switch (index) {
      1 => 'surface',
      2 => 'surface-2',
      _ => 'bg',
    };

// ── ThemeMode helpers ─────────────────────────────────────────────────────────

int _themeModeIndex(ThemeMode m) => switch (m) {
      ThemeMode.light => 0,
      ThemeMode.dark => 1,
      ThemeMode.system => 2,
    };

ThemeMode _indexToThemeMode(int i) =>
    const [ThemeMode.light, ThemeMode.dark, ThemeMode.system][i];

// ── StorybookScreen ───────────────────────────────────────────────────────────

/// Adaptive Storybook shell: sidebar + canvas + inspector (props) panel.
///
/// Breakpoints:
///   ≥1100 px : Row [sidebar 260 | canvas | inspector 280]
///   720–1099 px : Row [sidebar 260 | canvas] + inspector via info bottom-sheet
///   <720 px  : Drawer sidebar + inspector via info bottom-sheet
class StorybookScreen extends ConsumerStatefulWidget {
  const StorybookScreen({super.key});

  @override
  ConsumerState<StorybookScreen> createState() => _StorybookScreenState();
}

class _StorybookScreenState extends ConsumerState<StorybookScreen> {
  Story _selected = kStories.first;
  bool _deviceFrame = false;
  int _bgIndex = 0; // 0=bg  1=surface  2=surface2
  String _query = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _selectStory(Story story) {
    setState(() => _selected = story);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _showInspector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final c = KaiTheme.of(context).colors;
        return Container(
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: c.line,
                  borderRadius: KaiRadius.brPill,
                ),
              ),
              Flexible(child: _StoryPropsPanel(story: _selected)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final themeMode = ref.watch(themeModeProvider);

    final sidebar = _StorybookSidebar(
      selected: _selected,
      query: _query,
      onSelect: _selectStory,
      onQueryChanged: (q) => setState(() => _query = q),
    );

    final canvas = _StorybookCanvas(
      story: _selected,
      deviceFrame: _deviceFrame,
      bgIndex: _bgIndex,
    );

    final propsPanel = _StoryPropsPanel(story: _selected);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kBreakpoint;
        final isExtraWide = constraints.maxWidth >= _kWideBreakpoint;

        // ── Knob actions ────────────────────────────────────────────────────
        final deviceFrameBtn = IconButton(
          tooltip: _deviceFrame ? 'Full-width canvas' : 'Phone frame (390 px)',
          icon: Icon(
            _deviceFrame ? Icons.phone_android : Icons.phone_android_outlined,
            color: _deviceFrame ? c.accent : c.ink2,
          ),
          onPressed: () => setState(() => _deviceFrame = !_deviceFrame),
        );

        final bgToggleBtn = IconButton(
          tooltip: 'Canvas background: ${_bgLabel(_bgIndex)}',
          icon: Icon(Icons.contrast, color: c.ink2),
          onPressed: () =>
              setState(() => _bgIndex = (_bgIndex + 1) % _kBgCount),
        );

        final inspectorBtn = IconButton(
          tooltip: 'Inspector',
          icon: Icon(Icons.info_outline, color: c.ink2),
          onPressed: () => _showInspector(context),
        );

        // Segmented theme switch — fits inside the AppBar actions row.
        final themeSwitcher = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: KaiSegmentedControl(
            options: const ['Light', 'Dark', 'System'],
            selectedIndex: _themeModeIndex(themeMode),
            onSelected: (i) =>
                ref.read(themeModeProvider.notifier).state =
                    _indexToThemeMode(i),
          ),
        );

        // ── Extra-wide (≥1100): 3-pane row ─────────────────────────────────
        if (isExtraWide) {
          return Scaffold(
            backgroundColor: c.bg,
            appBar: AppBar(
              backgroundColor: c.bg,
              foregroundColor: c.ink1,
              surfaceTintColor: Colors.transparent,
              title: KaiText.h3(_selected.name),
              actions: [
                deviceFrameBtn,
                bgToggleBtn,
                themeSwitcher,
                const SizedBox(width: 8),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: _kSidebarWidth, child: sidebar),
                VerticalDivider(width: 1, thickness: 1, color: c.line),
                Expanded(child: canvas),
                VerticalDivider(width: 1, thickness: 1, color: c.line),
                SizedBox(width: _kPropsWidth, child: propsPanel),
              ],
            ),
          );
        }

        // ── Wide (720–1099): sidebar inline, inspector via bottom sheet ─────
        if (isWide) {
          return Scaffold(
            backgroundColor: c.bg,
            appBar: AppBar(
              backgroundColor: c.bg,
              foregroundColor: c.ink1,
              surfaceTintColor: Colors.transparent,
              title: KaiText.h3(_selected.name),
              actions: [
                deviceFrameBtn,
                bgToggleBtn,
                inspectorBtn,
                themeSwitcher,
                const SizedBox(width: 8),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: _kSidebarWidth, child: sidebar),
                VerticalDivider(width: 1, thickness: 1, color: c.line),
                Expanded(child: canvas),
              ],
            ),
          );
        }

        // ── Narrow (<720): Drawer sidebar, inspector via bottom sheet ───────
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
            actions: [
              deviceFrameBtn,
              bgToggleBtn,
              inspectorBtn,
              themeSwitcher,
              const SizedBox(width: 8),
            ],
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
    required this.selected,
    required this.query,
    required this.onSelect,
    required this.onQueryChanged,
  });

  final Story selected;
  final String query;
  final void Function(Story) onSelect;
  final void Function(String) onQueryChanged;

  String _layerLabel(StoryLayer layer) => switch (layer) {
        StoryLayer.foundations => 'FOUNDATIONS',
        StoryLayer.primitives => 'PRIMITIVES',
        StoryLayer.atoms => 'ATOMS',
        StoryLayer.molecules => 'MOLECULES',
        StoryLayer.organisms => 'ORGANISMS',
      };

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final lq = query.toLowerCase();

    // Group stories by layer, filtered by query.
    final grouped = <StoryLayer, List<Story>>{};
    for (final story in kStories) {
      if (lq.isEmpty || story.name.toLowerCase().contains(lq)) {
        grouped.putIfAbsent(story.layer, () => []).add(story);
      }
    }

    final items = <Widget>[];

    // Header (only in wide layout where sidebar is inline; drawer has its own title).
    items.add(
      const Padding(
        padding: EdgeInsets.fromLTRB(
            KaiSpace.s4, KaiSpace.s5, KaiSpace.s4, KaiSpace.s4),
        child: KaiText.h3('Storybook'),
      ),
    );
    items.add(KaiDivider(color: c.line));
    items.add(const SizedBox(height: KaiSpace.s2));

    // Search box
    items.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(
            KaiSpace.s3, KaiSpace.s2, KaiSpace.s3, KaiSpace.s3),
        child: TextField(
          onChanged: onQueryChanged,
          style: KaiType.small(color: c.ink1),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: 'Search…',
            hintStyle: KaiType.small(color: c.ink4),
            prefixIcon: Icon(Icons.search, size: 16, color: c.ink3),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 36),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: KaiSpace.s3, vertical: KaiSpace.s2),
            filled: true,
            fillColor: c.surface2,
            border: OutlineInputBorder(
              borderRadius: KaiRadius.br2,
              borderSide: BorderSide(color: c.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: KaiRadius.br2,
              borderSide: BorderSide(color: c.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: KaiRadius.br2,
              borderSide: BorderSide(color: c.accent),
            ),
          ),
        ),
      ),
    );

    // Story groups — only layers with matching results are shown.
    for (final layer in StoryLayer.values) {
      final entries = grouped[layer];
      if (entries == null || entries.isEmpty) continue;

      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
              KaiSpace.s4, KaiSpace.s4, KaiSpace.s4, KaiSpace.s2),
          child: Text(_layerLabel(layer), style: KaiType.micro(color: c.ink3)),
        ),
      );

      for (final story in entries) {
        final isActive = story == selected;
        items.add(
          _SidebarRow(
            label: story.name,
            isActive: isActive,
            onTap: () => onSelect(story),
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
                  style: KaiType.small(color: isActive ? c.accent : c.ink2),
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
    required this.bgIndex,
  });

  final Story story;
  final bool deviceFrame;
  final int bgIndex;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final bg = _bgColor(c, bgIndex);

    Widget storyContent = Builder(
      key: ValueKey(story.name),
      builder: story.build,
    );

    if (deviceFrame) {
      storyContent = Center(
        child: Container(
          width: _kFrameWidth,
          decoration: BoxDecoration(
            color: bg,
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

    return ColoredBox(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(KaiSpace.s6),
        child: storyContent,
      ),
    );
  }
}

// ── Props Panel ───────────────────────────────────────────────────────────────

/// Right-side properties panel showing component metadata for the active story.
///
/// Shown as a fixed-width column at ≥1100 px; accessible via a bottom sheet
/// at narrower widths (tapped via the AppBar info button).
///
/// Sections: name, NOT-YET-BUILT banner, IMPORT, CANON, DESCRIPTION,
/// VARIANTS, and (when populated) PROPS.
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
          Text(story.name, style: KaiType.h3(color: c.ink1)),
          const SizedBox(height: KaiSpace.s3),

          // NOT YET BUILT banner
          if (_isUnbuilt) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: KaiSpace.s3, vertical: KaiSpace.s2),
              decoration: BoxDecoration(
                color: c.warningWash,
                borderRadius: KaiRadius.br2,
                border:
                    Border.all(color: c.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [KaiText.micro('NOT YET BUILT', color: c.warning)],
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
                  story.description, style: KaiType.small(color: c.ink2)),
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
                        horizontal: KaiSpace.s2, vertical: 3),
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

          // Props (optional — only when populated by the story)
          if (story.props.isNotEmpty) ...[
            const SizedBox(height: KaiSpace.s3),
            _PropSection(
              label: 'PROPS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: story.props.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            p.name,
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              color: c.accent,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: KaiSpace.s2),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${p.type}  •  ${p.defaultValue}\n${p.description}',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              color: c.ink3,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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
