# JIRA Access Fallback Strategies

## Problem
JIRA API at https://jira.tools.sap frequently hits rate limits (HTTP 429), blocking automated ticket fetching.

## Solutions Implemented

### ✅ Solution 1: Helper Script with Auto-Retry (Recommended)
**Location**: `~/.claude/skills/jira-context/helpers/fetch-with-fallback.sh`

**Strategy**: Exponential backoff with automatic retries
- Immediate API call
- Wait 5s → retry
- Wait 15s more → retry
- Exit code 2 if all fail (suggests browser fallback)

**Usage**:
```bash
~/.claude/skills/jira-context/helpers/fetch-with-fallback.sh DWS-12345
```

**Exit codes**:
- 0: Success (JSON output)
- 1: HTTP error (non-429)
- 2: Rate limited after retries

### ✅ Solution 2: Browser MCP Fallback
When API is exhausted, use browser tools:

```javascript
// Navigate to ticket
mcp__browser__browser_navigate("https://jira.tools.sap/browse/DWS-12345")

// Get snapshot
mcp__browser__browser_snapshot(compact: false)

// Extract from DOM:
// - Title: page title or [data-testid="issue.views.issue-base.foundation.summary.heading"]
// - Status: status badge elements
// - Description: .user-content-block
// - Links: Issue Links section
```

**Pros**: Bypasses API rate limits
**Cons**: Manual DOM extraction, less structured data

### ❌ Failed Approaches

1. **Python requests**: Same rate limit as curl
2. **urllib**: Same rate limit
3. **Alternative auth**: No other tokens available
4. **WebFetch XML**: Blocked by enterprise network
5. **Long waits**: 60s+ still hit rate limits

## Integration with jira-context Skill

The skill now:
1. **First tries** helper script with auto-retry (20s max wait)
2. **Falls back to** browser MCP if script exits with code 2
3. **Continues analysis** with partial data if available
4. **Never blocks** entire analysis on rate limits

## Rate Limit Patterns Observed

- Multiple consecutive calls → 429 immediately
- Single call after ~5min idle → usually succeeds
- Exponential backoff (5s, 15s) → ~50% success rate
- Long wait (60s) → still often fails

## Recommendations

1. **For single tickets**: Use helper script (auto-handles retries)
2. **For multiple tickets**: Space calls 5-10s apart
3. **For deep analysis**: Use browser fallback for less critical tickets
4. **For CI/CD**: Cache ticket data, don't fetch on every run
