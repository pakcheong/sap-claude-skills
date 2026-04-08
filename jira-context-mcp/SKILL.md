---
name: jira-context-mcp
description: Deep dive into JIRA ticket context using MCP tools with browser fallback
tags: [jira, context, analysis, mcp]
---

You are analyzing a JIRA ticket and its complete context using MCP tools. Follow these steps:

## Step 1: Get Main Ticket
Parse ticket ID from args: {{args}}

### Primary Method: JIRA MCP
```
Use mcp__sap-jira-mcp__get_issue with the ticket key
```

This provides structured JSON with:
- `fields.summary` - Title
- `fields.description` - Full description
- `fields.issuetype.name` - Type (Story/Bug/Task/Epic)
- `fields.status.name` - Status
- `fields.priority.name` - Priority
- `fields.parent` - Parent ticket (if exists)
- `fields.subtasks` - Subtasks array (if exists)
- `fields.issuelinks` - Related tickets array
- Custom fields (sprint, epic, etc.)

### Fallback Method: Browser MCP (if JIRA MCP fails)
If MCP returns error or is not available, use browser tools:

```
1. mcp__sap-auth-mcp__sap_authenticate(
     entry_url="https://jira.tools.sap/",
     store_path="/Users/I522040/sap-auth-mcp/tmp"
   )
   
2. mcp__sap-auth-mcp__sap_make_request(
     method="GET",
     url="https://jira.tools.sap/rest/api/2/issue/<TICKET-ID>?expand=names,schema"
   )
```

If REST API also fails, use browser navigation:
```
1. Navigate to https://jira.tools.sap/browse/<TICKET-ID>
2. Extract page content
3. Look for key data in page elements:
   - Title from page title or summary heading
   - Status from status badge
   - Description from content blocks
   - Links from "Issue Links" section
```

### Extract Key Information

**IMPORTANT**: Any URL found in the ticket description, comments, or custom fields is there for a reason and MUST be investigated deeply.

After getting the ticket data, **systematically scan and extract all URLs** from:
- **Description field**: Primary source of documentation
- **Comments**: May contain clarifications, updates, or additional context
- **Custom fields**: Design docs, technical specs, related discussions
- **Attachments**: May have linked documents

**Do NOT filter or skip links** - investigate ALL of them:
- Wiki pages: `https://wiki.one.int.sap/*`, `https://*.confluence.*/*`
- GitHub: `https://github.tools.sap/*`, `https://github.com/*`
- Design tools: `https://www.figma.com/*`, `https://miro.com/*`
- Documents: Google Docs, Office 365, SharePoint links
- Issue trackers: Other JIRA tickets, GitHub issues
- Communication: Slack threads, email archives
- Specifications: API docs, Swagger/OpenAPI specs
- Any other URLs found

**For EACH link found**:

1. **Use SAP auth MCP to access the content**:
   ```
   # For SAP internal pages (wiki, confluence, etc.)
   mcp__sap-auth-mcp__sap_make_request(
     method="GET",
     url="<URL>",
     headers={"Accept": "application/json"}
   )
   
   # For wiki pages specifically, try Confluence API:
   # https://wiki.one.int.sap/wiki/rest/api/content/<PAGE-ID>?expand=body.storage
   ```

2. **Extract comprehensive information**:
   - **Requirements**: What needs to be built, acceptance criteria
   - **Architecture**: Technical design, system diagrams, data flow
   - **Decisions**: Why certain approaches were chosen, trade-offs
   - **Context**: Background, motivation, business goals
   - **Dependencies**: What this relies on or affects
   - **Timeline**: Deadlines, milestones, phasing
   - **Stakeholders**: Who's involved, who to contact

3. **Summarize findings**: Include in the final report under appropriate sections

## Step 2: Get Parent Ticket (User Story/Epic)
If parent exists, fetch it:
```
Use mcp__sap-jira-mcp__get_issue with parent key
```

This gives you the bigger user story or epic context.

## Step 3: Get Initiative/Epic Parent
If the parent ticket also has a parent, fetch it to get the high-level business initiative.

