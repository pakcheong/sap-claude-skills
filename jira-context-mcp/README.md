# JIRA Context MCP Skill

## Overview

This skill performs deep analysis of JIRA tickets and their complete context using MCP (Model Context Protocol) tools, with automatic fallback to browser-based extraction when needed.

## Key Differences from Original jira-context

| Feature | Original jira-context | jira-context-mcp |
|---------|----------------------|------------------|
| Primary Method | JIRA CLI (`~/bin/jira`) | JIRA MCP tools |
| Authentication | Personal Access Token | SAP Auth MCP |
| Fallback | Browser MCP | SAP Auth MCP → Browser MCP |
| Rate Limiting | Shell script with retries | MCP error handling |
| Speed | Fast (direct CLI) | Fast (MCP tools) |
| Setup Required | CLI + PAT token | MCP servers configured |

## Core Features

- 📋 Fetch main ticket details via MCP
- 🔗 Analyze parent/epic hierarchy
- 👥 Find sibling tickets (same parent)
- 🔀 Track related/blocked/blocking tickets
- 📊 Generate structured context reports
- 🔍 **Deep dive into ALL links** found in tickets
- 🔄 Automatic fallback to browser extraction

## Usage

```bash
# Basic usage
/jira-context-mcp DWS-20925

# Before starting work to understand requirements
/jira-context-mcp DWS-21607

# Can be used as drop-in replacement for /jira-context
/jira-context-mcp <TICKET-ID>
```

## File Structure

```
jira-context-mcp/
├── SKILL.md           # Main skill file (instructions for Claude)
├── README.md          # This file
└── helpers/           # Future helper scripts (optional)
```

## Prerequisites

### Required MCP Servers

1. **sap-jira-mcp** - Main JIRA access
   - Installed at: Check with `npx @sfsfmcp/sap-jira-mcp@latest`
   - Config: Should be in MCP settings

2. **sap-auth-mcp** - SAP authentication for fallback
   - Installed at: Check with `npx @sfsfmcp/sap-auth-mcp@latest`
   - Config: Should be in MCP settings

### Check Installation

```bash
# For CLI Claude Code (~/.claude/settings.json)
cat ~/.claude/settings.json | grep -A5 mcpServers

# For VSCode (~/Library/Application Support/Code/User/mcp.json)
cat ~/Library/Application\ Support/Code/User/mcp.json
```

## Deep Link Analysis

**Philosophy**: If a link is in a ticket, it's there for a reason - investigate it thoroughly.

### What Links Are Extracted

The skill scans these locations for URLs:
- ✅ Ticket description
- ✅ All comments
- ✅ Custom fields
- ✅ Attachments metadata

### Supported Link Types

- 📚 **Wiki & Documentation** (wiki.one.int.sap, Confluence)
- 💻 **Code & Version Control** (GitHub, GitLab)
- 🎨 **Design & Collaboration** (Figma, Miro)
- 📄 **Documents** (Google Docs, Office 365)
- 🔗 **Related Issues** (JIRA tickets, GitHub issues)
- 📝 **Specifications** (API docs, OpenAPI specs)
- 💬 **Communication** (Slack threads, meeting notes)

### How It Works

For **each link found**:

1. **Access**: Use SAP Auth MCP to retrieve content
   ```
   mcp__sap-auth-mcp__sap_make_request(url=<URL>)
   ```

2. **Extract**: Pull out key information:
   - Requirements & acceptance criteria
   - Architecture & design decisions
   - Context & motivation
   - Dependencies & constraints

3. **Summarize**: Include findings in the context report

4. **Cross-reference**: Link information back to ticket requirements

## Fallback Strategy

### Three-Tier Fallback System

#### 1️⃣ **JIRA MCP** (Primary)
```python
mcp__sap-jira-mcp__get_issue(issue_key="DWS-20925")
```

**Pros**: 
- Fast, structured JSON
- Complete data access
- Built-in error handling

**When to use**: Always try this first

#### 2️⃣ **SAP Auth MCP + REST API** (Fallback 1)
```python
# Authenticate
mcp__sap-auth-mcp__sap_authenticate(
    entry_url="https://jira.tools.sap/",
    store_path="/Users/I522040/sap-auth-mcp/tmp"
)

# Make request
mcp__sap-auth-mcp__sap_make_request(
    method="GET",
    url="https://jira.tools.sap/rest/api/2/issue/DWS-20925?expand=names,schema"
)
```

