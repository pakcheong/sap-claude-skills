# SAP Claude Skills

Collection of enhanced Claude Code skills for SAP development workflows.

## Repository Structure

```
/Users/I522040/git/github/sap-claude-skills/
├── jira-context-mcp/          # Enhanced JIRA ticket analyzer
│   ├── SKILL.md               # Main skill definition
│   ├── README.md              # Documentation
│   └── test-mcp.sh            # Test script
└── README.md                  # This file
```

## Installed Skills

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

**Key enhancements over basic version**:
- 🎯 Executive summary with immediate actions
- 🔍 Intelligent link prioritization
- 📊 Risk assessment with mitigation
- 💬 Deep comment mining
- ⏰ Timeline and ETA analysis
- 🚨 Conflict detection
- 📋 Definition of done checklist
- 🎬 Recommended implementation approach

**Git**: Synced with https://github.com/pakcheong/sap-claude-skills

## Version History

- **v1.0 Enhanced** (2026-04-08): Initial release with full intelligence features
  - Actionable insights focus
  - Risk assessment engine
  - Stakeholder mapping
  - Proactive recommendations

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
# Test in Claude Code
/jira-context-mcp DWS-21607
```

### Adding New Skills
1. Create new directory: `skill-name/`
2. Add `SKILL.md` with frontmatter
3. Add `README.md` with documentation
4. Commit and push
5. Symlink to `~/.claude/skills/`

## Prerequisites

### MCP Servers Required
- `sap-jira-mcp` - JIRA access
- `sap-auth-mcp` - SAP authentication

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
