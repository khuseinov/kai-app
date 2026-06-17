import 'package:flutter/widgets.dart';
import 'package:kai_app/features/dev/storybook/stories/atom_stories.dart';
import 'package:kai_app/features/dev/storybook/stories/foundations_stories.dart';
import 'package:kai_app/features/dev/storybook/stories/molecule_stories.dart';
import 'package:kai_app/features/dev/storybook/stories/organism_stories.dart';
import 'package:kai_app/features/dev/storybook/stories/primitive_stories.dart';
import 'package:kai_app/features/dev/storybook/story_page.dart' show PropDoc;

export 'story_page.dart' show PropDoc;

// ── Story model ───────────────────────────────────────────────────────────────

enum StoryLayer { foundations, primitives, atoms, molecules, organisms }

class Story {
  const Story({
    required this.layer,
    required this.name,
    required this.build,
    this.importPath = '',
    this.canonFile = '',
    this.canonSelector = '',
    this.description = '',
    this.variants = const [],
    this.props = const [],
  });

  final StoryLayer layer;
  final String name;
  final String importPath;
  final String canonFile;
  final String canonSelector;
  final String description;
  final List<String> variants;
  final List<PropDoc> props;
  final WidgetBuilder build;
}

// ── Registry ──────────────────────────────────────────────────────────────────

final List<Story> kStories = [
  ...foundationsStories,
  ...primitiveStories,
  ...atomStories,
  ...moleculeStories,
  ...organismStories,
];
