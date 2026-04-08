#!/bin/bash
# Parse PR argument into REPO and PR_NUM
# Usage: parse-pr-arg.sh <arg>
# Outputs: REPO=<repo> PR_NUM=<number>

arg="$1"

if [ -z "$arg" ]; then
    echo "ERROR: No PR argument provided" >&2
    exit 1
fi

# Case 1: Full GitHub URL
# Example: https://github.wdf.sap.corp/sap-jam/ct/pull/1997
if [[ "$arg" =~ github\.wdf\.sap\.corp/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
    REPO="${BASH_REMATCH[1]}"
    PR_NUM="${BASH_REMATCH[2]}"

# Case 2: Full github.com URL
# Example: https://github.com/org/repo/pull/123
elif [[ "$arg" =~ github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
    REPO="${BASH_REMATCH[1]}"
    PR_NUM="${BASH_REMATCH[2]}"

# Case 3: repo#PR format
# Example: sap-jam/ct#1997
elif [[ "$arg" =~ ^([^/#]+/[^/#]+)#([0-9]+)$ ]]; then
    REPO="${BASH_REMATCH[1]}"
    PR_NUM="${BASH_REMATCH[2]}"

# Case 4: repo/PR format
# Example: sap-jam/ct/1997
elif [[ "$arg" =~ ^([^/]+/[^/]+)/([0-9]+)$ ]]; then
    REPO="${BASH_REMATCH[1]}"
    PR_NUM="${BASH_REMATCH[2]}"

# Case 5: Just number (default to sap-jam/ct)
# Example: 1997
elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    REPO="sap-jam/ct"
    PR_NUM="$arg"
    echo "INFO: No repo specified, defaulting to $REPO" >&2

# Invalid format
else
    echo "ERROR: Invalid PR format: $arg" >&2
    echo "Supported formats:" >&2
    echo "  - Full URL: https://github.wdf.sap.corp/sap-jam/ct/pull/1997" >&2
    echo "  - Repo#PR: sap-jam/ct#1997" >&2
    echo "  - Repo/PR: sap-jam/ct/1997" >&2
    echo "  - Number: 1997 (assumes sap-jam/ct)" >&2
    exit 1
fi

# Output in a format easy to source
echo "REPO=$REPO"
echo "PR_NUM=$PR_NUM"
