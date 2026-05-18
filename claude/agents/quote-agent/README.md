# Zoho Billing Quote Agent

Accelerate sales pipeline velocity by analyzing open quotes, identifying stalled deals, and recommending the next move for each quote.

> **Propose-Only Approach**: This plugin analyzes your quotes and recommends actions, but never directly modifies quotes or sends communications. All outputs are Markdown worklists for human review and approval.

## What It Does

This plugin provides one focused skill for quote acceleration:

**Quote Acceleration** — Analyzes all open quotes and estimates by staleness (a multi-factor score measuring how "dead" a deal is), ranks them by expected close value, and recommends the next action: send a follow-up email, apply a strategic discount, convert if accepted, or mark as lost.

The skill considers:
- **Days since last activity** (most important — how long since any engagement?)
- **Quote age** (older quotes have lower close probability)
- **Follow-up history** (multiple touches without response = declining interest)
- **Customer conversion rate** (some customers always convert; others rarely do)
- **Historical patterns** (matches to quotes that previously failed)

All recommendations are presented as an interactive Markdown worklist ranked by revenue impact.

## Setup Instructions

### Prerequisites

- Access to a Zoho Billing subscription account
- Your **Zoho Organization ID** (find in Zoho Billing Settings > Organization)
- A **Zoho API Key** (generate in Zoho Billing Settings > API Connections)

### Installation

1. **Download or extract this plugin folder** from the GitHub repository.

2. **Open Claude Code or Cowork**, then upload this plugin folder.

3. **Configure Zoho Billing connection**:
   - When prompted, provide your **Organization ID** and **API Key**.
   - The plugin will automatically connect to your Zoho Billing data via the custom MCP endpoint.

### First Use

Once installed, invoke the Quote Acceleration skill:

- **"Show me open quotes"** — Get a ranked analysis of all open quotes
- **"Which deals are stalling?"** — Highlight quotes at risk of being lost
- **"Prioritize quotes"** — Rank by expected close value
- **"Quote follow-up list"** — Get a list of quotes needing follow-up
- **"What should sales work on today?"** — Daily worklist
- **"Any quotes going cold?"** — Flag quotes losing momentum

## The Quote Acceleration Skill

### What It Analyzes

**Input:** All open quotes/estimates in Zoho Billing with statuses: Draft, Sent, or Accepted

**Analysis:** For each quote, calculates:
1. **Staleness Score** (0.0 = fresh, 1.0 = dead) — based on activity history, age, engagement, customer patterns
2. **Expected Close Value** — quote amount × probability of close
3. **Recommended Action** — what to do next (follow-up, discount, convert, mark lost)

**Output:** Ranked worklist (see Output Format section below)

### Staleness Scoring

The plugin calculates staleness on a 0.0 (fresh) to 1.0 (dead) scale:

| Signal | Weight | What It Measures |
|--------|--------|------------------|
| Days since last activity | 35% | How long since the customer or sales rep touched the quote? |
| Days since created | 25% | How old is this quote? (Older = lower close probability) |
| Follow-ups without response | 15% | How many times has sales reached out with no reply? |
| Customer conversion rate | 15% | What % of this customer's past quotes converted to paid? |
| Matches lost patterns | 10% | Does this quote match characteristics of deals that failed? |

**Example:**
- A quote sent 5 days ago to a customer who converts 80% of quotes → **Staleness: 0.10** (Fresh, high confidence)
- A quote sent 40 days ago to a customer who never converted, with 0 follow-ups → **Staleness: 0.90** (Dead, mark as lost)

### Recommended Actions

Based on staleness tier, the plugin recommends:

| Staleness | Tier | Recommended Action |
|-----------|------|-------------------|
| < 0.3 | Fresh | **No action** — customer is still evaluating, give time |
| 0.3–0.5 | Warm | **Send follow-up email** — gentle reminder with next steps |
| 0.5–0.7 (high value) | Stalled | **Apply discount** — offer concession (5–10%) to accelerate |
| 0.5–0.7 (low value) | Stalled | **Send follow-up email** — last-chance reminder |
| 0.7–0.9 | Critical | **Send follow-up email** or **manual review** — high-risk, needs intervention |
| > 0.9 | Dead | **Mark as lost** — no activity 30+ days, clean pipeline |
| Accepted | — | **Convert to invoice** — customer said yes, close the deal |

### The Output

**Example worklist (abbreviated):**

```
📊 Quote Acceleration Worklist — May 18, 2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total open quotes        : 47
Total pipeline value     : $1,250,000
Estimated closeable      : $892,500 (71%)
Stalled deals (>0.7)     : 12 ($185,000)
Dead deals (>0.9)        : 5 ($42,000)
```

| # | Customer | Quote # | Amount | Days Open | Staleness | Expected Close Value | Action |
|---|---|---|---|---|---|---|---|
| 1 | ✅ Acme Corp | QT-5823 | $150,000 | 8 | 0.0 | $150,000 | **Convert to invoice** |
| 2 | TechStart Inc | QT-5901 | $87,500 | 5 | 0.15 | $74,375 | No action (yet) |
| 3 | ⚠️ DataFlow | QT-5789 | $95,000 | 22 | 0.62 | $36,100 | **Apply 7% discount** |
| 4 | ☠️ Old Industries | QT-5401 | $42,000 | 45 | 0.95 | $2,100 | **Mark as lost** |

