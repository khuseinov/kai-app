import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/memory/data/models/memory_fact.dart';
import 'package:kai_app/features/memory/presentation/providers/memory_notifier.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/room/presentation/widgets/sheets/kai_action_sheet.dart';
import 'package:kai_app/l10n/app_localizations.dart';

/// Memory Screen. Canon: `new-design/memory.html`.
class MemoryPage extends ConsumerStatefulWidget {
  const MemoryPage({super.key});

  @override
  ConsumerState<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends ConsumerState<MemoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFactActions(BuildContext context, MemoryFact fact) {
    final l10n = AppLocalizations.of(context);
    showKaiActionSheet(
      context,
      items: [
        KaiActionItem(
          icon: KaiIconName.copy, // We can reuse copy icon or check
          title: l10n.memoryEditFactAction,
          onTap: () {
            _showEditFactDialog(context, fact);
          },
        ),
        KaiActionItem(
          icon: KaiIconName.trash,
          title: l10n.memoryDeleteFactAction,
          danger: true,
          onTap: () {
            ref.read(memoryFactsNotifierProvider.notifier).deleteFact(fact.id);
          },
        ),
      ],
    );
  }

  void _showEditFactDialog(BuildContext context, MemoryFact fact) {
    final l10n = AppLocalizations.of(context);
    final c = KaiTheme.of(context).colors;
    final controller = TextEditingController(text: fact.text);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: c.surface,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: KaiRadius.br3),
          title: Text(
            l10n.memoryEditFactTitle,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c.ink1,
            ),
          ),
          content: KaiInput.line(
            controller: controller,
            placeholder: 'Текст факта',
          ),
          actions: [
            KaiButton.text(
              label: l10n.memoryWipeCancelAction,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            KaiButton.ink(
              label: 'Сохранить',
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final updatedFact = fact.copyWith(text: text);
                  ref
                      .read(memoryFactsNotifierProvider.notifier)
                      .addFact(updatedFact);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWipeAllConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showKaiActionSheet(
      context,
      title: l10n.memoryWipeConfirmation,
      items: [
        KaiActionItem(
          icon: KaiIconName.trash,
          title: l10n.memoryWipeConfirmAction,
          danger: true,
          onTap: () {
            ref.read(memoryFactsNotifierProvider.notifier).clearAll();
          },
        ),
        KaiActionItem(
          icon: KaiIconName.close,
          title: l10n.memoryWipeCancelAction,
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final l10n = AppLocalizations.of(context);
    final facts = ref.watch(memoryFactsNotifierProvider);
    final memoryEnabled = ref.watch(memoryEnabledNotifierProvider);

    // Apply search query filter
    final filteredFacts = facts.where((fact) {
      final textMatches = fact.text.toLowerCase().contains(_searchQuery);
      final categoryMatches = fact.category.toLowerCase().contains(_searchQuery);
      final sourceMatches = fact.sourceText.toLowerCase().contains(_searchQuery);
      return textMatches || categoryMatches || sourceMatches;
    }).toList();

    // Group facts by category
    final grouped = <String, List<MemoryFact>>{};
    for (final fact in filteredFacts) {
      grouped.putIfAbsent(fact.category, () => []).add(fact);
    }

    // Explicit order matching memory.html
    const categoryOrder = ['about', 'preferences', 'restrictions', 'trips'];

    final scale = context.scale;
    final textScale = context.textScale;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar height 28
            Padding(
              padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 0),
              child: SizedBox(
                height: 28 * scale,
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () {
                        ref.read(roomNotifierProvider.notifier).openNavPanel();
                        context.go('/room');
                      },
                      child: Container(
                        width: 28 * scale,
                        height: 28 * scale,
                        decoration: BoxDecoration(
                          color: c.surface2,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Transform.flip(
                          flipX: true,
                          child: KaiIcon(
                            KaiIconName.chev,
                            size: 14 * scale,
                            color: c.ink1,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          l10n.memoryAppLabel,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13 * textScale,
                            fontWeight: FontWeight.w600,
                            color: c.ink1,
                            letterSpacing: -0.005 * 13 * textScale,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable facts body
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 24 * scale),
                children: [
                  // 1. Memory Hero Card
                  Container(
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2BA8C9).withValues(alpha: 0.08),
                          const Color(0xFFF4B589).withValues(alpha: 0.06),
                        ],
                      ),
                      border: Border.all(color: c.accentLine),
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36 * scale,
                          height: 36 * scale,
                          decoration: BoxDecoration(
                            gradient: KaiTide.gradient,
                            borderRadius: BorderRadius.circular(11 * scale),
                          ),
                          alignment: Alignment.center,
                          child: KaiIcon(
                            KaiIconName.memory,
                            size: 16 * scale,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.memoryFactsCount(facts.length),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w600,
                                  color: c.ink1,
                                  letterSpacing: -0.01 * 14 * textScale,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                l10n.memoryLastSaved('12 мин'),
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 11 * textScale,
                                  fontWeight: FontWeight.w400,
                                  color: c.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        KaiToggle(
                          value: memoryEnabled,
                          activeColor: c.positive,
                          onChanged: (val) {
                            ref
                                .read(memoryEnabledNotifierProvider.notifier)
                                .toggle(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14 * scale),

                  // 2. Search Bar
                  KaiInput.line(
                    controller: _searchController,
                    placeholder: l10n.memorySearchPlaceholder,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: 12 * scale, right: 8 * scale),
                      child: KaiIcon(
                        KaiIconName.search,
                        size: 13 * scale,
                        color: c.ink3,
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * scale),

                  // 3. Category Groups
                  ...categoryOrder.map((catKey) {
                    final catFacts = grouped[catKey] ?? [];
                    if (catFacts.isEmpty) return const SizedBox.shrink();

                    String title;
                    switch (catKey) {
                      case 'about':
                        title = l10n.memoryCategoryAbout;
                      case 'preferences':
                        title = l10n.memoryCategoryPreferences;
                      case 'restrictions':
                        title = l10n.memoryCategoryRestrictions;
                      case 'trips':
                        title = l10n.memoryCategoryTrips;
                      default:
                        title = l10n.memoryCategoryFacts;
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 14 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // s-label
                          Padding(
                            padding: EdgeInsets.fromLTRB(4 * scale, 8 * scale, 4 * scale, 4 * scale),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 9.5 * textScale,
                                    fontWeight: FontWeight.w400,
                                    color: c.ink3,
                                    letterSpacing: 9.5 * 0.1 * textScale,
                                  ),
                                ),
                                Text(
                                  '${catFacts.length}',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 9.5 * textScale,
                                    fontWeight: FontWeight.w400,
                                    color: c.ink4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // group
                          Container(
                            decoration: BoxDecoration(
                              color: c.surface2,
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            padding: EdgeInsets.all(4 * scale),
                            child: Column(
                              children: catFacts.map((fact) {
                                return _FactItemRow(
                                  fact: fact,
                                  onMenuTap: () => _showFactActions(context, fact),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // 4. Danger Zone GDPR Wipe All
                  Container(
                    margin: EdgeInsets.only(top: 4 * scale),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border.all(color: c.negativeWash),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    padding: EdgeInsets.all(4 * scale),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8 * scale),
                        onTap: () => _showWipeAllConfirmation(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 11 * scale,
                            horizontal: 12 * scale,
                          ),
                          child: Row(
                            children: [
                              KaiIcon(
                                KaiIconName.trash,
                                size: 14 * scale,
                                color: c.negative,
                              ),
                              SizedBox(width: 10 * scale),
                              Expanded(
                                child: Text(
                                  l10n.memoryDangerWipeAll,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12 * textScale,
                                    fontWeight: FontWeight.w500,
                                    color: c.negative,
                                    letterSpacing: -0.005 * 12 * textScale,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactItemRow extends StatelessWidget {
  const _FactItemRow({required this.fact, required this.onMenuTap});

  final MemoryFact fact;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final l10n = AppLocalizations.of(context);
    final scale = context.scale;
    final textScale = context.textScale;

    // Source texts parsing to match styling of memory.html
    // ".src .из" has c.accent color if it says "из", otherwise default c.ink3
    final isFromChat = fact.sourceText.startsWith('из');
    final labelSourceText = isFromChat
        ? fact.sourceText.substring(2).trim()
        : fact.sourceText;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8 * scale),
          onTap: onMenuTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * scale, horizontal: 11 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fact.text,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12 * textScale,
                          fontWeight: FontWeight.w500,
                          color: c.ink1,
                          letterSpacing: -0.005 * 12 * textScale,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Row(
                        children: [
                          if (isFromChat) ...[
                            Text(
                              '${l10n.memorySourceFrom} ',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 9.5 * textScale,
                                fontWeight: FontWeight.w400,
                                color: c.accent,
                              ),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              labelSourceText,
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 9.5 * textScale,
                                fontWeight: FontWeight.w400,
                                color: c.ink3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (fact.expiresIn != null) ...[
                            SizedBox(width: 6 * scale),
                            _TtlChip(
                              expiresIn: fact.expiresIn!,
                              isCritical: fact.isCritical,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * scale),
                Padding(
                  padding: EdgeInsets.all(4 * scale),
                  child: KaiIcon(
                    KaiIconName.menu, // i-dots matches dots menu
                    size: 13 * scale,
                    color: c.ink3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TtlChip extends StatefulWidget {
  const _TtlChip({required this.expiresIn, required this.isCritical});
  final String expiresIn;
  final bool isCritical;

  @override
  State<_TtlChip> createState() => _TtlChipState();
}

class _TtlChipState extends State<_TtlChip> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled || !widget.isCritical) {
      _controller?.stop();
      return;
    }
    if (_controller != null) return; // already running
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final scale = context.scale;
    final textScale = context.textScale;
    final text = 'expires ${widget.expiresIn}';

    final Widget chip = Container(
      padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1 * scale),
      decoration: BoxDecoration(
        color: widget.isCritical ? c.negativeWash : c.warningWash,
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9 * textScale,
          fontWeight: FontWeight.w500,
          color: widget.isCritical ? c.negative : c.warning,
          letterSpacing: 9 * 0.04 * textScale,
        ),
      ),
    );

    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.isCritical && _controller != null && !disabled) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.55, end: 1).animate(_controller!),
        child: chip,
      );
    }

    return chip;
  }
}
