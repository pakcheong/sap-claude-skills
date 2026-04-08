# JIRA Context Skill - Enhanced with Fallback Strategies

## Overview

This skill performs deep analysis of JIRA tickets and their complete context (parent, sibling, and related tickets). Now enhanced with automatic fallback support when API rate limits are hit.

## Core Features

- 📋 Fetch main ticket details
- 🔗 Analyze parent/epic hierarchy
- 👥 Find sibling tickets (same parent)
- 🔀 Track related/blocked/blocking tickets
- 📊 Generate structured context reports
- 🔍 **Deep dive into ALL links** found in tickets

## Usage

```bash
# Basic usage
/jira-context DWS-20925

# Before starting work to understand requirements
/jira-context DWS-21607

# Automatically called by /review-with-context
/review-with-context <PR-URL>
```

## File Structure

```
jira-context/
├── skill.md                      # Main skill file (instructions for Claude)
├── README.md                     # This file
├── FALLBACK_STRATEGY.md          # Detailed fallback strategy documentation
└── helpers/
    ├── fetch-with-fallback.sh    # API call script with auto-retry
    └── browser_extractor.py      # Browser extraction reference implementation
```

## Deep Link Analysis

**New in this version**: The skill now **deeply investigates ALL links** found in JIRA tickets.

### Philosophy

**If a link is in a ticket, it's there for a reason** - investigate it thoroughly. Don't skip or filter links.

### What Links Are Extracted

The skill scans these locations for URLs:
- ✅ Ticket description
- ✅ All comments
- ✅ Custom fields
- ✅ Attachments metadata

### Supported Link Types (All of them!)

- 📚 **Wiki & Documentation**
  - SAP Wiki (`wiki.one.int.sap`)
  - Confluence (`*.atlassian.net`)
  - GitHub Pages (`pages.github.tools.sap`)

- 💻 **Code & Version Control**
  - GitHub repos (`github.com`, `github.tools.sap`)
  - GitLab, Bitbucket
  - Code review tools

- 🎨 **Design & Collaboration**
  - Figma designs
  - Miro boards
  - Lucidchart diagrams

- 📄 **Documents**
  - Google Docs/Sheets
  - Office 365/SharePoint
  - PDF documents

- 🔗 **Related Issues**
  - Other JIRA tickets
  - GitHub issues/PRs
  - ServiceNow tickets

- 📝 **Specifications**
  - API documentation
  - Swagger/OpenAPI specs
  - Technical RFCs

- 💬 **Communication**
  - Slack threads
  - Email archives
  - Meeting notes

### How It Works

For **each link found**:

1. **Access**: Use browser MCP or fetch tool to retrieve content
2. **Extract**: Pull out key information:
   - Requirements & acceptance criteria
   - Architecture & design decisions
   - Context & motivation
   - Dependencies & constraints
   - Timeline & milestones
   - Stakeholders & contacts
3. **Summarize**: Include findings in the context report
4. **Cross-reference**: Link information back to ticket requirements

### Example Output

When links are found, you'll see detailed analysis:

```markdown
📚 Referenced Documentation & Links:

**SAP Wiki: Workspace Permission Model**
- Type: Wiki
- URL: https://wiki.one.int.sap/wiki/x/abc123
- Key Information:
  - Architecture: RBAC with inherited permissions from parent workspaces
  - 5 permission levels: Owner, Admin, Editor, Viewer, Guest
  - Permission checks must complete within 100ms (P95)
- Relevance: Defines the permission model this API must implement

**Figma: Permission Check UI Flow**
- Type: Design
- URL: https://figma.com/file/xyz
- Key Information:
  - 3-step wizard for permission requests
  - Error states for denied permissions
  - Uses SAP Fiori components
- Relevance: UI that will consume this API endpoint

**GitHub Issue: Auth Framework Update**
- Type: Related Issue
- URL: https://github.tools.sap/org/repo/issues/456
- Key Information:
  - New JWT token format required
  - Migration deadline: 2026-04-01
  - Breaking change in auth headers
- Relevance: Blocking dependency - must wait for auth update

Summary of Documentation:
- Permission model well-defined with 5 levels
- Performance requirement: <100ms response time
- Auth framework upgrade is a blocker (by April 1)
- UI design ready and waiting for API implementation
```

## Fallback Strategy (Solving API Rate Limits)

### Problem
SAP JIRA API frequently hits 429 rate limits, blocking automated access.

### Solution Priority

#### 1️⃣ **Auto-Retry Script** (Recommended)
```bash
~/.claude/skills/jira-context/helpers/fetch-with-fallback.sh DWS-20925
```
- Try API immediately
- Retry after 5s
- Retry after 15s more
- Total time: max 20 seconds

**Exit codes**:
- `0`: Success (outputs JSON)
- `1`: HTTP error
- `2`: Rate limited (suggests browser fallback)

#### 2️⃣ **Browser MCP** (Fallback)
When API is completely unavailable, use browser tools:

```python
# 1. Navigate to ticket
mcp__browser__browser_navigate("https://jira.tools.sap/browse/DWS-20925")

# 2. Get snapshot
mcp__browser__browser_snapshot(compact=False)

# 3. Extract basic info from title
# Title format: "[TICKET-ID] [Category] Summary"

# 4. Click to expand Description, Issue Links sections
# 5. Extract visible text content
```

**Can extract**:
- ✅ Ticket ID and Summary (from page title)
- ✅ Status (from status badge)
- ✅ Related links (from Issue Links section)
- ⚠️ Description (may be truncated)

#### 3️⃣ **Ask User** (Last Resort)
If all automated methods fail, prompt user:
```
"API rate limited and browser extraction failed.
Please visit https://jira.tools.sap/browse/DWS-20925
and provide the ticket description and acceptance criteria."
```

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

### 👥 Related Work
**Sibling Tickets**:
- DWS-20926: Workspace Permission List API
- DWS-20927: Workspace Role Management

**Dependencies**:
- ⏳ **Blocked by**: DWS-20300 - Auth framework update

**📚 Documentation**:
- **Wiki**: https://wiki.one.int.sap/wiki/x/abc123
  - Architecture overview: Workspace permission model
  - Key design decisions: Role-based access control
- **Figma**: https://figma.com/file/xyz
  - UX flows for permission checking UI

### 💡 Key Insights
- **Main Goal**: Allow users to query their own permissions in workspace
- **Edge Cases**: Handle inherited permissions, temporary permissions
- **Scope**: Only returns current user permissions, not other users
```

## Error Handling

- ✅ API 429 → Auto-retry + browser fallback
- ✅ Ticket not found (404) → Skip and continue
- ✅ Missing fields → Mark as "Not specified"
- ✅ Partial ticket failures → Don't block overall analysis

## Performance Recommendations

1. **Single ticket**: Direct call, auto-handles retries
2. **Multiple tickets**: Space calls 5-10s apart to avoid consecutive rate limits
3. **Deep analysis**: Prioritize main ticket, use browser for secondary ones
4. **CI/CD**: Cache results, don't refetch every run

## Dependencies

- JIRA CLI: `~/bin/jira` (requires PAT token)
- Browser MCP: Built-in to Claude Code
- Python 3: For JSON processing
- curl: For API calls

## Maintenance Log

- **2026-03-23**: Added complete fallback strategy
  - New `fetch-with-fallback.sh`
  - New browser extraction approach
  - Updated skill.md to support multi-strategy

- **Original version**: Direct API call only
