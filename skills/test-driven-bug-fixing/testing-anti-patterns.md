# Testing Anti-Patterns

**Load this reference when:** writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## Overview

Tests MUST verify real behavior, not mock behavior. Mocks are a means to isolate, not the thing being tested.

**Core principle:** Test what the code does, not what the mocks do.

**Following the reproduce-first discipline prevents these anti-patterns.**

## The Iron Laws

```
1. You MUST NOT test mock behavior
2. You MUST NOT add test-only methods to production classes
3. You MUST NOT mock without understanding the dependency
```

## Anti-Pattern 1: Testing Mock Behavior

**The violation:**
```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**Why this is wrong:**
- You're verifying the mock works, not that the component works
- Test passes when mock is present, fails when it's not
- Tells you nothing about real behavior

**Ask yourself:** "Am I testing the behavior of a mock?"

**The fix:**
```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

### Gate Function

```
BEFORE asserting on any mock element:
  Ask: "Am I testing real component behavior or just mock existence?"

  IF testing mock existence:
    STOP - Delete the assertion or unmock the component

  Test real behavior instead
```

## Anti-Pattern 2: Test-Only Methods in Production

**The violation:**
```typescript
// ❌ BAD: destroy() only used in tests
class Session {
  async destroy() {  // Looks like production API!
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... cleanup
  }
}

// In tests
afterEach(() => session.destroy());
```

**Why this is wrong:**
- Production class polluted with test-only code
- Dangerous if accidentally called in production
- Violates YAGNI and separation of concerns
- Confuses object lifecycle with entity lifecycle

**The fix:**
```typescript
// ✅ GOOD: Test utilities handle test cleanup
// Session has no destroy() - it's stateless in production

// In test-utils/
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// In tests
afterEach(() => cleanupSession(session));
```

### Gate Function

```
BEFORE adding any method to production class:
  Ask: "Is this only used by tests?"

  IF yes:
    STOP - Don't add it
    Put it in test utilities instead

  Ask: "Does this class own this resource's lifecycle?"

  IF no:
    STOP - Wrong class for this method
```

## Anti-Pattern 3: Mocking Without Understanding

**The violation:**
```typescript
// ❌ BAD: Mock breaks test logic
test('detects duplicate server', () => {
  // Mock prevents config write that test depends on!
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // Should throw - but won't!
});
```

**Why this is wrong:**
- Mocked method had side effect test depended on (writing config)
- Over-mocking to "be safe" breaks actual behavior
- Test passes for wrong reason or fails mysteriously

**The fix:**
```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager'); // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

### Gate Function

```
BEFORE mocking any method:
  STOP - Don't mock yet

  1. Ask: "What side effects does the real method have?"
  2. Ask: "Does this test depend on any of those side effects?"
  3. Ask: "Do I fully understand what this test needs?"

  IF depends on side effects:
    Mock at lower level (the actual slow/external operation)
    OR use test doubles that preserve necessary behavior
    NOT the high-level method the test depends on

  IF unsure what test depends on:
    Run test with real implementation FIRST
    Observe what actually needs to happen
    THEN add minimal mocking at the right level

  Red flags:
    - "I'll mock this to be safe"
    - "This might be slow, better mock it"
    - Mocking without understanding the dependency chain
```

## Anti-Pattern 4: Incomplete Mocks

**The violation:**
```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```

**Why this is wrong:**
- **Partial mocks hide structural assumptions** - You only mocked fields you know about
- **Downstream code may depend on fields you didn't include** - Silent failures
- **Tests pass but integration fails** - Mock incomplete, real API complete
- **False confidence** - Test proves nothing about real behavior

**The Iron Rule:** You MUST mock the COMPLETE data structure as it exists in reality, not just the fields your immediate test uses.

**The fix:**
```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

### Gate Function

```
BEFORE creating mock responses:
  Check: "What fields does the real API response contain?"

  Actions:
    1. Examine actual API response from docs/examples
    2. Include ALL fields system might consume downstream
    3. Verify mock matches real response schema completely

  Critical:
    If you're creating a mock, you must understand the ENTIRE structure
    Partial mocks fail silently when code depends on omitted fields

  If uncertain: Include all documented fields
```

## Anti-Pattern 5: Fixing Without a Reproducing Test

