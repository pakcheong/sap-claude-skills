---
name: review-with-context
description: Comprehensive PR review with full JIRA context analysis
tags: [review, pr, jira, context]
---

You are conducting a comprehensive PR review informed by complete JIRA context.

## Step 1: Get PR Information
Parse PR identifier from args: {{args}}

**Supported formats**:
1. Full URL: `https://github.wdf.sap.corp/sap-jam/ct/pull/1997`
2. Repo#PR: `sap-jam/ct#1997`
3. Repo/PR: `sap-jam/ct/1997`
4. PR number only (defaults to `sap-jam/ct`): `1997`

**Parse using helper script**:
```bash
# Parse the argument to extract repo and PR number
eval $(~/.claude/skills/review-with-context/helpers/parse-pr-arg.sh "{{args}}")

# Now $REPO and $PR_NUM are set
echo "Reviewing PR #$PR_NUM in $REPO"
```

Fetch PR details in parallel:
```bash
GH_HOST=github.wdf.sap.corp gh pr view $PR_NUM --repo $REPO --json title,body,number,author,additions,deletions,url,headRefName
GH_HOST=github.wdf.sap.corp gh pr diff $PR_NUM --repo $REPO
```

## Step 2: Extract JIRA Ticket ID
From PR title or branch name, extract ticket ID pattern (e.g., DWS-21607, BLDX-574).

## Step 3: Get Complete JIRA Context
**Use the `/jira-context` skill:**

Invoke: `/jira-context <TICKET-ID>`

This will provide:
- Ticket overview and requirements
- Business context (Epic/Initiative)
- Related work (siblings, dependencies)
- Implementation breakdown
- Key insights and edge cases

**Wait for the complete context before proceeding to code review.**

## Step 4: Analyze PR Against Context

Now review the code changes considering:

### 4.1 Requirements Coverage
- Does the PR implement the acceptance criteria?
- Are all required changes from the ticket description addressed?
- Is anything out of scope included?

### 4.2 Related Work Alignment
- Does it handle edge cases mentioned in related tickets?
- Does it integrate properly with sibling tickets' work?
- Are dependencies from blocking tickets properly addressed?

### 4.3 Implementation Scope
- Does it match the subtask breakdown (if applicable)?
- Is the scope appropriate for this ticket vs parent story?

## Step 5: Standard Code Review

Assess code quality:
- **Correctness**: Logic bugs, edge cases
- **Style**: Follows project conventions
- **Performance**: Efficiency concerns
- **Security**: Vulnerabilities (XSS, injection, etc.)
- **Tests**: Coverage and quality
- **Documentation**: Comments, API docs

## Step 6: Structured Review Output

### 🎫 Context Summary
**Ticket**: [TICKET-ID] Title
**Business Goal**: [One sentence from JIRA context]
**Key Requirements**: [2-3 bullet points]

### ✅ Requirements Assessment
- ✅ Requirement 1 - Implemented correctly
- ✅ Requirement 2 - Implemented correctly
- ⚠️ Requirement 3 - Partially implemented / Missing
- ❌ Edge case from [RELATED-TICKET] - Not handled

### 📝 PR Overview
**Changes**: [High-level summary]
**Files Modified**: [Count and key files]
**Complexity**: Low/Medium/High

### 💻 Code Quality Review

**Strengths**:
- [What's done well]

**Issues Found**:

#### 🔴 Critical Issues
- [Issue 1] - file.rb:123
  - Why it's critical
  - How to fix

#### 🟡 Suggestions
- [Suggestion 1] - file.rb:456
  - Context
  - Recommendation

#### 🟢 Nice-to-haves
- [Optional improvement]

### 🧪 Test Coverage
- ✅ Core functionality tested
- ⚠️ Missing tests for [edge case from JIRA]
- 💡 Suggested additional tests:
  - [Test case 1]
  - [Test case 2]

### 🔗 Integration Concerns
[Based on related tickets]
- Does it work with [SIBLING-TICKET]'s changes?
- Potential conflicts with [RELATED-TICKET]

### 📊 Final Verdict

**Decision**: ✅ Approve / 🔄 Request Changes / 💬 Comment

**Summary**: [2-3 sentences]

**Blockers** (if any):
- [Critical issue that must be fixed]

**Recommendations**:
- [Important but non-blocking suggestions]

**Risk Level**: Low / Medium / High

---

## Notes
- If `/jira-context` fails (rate limit/network), continue with available info
- Focus review on what matters for this specific ticket
- Don't nitpick - focus on correctness, security, and maintainability
- Reference specific line numbers when suggesting changes
