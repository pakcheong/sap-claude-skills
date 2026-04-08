---
name: jira-context
description: Deep dive into JIRA ticket context including parent, related, and sibling tickets
tags: [jira, context, analysis]
---

You are analyzing a JIRA ticket and its complete context. Follow these steps:

## Step 1: Get Main Ticket
Parse ticket ID from args: {{args}}

### Recommended Method: Helper Script with Auto-Fallback
```bash
~/.claude/skills/jira-context/helpers/fetch-with-fallback.sh <TICKET-ID>
```

This script automatically:
1. Tries API immediately
2. If rate limited (429), waits 5s and retries
3. If still limited, waits 15s more and retries
4. Suggests browser fallback if all retries fail

### Manual Methods (if helper fails):

#### Primary: CLI API
```bash
/Users/I522040/bin/jira get <TICKET-ID>
```

#### Fallback 1: Wait and Retry
If rate limited, wait 60 seconds and retry:
```bash
sleep 60 && /Users/I522040/bin/jira get <TICKET-ID>
```

You can run this in background while attempting fallback method 2.

#### Fallback 2: Browser MCP
Use browser tools to access JIRA web UI:
```
1. mcp__browser__browser_navigate to https://jira.tools.sap/browse/<TICKET-ID>
2. mcp__browser__browser_snapshot to get page elements
3. Look for key data in page title and DOM elements
```

Browser can extract:
- Title from page title or `[data-testid="issue.views.issue-base.foundation.summary.heading"]`
- Status from status badge elements
- Description from `.user-content-block` or description field
- Links from "Issue Links" section

### Extract from JSON response (API method):
- `fields.summary` - Title
- `fields.description` - Full description
- `fields.issuetype.name` - Type (Story/Bug/Task/Epic)
- `fields.status.name` - Status
- `fields.priority.name` - Priority
- `fields.parent` - Parent ticket (if exists)
- `fields.subtasks` - Subtasks array (if exists)
- `fields.issuelinks` - Related tickets array
- Acceptance criteria (usually in description)

### Check for Links and Deep Dive:

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

1. **Use browser or fetch to access the content**:
   ```
   # For web pages
   mcp__browser__browser_navigate("URL")
   mcp__browser__browser_snapshot(compact=false)

   # Or use fetch for text extraction
   mcp__fetch__fetch(url="URL", prompt="Extract key information, requirements, decisions, and context")
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

**Browser extraction workflow**:
```
1. Navigate to URL
2. Wait for page load (sleep 2-3 seconds if needed)
3. Take snapshot to get page structure
4. Extract headings, sections, key content
5. If content is too long, focus on:
   - Introduction/Overview
   - Requirements/Acceptance Criteria
   - Architecture/Design sections
   - Key decisions and rationale
   - Action items or next steps
```

**Link extraction patterns** (regex to find in JSON):
- `https?://[^\s\)"'\]]+` - Basic URL pattern
- Look in: `fields.description`, `fields.comment.comments[].body`, `fields.customfield_*`

## Step 2: Get Parent Ticket (User Story/Epic)
If `fields.parent.key` exists:
```bash
/Users/I522040/bin/jira get <PARENT-KEY>
```

This gives you the bigger user story or epic context.

## Step 3: Get Initiative/Epic Parent
If the parent ticket also has a parent, fetch it:
```bash
/Users/I522040/bin/jira get <GRANDPARENT-KEY>
```

This gives you the high-level business initiative.

## Step 4: Get Sibling Tickets
If there's a parent, search for other tickets with same parent:
```bash
/Users/I522040/bin/jira search "parent = <PARENT-KEY> ORDER BY created ASC" 20
```

This shows parallel work and helps understand the feature breakdown.

## Step 5: Get Related Tickets
Parse `fields.issuelinks` array and fetch important related tickets:

For each link where `type.name` is:
- "Blocks" / "Blocked by" - Dependencies
- "Relates to" - Context
- "Clones" / "Cloned by" - Similar work
- "Duplicates" - Same issue

```bash
/Users/I522040/bin/jira get <RELATED-KEY>
```

**Prioritize**: Blocks/Blocked-by > Relates-to > Others

## Step 6: Get Subtasks
If `fields.subtasks` exists, fetch key subtasks:
```bash
/Users/I522040/bin/jira get <SUBTASK-KEY>
```

This shows implementation breakdown.

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

**📚 Referenced Documentation & Links**:

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
> [What user need this addresses]

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

## Error Handling & Rate Limiting

### Rate Limit Strategy (HTTP 429)
1. **Background retry**: Start a 60-second wait-and-retry in background
2. **Browser fallback**: Immediately try browser MCP to get partial data
3. **Progressive degradation**: Continue analysis with whatever data is available
4. **User prompt**: As last resort, ask user to provide ticket details

### When to use each method:
- **CLI API** (primary): Fast, structured JSON, complete data
- **Wait + Retry** (rate limited): Automatic background recovery
- **Browser MCP** (fallback): Bypass API limits, partial manual extraction
- **User input** (last resort): When all automated methods fail

### Other Error Handling:
- If JIRA API returns 429 (rate limit), use fallback methods above
- If a ticket doesn't exist (404), note it and skip
- If fields are missing, note as "Not specified"
- Don't fail the entire analysis if one ticket fetch fails
- For related/parent/sibling tickets, gracefully degrade if rate limited

## Usage Examples
- `/jira-context DWS-21607` - Analyze single ticket
- `/jira-context DWS-21607` (before starting work) - Understand requirements
- Used automatically by `/review-with-context`
