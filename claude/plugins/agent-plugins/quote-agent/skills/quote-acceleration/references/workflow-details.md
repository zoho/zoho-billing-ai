# Staleness Algorithm & Workflow

## 7-Step Workflow

### Step 1: Gather Open Quotes
Fetch all quotes with status: Draft, Sent, or Accepted. Include amount, creation date, last activity, follow-up count.

### Step 2: Get Historical Context
- Query customer conversion rates (which % of past quotes converted?)
- Analyze lost quote patterns (what characteristics kill deals?)

### Step 3: Calculate Staleness Score (0.0 to 1.0)

| Signal | Weight | Scoring |
|--------|--------|---------|
| Days since last activity | 35% | <7d=0.0, 7-14d=0.2, 14-30d=0.5, 30+d=1.0 |
| Days since created | 25% | <7d=0.0, 7-30d=0.3, 30-60d=0.6, 60+d=1.0 |
| Follow-ups without response | 15% | 0=0.0, 1-2=0.3, 3-5=0.7, 5+=1.0 |
| Customer conversion rate | 15% | 80+=0.0, 50-80%=0.2, 20-50%=0.5, <20%=1.0 |
| Matches lost pattern | 10% | Not similar=0.0, somewhat=0.5, very=1.0 |

**Example calculation:**
- Quote sent 20 days ago, 1 follow-up, customer converts 60% of quotes
- Staleness = (0.3 × 0.35) + (0.3 × 0.25) + (0.3 × 0.15) + (0.2 × 0.15) + (0.0 × 0.10) = **0.22** (Fresh)

### Step 4: Calculate Expected Close Value
`Expected Close Value = Quote Amount × (1.0 − Staleness Score)`

| Quote | Amount | Staleness | Expected Close Value |
|-------|--------|-----------|----------------------|
| Fresh Startup | $100,000 | 0.05 | $95,000 |
| TechFlow Corp | $65,000 | 0.22 | $50,700 |
| OldCorp Industries | $42,000 | 0.85 | $6,300 |

### Step 5: Rank by Expected Close Value
Sort all quotes descending.

### Step 6: Flag Staleness Tiers
- 🟢 Fresh (< 0.3)
- 🟡 Warm (0.3–0.5)
- 🟠 Stalled (0.5–0.7) ⚠️
- 🔴 Critical (0.7–0.9) ⚠️
- ☠️ Dead (> 0.9)

### Step 7: Recommend Action

| Condition | Action |
|-----------|--------|
| Accepted | **Convert to invoice** |
| < 0.3, sent < 7d | **No action** |
| 0.3–0.5, no follow-up in 7d | **Send follow-up email** |
| 0.5–0.7, high-value | **Apply 5-10% discount** |
| 0.5–0.7, low-value | **Send follow-up email** |
| 0.7–0.9, responsive customer | **Send follow-up email** |
| > 0.9, 30+ days no activity | **Mark as lost** |
| Multiple per customer | **Flag for consolidation** |

## Edge Cases

- **No activity history** → Use creation date only; flag "Limited data"
- **New customer** → Use org-wide average conversion rate
- **Zero amount** → Exclude from ranking; flag for cleanup
- **Multiple quotes per customer** → Group together; flag upsell opportunity
- **Draft (never sent)** → Recommend "Send quote" first
- **API unavailable** → Proceed with available data; note missing sources
