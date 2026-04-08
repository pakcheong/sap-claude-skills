# ServiceNow Integration for jira-context-mcp

## What Was Added

### Link Detection & Prioritization
- ServiceNow incident links now detected as **HIGH PRIORITY**
- Regex patterns added:
  - `https?://itsm\.services\.sap/now/[^\s\)"'\]]+/incident/[^\s\)"'\]]+`
  - `https?://itsm\.services\.sap/[^\s\)"'\]]+`

### API Integration
```bash
# ServiceNow incident fetch via SAP Auth MCP
mcp__sap-auth-mcp__sap_make_request(
  method="GET",
  url="https://itsm.services.sap/api/now/table/incident/<ID>?sysparm_display_value=true",
  headers={"Accept": "application/json"}
)
```

### Information Extracted from Incidents

**Critical Data**:
- Incident summary & description (what broke, when, impact)
- Priority/Severity (P1/P2/P3)
- Affected systems
- Workarounds applied
- Root cause analysis
- Resolution notes
- Related incidents (pattern detection)
- Customer impact
- Timeline (reported → resolved, SLA status)

### Output Format
Incidents are flagged with 🔥 and include:

```markdown
#### 🔥 [ServiceNow] Production Incident - Permission Check Timeout
**URL**: https://itsm.services.sap/now/cwf/agent/record/incident/cfa604...
**Incident**: INC0123456 | **Priority**: P2 - High | **Status**: Resolved

**What Happened**:
- Permission checks timing out (>5 seconds) during peak load
- Affected 500+ users on 2026-03-10 between 14:00-15:30 UTC

**Root Cause**:
- Database connection pool exhausted under load
- Missing index on workspace_permissions.user_id
- Recursive queries not optimized

**Resolution Applied**:
- Added database index (4.2s → 45ms)
- Increased connection pool: 10 → 50
- Implemented 5-minute result caching

**Impact on This Ticket**:
- 🔴 CRITICAL: Must implement same optimizations
- Required: Database indexes on all permission queries
- Required: Load testing with >1000 concurrent users
- Edge case: Recursive inheritance needs depth limit

**Lessons Learned**:
- Implement circuit breaker pattern
- Add request timeout at 200ms
- Test with production-scale data
```

## Why This Matters

### Learning from Production
- **Real-world requirements**: Incidents reveal actual production constraints
- **Proven solutions**: Learn what worked to fix similar issues
- **Edge cases**: Discover failure modes that testing missed
- **Performance baselines**: Real metrics from production incidents

### Risk Prevention
- **Avoid repeat incidents**: Apply preventive measures from past issues
- **Inform implementation**: Design with production lessons in mind
- **Critical requirements**: Identify must-have safeguards

### Example Impact
If ticket references incident about permission timeout:
- ✅ **Know**: Database indexes are mandatory (proven in production)
- ✅ **Know**: Query performance must be <100ms (real requirement)
- ✅ **Know**: Load testing required (production-scale data)
- ✅ **Know**: Circuit breaker pattern needed (learned from incident)

## Usage Example

```bash
/jira-context-mcp DWS-21607
```

If DWS-21607 description or comments contain:
```
Related to incident: https://itsm.services.sap/now/cwf/agent/record/incident/cfa604732b62ba50b4ecf3b4c191bf87
```

Skill will:
1. Detect the incident link
2. Flag as 🔥 HIGH PRIORITY
3. Fetch incident details via ServiceNow API
4. Extract root cause, resolution, lessons
5. Include in "Referenced Documentation" section
6. Flag critical requirements from incident
7. Update risk assessment based on incident

## Supported Link Types (Updated)

1. **HIGH PRIORITY**:
   - Wiki specs/design docs
   - GitHub PRs/issues
   - Figma/design tools
   - Technical RFCs
   - **🔥 ServiceNow incidents** ← NEW

2. **MEDIUM PRIORITY**:
   - JIRA tickets
   - Meeting notes
   - ServiceNow requests (non-incidents)

3. **LOW PRIORITY**:
   - General docs
   - Reference materials

## Benefits

### For Developers
- **Context-aware development**: Understand why certain patterns are critical
- **Proven solutions**: Don't reinvent the wheel, use what worked
- **Risk awareness**: Know what can go wrong in production

### For Planning
- **Realistic estimates**: Factor in production-hardening work
- **Requirement discovery**: Uncover hidden requirements from incidents
- **Test planning**: Know what scenarios to test based on past failures

### For Quality
- **Preventive measures**: Build in safeguards before they're needed
- **Performance targets**: Real-world metrics, not guesses
- **Edge case coverage**: Test scenarios that actually failed in production

## Git Commit

```
commit 4c20e6d
feat: add ServiceNow incident analysis support

- Add ServiceNow incident links as HIGH PRIORITY
- Extract incident details: root cause, resolution, preventive measures
- Flag incidents with 🔥 for immediate attention
- Include incident impact analysis in ticket context
```

## Next Steps

1. Test with real incident link
2. Verify ServiceNow API access
3. Confirm incident data extraction
4. Validate output format

## Notes

- Incidents require SAP Auth MCP for API access
- API endpoint: `/api/now/table/incident/<ID>?sysparm_display_value=true`
- Response includes full incident lifecycle data
- Flagged as 🔥 to highlight production impact
