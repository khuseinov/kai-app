# Archive

Historical documents — read-only. Created 2026-07-15 (docs audit) as the drain for `docs/superpowers/` — this is the first triage pass kai-app's docs tree has had.

- `MOBILE_ARCHITECTURE_PLAN.md` — early (2026-04-09) incremental S1-S5 mobile architecture plan; superseded by the full v3 rebuild (`docs/superpowers/specs/2026-05-26-kai-app-rebuild-v3-design.md`), which took a different path (clean-slate rebuild, not incremental S1-S5).
- `memory-architecture-human-ai.md` + `superpowers/research/academic-memory-survey-2026-06-18.json` — backend/AI-conceptual research (human memory systems → Kai's Neo4j/Qdrant/Redis mapping), not mobile-app-specific. Flagged during the audit as possibly better suited to the `kai-agent` repo's `docs/explanation/research/10_World_Model/` — kept here for now since moving content across repos wasn't executed as part of this pass.
- `superpowers/handoffs/` — session handoffs whose one-time job (kick off the next work session) is long fulfilled; superseded by later handoffs or by the current `lib/design_system/COMPONENTS.md`.
- `superpowers/plans/` + `superpowers/plans/tasks/` — completed implementation plans, including all 6 `bucket-*.md` children of `2026-05-27-design-fidelity-fixes.md` (still live — see `docs/superpowers/plans/`) and the `2026-06-02-design-system-restructuring-plan.md` whose goal was absorbed into the later, broader `2026-06-17-unified-architecture-design.md` (still live).
- `superpowers/specs/` — design specs for completed work.

## Still-live in `docs/superpowers/`

Not everything moved — these stay because they're either load-bearing (cited by root `CLAUDE.md`) or still active reference:

- `plans/2026-05-26-kai-app-rebuild-v3-implementation.md` + `specs/2026-05-26-kai-app-rebuild-v3-design.md` — the v3 rebuild this whole app is built on
- `plans/2026-05-27-design-fidelity-fixes.md` — parent of the 6 archived buckets above
- `plans/2026-05-28-kai-ui-atomic-library-v3.md` + `specs/2026-05-28-kai-ui-atomic-library-v3-design.md` — current design-system spec
- `audits/2026-05-28-design-system-audit.md` — audit that triggered the v3 rebuild
- `handoffs/2026-05-28-design-fidelity-v2-session.md` + `handoffs/2026-05-30-storybook-review-handoff.md` — see note below
- `specs/2026-06-17-unified-architecture-design.md` — best current description of the app's actual `data/domain/presentation` architecture; no `docs/architecture/` home exists yet in this repo to promote it to

⚠️ Root `CLAUDE.md` labels `2026-05-28-design-fidelity-v2-session.md` the "Latest session handoff" — this is stale. `2026-05-30-storybook-review-handoff.md` is both later and a much closer match to current repo state (838 tests / 17 atoms / 18 molecules / 4 organisms, an exact match to current `CLAUDE.md`). Not corrected here since it's a `CLAUDE.md` edit, out of scope for a `docs/` restructure — flagged for a follow-up.
