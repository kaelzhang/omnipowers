# Skill Fitness Review — the maintenance loop

Skills age: models improve, no-op lines accumulate, and every resident description
taxes every session. This runbook is the periodic review that decides, per skill:
**keep / simplify / merge / retire**. Evaluations are the source of truth — content
changes driven by taste alone don't count as fitness work.

## Cadence

Run a review **on every major model upgrade** and **at least quarterly**. The
no-op boundary moves with model capability: a rule that earned its place last
quarter may be default behavior now.

## The four measurements (per skill)

1. **Trigger precision / recall** — `make fitness-triggers SKILL=<name> EVALSET=<file>`
   runs the official skill-creator harness over a labelled query set
   (`[{"query": …, "should_trigger": true|false}, …]`): does the description fire
   when it should and stay quiet when it shouldn't? Cheap (description-only runs).
2. **Compliance delta vs a no-skill control** — the harness's benchmark flow
   (grader/comparator agents, blind A/B with and without the skill) on ≥3
   representative scenarios per skill. This is the skill's reason to exist,
   measured.
3. **Token cost** — resident description cost (all sessions) + body size ×
   activation frequency. `make fitness-validate` covers structure; body size is
   `wc -w`.
4. **Model-version sensitivity** — re-run (2) after each model upgrade before
   trusting last quarter's verdict.

## Decision rules

| Observation | Action |
|---|---|
| Delta ≈ 0, triggers healthy | Run the **no-op deletion test** line by line (delete a line → re-run the eval → unchanged = the line was cost); ship the simplified skill. |
| Delta ≈ 0 after simplification | **Retire** — move to an `attic/` (archive, don't delete; a model regression may resurrect it). |
| Delta negative | **Retire immediately** — the skill is making output worse. |
| Two skills' deltas come from the same rules | **Merge** them. |
| Triggers too eager (low precision) | Tighten the description (collapse branches, add anti-routing); re-measure. |
| Delta clearly positive and stable | **Keep**; freeze growth — additions need their own measured delta. |

## Ground rules

- Every cut and every keep cites a measurement, not an opinion. The no-op test IS
  the licensed way to shrink a skill.
- MUSTs remain failure-driven (see `AGENTS.md`): a rule that survives the no-op
  test but has no nameable failure mode is still a candidate for downgrade.
- Eval sets live outside this repo (dev data): keep them with your workspace and
  pass `EVALSET=` (or set `OMNIPOWERS_FITNESS_ROOT`).
- The harness is an external dependency: a clone of
  [anthropics/skills](https://github.com/anthropics/skills) at
  `~/Sources/harness/anthropic-skills` (override with `SKILLCREATOR_HOME`). Its
  trigger evals shell out to an authenticated `claude` CLI.