## Step 4: Get Sibling Tickets
If there's a parent, search for other tickets with same parent:
```
mcp__sap-jira-mcp__search_issues(
  jql="parent = <PARENT-KEY> ORDER BY created ASC",
  maxResults=20
)
```

This shows parallel work and helps understand the feature breakdown.

## Step 5: Get Related Tickets
Parse issue links and fetch important related tickets:

For each link where type is:
- "Blocks" / "Blocked by" - Dependencies
- "Relates to" - Context
- "Clones" / "Cloned by" - Similar work
- "Duplicates" - Same issue

```
Use mcp__sap-jira-mcp__get_issue for each related ticket key
```

**Prioritize**: Blocks/Blocked-by > Relates-to > Others

## Step 6: Get Subtasks
If subtasks exist, fetch key subtasks to show implementation breakdown.

## Step 7: Synthesize Context

Provide structured output:

### 🎫 Ticket Overview
**Main Ticket**: [TICKET-ID] Summary
- **Type**: Bug/Story/Task/Epic
- **Status**: Current status
- **Priority**: Priority level

### 📖 Description & Requirements
[Full description from ticket]

**Acceptance Criteria**:
- [Criteria 1]
- [Criteria 2]
- ...

### 🎯 Business Context
**Initiative/Epic**: [EPIC-ID] Title (if exists)
> [Brief description of business goal]

**Parent Story**: [PARENT-ID] Title (if exists)
> [What user need this addresses]

### 📚 Referenced Documentation & Links

For EACH link found in the ticket, provide:

**[Link 1 Title/URL]**
- **Type**: Wiki/GitHub/Figma/Doc/etc.
- **Key Information**:
  - [Main points, requirements, or decisions]
  - [Architecture or design highlights]
  - [Dependencies or constraints mentioned]
- **Relevance**: [Why this link matters for this ticket]

**[Link 2 Title/URL]**
- **Type**: ...
- **Key Information**: ...
- **Relevance**: ...

*(Repeat for all links found)*

**Summary of Documentation**:
- Overall context from all linked resources
- Key requirements extracted
- Design decisions confirmed
- Open questions or gaps identified

### 👥 Related Work
**Sibling Tickets** (same parent):
- [SIBLING-1]: Title - Status
- [SIBLING-2]: Title - Status

**Dependencies**:
- 🚫 **Blocks**: [TICKET-ID] - Brief description
- ⏳ **Blocked by**: [TICKET-ID] - Brief description

**Related Tickets**:
- [RELATED-1]: Title - Why relevant
- [RELATED-2]: Title - Why relevant

### 📋 Implementation Breakdown
**Subtasks**:
- [SUBTASK-1]: Title - Status
- [SUBTASK-2]: Title - Status

### 💡 Key Insights
- **Main Goal**: [One sentence - what we're trying to achieve]
- **Edge Cases**: [From related tickets]
- **Dependencies**: [What needs to happen first/after]
- **Scope**: [What's in/out of scope]

## Error Handling & Fallback Strategy

### Fallback Priority:
1. **JIRA MCP** (primary): Fast, structured JSON, complete data
2. **SAP Auth MCP + REST API** (fallback 1): Direct API access with authentication
3. **Browser extraction** (fallback 2): Manual extraction from web UI
4. **User input** (last resort): When all automated methods fail

### Error Handling:
- If JIRA MCP fails, immediately try SAP Auth MCP with REST API
- If REST API fails, fall back to browser extraction
- If a ticket doesn't exist (404), note it and skip
- If fields are missing, note as "Not specified"
- Don't fail the entire analysis if one ticket fetch fails
- For related/parent/sibling tickets, gracefully degrade if unavailable

### Browser Extraction Details:
When falling back to browser:
1. Ensure SAP authentication is valid
2. Navigate to ticket URL
3. Wait for page load (2-3 seconds)
4. Extract visible content from:
   - Page title (contains ticket ID and summary)
   - Status badge/indicator
   - Description section
   - Issue Links section
   - Comments section (if expanded)

## Usage Examples
- `/jira-context-mcp DWS-21607` - Analyze single ticket
- `/jira-context-mcp DWS-21607` (before starting work) - Understand requirements
- Can be used as replacement for `/jira-context` with MCP support
