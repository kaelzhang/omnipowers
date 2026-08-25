# Testing Anti-Patterns

**Load this reference when:** writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Laws

```
1. You MUST NOT test mock behavior
2. You MUST NOT add test-only methods to production classes
3. You MUST NOT mock without understanding the dependency
```

Tests MUST verify real behavior, not mock behavior.

## Anti-Pattern 1: Testing Mock Behavior

Match:
```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

Tell: testing mock behavior means reproduce-first was skipped — the mocks went in without watching the test fail against real code first.

Fix:
```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

Gate — before asserting on any mock element:

- Ask: "Am I testing real component behavior or just mock existence?"
- Testing mock existence → STOP; delete the assertion or unmock the component, then test real behavior instead.

## Anti-Pattern 2: Test-Only Methods in Production

Match:
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

Fix:
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

Gate — before adding any method to a production class:

- Ask: "Is this only used by tests?" Yes → STOP; don't add it, put it in test utilities instead.
- Ask: "Does this class own this resource's lifecycle?" No → STOP; wrong class for this method.

## Anti-Pattern 3: Mocking Without Understanding

Match:
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

Fix:
```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager'); // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

Gate — before mocking any method, STOP and don't mock yet:

- Ask: "What side effects does the real method have?"
- Ask: "Does this test depend on any of those side effects?"
- Ask: "Do I fully understand what this test needs?"
- Depends on side effects → mock at a lower level (the actual slow/external operation), OR use test doubles that preserve necessary behavior — NOT the high-level method the test depends on.
- Unsure what the test depends on → run the test with the real implementation FIRST, observe what actually needs to happen, THEN add minimal mocking at the right level.

Red flags:
- "I'll mock this to be safe"
- "This might be slow, better mock it"
- Mocking without understanding the dependency chain

## Anti-Pattern 4: Incomplete Mocks

Match:
```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```

Fix:
```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

**The Iron Rule:** You MUST mock the COMPLETE data structure as it exists in reality, not just the fields your immediate test uses.

Gate — before creating mock responses:

- Check: "What fields does the real API response contain?"
- Examine the actual API response from docs/examples.
- Include ALL fields the system might consume downstream.
- Verify the mock matches the real response schema completely.
- Creating a mock → understand the ENTIRE structure; partial mocks fail silently when code depends on omitted fields.
- Uncertain → include all documented fields.

## Anti-Pattern 5: Fixing Without a Reproducing Test

Match:
```
✅ Fix applied
❌ No test reproduces the bug
"Should be fixed now"
```

Can't claim fixed without a test that failed first.

Fix:
```
Reproduce-first cycle:
1. Write a test that reproduces the bug (it fails)
2. Fix the root cause to make it pass
3. Harden adjacent cases
4. THEN claim fixed
```

## Anti-Pattern 6: Tautological Tests

Match — the assertion recomputes the expected value the way the code does, so the test passes even when the formula itself is the bug:
```typescript
// production: total = items.reduce((a, i) => a + i.price * i.qty, 0)
test('computes total', () => {
  const expected = items.reduce((a, i) => a + i.price * i.qty, 0); // same formula!
  expect(computeTotal(items)).toBe(expected);
});
```

Fix — the expected value MUST come from an independent source of truth: a hand-computed constant, the bug report's stated value, or a known-good fixture.
```typescript
test('computes total', () => {
  // 2×$3.00 + 1×$4.50, computed by hand
  expect(computeTotal(items)).toBe(10.50);
});
```

## Anti-Pattern 7: Implementation-Coupled Tests

Match: a test that verifies HOW the code works instead of WHAT it does — asserting call counts, spying on internal collaborators, reading private state, or verifying through a side channel (e.g. checking `createUser` worked by inspecting the database row instead of calling `getUser`).

Tell: a refactor that preserves behavior breaks the test.

Fix: verify through the same public interface a real caller uses. Behavior cannot be observed through any public interface → raise it as a design smell, not a license to test privates.

## Where Mocking Is Permitted

Mock at **system boundaries** you do not own or cannot run in a test:

- **MAY mock:** network services, third-party APIs, clocks/timers, randomness, filesystem/OS calls, message queues — the process edge.
- **MUST NOT mock:** your own internal collaborators (classes/functions/modules inside the codebase). Needing to mock an internal collaborator means the boundary is wrong → restructure (e.g. inject the dependency) instead of mocking around it.

## When Mocks Become Too Complex

Warning signs:
- Mock setup longer than test logic
- Mocking everything to make test pass
- Mocks missing methods real components have
- Test breaks when mock changes

Ask: "Do we need a mock here at all?"

Mock setup exceeds the test logic → you SHOULD prefer an integration test with real components; this varies by how expensive or external the real dependency is.

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
