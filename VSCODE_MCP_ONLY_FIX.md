# VSCode MCP-Only Issue Fix

## Problem Observed

在 VSCode 中使用 `/jira-context-mcp` 时，Claude 尝试了多种方法才成功：

| 方法 | 结果 | 耗时 | 信息完整度 |
|------|------|------|-----------|
| JIRA MCP | ❌ 无法直接调用 | 2分钟 | 0% |
| JIRA REST API (无认证) | ❌ 401 | 10秒 | 0% |
| **JIRA CLI (有认证)** | ❌ 429 速率限制 | 1分钟 | 0% |
| 重试 (5秒等待) | ❌ 仍然 429 | 15秒 | 0% |
| 重试 (30秒等待) | ❌ 仍然速率限制 | 40秒 | 0% |
| Git 历史分析 | ✅ 成功 | 5分钟 | 95%+ |

## 🔴 核心问题

**`jira-context-mcp` skill 不应该尝试 JIRA CLI！**

- Skill 名称是 `jira-context-mcp` (MCP-based)
- CLI 属于 `jira-context` skill (CLI-based)
- 两个 skills 应该各司其职

## 为什么会尝试 CLI？

### 可能原因 1: Skill 指令不够明确
之前的 SKILL.md 没有明确禁止 CLI，只说了 "Primary Method: JIRA MCP"，这给了 Claude 自由度去尝试其他工具。

### 可能原因 2: VSCode 环境中的混淆
VSCode 可能同时加载了两个 skills：
- `jira-context` (CLI-based)
- `jira-context-mcp` (MCP-based)

Claude 可能在尝试 fallback 时混淆了两者。

### 可能原因 3: Claude 的"智能"fallback
Claude 看到 API 失败后，自己决定尝试所有可能的方法（包括 CLI），即使 skill 没有明确指示。

## ✅ 解决方案

### 修复 1: 明确的 MCP-ONLY 声明
在 SKILL.md 顶部添加醒目警告：

```markdown
**⚠️ MCP-ONLY SKILL**: This skill uses **ONLY MCP tools**. 
Never use JIRA CLI, curl, or shell scripts.
```

### 修复 2: 明确禁止列表
在 fallback 策略中明确列出**不允许的工具**：

```markdown
**IMPORTANT**: This is an **MCP-only** skill. DO NOT use:
- ❌ JIRA CLI (`~/bin/jira`) - Use `jira-context` skill instead
- ❌ Direct curl/wget commands - Use MCP tools only
- ❌ Shell scripts - Use MCP tools only

**Only allowed tools**:
- ✅ `mcp__sap-jira-mcp__*` functions
- ✅ `mcp__sap-auth-mcp__*` functions  
- ✅ Git commands (git log, git show, etc.)
- ✅ Read/Grep tools for local files
```

### 修复 3: 优化 Fallback 顺序
把 **Git 历史分析** 提到最前面（Tier 0），因为：
- ✅ 100% 成功率（对于已完成的 tickets）
- ✅ 无速率限制
- ✅ 信息更丰富
- ✅ 更快

新的 fallback 顺序：
```
Tier 0: Git History (for completed tickets)
  ↓ (if not in git)
Tier 1: JIRA MCP
  ↓ (if MCP fails)
Tier 2: SAP Auth MCP + REST API
  ↓ (if 429 rate limit)
Tier 3: Browser Extraction
  ↓ (if all fail)
Tier 4: Ask User
```

## 预期效果

### 修复前
```
用户: /jira-context-mcp DWS-20938
  ↓
尝试 MCP → 失败
  ↓
尝试 REST API → 401
  ↓
❌ 尝试 CLI → 429 (不应该！)
  ↓
重试 → 429
  ↓
重试 → 429
  ↓
最终尝试 Git → 成功
```

### 修复后
```
用户: /jira-context-mcp DWS-20938
  ↓
检查 Git 历史 → ✅ 成功！（5秒内）

OR (if not in git):

检查 Git 历史 → 未找到
  ↓
尝试 MCP → 如果失败
  ↓
尝试 SAP Auth MCP → 如果 429，回到 Git
  ↓
❌ 绝不尝试 CLI
```

## 两个 Skills 的明确分工

| Feature | jira-context | jira-context-mcp |
|---------|--------------|------------------|
| **主要工具** | JIRA CLI | MCP 工具 |
| **认证方式** | PAT token | MCP 服务器 |
| **环境** | 命令行 | VSCode + 命令行 |
| **Fallback** | Shell 脚本重试 | Git → MCP → Browser |
| **何时使用** | 已有 CLI 配置 | VSCode 用户，学习生产事故 |

**关键区别**：
- `jira-context` = CLI 优先
- `jira-context-mcp` = MCP 优先，**绝不用 CLI**

## Git 提交

```
commit 3ccd8f4
fix: enforce MCP-only, prohibit CLI fallback

- Added MCP-ONLY warning at top
- Explicitly prohibit CLI, curl, shell scripts
- Clarified allowed tools
- Updated fallback order
```

## 测试验证

下次在 VSCode 中使用时应该看到：

```
✅ 检查 Git 历史 → 找到 commits
✅ 分析代码和测试
✅ 提取完整信息
✅ 完成（无 CLI 尝试）
```

OR (if ticket not in git):

```
✅ 检查 Git 历史 → 未找到
✅ 使用 MCP 工具获取
✅ 完成（无 CLI 尝试）
```

**绝不应该出现**：
- ❌ "Trying JIRA CLI"
- ❌ "429 rate limit from CLI"
- ❌ "curl: command not found"

## 为什么 Git-First 是最佳实践

从实际案例（DWS-20938）学到的经验：

### Git 提供的信息
- ✅ 15+ commits 的完整历史
- ✅ API 规格（从代码中提取）
- ✅ 11 个测试用例 + 41 个断言
- ✅ 技术决策（commit messages）
- ✅ 相关 tickets（sibling work）
- ✅ 时间线（合并日期，修复日期）

### JIRA 提供的信息（如果能访问）
- ⚠️ 业务描述
- ⚠️ 评论讨论
- ⚠️ 外部文档链接

### 结论
对于**已完成的 tickets**，Git 提供了更完整、更准确的信息，应该**优先使用**。

## 未来改进建议

1. **自动检测**：根据 ticket ID 在 git 中出现的次数，自动判断是否已完成
2. **智能选择**：
   - 找到 >5 commits → 100% 用 Git
   - 找到 1-4 commits → Git + MCP 补充
   - 找不到 → 纯 MCP
3. **缓存策略**：Git 数据可以缓存更长时间（已完成的不会变）
4. **VSCode 优化**：在 VSCode 中默认 Git-First

## 相关文件

- `jira-context-mcp/SKILL.md` - 主 skill 文件（已修复）
- `jira-context/SKILL.md` - CLI-based skill（保持不变）
- `QUICK_REFERENCE.md` - 快速参考（需要更新）
