import 'package:flutter/widgets.dart';
import 'story_page.dart' show PropDoc;
import 'stories/foundations_stories.dart';
import 'stories/primitive_stories.dart';
import 'stories/atom_stories.dart';
import 'stories/molecule_stories.dart';
import 'stories/organism_stories.dart';

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
  final String name, importPath, canonFile, canonSelector, description;
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
