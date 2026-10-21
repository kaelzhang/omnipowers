# 测试反模式

> 本文中全大写的规范关键词 MUST、MUST NOT、REQUIRED、SHALL、SHALL NOT、SHOULD、SHOULD NOT、RECOMMENDED、MAY、OPTIONAL 按 BCP 14（RFC 2119、RFC 8174）解释，且仅在全大写时具有规范含义。

## 铁律

```
1. 你 MUST NOT 测试 mock 行为
2. 你 MUST NOT 向生产类添加测试专用方法
3. 你 MUST NOT 在未理解依赖时 mock
```

测试 MUST 验证真实行为，而非 mock 行为。

## 反模式 1：测试 mock 行为

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

## 反模式 2：生产代码中的测试专用方法

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

## 反模式 3：未理解就 mock

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

## 反模式 4：不完整的 mock

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

mock 数据时 → 你 MUST 按真实情况 mock 完整数据结构，而非只 mock 当前测试用到的字段。

## 反模式 5：自证循环测试

```typescript
// production: total = items.reduce((a, i) => a + i.price * i.qty, 0)
test('computes total', () => {
  const expected = items.reduce((a, i) => a + i.price * i.qty, 0); // same formula!
  expect(computeTotal(items)).toBe(expected);
});
```

确定预期值时 → 预期值 MUST 来自独立的事实依据：手算常量、bug 报告陈述的值，或已知正确的 fixture。

```typescript
test('computes total', () => {
  // 2×$3.00 + 1×$4.50, computed by hand
  expect(computeTotal(items)).toBe(10.50);
});
```

## mock 的适用范围

- 位于你不拥有或无法在测试中运行的系统边界 → 你 MAY mock 网络服务、第三方 API、时钟 / 定时器、随机性、文件系统 / OS 调用和消息队列。
- 对于你自己的内部协作对象（代码库内的类 / 函数 / 模块）→ 你 MUST NOT mock 它们。

## mock 变得过于复杂时

mock 准备工作超过测试逻辑 → 你 SHOULD 优先采用真实组件的集成测试。