See `skills/quote-acceleration/references/output-format.md` for full examples and explanation of the output table.

## Workflow Example

### Typical Sales Rep Day

1. **Morning**: Run Quote Acceleration → Get ranked worklist of 47 open quotes
2. **Review**: Identify top 5 by expected close value → All are fresh or warm (low staleness)
3. **Action 1**: Convert 1 accepted quote (Acme Corp, $150K) to invoice
4. **Action 2**: Send follow-up to 3 warm quotes with standard reminder message
5. **Action 3**: Review 2 stalled quotes (>0.7 staleness) → decide to apply discount to high-value one
6. **Action 4**: Mark 1 dead quote (>0.9 staleness, 50+ days old) as lost to clean pipeline
7. **Result**: Moved $150K quote to invoice, sent 3 follow-ups, applied 1 discount, cleaned 1 dead deal

### Full Workflow

1. **Run Quote Acceleration** → Analyze all open quotes
2. **Review ranked worklist** → Executive summary + detailed table
3. **Filter by action type**:
   - Quotes to convert (accepted) → Convert to invoice in Zoho
   - Quotes to follow-up (warm/stalled, responsive) → Send email via Zoho
   - Quotes to discount (stalled, high-value) → Update quote with discount, re-send
   - Quotes to close (dead, no activity) → Mark as lost/declined in Zoho
4. **Manage consolidations** → Group customers with multiple quotes for upsell review

All actions happen in Zoho Billing after reviewing the plugin's recommendations.

## Propose-Only Approach

This plugin **identifies** and **recommends** actions, but **never**:
- Sends emails to customers
- Applies discounts or modifies quotes
- Converts quotes to invoices
- Marks quotes as lost or accepted
- Modifies any quote data

All outputs are Markdown worklists for human review. Your sales team reviews the analysis, approves the recommendations, and executes actions in Zoho Billing.

### Why Propose-Only?

✓ **Full control** — Sales rep sees every recommendation before acting
✓ **Context awareness** — Rep can factor in customer relationships and ongoing negotiations
✓ **Flexibility** — Discount amounts and follow-up messaging can be customized per customer
✓ **Auditability** — Clear record of what was recommended vs. what was actually executed
✓ **Safety** — No accidental bulk modifications or miscommunications

## How It Works

The plugin uses the Zoho Billing MCP server to access:

- **Quote/Estimate reports** — get_estimate_details_report (all open quotes)
- **Progress invoice data** — get_progress_invoice_summary_report (conversion tracking)
- **Lost opportunities** — get_lost_opportunities_report (failure patterns)
- **Customer details** — customer info for context
- **Subscription history** — to assess customer's payment and conversion patterns

Each run fetches fresh data and produces a current worklist.

### Edge Cases Handled

- **No open quotes** → Reports "Pipeline is empty—review lead generation"
- **Customer with no history** → Uses organization-wide average conversion rate
- **Draft quotes (never sent)** → Flags "Send quote" as primary action
- **Multiple quotes per customer** → Groups with note "Consolidation opportunity"
- **Zero-amount quotes** → Excluded; flagged for data cleanup
- **API temporarily unavailable** → Proceeds with available data, notes missing sources

## Data Access

This plugin requires **read-only access** to:
- Quotes and estimates
- Customer data
- Subscription and payment history
- Invoice records
- Customer activity logs

It does **not** modify any data or execute transactions.

## Customization for v0.2.0+

Future versions may include:
- **Configurable staleness thresholds** — teams can adjust which scores trigger "stalled" vs "dead"
- **Custom scoring weights** — organizations can increase/decrease emphasis on specific signals (e.g., weight customer history more heavily)
- **Bulk action support** — one-click "Email all stalled quotes", "Mark all dead deals as lost"
- **Automation rules** — auto-execute actions if staleness exceeds a threshold

For v0.1.0, all scoring uses built-in defaults and all actions are propose-only.

## Troubleshooting

**Plugin doesn't connect to Zoho Billing**
→ Verify your **Organization ID** and **API Key** are correct. Check in Zoho Billing Settings > Organization and Settings > API Connections.

**Quotes show no last activity date**
→ Legitimate for new quotes. Plugin defaults to creation date and flags as "Limited data".

**Recommendations seem generic**
→ The plugin uses organization-wide averages for customers with no prior quote history. As more data accumulates, recommendations become more personalized.

**Some quotes are missing**
→ The skill fetches only quotes with status Draft, Sent, or Accepted. Declined and lost quotes are intentionally excluded (already decided).

## Support

For issues or feature requests:
- Check the GitHub repository: https://github.com/zoho/zoho-billing-ai
- Contact your Zoho Billing support team
- Reach out to the plugin maintainers

## Version History

**v0.1.0** (May 2026)
- Initial release
- Quote Acceleration skill with staleness scoring
- Ranked worklist output
- Propose-only recommendations
- Support for 6 trigger phrases

## License

See LICENSE file in the plugin directory, or visit https://github.com/zoho/zoho-billing-ai for license details.
