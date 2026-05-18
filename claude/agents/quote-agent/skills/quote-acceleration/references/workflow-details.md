# Quote Acceleration Workflow — Detailed Steps

## Step 1: Gather Open Quotes

Call the Zoho Billing MCP to fetch all quotes with:
- Status: Draft, Sent, or Accepted
- Include: Amount, customer name, creation date, last activity date, follow-up history
- Exclude: Declined or marked-as-lost quotes (already decided)

**Data retrieved:**
- Quote ID, customer ID, amount, creation date, status
- Last activity timestamp (when quote was viewed, emailed, or updated)
- Number of follow-ups already sent
- Customer contact info

## Step 2: Assess Historical Context

### Get Conversion Patterns
Query the Zoho Billing reports to understand:
- Which customers have quoted before and what % converted
- Average time from quote sent to first payment
- Benchmark conversion rate by product/plan type

### Get Lost Quote Patterns
Analyze historically declined and lost quotes to identify:
- Common characteristics of dead deals (age, value range, customer type)
- Failure signals (e.g., "tech companies rarely convert on annual plans at 50% discount")
- Time-to-death (how long before a stalled quote typically gets marked lost)

**Why this matters:** A 45-day-old quote from a customer who *always* converts gets scored differently than a 45-day-old quote from someone who never has.

## Step 3: Calculate Staleness Score

For each open quote, compute a **staleness score between 0.0 (fresh) and 1.0 (dead)**.

### Scoring Matrix

| Signal | Weight | Calculation |
|--------|--------|-------------|
| **Days since last activity** | 35% | < 7 days = 0.0, 7–14 = 0.2, 14–30 = 0.5, 30+ = 1.0 |
| **Days since created** | 25% | < 7 days = 0.0, 7–30 = 0.3, 30–60 = 0.6, 60+ = 1.0 |
| **Follow-ups without response** | 15% | 0 follow-ups = 0.0, 1–2 = 0.3, 3–5 = 0.7, 5+ = 1.0 |
| **Customer conversion rate** | 15% | If they convert 80%+ of quotes = 0.0, 50–80% = 0.2, 20–50% = 0.5, <20% = 1.0 |
| **Matches lost pattern** | 10% | Not similar = 0.0, somewhat = 0.5, very similar = 1.0 |

### Example Calculation

**Quote: TechFlow Corp — $65,000, created 20 days ago, sent 20 days ago, 1 follow-up sent 10 days ago**

- Days since activity: 10 days (last follow-up opened) → 0.2
- Days since created: 20 days → 0.3
- Follow-ups: 1 without response → 0.3
- Conversion rate: Customer converted 3 of 5 quotes (60%) → 0.2
- Lost pattern match: Doesn't match → 0.0

**Staleness = (0.2 × 0.35) + (0.3 × 0.25) + (0.3 × 0.15) + (0.2 × 0.15) + (0.0 × 0.10) = 0.07 + 0.075 + 0.045 + 0.03 + 0 = 0.22**

→ **Staleness: 0.22** (Fresh, needs low engagement)

---

**Quote: OldCorp Industries — $42,000, created 45 days ago, sent 45 days ago, 0 follow-ups**

- Days since activity: 45 days → 1.0
- Days since created: 45 days → 1.0
- Follow-ups: 0 (never followed up) → 0.0
- Conversion rate: Company never converted (0%) → 1.0
- Lost pattern match: Matches failed customer type → 1.0

**Staleness = (1.0 × 0.35) + (1.0 × 0.25) + (0.0 × 0.15) + (1.0 × 0.15) + (1.0 × 0.10) = 0.35 + 0.25 + 0 + 0.15 + 0.10 = 0.85**

→ **Staleness: 0.85** (Stalled, high-risk)

## Step 4: Calculate Expected Close Value

For each quote:

```
Expected Close Value = Quote Amount × P(close)
where P(close) = 1.0 − staleness_score
```

**Examples:**

| Quote | Amount | Staleness | P(close) | Expected Close Value |
|-------|--------|-----------|----------|----------------------|
| TechFlow Corp | $65,000 | 0.22 | 0.78 | $50,700 |
| OldCorp Industries | $42,000 | 0.85 | 0.15 | $6,300 |
| Fresh Startup | $100,000 | 0.05 | 0.95 | $95,000 |

This metric tells you: "If I work on these quotes in order of expected close value, I'm prioritizing by the highest revenue impact."

## Step 5: Rank All Quotes

Sort all quotes by Expected Close Value in descending order.

### Output Ranking Example (8 quotes)

