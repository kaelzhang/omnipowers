# Splitting a Round Into Commits

> Normative keywords — MUST, MUST NOT — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this when one round of work touched more than one independently reviewable unit.

- The round touches units that can be reviewed and verified independently — separate services, packages, modules, layers, migration phases → you MUST split the commits by unit or phase. Separate unless review or verification genuinely cannot proceed independently:
  - one component vs. another that does not depend on it;
  - a shared contract or interface change vs. each consumer's adoption of it;
  - schema migration scaffolding vs. the behavior that uses it;
  - regenerated artifacts vs. the handwritten source that generates them;
  - housekeeping (ignore rules, formatting, file moves) vs. product behavior.
- Several valid splits exist → pick the one that simplifies review, rollback, and recovery. That choice is judgment; the requirement to split is not.
