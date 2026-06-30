# KAI App — Workspace Rules and Memory

This file serves as the project memory and workspace-specific rules for AI agents.

## Project Architecture & Layout

*   **Production Entrypoint**: `lib/main.dart` (runs `BootingApp` which transitions to `KaiApp`).
*   **Storybook Entrypoint**: `lib/main_storybook.dart` (runs `StorybookScreen` standalone).
*   **Production Router**: `lib/core/routing/router.dart` is clean of dev routes. It only routes production pages.

## Standalone Development Scripts (Windows)

Use these batch scripts in the root directory for local dev tasks:
*   `run_storybook.bat` -> Runs the standalone component Storybook (`lib/main_storybook.dart`) on Chrome at port `8081`.
*   `run_specs.bat` -> Runs local Python server in `new-design/` at port `8743` to browse HTML design specs.

## Persistent Rules & Safeguards

1.  **Hive Safety in Tests**: In widget and unit tests, Hive is not initialized. When writing to or reading from Hive in Notifiers/Providers, always protect the database accesses with a check to `Hive.isBoxOpen(boxName)`.
2.  **Zero-UI Principles**: Respect the Zero-UI brand guidelines (see `new-design/CLAUDE.md`).
3.  **Lints & Import Sorting**: Always check that imports are alphabetized and grouped correctly (external packages followed by `package:kai_app/...` imports) to avoid breaking the `directives_ordering` rule.
4.  **Minimalist Approach (Ponytail)**: Keep files clean, avoid over-engineering, do not add unnecessary packages or boilerplate, and mark intentional simplifications with a `// ponytail:` comment.

## Kai Global Skills

Global skill pack adapted from `cursor/plugins`:
`C:/Users/79050/kai-global-skills/`

Install for all tools:
```powershell
./install/install-all.ps1
```

Available commands:
- `/kai-verify-this` — verify a claim with fresh local evidence.
- `/kai-deslop` — remove AI-generated slop and clean style (Flutter-specific: `debugPrint`, unused providers, import sorting).
- `/kai-fix-ci` — chase failing PR checks until green.
- `/kai-loop-on-ci` — monitor and fix CI loops.
- `/kai-make-pr-easy-to-review` — tidy PR descriptions and history for widget refactors.
- `/kai-review-and-ship` — review branch, run `flutter analyze && flutter test`, open/update PR.
- `/kai-what-did-i-get-done` — summarize recent authored commits.
- `/kai-continual-learning` — propose incremental updates to this file from recent work.

Always-on principles: `kai-boundary-discipline`, `kai-type-system-discipline`, `kai-prove-it-works`, `kai-guard-the-context-window`, `kai-laziness-protocol`, `kai-subtract-before-you-add`.

