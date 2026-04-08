# SAP Claude Skills

Collection of enhanced Claude Code skills for SAP development workflows.

## Repository Structure

```
/Users/I522040/git/github/sap-claude-skills/
├── jira-context/              # CLI-based JIRA analyzer (original)
│   ├── SKILL.md               # Skill definition
│   ├── README.md              # Documentation
│   ├── FALLBACK_STRATEGY.md   # Fallback strategies
│   └── helpers/               # Helper scripts
├── jira-context-mcp/          # MCP-based JIRA analyzer (enhanced)
│   ├── SKILL.md               # Skill definition
│   ├── README.md              # Documentation
│   └── test-mcp.sh            # Test script
├── review-with-context/       # PR review with JIRA context
│   ├── SKILL.md               # Skill definition
│   ├── README.md              # Documentation
│   └── helpers/               # Helper scripts
├── README.md                  # This file
└── SERVICENOW_INTEGRATION.md  # ServiceNow integration guide
```

## Installed Skills

### jira-context (CLI-based)
**Location**: `~/.claude/skills/jira-context` → symlink to repo

**Usage**: `/jira-context <TICKET-ID>`

**What it does**:
- Analyzes JIRA tickets using CLI tools
- Fetches parent, sibling, and related tickets
- Deep link analysis (wiki, GitHub, docs)
- Automatic fallback with retry logic
- Browser extraction when API rate limited

**Best for**:
- Users with JIRA CLI already configured
- Fast, direct API access
- Shell script integration

### jira-context-mcp (Enhanced)
**Location**: `~/.claude/skills/jira-context-mcp` → symlink to repo

**Usage**: `/jira-context-mcp <TICKET-ID>`

**What it does**:
- Analyzes JIRA tickets with actionable intelligence
- Provides risk assessment and mitigation strategies
- Mines comments for decisions and scope changes
- Identifies blockers with ETA analysis
- Generates day-by-day implementation plans
- Flags conflicts between ticket and documentation
- **ServiceNow incident analysis** (NEW)

**Key enhancements**:
- 🎯 Executive summary with immediate actions
- 🔍 Intelligent link prioritization
- 📊 Risk assessment with mitigation
- 💬 Deep comment mining
- ⏰ Timeline and ETA analysis
- 🚨 Conflict detection
- 📋 Definition of done checklist
- 🎬 Recommended implementation approach
- 🔥 Production incident learning (ServiceNow)

**Best for**:
- VSCode extension users
- Actionable insights over raw data
- Learning from production incidents
- Strategic planning and risk assessment

### review-with-context
**Location**: `~/.claude/skills/review-with-context` → symlink to repo

**Usage**: `/review-with-context <PR-URL>`

**What it does**:
- Comprehensive PR review with full JIRA context
- Automatically fetches related JIRA ticket
- Verifies code against acceptance criteria
- Checks for edge cases from related tickets
- Assesses integration with sibling work
- Provides structured review output

**Integrates with**:
- `/jira-context` or `/jira-context-mcp` for ticket analysis
- Supports multiple PR URL formats
- GitHub Enterprise integration

**Git**: Synced with https://github.com/pakcheong/sap-claude-skills

## Version History

### 2026-04-08
- **jira-context** (v1.0): CLI-based analyzer added to repo
- **jira-context-mcp** (v1.0 Enhanced): MCP-based with intelligence features
- **review-with-context** (v1.0): PR review with JIRA integration
- **ServiceNow integration**: Production incident analysis support

**Features**:
- Three JIRA analysis approaches (CLI, MCP, PR review)
- Actionable insights focus
- Risk assessment engine
- Stakeholder mapping
- Proactive recommendations
- Production incident learning

## Development Workflow

### Making Changes
```bash
cd /Users/I522040/git/github/sap-claude-skills
# Edit files
git add .
git commit -m "feat: your changes"
git push origin main
```

### Testing
```bash
# Test JIRA context analyzers
/jira-context DWS-21607        # CLI-based
/jira-context-mcp DWS-21607    # MCP-based (enhanced)

# Test PR review
/review-with-context https://github.wdf.sap.corp/sap-jam/ct/pull/1997
/review-with-context sap-jam/ct#1997
```

### Adding New Skills
1. Create new directory: `skill-name/`
2. Add `SKILL.md` with frontmatter
3. Add `README.md` with documentation
4. Commit and push
5. Symlink to `~/.claude/skills/`

## Prerequisites

### For jira-context (CLI-based)
- JIRA CLI: `~/bin/jira` installed and configured
- Personal Access Token (PAT) configured
- Set `JIRA_TOKEN` environment variable for helpers

### For jira-context-mcp (MCP-based)
- `sap-jira-mcp` - JIRA access via MCP
- `sap-auth-mcp` - SAP authentication

### For review-with-context
- GitHub CLI (`gh`) installed
- One of the JIRA context skills (jira-context or jira-context-mcp)

### Installation
See individual skill READMEs for setup instructions.

## Contributing

This is a personal skills repository. To contribute:
1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit PR with description

## License

Internal SAP use only.
