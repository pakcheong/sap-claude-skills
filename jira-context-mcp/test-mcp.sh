#!/bin/bash
# Test script for JIRA MCP tools
# Usage: ./test-mcp.sh <TICKET-ID>

TICKET_ID="${1:-DWS-20925}"

echo "Testing JIRA MCP access for ticket: $TICKET_ID"
echo "================================================"
echo ""

echo "✓ MCP tools should be available in Claude Code"
echo "✓ This script is just a placeholder for documentation"
echo ""
echo "To test in Claude Code, run:"
echo "  /jira-context-mcp $TICKET_ID"
echo ""
echo "The skill will automatically:"
echo "  1. Try JIRA MCP first"
echo "  2. Fall back to SAP Auth MCP + REST API if needed"
echo "  3. Fall back to browser extraction if all else fails"
echo ""
echo "Check ~/.claude/skills/jira-context-mcp/README.md for details"
