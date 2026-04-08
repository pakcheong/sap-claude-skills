# Review with Context Skill

Comprehensive PR review with full JIRA context analysis.

## Usage

The skill accepts multiple PR identifier formats:

### Format 1: Full URL
```bash
/review-with-context https://github.wdf.sap.corp/sap-jam/ct/pull/1997
```

### Format 2: Repo#PR
```bash
/review-with-context sap-jam/ct#1997
```

### Format 3: Repo/PR
```bash
/review-with-context sap-jam/ct/1997
```

### Format 4: PR Number Only
Defaults to `sap-jam/ct` repository:
```bash
/review-with-context 1997
```

## How It Works

1. **Parse PR identifier** - Extracts repo and PR number from various formats
2. **Fetch PR details** - Gets PR metadata and diff using `gh` CLI
3. **Extract JIRA ticket** - Identifies ticket ID from PR title/branch name
4. **Get JIRA context** - Uses `/jira-context` skill to fetch complete ticket context
5. **Analyze changes** - Reviews code against requirements and business context
6. **Generate report** - Provides structured review with context-aware insights

## Features

✅ **Multi-repo support** - Works with any GitHub Enterprise repository
✅ **Flexible input** - Accepts URLs, repo/PR formats, or just numbers
✅ **JIRA integration** - Automatically fetches and analyzes ticket context
✅ **Comprehensive review** - Code quality + requirements coverage + integration concerns
✅ **Structured output** - Clear verdict with blockers, suggestions, and risk assessment

## Examples

### Review PR from different repo
```bash
/review-with-context another-org/another-repo#456
```

### Review with full URL
```bash
/review-with-context https://github.wdf.sap.corp/team/project/pull/789
```

### Quick review (default repo)
```bash
/review-with-context 1997
```

## File Structure

```
review-with-context/
├── skill.md              # Main skill definition
├── README.md             # This file
└── helpers/
    └── parse-pr-arg.sh   # PR argument parser
```

## Dependencies

- `gh` CLI with `GH_HOST=github.wdf.sap.corp`
- `/jira-context` skill for ticket analysis
- Access to GitHub Enterprise at `github.wdf.sap.corp`

## Output Format

The skill provides a structured review including:

- 🎫 **Context Summary** - JIRA ticket overview and key requirements
- ✅ **Requirements Assessment** - Coverage of acceptance criteria
- 📝 **PR Overview** - Changes summary and complexity
- 💻 **Code Quality Review** - Issues categorized by severity
- 🧪 **Test Coverage** - Test assessment and suggestions
- 🔗 **Integration Concerns** - Compatibility with related work
- 📊 **Final Verdict** - Approve/Request Changes/Comment with rationale

## Maintenance

- **2026-03-23**: Added multi-repo support with flexible PR formats
- **Original**: Single repo (sap-jam/ct) with numeric PR IDs only
