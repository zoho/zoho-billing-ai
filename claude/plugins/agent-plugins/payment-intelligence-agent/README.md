# Payment Intelligence Agent

Predict and prevent involuntary churn by identifying payment failures early and recommending proactive interventions.

> **Propose-Only Approach**: This plugin identifies at-risk subscriptions and recommends recovery actions, but never directly modifies subscriptions or sends communications. All outputs are Markdown proposals for human review and approval.

## What It Does

This plugin provides four focused skills for payment risk management:

1. **Card Expiry Detector** — Flags subscriptions with cards expiring within 30 days to enable proactive payment updates before failures occur.

2. **Payment Failure Analyzer** — Analyzes payment failures from the last 30 days, categorizes them by error type, and reveals systemic gateway issues.

3. **Dunning Risk Assessor** — Identifies all subscriptions in dunning status or at risk of entering dunning, then segments by risk level for prioritized recovery.

4. **Recovery Recommender** — Recommends tailored recovery actions for each at-risk subscription using your company's decision matrix. Produces propose-only Markdown reports for human review.

## Setup Instructions

### Prerequisites

- Access to a Zoho Billing subscription account
- Your **Zoho Organization ID** (find this in Zoho Billing Settings > Organization)
- A **Zoho API Key** (generate in Zoho Billing Settings > API Connections)

### Installation

1. **Download the plugin** from the GitHub repository or extract the plugin folder.

2. **Open Claude Code or Cowork**, then upload this plugin folder.

3. **Configure Zoho Billing connection**:
   - When prompted, provide your **Organization ID** and **API Key**.
   - The plugin will automatically connect to your Zoho Billing data.

### First Use

Once installed, you can run any of the four skills:

- **Card Expiry Detector**: "Check for cards expiring soon" or "Flag cards expiring in next 30 days"
- **Payment Failure Analyzer**: "Analyze recent payment failures" or "Show me what's causing payment issues"
- **Dunning Risk Assessor**: "Which subscriptions are at risk?" or "Show me dunning customers"
- **Recovery Recommender**: "What should I do about at-risk subscriptions?" or "Generate a recovery strategy"

## Decision Matrix Configuration

The plugin uses a **decision matrix** to tune recovery strategies without code changes.

### How It Works

The decision matrix (`config/decision-matrix.yaml`) maps:
- **Risk tier** (critical, high, medium, low) + **Failure type** → **Recommended action** + **Incentive** + **Success probability**

For example:
```yaml
critical:
  card_expired:
    primary: "update_payment_method"
    incentive: "none"
  insufficient_funds:
    primary: "retry_with_delay"
    incentive: "discount_5pct"
```

### Customizing Strategies

Edit `config/decision-matrix.yaml` to adjust:
- **Success probabilities** for each risk tier
- **Recovery actions** for each failure type
- **Incentive amounts** (5% discount, 10% discount, 1 free month, etc.)
- **Thresholds** for LTV/LTD segmentation
- **Urgency levels** and escalation rules

The Recovery Recommender reads your decision matrix at each run — no code changes needed.

### Example Customizations

**Increase discounts for high-risk customers:**
```yaml
high:
  insufficient_funds:
    primary: "pause_subscription"
    incentive: "discount_10pct_on_resume"  # Was: discount_5pct
```

**Add new recovery actions:**
```yaml
low:
  unknown:
    primary: "contact_sales_team"  # New action type
    incentive: "discount_pro_bono_month"
```

**Adjust risk thresholds:**
```yaml
ltv_tiers:
  high: 10000  # Was: 5000 (be more selective about high-value customers)
```

## Workflow Example

1. Run **Card Expiry Detector** → get list of customers with expiring cards
2. Run **Payment Failure Analyzer** → understand recent payment failure patterns
3. Run **Dunning Risk Assessor** → segment subscriptions by risk tier
4. Run **Recovery Recommender** → get tailored recovery actions using decision matrix
5. **Review Markdown proposal** → approve/adjust recommendations
6. **Implement approved actions** → send emails, apply discounts, etc. (manually, outside this plugin)

## Propose-Only Approach

This plugin identifies and recommends actions, but **never**:
- Sends emails to customers
- Applies discounts or credits
- Pauses or downgrades subscriptions
- Modifies payment methods
- Cancels subscriptions

All outputs are Markdown proposals for human review. Your team reviews, approves, and implements actions in Zoho Billing.

### Why Propose-Only?

✓ **Full control** — you see every action before it happens
✓ **Flexibility** — adjust recommendations based on customer context
✓ **Auditability** — clear record of what was proposed and approved
✓ **Safety** — no accidental mass modifications or communications

## How It Works

The plugin uses the Zoho Billing MCP server to access:
- Card expiration dates
- Payment failure logs and error codes
- Dunning subscription records
- Involuntary churn data
- Churn after retry cycles

Each skill is lightweight and focused on one specific task, making them easy to combine into custom workflows.

## Data Access

This plugin requires read-only access to:
- Subscriptions
- Payments and payment methods
- Customer data
- Transaction history

It does **not** modify any data or execute transactions.

## Troubleshooting

**Plugin doesn't connect to Zoho Billing**
→ Check that your Organization ID and API Key are set correctly in the plugin configuration.

**Recommendations seem generic**
→ Review and customize `config/decision-matrix.yaml` to match your recovery strategy. Default values are starting points only.

**Skill shows no results**
→ Legitimate result — you may not have any subscriptions in the queried risk tier right now. Try a broader search or different risk level.

## Support

For issues or feature requests, contact your Zoho Billing support team or plugin administrator.

## License

See LICENSE file in the plugin directory.
