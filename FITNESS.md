# Skill Fitness Review — the maintenance loop

Skills age: models improve, no-op lines accumulate, and every resident description
taxes every session. This runbook is the periodic review that decides, per skill:
**keep / simplify / merge / retire**. Evaluations are the source of truth — content
changes driven by taste alone don't count as fitness work.

## Cadence

Run a review **on every major model upgrade** and **at least quarterly**. The
no-op boundary moves with model capability: a rule that earned its place last
quarter may be default behavior now.

## Running a round

`make fitness-round` runs the whole review — every skill's trigger eval, then
every skill's behavioral A/B — and enforces the protocol so it cannot be
forgotten: it **preflights the CLI** with one cheap call and aborts if the API is
unreachable (an expired token otherwise turns the whole round into pages of
silently INVALID runs that read like a protocol bug), it **refuses to start the
trigger phase while the skills are installed** (a globally installed copy shadows
the synthetic command and zeroes the measurement), and it **runs large skills
serially**. Narrow it with `SKILLS=a,b` and `PHASE=triggers|compliance`.

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
- **Read the two arms, never the delta alone.** The delta is a difference of two
  noisy measurements: a control arm that moves between rounds (same scenario,
  same expectations) shifts the delta without the skill changing at all. Before
  concluding a skill got worse, check whether the SKILL arm fell or the CONTROL
  arm rose — only the former is about the skill. One scenario × 3 runs cannot
  resolve deltas below ~0.2; add scenarios before trusting a small number, and
  run serially when the skill is large (a long injected skill times out under
  worker contention and the run is discarded as invalid).
- **A guardrail's trigger recall is not its fitness.** When an explicit request
  ("verify this before I ship") is one the model handles natively, the trigger
  eval reads low while the skill is doing its real job elsewhere — stopping an
  unverified claim nobody asked it to check. Judge that class on compliance delta
  alone; a low-recall/high-delta skill is a KEEP.
- **A scenario that asks for the discipline measures nothing.** When the prompt
  says "review this", "debug this", or "write a plan", the control arm gets the
  skill's behavior for free and the delta collapses toward zero — that reads as
  "the skill adds nothing" when it only means "the request already contained the
  skill". An **unprompted** scenario asks for the work but not the discipline, and
  frames it to push against the discipline (urgency, an "obvious" one-liner, "just
  ship it"). Every skill SHOULD have one; a skill measuring a small delta MUST get
  one before any keep/simplify/cut decision, because until then it has not been
  measured on the case it exists for.
- **Under-powered arms are not verdicts.** An arm with fewer than ~15 graded
  expectations, or a skill with a single scenario, cannot support a keep/cut
  decision — invalid runs shrink n silently, so read the arm totals before the
  delta. Any skill heading for a keep/simplify/cut decision MUST carry at least 3
  scenarios; large skills MUST be run serially, because a long injected skill
  times out under worker contention and the discarded runs land in one arm only.
- **Both arms low is a floor, not a ceiling.** A small delta between two low
  arms (e.g. 0.20 → 0.25) means the scenario's expectations are near-unachievable
  in one run, not that the skill is worthless. Before concluding anything, check
  whether any run satisfied most clauses; if none did, fix the scenario — split
  conjunctive expectations into independently gradable clauses — and re-measure.
- **using-omnipowers cannot be A/B tested and MUST NOT be.** Its job is to make
  *other* skills fire; injecting its text into a session that has no other skills
  measures nothing, and both arms score zero by construction. Judge it instead by
  the collection's aggregate trigger recall — if skills fire when they should, it
  is doing its job.
- **Interpret low recall through the routing lens before touching a description.**
  With competitive planting, a "missed" trigger often means the query correctly
  routed to a sibling (a bug report routing to the debugging skill before the
  fix-time skill is our own designed flow). Check WHICH skill fired before
  condemning the description; the fix may be the eval label, not the skill.
