import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/kai_text.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// One documented prop row (mirrored in the inspector).
class PropDoc {
  const PropDoc(this.name, this.type, this.defaultValue, this.description);
  final String name;
  final String type;
  final String defaultValue;
  final String description;
}

/// A single labelled demo cell — the component variant in a bordered card.
class StoryCell {
  const StoryCell(this.label, this.child);
  final String label;
  final Widget child;
}

/// A titled group of cells (e.g. "Variants", "States").
class StorySection {
  const StorySection(this.title, this.cells);
  final String title;
  final List<StoryCell> cells;
}

/// Structured story page: header + sections of labelled cells + usage + props.
class StoryPage extends StatelessWidget {
  const StoryPage({
    required this.title, required this.layer, required this.blurb, required this.sections, super.key,
    this.usage = '',
    this.props = const [],
  });

  final String title;
  final String layer;
  final String blurb;
  final String usage;
  final List<StorySection> sections;
  final List<PropDoc> props;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Flexible(child: KaiText.h2(title)),
          const SizedBox(width: KaiSpace.s3),
          _LayerChip(layer),
        ],),
        const SizedBox(height: KaiSpace.s2),
        KaiText.body(blurb, color: c.ink2),
        const SizedBox(height: KaiSpace.s6),
        for (final s in sections) ...[
          _SectionHeader(s.title),
          const SizedBox(height: KaiSpace.s3),
          Wrap(
            spacing: KaiSpace.s4,
            runSpacing: KaiSpace.s4,
            children: [for (final cell in s.cells) _Cell(cell)],
          ),
          const SizedBox(height: KaiSpace.s6),
        ],
        if (usage.isNotEmpty) ...[
          const _SectionHeader('Usage'),
          const SizedBox(height: KaiSpace.s2),
          _CodeBox(usage),
          const SizedBox(height: KaiSpace.s6),
        ],
        if (props.isNotEmpty) ...[
          const _SectionHeader('Props'),
          const SizedBox(height: KaiSpace.s2),
          _PropsTable(props),
        ],
      ],
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KaiSpace.s2, vertical: 2),
      decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: KaiRadius.brPill,
          border: Border.all(color: c.line),),
      child: Text(label,
          style: KaiType.mono(color: c.ink3).copyWith(fontSize: 9),),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: KaiType.micro(color: KaiTheme.of(context).colors.ink3));
}

class _Cell extends StatelessWidget {
  const _Cell(this.cell);
  final StoryCell cell;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.all(KaiSpace.s4),
      decoration: BoxDecoration(
          color: c.surface,
          borderRadius: KaiRadius.br3,
          border: Border.all(color: c.line),),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        cell.child,
        const SizedBox(height: KaiSpace.s3),
        Text(cell.label,
            style: KaiType.mono(color: c.ink3).copyWith(fontSize: 10),),
      ],),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox(this.code);
  final String code;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaiSpace.s3),
      decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: KaiRadius.br2,
          border: Border.all(color: c.line),),
      child: Text(code,
          style: KaiType.mono(color: c.ink2).copyWith(fontSize: 11, height: 1.5),),
    );
  }
}

class _PropsTable extends StatelessWidget {
  const _PropsTable(this.props);
  final List<PropDoc> props;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in props)
          Padding(
            padding: const EdgeInsets.only(bottom: KaiSpace.s2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 110,
                  child: Text(p.name,
                      style:
                          KaiType.mono(color: c.ink1).copyWith(fontSize: 11),),),
              SizedBox(
                  width: 90,
                  child: Text(p.type,
                      style: KaiType.mono(color: c.accent)
                          .copyWith(fontSize: 11),),),
              SizedBox(
                  width: 70,
                  child: Text(p.defaultValue,
                      style: KaiType.mono(color: c.ink3)
                          .copyWith(fontSize: 11),),),
              Expanded(child: KaiText.small(p.description, color: c.ink2)),
            ],),
          ),
      ],
    );
  }
}
