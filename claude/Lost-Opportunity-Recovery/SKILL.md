---
name: lost-opportunity-recovery
title: Lost Opportunity Recovery
description: >
  Maintains a single ranked second-chance pipeline across abandoned carts, expired quotes,
  declined deals, and inactive trials. Each entry has the loss reason and recommended
  re-engagement move.
action_type: Re-engagement
tools:
  - get_abandoned_carts_report
  - get_abandoned_products_report
  - get_lost_opportunities_report
  - get_inactive_trials_report
  - get_estimate_details_report
  - email_quote
  - create_paymentlink
  - associate_coupon_to_subscription
---

# Lost Opportunity Recovery

## Overview

**Action Type:** Re-engagement

Maintains a single ranked second-chance pipeline across abandoned carts, expired quotes, declined deals, and inactive trials. Each entry has the loss reason and recommended re-engagement move.

---

## Trigger Phrases

- "show me lost opportunities"
- "second-chance pipeline"
- "what deals can we recover"
- "abandoned carts"
- "expired quotes"
- "inactive trials"
- "who dropped off"
- "re-engagement worklist"

---

## MCP Tools Used

All tools are called via the **custom MCP connection** to Zoho Billing.

### Read Tools

| Tool | Purpose |
|---|---|
| `get_abandoned_carts_report` | Fetches checkout sessions that were started but never completed |
| `get_abandoned_products_report` | Retrieves product-level data on which items are most abandoned |
| `get_lost_opportunities_report` | Pulls quotes/deals that were declined or marked as lost |
| `get_inactive_trials_report` | Gets trial subscriptions with no activity or engagement |
| `get_estimate_details_report` | Fetches expired and open-but-stale quotes with customer details |

### Write Tools

| Tool | Purpose |
|---|---|
| `email_quote` | Re-send or follow up on a quote via email |
| `create_paymentlink` | Generate a payment link to reduce friction for abandoned carts |
| `associate_coupon_to_subscription` | Attach a discount coupon as a re-engagement incentive |

---

## Workflow

### Step 1 — Gather Lost Opportunities from All Sources

1. Call `get_abandoned_carts_report` to fetch all abandoned checkout sessions.
2. Call `get_abandoned_products_report` to identify which products have the highest abandonment — used for pattern detection.
3. Call `get_lost_opportunities_report` to pull declined and lost deals.
4. Call `get_inactive_trials_report` to fetch trials with no engagement or approaching expiry.
5. Call `get_estimate_details_report` to get expired quotes and quotes older than 30 days with no response.

### Step 2 — Unify into a Single Pipeline

6. Normalize all entries into a single pipeline with a common schema:

| Field | Source Mapping |
|---|---|
| Customer / Contact | Customer name or email from each source |
| Opportunity Type | `Abandoned Cart`, `Expired Quote`, `Declined Deal`, `Inactive Trial` |
| Product / Plan | Product or plan from the original opportunity |
| Value | Cart value, quote amount, or plan MRR |
| Loss Date | Date of abandonment, expiry, decline, or last trial activity |
| Days Since Loss | Calendar days since the loss date |
| Loss Reason | Explicit reason if available, otherwise inferred (see Step 3) |

### Step 3 — Determine Loss Reason

For each entry, assign or infer the loss reason:

| Opportunity Type | Reason Logic |
|---|---|
| Abandoned Cart | **Checkout friction** — customer started but didn't finish. If product appears frequently in `get_abandoned_products_report`, flag as systemic. |
| Expired Quote | **No response** — quote sat unanswered past expiry. If customer viewed but didn't act, **price hesitation**. |
| Declined Deal | Use explicit decline reason from `get_lost_opportunities_report`. Common: **price**, **competitor**, **timing**, **feature gap**. |
| Inactive Trial | **Low engagement** — trial started but no meaningful activity. If trial is near expiry, **conversion window closing**. |

### Step 4 — Score Recovery Potential

For each entry, compute a **Recovery Score** (0.0 to 1.0):

| Signal | Weight | Logic |
|---|---|---|
| Recency (days since loss) | 35% | More recent = higher recovery chance. <7 days = high, 7–30 = medium, >30 = low. |
| Opportunity value | 25% | Higher value = worth more effort. Normalize against org's average deal size. |
| Customer engagement history | 20% | Returning visitor, multiple carts, or prior purchases = higher recovery potential. |
| Loss reason actionability | 20% | Price sensitivity (coupon can help) = high. Competitor/feature gap = low. |

### Step 5 — Determine Recommended Action

For each entry, assign the **recommended re-engagement move**:

