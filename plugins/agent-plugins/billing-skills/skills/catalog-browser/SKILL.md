---
name: catalog-browser
description: >
  Show the full product catalog: all products, their plans with pricing and billing
  frequency, addons, and one-time items. Use when the user asks what plans are available,
  wants to see the product catalog, pricing, or available addons and items.
  Do NOT use for subscription status, customer-specific data, or coupon lookup.
when_to_use: >
  Trigger on: "what plans do we have", "show me the catalog", "what products",
  "pricing options", "available plans", "what addons", "product catalog",
  "plan list", "catalog", "what can I sell".
argument-hint: "[product name to filter — optional]"
---

# Catalog Browser

Show the full pricing catalog: products → plans → addons → items.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.
If `$ARGUMENTS` is provided, filter output to products/plans matching that name.

## Fetch (run in parallel)

| # | Tool | Params |
|---|------|--------|
| 1 | `ZohoBilling_List_all_Products` | `per_page: 200` |
| 2 | `ZohoBilling_List_all_Plans` | `filter_by: PlanStatus.ACTIVE`, `per_page: 200` |
| 3 | `ZohoBilling_List_all_Addons` | `per_page: 200` |
| 4 | `ZohoBilling_List_all_Items` | `per_page: 200` |

## Output

Group plans under their parent product:

```
PRODUCTS & PLANS
────────────────────────────────────────────────
Product: Zoho Billing Pro
  ├── Starter       $29/month   (also: $290/yr)
  ├── Professional  $79/month   (also: $790/yr)
  └── Enterprise    $199/month  (also: $1,990/yr)

Product: Add-on Pack
  └── Extra Users   $9/user/month

ADDONS (N)
  • Extra Storage    $5/GB/month
  • Priority Support $49/month

ONE-TIME ITEMS (N)
  • Setup Fee        $299 (one-time)
  • Training Session $499 (one-time)
────────────────────────────────────────────────
Total: N products · N active plans · N addons · N items
```

Show per plan: name · price · billing frequency · trial days (if any) · status.
Inactive plans: list separately at the bottom as "Inactive plans (N)" without detail.

## Constraints

- Only show ACTIVE plans in the main section
- Group plans by product_id — do not list plans without a product parent
- Propose-only: no catalog changes

## Edge cases

- No products defined: "No products found — set up your product catalog in Zoho Billing first"
- $ARGUMENTS filter matches nothing: "No products or plans matching '[filter]' — showing full catalog"
