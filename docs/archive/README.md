# Archive

Historical documents — read-only. Created 2026-07-15 (docs audit) as the drain for `docs/superpowers/` — the first triage pass kai-app's docs tree has had. A same-day follow-up pass then deleted everything here that had zero outside citations; only files still cited *by name* from a live document survived as archived (not deleted).

## What's kept here (and why it wasn't deleted)

- `superpowers/handoffs/2026-05-27-design-system-review.md` — cited by the still-live `docs/superpowers/plans/2026-05-27-design-fidelity-fixes.md`.
- `superpowers/plans/2026-05-28-design-system-refactor.md` — cited by the load-bearing `docs/superpowers/audits/2026-05-28-design-system-audit.md` and by `docs/superpowers/handoffs/2026-05-30-storybook-review-handoff.md`.
- `superpowers/specs/2026-05-28-design-system-audit-design.md` — cited by the load-bearing design-system audit.
- `superpowers/plans/tasks/bucket-{a..f}-*.md` (all 6) — the implementation record `docs/superpowers/plans/2026-05-27-design-fidelity-fixes.md` links to by name in its own decomposition table.

## What was deleted (not just archived)

Everything else from the original 28-file move: `MOBILE_ARCHITECTURE_PLAN.md`, `memory-architecture-human-ai.md` + its source research JSON, the `2026-05-27-context-transfer-phase-4-onwards.md` handoff, 8 completed plans (dechrome, stream-indicator-bug, the 4 Cycle 2/3 build-log plans, storybook-review-fixes, the 06-02 restructuring plan), and 7 completed specs (2026 redesign philosophy, Cycle 2/3 design docs, compose-island redesign, splash living-tide). None of these were cited by name from any file that's still live — recoverable from git history if ever needed, just not from this tree.

## Still-live in `docs/superpowers/`

Not everything moved — these stay because they're either load-bearing (cited by root `CLAUDE.md`) or still active reference:

- `plans/2026-05-26-kai-app-rebuild-v3-implementation.md` + `specs/2026-05-26-kai-app-rebuild-v3-design.md` — the v3 rebuild this whole app is built on
- `plans/2026-05-27-design-fidelity-fixes.md` — parent of the 6 archived buckets above
- `plans/2026-05-28-kai-ui-atomic-library-v3.md` + `specs/2026-05-28-kai-ui-atomic-library-v3-design.md` — current design-system spec
- `audits/2026-05-28-design-system-audit.md` — audit that triggered the v3 rebuild
- `handoffs/2026-05-28-design-fidelity-v2-session.md` + `handoffs/2026-05-30-storybook-review-handoff.md` — see note below
- `specs/2026-06-17-unified-architecture-design.md` — best current description of the app's actual `data/domain/presentation` architecture; no `docs/architecture/` home exists yet in this repo to promote it to

⚠️ Root `CLAUDE.md` labels `2026-05-28-design-fidelity-v2-session.md` the "Latest session handoff" — this is stale. `2026-05-30-storybook-review-handoff.md` is both later and a much closer match to current repo state (838 tests / 17 atoms / 18 molecules / 4 organisms, an exact match to current `CLAUDE.md`). Not corrected here since it's a `CLAUDE.md` edit, out of scope for a `docs/` restructure — flagged for a follow-up.
