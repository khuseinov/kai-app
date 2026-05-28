/// v3 organisms — top presentational layer, composes molecules + atoms.
///
/// Organisms may import molecules, atoms, primitives, tokens, theme, and
/// domain models received as params. They must NOT contain business logic
/// (no Riverpod reads, no I/O — data comes in via params only).
library;

export 'kai_chat_list.dart';
export 'kai_nav_panel.dart';
