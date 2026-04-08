# Quick Reference Card

## Available Skills

### JIRA Context Analysis

#### 🔧 /jira-context (CLI-based)
Fast, direct JIRA API access via CLI tools.

**When to use**: Quick ticket lookups, shell integration
**Prerequisites**: JIRA CLI + JIRA_TOKEN env var
**Output**: Structured ticket data with links

```bash
/jira-context DWS-21607
```

#### 🧠 /jira-context-mcp (Enhanced)
Intelligent analysis with actionable recommendations.

**When to use**: Strategic planning, risk assessment, learning from incidents
**Prerequisites**: sap-jira-mcp + sap-auth-mcp
**Output**: Executive summary, risks, recommendations, day-by-day plan

```bash
/jira-context-mcp DWS-21607
```

**Unique features**:
- 🎯 Executive summary with blockers
- 📊 Risk assessment + mitigation
- 💬 Decision mining from comments
- ⏰ ETA analysis for blockers
- 🔥 ServiceNow incident learning
- 🎬 Day-by-day implementation plan

### PR Review

#### 📝 /review-with-context
Comprehensive PR review informed by JIRA context.

**When to use**: Reviewing PRs, checking requirements coverage
**Prerequisites**: gh CLI + one of the jira-context skills
**Output**: Requirements check, code review, integration assessment

```bash
/review-with-context https://github.wdf.sap.corp/sap-jam/ct/pull/1997
/review-with-context sap-jam/ct#1997
/review-with-context 1997  # defaults to sap-jam/ct
```

## Decision Matrix

### Which skill to use?

| Your Goal | Recommended Skill |
|-----------|------------------|
| Quick ticket info lookup | /jira-context |
| Understand requirements before coding | /jira-context-mcp |
| Risk assessment for planning | /jira-context-mcp |
| Learn from production incidents | /jira-context-mcp |
| Review a PR | /review-with-context |
| Sprint planning estimation | /jira-context-mcp |
| Check for blockers | /jira-context or /jira-context-mcp |
| VSCode integration | /jira-context-mcp |

## Comparison

| Feature | jira-context | jira-context-mcp | review-with-context |
|---------|--------------|------------------|-------------------|
| Speed | ⚡⚡⚡ | ⚡⚡ | ⚡ |
| Depth | 📊 | 📊📊📊 | 📊📊 |
| Setup | Easy | Medium | Easy |
| Output | Data | Insights | Review |
| VSCode | ❌ | ✅ | ✅ |
| ServiceNow | ❌ | ✅ | ❌ |

## Setup Quick Start

### For /jira-context
```bash
# Set token
export JIRA_TOKEN='your-token'
```

### For /jira-context-mcp
MCP servers should already be configured in:
- CLI: `~/.claude/settings.json`
- VSCode: `~/Library/Application Support/Code/User/mcp.json`

### For /review-with-context
```bash
# Install gh CLI if not present
brew install gh
gh auth login
```

## Common Workflows

### Starting New Ticket
```bash
# Get full context
/jira-context-mcp DWS-21607

# Review output for:
# - Blockers (can I start?)
# - Requirements (what to build?)
# - Risks (what to watch out for?)
# - Plan (how to approach?)
```

### PR Review
```bash
# Get ticket + PR context
/review-with-context sap-jam/ct#1997

# Check output for:
# - Requirements coverage
# - Missing edge cases
# - Integration concerns
# - Test suggestions
```

### Sprint Planning
```bash
# Analyze multiple tickets
/jira-context-mcp DWS-21607
/jira-context-mcp DWS-21608
/jira-context-mcp DWS-21609

# Compare:
# - Estimated effort
# - Risk levels
# - Dependencies
# - Complexity
```

## Tips

### jira-context (CLI)
- ✅ Use for quick lookups
- ✅ Good for scripting
- ✅ Fastest performance
- ⚠️ Less analysis depth

### jira-context-mcp (Enhanced)
- ✅ Use for planning phase
- ✅ Learn from incidents
- ✅ Get recommendations
- ⚠️ Slower (more thorough)

### review-with-context
- ✅ Use before merging PR
- ✅ Catches missing requirements
- ✅ Structured feedback
- ⚠️ Requires ticket in PR title/branch

## Troubleshooting

### "JIRA_TOKEN not set"
```bash
export JIRA_TOKEN='your-token-here'
```

### "MCP server not found"
Check MCP configuration in settings.json

### "Cannot fetch ticket"
Try alternate skill:
- CLI failed → try MCP version
- MCP failed → try CLI version

## Links

- **Repository**: https://github.com/pakcheong/sap-claude-skills
- **ServiceNow Guide**: SERVICENOW_INTEGRATION.md
- **Migration Summary**: MIGRATION_SUMMARY.md