**Pros**:
- Direct API access
- Bypasses MCP server issues
- Same data structure as JIRA MCP

**When to use**: If JIRA MCP returns error or is not available

#### 3️⃣ **Browser Extraction** (Fallback 2)
When APIs fail completely, extract from web UI:

```python
# Navigate to ticket
# (using whatever browser MCP tools are available)
# Extract visible text content from page structure
```

**Pros**:
- Always works (if authenticated)
- Bypasses API rate limits

**Cons**:
- Manual DOM extraction
- Less structured data
- May miss some fields

## Output Format

```markdown
### 🎫 Ticket Overview
**Main Ticket**: DWS-20925 [Workspace API] User Self Permission Check API
- **Type**: Story
- **Status**: In Progress
- **Priority**: High

### 📖 Description & Requirements
[Full description]

**Acceptance Criteria**:
- [Criteria 1]
- [Criteria 2]

### 🎯 Business Context
**Parent Story**: DWS-20312 Workspace API Enhancements
> Implement workspace permission management features

### 📚 Referenced Documentation & Links

**SAP Wiki: Workspace Permission Model**
- **Type**: Wiki
- **URL**: https://wiki.one.int.sap/wiki/x/abc123
- **Key Information**:
  - Architecture: RBAC with inherited permissions
  - 5 permission levels defined
  - Performance requirement: <100ms response time
- **Relevance**: Defines the permission model this API must implement

**Figma: Permission Check UI Flow**
- **Type**: Design
- **URL**: https://figma.com/file/xyz
- **Key Information**:
  - 3-step wizard for permission requests
  - Error states for denied permissions
- **Relevance**: UI that will consume this API endpoint

### 👥 Related Work
**Sibling Tickets**:
- DWS-20926: Workspace Permission List API - In Progress
- DWS-20927: Workspace Role Management - To Do

**Dependencies**:
- ⏳ **Blocked by**: DWS-20300 - Auth framework update

### 💡 Key Insights
- **Main Goal**: Allow users to query their own permissions in workspace
- **Edge Cases**: Handle inherited permissions, temporary permissions
- **Scope**: Only returns current user permissions, not other users
```

## Error Handling

- ✅ MCP error → Try SAP Auth MCP + REST API
- ✅ REST API error → Try browser extraction
- ✅ Ticket not found (404) → Skip and continue
- ✅ Missing fields → Mark as "Not specified"
- ✅ Partial ticket failures → Don't block overall analysis

## Performance Tips

1. **Single ticket**: Direct MCP call is fastest
2. **Multiple tickets**: Batch queries if MCP supports it
3. **Deep analysis**: Prioritize main ticket, use fallback for secondary ones
4. **CI/CD**: Cache results, don't refetch every run

## Migration from jira-context

If you're already using `/jira-context`:

```bash
# Old way (CLI-based)
/jira-context DWS-20925

# New way (MCP-based)
/jira-context-mcp DWS-20925
```

**Advantages of MCP version**:
- ✅ No CLI setup required
- ✅ Works in VSCode extension
- ✅ Better error handling
- ✅ Integrated authentication
- ✅ More reliable fallback strategy

**When to use original**:
- You already have JIRA CLI configured and working
- You prefer shell-based tools
- You need the absolute fastest performance

## Troubleshooting

### "MCP server not found" error

Check your MCP configuration:

**For CLI:**
```bash
cat ~/.claude/settings.json
```

**For VSCode:**
```bash
cat ~/Library/Application\ Support/Code/User/mcp.json
```

Ensure both `sap-jira-mcp` and `sap-auth-mcp` are configured.

### Authentication errors

Re-authenticate:
```python
mcp__sap-auth-mcp__sap_authenticate(
    entry_url="https://jira.tools.sap/",
    store_path="/Users/I522040/sap-auth-mcp/tmp"
)
```

### Rate limiting

MCP tools should handle this automatically, but if you see persistent rate limiting:
1. Wait 60 seconds
2. Use browser fallback
3. Check if cookies need refresh

## Dependencies

- **sap-jira-mcp**: JIRA access via MCP
- **sap-auth-mcp**: SAP authentication for fallback
- Browser MCP tools (built-in to Claude Code)
- Internet connection to SAP internal network

## Maintenance Log

- **2026-04-08**: Initial version created
  - MCP-based implementation
  - Three-tier fallback strategy
  - Deep link analysis support
  - Documentation complete
