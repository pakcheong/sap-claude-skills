#!/usr/bin/env python3
"""
Browser-based JIRA ticket extractor using MCP browser tools
Fallback when API is rate-limited

Usage: Called by jira-context skill when API fails
"""

def extract_from_browser_snapshot(ticket_id, snapshot_data):
    """
    Extract ticket info from browser snapshot

    Args:
        ticket_id: JIRA ticket ID (e.g., DWS-20925)
        snapshot_data: Output from mcp__browser__browser_snapshot

    Returns:
        dict with extracted fields
    """

    # Initialize result
    result = {
        "key": ticket_id,
        "fields": {
            "summary": None,
            "description": None,
            "status": None,
            "priority": None,
            "issuetype": None,
            "parent": None,
            "issuelinks": [],
            "subtasks": []
        }
    }

    # Parse snapshot for key elements
    # Common patterns:
    # - Description button: ref like "e47", text "Description"
    # - Issue Links: ref like "e62", text "Issue Links"
    # - Status: ref like "e36", text contains status
    # - Details: ref like "e40", text "Details"

    # In practice, you would:
    # 1. Click on Description to expand it
    # 2. Click on Issue Links to see related tickets
    # 3. Parse the expanded content

    return result


# Browser MCP extraction workflow
BROWSER_EXTRACTION_STEPS = """
Step-by-step browser extraction for JIRA tickets:

1. Navigate to ticket
   mcp__browser__browser_navigate(f"https://jira.tools.sap/browse/{ticket_id}")

2. Get initial snapshot
   snapshot = mcp__browser__browser_snapshot(compact=false)

3. Extract from page title (already visible)
   Title format: "[TICKET-ID] [Category] Summary - SAPJIRA"
   Example: "[DWS-20925] [Workspace API] User Self Permission Check API"

4. Find and extract key sections:

   a) Status (usually visible in snapshot):
      - Look for button with text like "In Progress", "Done", etc.
      - Usually ref like "e36" with status text

   b) Description (may need expansion):
      - Find button with text "Description"
      - Click to expand: mcp__browser__browser_click(ref="e47")
      - Get new snapshot to see expanded content

   c) Issue Links (may need expansion):
      - Find button/section with text "Issue Links"
      - Look for links to other tickets (DWS-XXXXX)
      - Extract related ticket IDs

   d) Details panel (usually expanded by default):
      - Contains: Type, Priority, Assignee, Labels
      - Look for links and text in Details section

5. Build partial ticket data:
   {
     "key": ticket_id,
     "fields": {
       "summary": extracted_from_title,
       "status": {"name": extracted_status},
       "issuelinks": [{"key": linked_id} for each found],
       ...
     }
   }

6. Note: Description may be truncated or hard to extract
   - Browser view may not show full formatted description
   - For critical tickets, ask user to provide description
   - Focus on: summary, status, links (most important for context)

Exit strategy:
- If description is critical and can't be extracted: ask user
- If links found: can still build sibling/related context
- Always extract at least: key, summary, status
"""

if __name__ == "__main__":
    print(BROWSER_EXTRACTION_STEPS)
