# Repairing a Documentation Set

> Normative keywords — MUST, MUST NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## 1. Get the repair in scope first

- Before restructuring a set with no entrypoint, multiple entrypoints, or an entrypoint that no longer matches what is on disk → you MUST tell the user what you found (the set, the specific defect, and what the repair touches) and get their agreement.

## 2. Read the whole set

- Before writing a single row → you MUST read every document in the set.

## 3. Inventory

- A document has no identifiable task that should send a reader to it → you MUST NOT invent a task signal to make it fit.

## 4. Reconcile every path

- Writing a path → you MUST open it, resolving it from the entrypoint's directory.