**The violation:**
```
✅ Fix applied
❌ No test reproduces the bug
"Should be fixed now"
```

**Why this is wrong:**
- A fix you never watched fail proves nothing
- The bug can silently return on the next change
- Can't claim fixed without a test that failed first

**The fix:**
```
Reproduce-first cycle:
1. Write a test that reproduces the bug (it fails)
2. Fix the root cause to make it pass
3. Harden adjacent cases
4. THEN claim fixed
```

## Anti-Pattern 6: Tautological Tests

**The violation:**
```typescript
// production: total = items.reduce((a, i) => a + i.price * i.qty, 0)
test('computes total', () => {
  const expected = items.reduce((a, i) => a + i.price * i.qty, 0); // same formula!
  expect(computeTotal(items)).toBe(expected);
});
```

**Why this is wrong:**
- The assertion recomputes the expected value the same way the code does — the test passes even when the formula itself is the bug
- It verifies the code agrees with itself, not that it is correct

**The fix:** the expected value MUST come from an independent source of truth — a hand-computed constant, the bug report's stated value, or a known-good fixture:
```typescript
test('computes total', () => {
  // 2×$3.00 + 1×$4.50, computed by hand
  expect(computeTotal(items)).toBe(10.50);
});
```

## Anti-Pattern 7: Implementation-Coupled Tests

**The violation:** a test that verifies HOW the code works instead of WHAT it does — asserting call counts, spying on internal collaborators, reading private state, or verifying through a side channel (e.g. checking `createUser` worked by inspecting the database row instead of calling `getUser`).

**Why this is wrong:**
- The tell: a refactor that preserves behavior breaks the test — the test is pinning the implementation, not the contract
- Such tests block every improvement and prove nothing about user-visible behavior

**The fix:** verify through the same public interface a real caller uses. If behavior cannot be observed through any public interface, that is a design smell to raise — not a license to test privates.

## Where Mocking Is Permitted

Mock at **system boundaries** you do not own or cannot run in a test:

- **MAY mock:** network services, third-party APIs, clocks/timers, randomness, filesystem/OS calls, message queues — the process edge.
- **MUST NOT mock:** your own internal collaborators (classes/functions/modules inside the codebase). Needing to mock an internal collaborator means the boundary is wrong — restructure (e.g. inject the dependency) instead of mocking around it.

## When Mocks Become Too Complex

**Warning signs:**
- Mock setup longer than test logic
- Mocking everything to make test pass
- Mocks missing methods real components have
- Test breaks when mock changes

**Ask yourself:** "Do we need a mock here at all?"

When mock setup exceeds the test logic, you SHOULD prefer an integration test with real components — the choice varies by how expensive or external the real dependency is, so it is a recommendation, not an absolute.

## Reproduce-First Prevents These Anti-Patterns

**Why reproducing the bug first helps:**
1. **Write the failing test first** → Forces you to pin what the bug actually is
2. **Watch it fail** → Confirms the test exercises real behavior, not mocks
3. **Minimal fix** → No test-only methods creep in
4. **Real dependencies** → You see what the test actually needs before mocking

**If you're testing mock behavior, you skipped reproduce-first** - you added mocks without watching the test fail against real code first.

## Quick Reference

| Anti-Pattern | Fix |
|--------------|-----|
| Assert on mock elements | Test real component or unmock it |
| Test-only methods in production | Move to test utilities |
| Mock without understanding | Understand dependencies first, mock minimally |
| Incomplete mocks | Mirror real API completely |
| Fix without a reproducing test | Reproduce the bug first |
| Tautological test | Expected value from an independent source of truth |
| Implementation-coupled test | Verify through the public interface |
| Over-complex mocks | Consider integration tests |

## Red Flags

- Assertion checks for `*-mock` test IDs
- Methods only called in test files
- Mock setup is >50% of test
- Test fails when you remove mock
- Can't explain why mock is needed
- Mocking "just to be safe"
- The assertion re-derives the expected value with the code's own formula
- The test asserts call counts or inspects private/internal state
- Mocking a collaborator that lives in this codebase

## The Bottom Line

**Mocks are tools to isolate, not things to test.**

If you find yourself testing mock behavior, you have gone wrong.

Fix: Test real behavior or question why you're mocking at all.
