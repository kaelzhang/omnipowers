# Repairing a Documentation Set

> Normative keywords — MUST, MUST NOT, SHOULD, SHOULD NOT, MAY — are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

Apply this when the set you are about to change has no entrypoint, has more than one, or has an entrypoint that no longer matches what is on disk. The rules in `SKILL.md` still bind; this file is only the order of operations for rebuilding routing that is already broken.

## 1. Get the repair in scope first

Before restructuring anything you MUST tell the user what you found — the set, the specific defect, and what the repair touches — and get their agreement.

They decline → make the change you were asked for, keep it consistent with the entrypoint as it stands, and leave the defect stated in your reply by exact path.

## 2. Read the whole set — this is the licensed case

You MUST read every document in the set before writing a single row.

## 3. Inventory

For each document, write one line: **what it governs**, and **the task that should send a reader to it**.

A document you cannot write that second half for is mis-scoped, superseded, or dead. You MUST NOT invent a task signal to make it fit — list it as a finding for the user instead, and let them decide between rescoping it, merging it, and deleting it.

## 4. Choose the shape

- Every document binds every reader → required-reading list.
- Readers legitimately need different subsets → task-signal resolver table.
- Both are true of different documents → state both, and mark which documents are unconditional.
- The set's history does not make this obvious → ask.

## 5. Derive signals from tasks, then split

Write each signal from the inventory's second half — the task, not the title. Then split any signal whose load set is not small, until each branch resolves to a handful of documents. A table with three broad rows is a directory listing with extra steps.

## 6. Reconcile every path

You MUST open each path you write, resolving it from the entrypoint's directory.

## 7. Sweep for redundancy

With the whole set in context, find rules stated normatively in two documents. For each: keep one source, cross-reference from the other, and record in the entrypoint which is authoritative. Either document is read alone → both copies stay and the entrypoint names the authoritative one.

Redundancy you find in a **neighbouring** set is a finding, not a task: surface it by exact path and leave it alone.

## 8. Collapse extra entrypoints

A set has more than one door → keep the one its readers already open, and reduce each other to a single redirect line or delete it.

## 9. Deliver

State plainly: the entrypoint you wrote, the documents it now routes to, what you changed to make paths resolve, and the findings you did **not** act on — dead documents, mis-scoped documents, and redundancy outside this set — each by exact path.
