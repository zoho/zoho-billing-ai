---
name: invoice-investigator
description: >
  Full invoice history for a customer: charges, payments applied, credit notes,
  and any gaps. Use when a customer disputes a charge, claims to have paid,
  asks about a specific invoice, or when the user needs to investigate a billing
  discrepancy. Do NOT use for aggregate overdue lists or collections worklists.
when_to_use: >
  Trigger on: "customer says they were overcharged", "check invoice [INV-XXX]",
  "customer paid but still showing overdue", "invoice dispute", "billing discrepancy",
  "payment history for [customer]", "why is this invoice still open",
  "did [customer] pay", "invoice investigator".
argument-hint: "[customer name or invoice number]"
---

# Invoice Investigator

Build a complete charge + payment timeline for a customer or specific invoice.
Designed for dispute resolution.

## Step 1 — Resolve the subject

If `$ARGUMENTS` looks like an invoice number (starts with INV):
- `ZohoBilling_Get_an_Invoice` with that invoice ID
- From the invoice, extract the customer ID

If `$ARGUMENTS` is a customer name:
- `ZohoBilling_Search_Customers` with `search_text: $ARGUMENTS`
- Confirm if multiple results. Proceed with customer_id.

If `$ARGUMENTS` is empty: ask "Which customer or invoice number should I investigate?"

## Step 2 — Fetch all linked records (in parallel)

| # | Tool | Params |
|---|------|--------|
| 1 | `ZohoBilling_Get_a_Customer` | customer_id |
| 2 | `ZohoBilling_List_all_Invoices` | all, then filter by customer_id |
| 3 | `ZohoBilling_List_all_Payments` | all, then filter by customer_id |

## Output

Render a chronological timeline:

```
Invoice Investigation — [Customer Name]
────────────────────────────────────────────────────────────────
[May 1]   📄 Invoice INV-10045 created     $2,500   due Jun 1
[May 15]  💳 Payment received              $1,000   Partial ✅
[Jun 2]   ⚠  Invoice INV-10045 OVERDUE     $1,500   remaining
[Jun 5]   📄 Invoice INV-10047 created     $2,500   due Jul 5
[Jun 10]  ❌ Payment failed                          Card declined
────────────────────────────────────────────────────────────────
Open balance: $4,000  (INV-10045 partial $1,500 + INV-10047 full $2,500)

FINDINGS:
• Customer made a $1,000 partial payment on May 15 — they did pay, partially
• Remaining $1,500 on INV-10045 is 28 days overdue
• Payment failure on Jun 10 — card may need updating
```

**Findings section** must explicitly answer the most likely question:
- Did they pay? (yes/no/partial + amount + date)
- Is there still an open balance? (yes/no + amount)
- Any anomalies? (duplicate charges, missing payments, credit notes not applied)

## Constraints

- Build a real timeline sorted by date — not separate invoice and payment lists
- Show every invoice and payment for this customer, not just the one in $ARGUMENTS
- Credit notes: if `Get_a_Credit_Note` is needed, call it with the note ID from the invoice
- Propose-only: no invoice or payment modifications

## Edge cases

- Customer has no invoices: "No invoice history for this customer"
- Invoice ID doesn't exist: "Invoice [ID] not found — check the number and try again"
- Payments don't clearly map to invoices: flag "⚠ Payment-to-invoice mapping unclear — manual reconciliation may be needed"
