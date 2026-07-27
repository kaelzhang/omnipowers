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
2. **Compliance delta vs a no-skill control** — `make fitness-compliance SKILL=<name>`
   runs each scenario twice in an identical fixture (skill text injected vs not),
   grades both transcripts blind against the scenario's expectations, and reports
   `control → skill = DELTA`. **This is the skill's reason to exist, measured** —
   and it is the ONLY measurement that can judge a guardrail skill, whose value
   appears when nobody asked for it (a low trigger recall on an explicit "verify
   this" request says nothing about that value).
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
- **Trigger evals need a clean room.** The harness measures the description via a
  synthetic command; a globally installed copy of the skill shadows it, and a
  real project cwd makes the model start working instead of reaching for a
  skill — both zero the measurement (uniform 0/N across all queries is the
  tell). `make uninstall` before a trigger round, reinstall with `make dev`
  after; `fitness.py` already runs each eval from an empty scratch directory
  and warns if the skill is still installed.
- **Trigger protocol (v2, validated).** Each eval case names a small **fixture
  repo** (copied into the scratch + `setup.sh` for git state) so repo-contextual
  queries are ecologically plausible; all descriptions are planted competitively;
  detection scans the whole stream for an assistant tool_use naming the target
  (models explore before invoking — a first-tool criterion miscounts; listing
  events are announcements, not invocations). Uniform-zero or uniform-one rounds
  mean the protocol, not the skills, needs debugging first.
- **A guardrail's trigger recall is not its fitness.** When an explicit request
  ("verify this before I ship") is one the model handles natively, the trigger
  eval reads low while the skill is doing its real job elsewhere — stopping an
  unverified claim nobody asked it to check. Judge that class on compliance delta
  alone; a low-recall/high-delta skill is a KEEP.
- **Interpret low recall through the routing lens before touching a description.**
  With competitive planting, a "missed" trigger often means the query correctly
  routed to a sibling (a bug report routing to the debugging skill before the
  fix-time skill is our own designed flow). Check WHICH skill fired before
  condemning the description; the fix may be the eval label, not the skill.