1. Fresh Startup — $100,000 (staleness 0.05, expected close value $95,000)
2. Acme Corp — $150,000 (staleness 0.0, expected close value $150,000) *← But listed 2nd because Acme is already accepted; Fresh is next to close*
3. TechFlow Corp — $65,000 (staleness 0.22, expected close value $50,700)
4. GlobalTech — $95,000 (staleness 0.35, expected close value $61,750)
5. MidMarket Solutions — $64,000 (staleness 0.58, expected close value $26,880)
6. DataFlow Systems — $50,000 (staleness 0.72, expected close value $14,000) ← Stalled
7. OldCorp Industries — $42,000 (staleness 0.85, expected close value $6,300) ← Stalled
8. Defunct LLC — $18,500 (staleness 0.95, expected close value $925) ← Dead

## Step 6: Flag Staleness Tiers

After ranking, mark each quote:

- ✅ **Accepted** — Staleness 0.0, status = "Accepted"
- 🟢 **Fresh** — Staleness < 0.3
- 🟡 **Warm** — Staleness 0.3–0.5
- 🟠 **Stalled** — Staleness 0.5–0.7 (⚠️ flag)
- 🔴 **Critical** — Staleness 0.7–0.9 (⚠️ flag)
- ☠️ **Dead** — Staleness > 0.9

## Step 7: Recommend Next Action

For each quote, assign the recommended action:

| Staleness Tier | Condition | Recommended Action |
|---|---|---|
| Accepted (0.0) | Status = Accepted | **Convert to invoice immediately** |
| Fresh (< 0.3) | Sent < 7 days ago | **No action** — still in evaluation window |
| Warm (0.3–0.5) | No follow-up in 7 days | **Send follow-up email** — gentle reminder |
| Warm–Stalled (0.5–0.7) | High-value quote (e.g., > $50K) | **Apply discount** — offer 5–10% concession |
| Warm–Stalled (0.5–0.7) | Low-value quote | **Send follow-up email** — last-chance reminder |
| Stalled (0.7–0.9) | Customer was responsive before | **Send follow-up email** — direct ask with deadline |
| Critical (0.7–0.9) | Customer never engaged | **Flag for manual review** — may need different approach |
| Dead (> 0.9) | No activity in 30+ days | **Mark as lost** — clean up pipeline |
| Multiple per customer | Detected duplicate customer | **Flag for consolidation** — upsell opportunity |

## Handling Edge Cases

### Case 1: Quote with No Activity History
**Situation:** Quote created 15 days ago but no "last activity" timestamp
**Handling:** Assume last activity = creation date. Flag as "Limited data — no customer engagement tracked"

### Case 2: Customer with No Historical Quotes
**Situation:** First quote ever sent to this customer
**Handling:** Use organization-wide average conversion rate (e.g., 45%) instead of customer-specific rate

### Case 3: Zero or Negative Quote Amount
**Situation:** Data error or test quote with $0 amount
**Handling:** Exclude from ranking. Flag for data cleanup.

### Case 4: Multiple Quotes to Same Customer
**Situation:** TechFlow Corp has 3 open quotes (different products)
**Handling:** List separately in table, but group at bottom with note: "Consolidation opportunity — review for bundle or upsell"

### Case 5: Quote Sent as Draft (Never Formally Sent)
**Situation:** Quote exists in Zoho but marked "Draft" (not "Sent")
**Handling:** Flag separately. Recommend "Send quote" as primary action before other tactics.

### Case 6: API Unavailable for One Data Source
**Situation:** Can fetch quotes but conversion history API is down
**Handling:** Proceed with available data. Recalculate staleness using only: days since activity, days since created, follow-up count. Adjust confidence ("Partial analysis — customer history unavailable").

---

## Output Example: Start to Finish

### Input
```
47 total quotes
$1.25M total pipeline value
```

### Processing
1. Fetch all 47 quotes from Zoho Billing
2. Get conversion history for 35 unique customers
3. Analyze 127 historical lost quotes to identify patterns
4. Calculate staleness for each of 47 quotes
5. Calculate expected close value
6. Rank by expected close value

### Output
```
Top 3 quotes by expected close value:
1. $150,000 (Acme Corp, accepted, convert now)
2. $95,000 (Fresh Startup, fresh, no action)
3. $80,000 (GlobalTech, warm, gentle follow-up)

Total expected closeable value: $892,500 (71% of pipeline)

Stalled deals (need intervention): 12 quotes, $185,000 at risk
Dead deals (recommend marking lost): 5 quotes, $42,000 in pipeline bloat
```

### Actions Recommended
- ✅ Convert 1 accepted quote ($150,000)
- 📧 Send follow-ups to 8 quotes ($280,000)
- 💰 Apply discounts to 3 quotes ($185,000)
- ❌ Mark 5 as lost ($42,000)
