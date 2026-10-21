# Testing Anti-Patterns

> Normative keywords (MUST, MUST NOT, SHOULD, MAY, …) are used as defined in BCP 14 (RFC 2119, RFC 8174), and only when capitalized.

## The Iron Laws

```
1. You MUST NOT test mock behavior
2. You MUST NOT add test-only methods to production classes
3. You MUST NOT mock without understanding the dependency
```

Tests MUST verify real behavior, not mock behavior.

## Anti-Pattern 1: Testing Mock Behavior

```typescript
// ❌ BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

```typescript
// ✅ GOOD: Test real component or don't mock it
test('renders sidebar', () => {
  render(<Page />);  // Don't mock sidebar
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// OR if sidebar must be mocked for isolation:
// Don't assert on the mock - test Page's behavior with sidebar present
```

## Anti-Pattern 2: Test-Only Methods in Production

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

## Anti-Pattern 3: Mocking Without Understanding

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

```typescript
// ✅ GOOD: Mock at correct level
test('detects duplicate server', () => {
  // Mock the slow part, preserve behavior test needs
  vi.mock('MCPServerManager'); // Just mock slow server startup

  await addServer(config);  // Config written
  await addServer(config);  // Duplicate detected ✓
});
```

## Anti-Pattern 4: Incomplete Mocks

```typescript
// ❌ BAD: Partial mock - only fields you think you need
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // Missing: metadata that downstream code uses
};

// Later: breaks when code accesses response.metadata.requestId
```

```typescript
// ✅ GOOD: Mirror real API completeness
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // All fields real API returns
};
```

When mocking data → you MUST mock the COMPLETE data structure as it exists in reality, not just the fields your immediate test uses.

## Anti-Pattern 5: Tautological Tests

```typescript
// production: total = items.reduce((a, i) => a + i.price * i.qty, 0)
test('computes total', () => {
  const expected = items.reduce((a, i) => a + i.price * i.qty, 0); // same formula!
  expect(computeTotal(items)).toBe(expected);
});
```

For expected values → the expected value MUST come from an independent source of truth: a hand-computed constant, the bug report's stated value, or a known-good fixture.

```typescript
test('computes total', () => {
  // 2×$3.00 + 1×$4.50, computed by hand
  expect(computeTotal(items)).toBe(10.50);
});
```

## Where Mocking Is Permitted

- At system boundaries you do not own or cannot run in a test → you MAY mock network services, third-party APIs, clocks/timers, randomness, filesystem/OS calls, and message queues.
- For your own internal collaborators (classes/functions/modules inside the codebase) → you MUST NOT mock them.

## When Mocks Become Too Complex

Mock setup exceeds the test logic → you SHOULD prefer an integration test with real components.