| Opportunity Type | Recovery Score | Loss Reason | Recommended Action |
|---|---|---|---|
| Abandoned Cart | > 0.5 | Checkout friction | **Create payment link** — simplify the path to purchase |
| Abandoned Cart | > 0.5 | Price hesitation | **Associate coupon** + **Create payment link** |
| Abandoned Cart | < 0.5 | Any | **Email quote** — light-touch reminder |
| Expired Quote | > 0.5 | No response | **Email quote** — resend with urgency or updated terms |
| Expired Quote | > 0.5 | Price | **Associate coupon** + **Email quote** |
| Expired Quote | < 0.5 | Any | **Email quote** — final follow-up |
| Declined Deal | > 0.5 | Price | **Associate coupon** — offer incentive to reconsider |
| Declined Deal | > 0.5 | Timing | **Email quote** — check if timing has improved |
| Declined Deal | Any | Competitor/feature gap | **Flag for review** — no automated re-engagement |
| Inactive Trial | > 0.5, trial not expired | Low engagement | **Email quote** — share onboarding tips, extend trial |
| Inactive Trial | > 0.5, trial near expiry | Conversion window | **Associate coupon** — conversion incentive |
| Inactive Trial | < 0.5 | Any | **Email quote** — standard win-back |

### Step 6 — Rank and Present

7. Sort the unified pipeline by Recovery Score (descending).
8. Group by Opportunity Type for readability.
9. Output the ranked worklist (see Output Format below).

---

## Edge Cases

| Scenario | Handling |
|---|---|
| No lost opportunities found | Report "No recoverable opportunities — pipeline is clean" with current active deal count. |
| Customer appears in multiple sources | Merge into a single entry; combine signals and pick the highest-value opportunity. Note "Multiple touchpoints" in reasoning. |
| Abandoned cart has no customer email | Skip — cannot re-engage without contact info. Note count of uncontactable entries in summary. |
| Loss reason not available | Classify as "Unknown" and default to email follow-up as the safe first move. |
| Opportunity is > 90 days old | Move to "Archive" section — low recovery probability. Show only if explicitly requested. |
| Product is discontinued or plan changed | Flag as "Product/plan no longer available" — recommend alternative plan in email. |
| API returns an error for any tool | Proceed with available data, note the missing source, and adjust the pipeline accordingly. |

---

## Output Format

### Executive Summary

```
🔄 Lost Opportunity Recovery — Week of [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total recoverable opportunities : [count]
Total pipeline value             : [currency amount]
Estimated recoverable value      : [currency amount] (based on Recovery Scores)

By Source:
  Abandoned Carts     : [count] ([currency amount])
  Expired Quotes      : [count] ([currency amount])
  Declined Deals      : [count] ([currency amount])
  Inactive Trials     : [count] ([currency amount])

Top abandoned product  : [Product name] ([N] abandonments)
```

### Ranked Second-Chance Pipeline

#### 🛒 Abandoned Carts

| # | Customer | Product/Plan | Value | Days Since | Loss Reason | Recovery Score | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|
| 1 | [Name/Email] | [Product] | [Amount] | [Days] | [Reason] | [0.X] | [Action] | [Brief explanation] |

#### 📄 Expired Quotes

| # | Customer | Quote # | Value | Days Since | Loss Reason | Recovery Score | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [QT-XXX] | [Amount] | [Days] | [Reason] | [0.X] | [Action] | [Brief explanation] |

#### ❌ Declined Deals

| # | Customer | Deal/Quote # | Value | Days Since | Loss Reason | Recovery Score | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [QT-XXX] | [Amount] | [Days] | [Reason] | [0.X] | [Action] | [Brief explanation] |

#### ⏸️ Inactive Trials

| # | Customer | Plan | MRR | Trial Expires | Loss Reason | Recovery Score | Recommended Action | Reasoning |
|---|---|---|---|---|---|---|---|---|
| 1 | [Name] | [Plan] | [Amount] | [Date/Days] | [Reason] | [0.X] | [Action] | [Brief explanation] |

### Per-Row Reasoning Format

Each reasoning cell should briefly state the key signals, e.g.:
> *"Cart abandoned 3 days ago, $480 value. Product has 15% abandonment rate. Customer has 1 prior purchase. Likely checkout friction — payment link should convert."*

### One-Click Actions

For each row, present the available actions:

- **📧 Email quote** — Send or resend a quote/reminder to the customer
- **🔗 Create payment link** — Generate a frictionless payment link
- **🎟️ Apply coupon** — Attach a discount coupon as a re-engagement incentive

---

## Output Rules

1. Always show amounts in the organization's base currency.
2. Sort within each group by Recovery Score descending.
3. Keep reasoning concise — max 2 sentences per row.
4. If Recovery Score < 0.2, flag the row with 🪦 to indicate very low recovery chance.
5. If an opportunity is < 3 days old, flag with 🔥 to indicate a hot recovery window.
6. Entries older than 90 days should be excluded by default — show only if user asks for the full archive.
7. Highlight systemic patterns in the summary (e.g., "Product X has 40% cart abandonment — consider pricing or checkout UX review").
8. Group actions by type at the bottom for bulk execution if the user requests it.