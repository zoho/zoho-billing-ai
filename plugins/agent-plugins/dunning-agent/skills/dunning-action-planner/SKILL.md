---
name: dunning-action-planner
description: >
  Takes a scored dunning cohort (from dunning-cohort-builder) and applies error-code
  playbooks to produce three outputs: (1) a prioritised action list per subscription,
  (2) an error-code segment summary table, and (3) playbook reference cards grouped by
  error code. Propose-only — all recommendations require human approval. Use after
  dunning-cohort-builder has run, or when the user asks for a recommended action plan
  for at-risk subscriptions.
---

# Dunning Action Planner

Apply error-code playbooks and produce the prioritised remediation report.

---

## Error-Code Playbooks

For each `gateway_error_code`, apply the strategy below. If the code is not in this
table, use the **`unknown`** row.

| Error Code | Root Cause | Owner | Primary Action | Secondary Action | Retry Delay (days) | Auto-Recoverable | Escalate if retry ≥ | Incentive |
|---|---|---|---|---|---|---|---|---|
| `card_expired` | Card past expiry date | customer | send_card_update_request | escalate_to_support | 3 | No | 2 | none |
| `insufficient_funds` | Account lacks funds | customer | retry_after_delay | offer_pause_or_downgrade | 7 | Yes | 3 | 10% off on resume |
| `do_not_honor` | Bank declined (generic) | customer | send_card_update_request | escalate_to_support | 5 | No | 2 | none |
| `card_declined` | Bank declined (unspecified) | customer | send_card_update_request | offer_alternative_payment_method | 5 | No | 2 | none |
| `processing_error` | Transient gateway/network error | auto | retry_immediately | retry_after_delay | 1 | Yes | 4 | none |
| `authentication_required` | 3DS / SCA required | customer | send_authentication_link | request_new_payment_method | 2 | No | 2 | none |
| `invalid_card_number` | Card number invalid or reissued | customer | send_card_update_request | escalate_to_support | 0 | No | 1 | none |
| `lost_card` | Card reported lost | support | escalate_to_support | request_new_payment_method | 0 | No | 1 | none |
| `stolen_card` | Card reported stolen | support | escalate_to_support | request_new_payment_method | 0 | No | 1 | none |
| `fraud_suspected` | Transaction flagged as fraud | support | manual_triage | contact_customer_via_alternate_channel | 0 | No | 1 | none |
| `transaction_not_permitted` | Card type / account restriction | customer | request_alternative_payment_method | escalate_to_support | 0 | No | 1 | none |
| `currency_not_supported` | Card can't transact in billing currency | support | review_billing_currency_config | request_alternative_payment_method | 0 | No | 1 | none |
| `unknown` | Code not recognised or not returned | support | retry_after_delay | manual_triage | 3 | Yes | 3 | none |

**Retry delay of 0** means do not retry — the customer or support must act first.

**Communication templates by action:**

| Primary Action | Customer-facing subject line |
|---|---|
| send_card_update_request | "Action required: Update your payment method" |
| retry_after_delay | "We'll retry your payment shortly — no action needed" |
| offer_pause_or_downgrade | "We couldn't process your payment — here are your options" |
| send_authentication_link | "Action required: Verify your payment to keep your subscription active" |
| request_alternative_payment_method | "Your card can't be used — please add a new payment method" |
| retry_immediately | *(silent — no email for auto-retry)* |
| escalate_to_support | "[Internal] Payment failure requires manual review" |
| manual_triage | "[Internal] Payment failure requires manual review" |

---

## Step 0 — Setup

**Input**: The JSON cohort emitted by `dunning-cohort-builder`. If called standalone,
run dunning-cohort-builder first.

---

## Step 1 — Apply playbooks to each subscription

Look up each subscription's `gateway_error_code` in the playbook table. Apply:

| Field | Value |
|---|---|
| `playbook_owner` | from table |
| `primary_action` | from table |
| `secondary_action` | from table |
| `suggested_retry_delay_days` | from table |
| `incentive` | from table |
| `auto_recoverable` | from table |
| `needs_escalation` | `true` if `retry_number ≥ escalate_if_retry_gte` |
| `next_suggested_retry` | today + retry_delay days (null if retry_delay == 0) |

### Escalation override

If `needs_escalation: true` → override `primary_action` to `escalate_to_support` and append flag `"⚠ Escalation threshold reached"`.

### High-value note

If `is_high_value: true` → append note `"★ High-value customer — prioritise personal outreach over automated message"`.

---

## Step 2 — Error-code segment summary table

For each error group:

| Column | Value |
|---|---|
| Error Code | error_code |
| # Subs | subscription_count |
| Total at Risk | total_bcy_amount |
| P0 | p0_count |
| Avg LTV | avg_ltv |
| Avg LTD (days) | avg_ltd |
| Owner | from playbook table |
| Primary Action | from playbook table |
| Auto-Recover? | ✓ or ✗ |

Sort by `total_bcy_amount` DESC. Add a totals row at the bottom.

---

## Step 3 — Prioritised action list

Flat list of all subscriptions ordered by: priority tier (P0 first) then `composite_score` DESC.

Columns: `Priority`, `Score`, `Sub#`, `Customer`, `Amount`, `LTV`, `LTD`, `Retry#`, `Error Code`, `Action`, `Notes`

Annotations: `★` high-value · `⚠` needs escalation · `↻` auto-recoverable and no escalation

Priority indicators: 🔴 P0 · 🟠 P1 · 🟡 P2 · ⚪ P3

---

## Step 4 — Playbook reference cards

One card per distinct error code in the cohort, ordered by `total_bcy_amount` DESC:

```markdown
### <error_code> (<count> subscriptions · <total_bcy> at risk)
**Root cause:** ...
**Owner:** customer | support | auto
**Primary action:** ...   **Secondary:** ...
**Retry delay:** N days   **Auto-recoverable:** Yes / No
**Escalate if retries ≥:** N
**Incentive:** ... or None
**Communication:** <subject line or "Silent auto-retry">
```

---

## Step 5 — Action metrics

```
total_needs_escalation            count where needs_escalation == true
total_auto_recoverable            count where auto_recoverable == true AND !needs_escalation
total_requires_customer_action    count where owner == "customer"
total_requires_support_action     count where owner == "support"
p0_high_value_overlap             count where priority_tier == "P0" AND is_high_value == true
estimated_recoverable_revenue     sum of bcy_amount where auto_recoverable == true
estimated_at_risk_manual          sum of bcy_amount where auto_recoverable == false
```

---

## Edge Cases

- **Code not in table**: apply `unknown` playbook; add flag `"Error code not recognised — applied default 'unknown' strategy"`.
- **retry_delay == 0**: set `next_suggested_retry: null`; note `"Do not retry — action required first"`.
- **All subscriptions P0**: add executive warning `"⚠ All dunning subscriptions are P0 — immediate triage required"`.
- **`retry_immediately` action**: no customer email — annotate `"Silent auto-retry"`.
