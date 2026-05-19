# Zoho Billing Quote Agent

Accelerate sales pipeline velocity by analyzing open quotes, identifying stalled deals, and recommending the next move for each quote.

> **Propose-Only Approach**: This plugin analyzes your quotes and recommends actions, but never directly modifies quotes or sends communications. All outputs are Markdown worklists for human review and approval.

## What It Does

**Quote Acceleration** — Analyzes all open quotes by staleness (a multi-factor score measuring deal health), ranks by expected close value, and recommends: send follow-up, apply discount, convert if accepted, or mark as lost.

### Staleness Scoring

The skill scores each quote 0.0 (fresh) to 1.0 (dead) based on:
- Days since last activity (most important — 35%)
- Quote age (25%)
- Follow-up history (15%)
- Customer conversion rate (15%)
- Match to lost deal patterns (10%)

## Setup Instructions

### Prerequisites
- Zoho Billing subscription account
- **Organization ID** (Zoho Billing Settings > Organization)
- **API Key** (Zoho Billing Settings > API Connections)

### Installation
1. Download/extract this plugin folder
2. Open Claude Code or Cowork, upload plugin folder
3. Provide **Organization ID** and **API Key** when prompted

### First Use

Invoke the Quote Acceleration skill:
- "Show me open quotes"
- "Which deals are stalling?"
- "Prioritize quotes for today"
- "Quote follow-up list"
- "What should sales work on today?"
- "Any quotes going cold?"

## The Skill Output

**Ranked worklist** showing:
- Customer name, quote amount, days open
- Staleness score (0.0 to 1.0)
- Expected close value (amount × probability)
- Reasoning (why this staleness)
- Recommended action (follow-up, discount, convert, mark lost)

**Status flags:**
- ✅ Accepted — Convert to invoice now
- ⚠️ Stalled (staleness 0.7-0.9) — Needs intervention
- ☠️ Dead (staleness > 0.9) — Mark as lost

### Example Output
```
📊 Quote Acceleration Worklist
━━━━━━━━━━━━━━━━━━━━━━━━━━
Total open quotes        : 47
Pipeline value           : $1,250,000
Estimated closeable      : $892,500 (71%)
Stalled deals (>0.7)     : 12 ($185,000)
Dead deals (>0.9)        : 5 ($42,000)
```

## MCP Actions Used

The Quote Acceleration skill uses these **Zoho Billing MCP actions**:

| Action | Purpose |
|--------|---------|
| `get_estimate_details_report` | Fetch all open quotes/estimates with amounts, dates, customer details |
| `get_progress_invoice_summary_report` | Retrieve quote-to-invoice conversion history and progress |
| `get_lost_opportunities_report` | Analyze historically lost quotes to identify failure patterns |

These are called via the custom **Zoho Billing MCP endpoint** configured in `.mcp.json`.

## Recommended Actions by Staleness

| Staleness | Action |
|-----------|--------|
| < 0.3 (Fresh) | No action — customer evaluating |
| 0.3–0.5 (Warm) | Send follow-up email |
| 0.5–0.7 (Stalled, high-value) | Apply 5-10% discount |
| 0.5–0.7 (Stalled, low-value) | Send follow-up email |
| 0.7–0.9 (Critical) | Send follow-up with deadline |
| > 0.9 (Dead) | Mark as lost, clean pipeline |
| Accepted | Convert to invoice immediately |

See `skills/quote-acceleration/references/workflow-details.md` for detailed algorithm and edge cases.

## Workflow Example

1. **Morning**: Run Quote Acceleration → Get ranked worklist
2. **Review**: Identify top 5 quotes by close value
3. **Act**:
   - Convert 1 accepted quote to invoice
   - Send follow-ups to 3 warm quotes
   - Apply discount to 1 stalled high-value quote
   - Mark 1 dead quote (45+ days) as lost
4. **Result**: Moved $150K to invoice, cleaned pipeline, touched 4 deals

## Propose-Only Approach

✓ **Analyzes and recommends**
✗ **Never modifies quotes, sends emails, or applies changes**

All outputs are Markdown proposals. Your sales team reviews and executes actions in Zoho Billing.

### Why Propose-Only?
✓ Full control — rep sees every recommendation
✓ Context aware — can factor in customer relationships
✓ Flexible — customize discount amounts and messaging
✓ Auditable — clear record of what was proposed vs executed
✓ Safe — no accidental bulk changes

## Data Access

**Requires read-only access to:**
- Quotes and estimates
- Customer data
- Subscription and payment history
- Customer activity logs

**Does NOT modify** any data or execute transactions.

## Troubleshooting

**Can't connect to Zoho Billing**
→ Verify Organization ID and API Key in `.mcp.json` env section

**Quotes show incomplete activity history**
→ Normal for new quotes. Plugin defaults to creation date; flags as "Limited data"

**Some quotes missing**
→ Plugin fetches only Draft, Sent, or Accepted status. Declined/lost quotes excluded.

## Future Enhancements (v0.2.0+)

- Configurable staleness thresholds
- Custom scoring weights
- Bulk action support ("Email all stalled quotes")
- Automation rules (auto-actions if staleness exceeds threshold)

## Support

- GitHub: https://github.com/zoho/zoho-billing-ai
- Zoho Billing Support

## License

See LICENSE file in plugin directory.
