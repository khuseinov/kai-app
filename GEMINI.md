# KAI App — Notes for Gemini Agents

This is a mobile-first Flutter application (iOS + Android) for the KAI travel companion. 
It uses a light-first zero-UI humanist design system. The v3 clean atomic component library is built and live.

---

## Standalone Development Tools

To keep the production product clean of development screens, the Storybook and design specs have been isolated from the production router and can be run separately using these double-clickable Windows batch files:

*   **`run_storybook.bat`**: Runs the standalone Storybook in Chrome at port `8081` (`lib/main_storybook.dart`).
*   **`run_specs.bat`**: Serves the HTML design specifications (from `new-design/` containing `spec-viewer.html` and others) at port `8743` using a local Python HTTP server.

---

## Build & Test Commands

Run the following commands in the workspace root:

```sh
# Setup & dependencies
cp .env.example .env
flutter pub get

# Codegen (must be run to build *.g.dart and *.freezed.dart)
dart run build_runner build --delete-conflicting-outputs

# Run the production app
flutter run

# Run the Storybook separately
run_storybook.bat

# Run local design spec server
run_specs.bat

# Run the test suite
flutter test

# Run static analysis
flutter analyze
```

---

## Architectural Stack (Non-Negotiable)

*   **State Management**: `flutter_riverpod`, `riverpod_annotation` (always use `@riverpod` codegen, never manual providers).
*   **Navigation**: `go_router` (constants in `Routes`, routing file is [router.dart](file:///E:/startup/kai-app/lib/core/routing/router.dart)).
*   **Network**: `dio` + `retrofit`.
*   **Serialization**: `freezed` + `json_serializable`.
*   **Local Storage**: `hive_flutter`.
    *   *Warning*: Hive adapters under `lib/core/storage/` are **hand-rolled** to avoid code generation conflicts with Freezed. Check existing fields and manually update the adapter's `read()` and `write()` methods when adding fields.
*   **Lints**: `very_good_analysis` (always alphabetize imports and clean up warnings to ensure `flutter analyze` passes).

---

## Customization Skills to Use

When working in this repo, ensure the following skills are read and followed:
*   [flutter-kai](file:///C:/Users/79050/.gemini/config/skills/flutter-kai/SKILL.md): Production-ready Flutter development instructions.
*   [ponytail](file:///C:/Users/79050/.gemini/config/plugins/ponytail/skills/ponytail/SKILL.md): Senior-developer minimal change guideline (YAGNI, build the minimum that works, mark simplifications with `// ponytail:` comment).
