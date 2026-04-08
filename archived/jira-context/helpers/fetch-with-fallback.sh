#!/bin/bash
# JIRA fetch with automatic fallback strategies
# Usage: fetch-with-fallback.sh DWS-12345
# Requires: JIRA_TOKEN environment variable or ~/bin/jira CLI configured

TICKET_ID="$1"
TOKEN="${JIRA_TOKEN}"  # Set via environment variable
BASE="https://jira.tools.sap"

if [ -z "$TICKET_ID" ]; then
    echo "Usage: $0 <TICKET-ID>"
    echo "Required: JIRA_TOKEN environment variable"
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "Error: JIRA_TOKEN environment variable not set"
    echo "Set it with: export JIRA_TOKEN='your-token'"
    exit 1
fi

# Try 1: Direct API call
echo "Attempting API call..." >&2
response=$(curl -s -w "\n__HTTP_CODE__:%{http_code}" -H "Authorization: Bearer $TOKEN" \
  "$BASE/rest/api/2/issue/$TICKET_ID?fields=summary,description,status,assignee,priority,issuetype,labels,created,updated,parent,subtasks,issuelinks")

http_code=$(echo "$response" | grep "__HTTP_CODE__:" | cut -d: -f2)

if [ "$http_code" = "200" ]; then
    echo "✓ API success" >&2
    echo "$response" | sed '/__HTTP_CODE__:/d'
    exit 0
fi

if [ "$http_code" = "429" ]; then
    echo "⚠ Rate limited (429), trying exponential backoff..." >&2

    # Try 2: Wait 5s and retry
    sleep 5
    response=$(curl -s -w "\n__HTTP_CODE__:%{http_code}" -H "Authorization: Bearer $TOKEN" \
      "$BASE/rest/api/2/issue/$TICKET_ID?fields=summary,description,status,assignee,priority,issuetype,labels,created,updated,parent,subtasks,issuelinks")
    http_code=$(echo "$response" | grep "__HTTP_CODE__:" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        echo "✓ API success after 5s wait" >&2
        echo "$response" | sed '/__HTTP_CODE__:/d'
        exit 0
    fi

    # Try 3: Wait 15s more and retry
    echo "⚠ Still rate limited, waiting 15s more..." >&2
    sleep 15
    response=$(curl -s -w "\n__HTTP_CODE__:%{http_code}" -H "Authorization: Bearer $TOKEN" \
      "$BASE/rest/api/2/issue/$TICKET_ID?fields=summary,description,status,assignee,priority,issuetype,labels,created,updated,parent,subtasks,issuelinks")
    http_code=$(echo "$response" | grep "__HTTP_CODE__:" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        echo "✓ API success after 20s total wait" >&2
        echo "$response" | sed '/__HTTP_CODE__:/d'
        exit 0
    fi

    # All retries failed
    echo "✗ API rate limited after retries" >&2
    echo "→ Suggest using browser fallback: mcp__browser__browser_navigate https://jira.tools.sap/browse/$TICKET_ID" >&2
    exit 2
fi

# Other HTTP error
echo "✗ API error: HTTP $http_code" >&2
exit 1
