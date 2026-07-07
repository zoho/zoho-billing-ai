---
name: invoice-aging
description: >
  List all overdue and unpaid invoices ranked by amount and days overdue.
  Use when the user wants to see what's unpaid, which invoices are overdue,
  total AR exposure, or a quick unpaid invoice list.
  Do NOT use for collections prioritisation (use /collections-today) or customer-specific invoice lookup.
when_to_use: >
  Trigger on: "show overdue invoices", "what's unpaid", "overdue list",
  "unpaid invoices", "which invoices are overdue", "total overdue", "AR list".
---

# Overdue Invoices

List all overdue and unpaid invoices ranked by amount descending.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Params |
|---|------|--------|
| 1 | `ZohoBilling_List_all_Invoices` | `filter_by: Status.OverDue`, `per_page: 200` |
| 2 | `ZohoBilling_List_all_Invoices` | `filter_by: Status.Unpaid`, `per_page: 200` |
| 3 | `ZohoBilling_List_all_Invoices` | `filter_by: Status.PartiallyPaid`, `per_page: 200` |

Paginate while `has_more_page: true`. Deduplicate across lists by invoice ID.

## Output

```
Overdue & Unpaid Invoices — [date]
Total exposure: $XXX,XXX across N invoices
────────────────────────────────────────────────────────
 #  Invoice      Customer            Amount    Days    Status
────────────────────────────────────────────────────────
 1  INV-10045    Acme Corp          $48,200    92d    Overdue
 2  INV-10089    Northwind Traders  $31,500    45d    Overdue
 3  INV-10102    Globex Industries  $18,300    31d    PartiallyPaid
...
────────────────────────────────────────────────────────
Subtotals: Overdue $X · Unpaid $X · PartiallyPaid $X
```

Sort order: Overdue first (by days desc), then Unpaid (by amount desc), then PartiallyPaid.

Aging buckets summary at the bottom:
```
0–30 days:   N invoices  $XXX,XXX
31–60 days:  N invoices  $XXX,XXX
61–90 days:  N invoices  $XXX,XXX
90+ days:    N invoices  $XXX,XXX  ⚠ High write-off risk
```

## Constraints

- Paginate all three status lists fully before deduplicating
- Days overdue = today − due_date
- Flag 90+ day bucket if it contains > 20% of total exposure
- Propose-only: no write actions

## Edge cases

- Zero results: "No overdue or unpaid invoices — AR is clean 🟢"
- More than 100 invoices: show top 50 by amount, add note "Showing top 50 of N — filter by customer for details"
