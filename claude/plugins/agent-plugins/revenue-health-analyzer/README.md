# Revenue Health Analyzer

Portfolio-level revenue retention diagnostic for Zoho Billing.

Acquiring a customer is only half the equation in any subscription
business — what matters more is whether that customer's revenue
compounds through expansion or quietly leaks through contraction and
churn. This plugin computes Net Revenue Retention and bands it against
industry norms, pulls cohort retention curves so the user can compare
cohort-by-cohort whether recent acquisitions are sticking better or
worse than older ones, renders a revenue waterfall that bridges
starting MRR through expansion, contraction, and churn to ending MRR,
and surfaces the next 30 / 60 / 90-day renewal exposure in dollars.

Every output is **propose-only** — the plugin never calls a mutating
Zoho Billing endpoint, never sends communications, and never extends
or cancels a subscription. A human reviewer always decides what to act
on.

---

## When to run it

- After a pricing change, to validate whether new cohorts retain like old ones
- Before a board meeting, to defend the long-term value of the customer base
- As a monthly retention read, to spot revenue erosion before it becomes a quarterly miss

---

## Sample prompts

1. Run a revenue retention health check for the last 12 months.
2. Show NRR by cohort and flag the weakest cohort.
3. What is the renewal cliff for the next 60 days in dollars?
4. How did the March acquisition cohort retain compared to January?
5. Generate a revenue waterfall from the start of the year to last month.

---

## Outputs

- A **Red / Yellow / Green retention call** with a one-sentence rationale
- The **NRR band** against industry benchmarks (best-in-class ≥ 110%,
  healthy 100–110%, leaking < 100%)
- A **cohort heatmap** with a call-out for the weakest acquisition month
- The **dollar value of upcoming renewal exposure** at 30, 60, and 90 days
- A **propose-only short-list** of at-risk renewals worth proactive attention
- A Markdown report archived to `retention-runs/<YYYY-MM-DD>/`
- A live visual dashboard rendered inline

---

## Skills bundled

| Skill | What it does |
|---|---|
| `retention-health-orchestrator` | Runs the full pipeline end-to-end and synthesises the R/Y/G call |
| `nrr-calculator` | Computes Net Revenue Retention and bands it against industry norms |
| `cohort-retention-analyzer` | Builds the cohort heatmap and flags cohorts retaining below peer median |
| `revenue-waterfall-builder` | Bridges starting MRR through new / expansion / contraction / churn to ending MRR |
| `renewal-exposure-tracker` | Quantifies the 30/60/90-day renewal cliff and ranks at-risk renewals |

Each diagnostic skill can also be invoked directly when the user only
wants one slice.

---

## MCP tools used

- `ZohoBilling_get_net_revenue_retention_rate_report`
- `ZohoBilling_get_subscription_retention_rate_report`
- `ZohoBilling_get_revenue_retention_cohort_report`
- `ZohoBilling_get_subscription_retention_cohort_report`
- `ZohoBilling_get_revenue_waterfall_report`
- `ZohoBilling_get_revenue_waterfall_details_report`
- `ZohoBilling_get_renewal_summary_report`
- `ZohoBilling_get_upcoming_renewal_details_report`
- `ZohoBilling_get_non_renewing_subscriptions_report`

All endpoints are read-only.

---

## Tuning

All thresholds live in `config/retention-bands.yaml` — NRR bands,
cohort-variance sensitivity, renewal-exposure risk triggers, and the
R/Y/G decision rules. Edit the YAML to tune the agent's behaviour;
no skill code changes required.

---

## Where it sits next to existing plugins

| Plugin | Layer | Focus |
|---|---|---|
| `analyst-agent` | Business health (broad) | Sales × Collections × Subscription growth scorecard |
| `retention-agent` | Per-subscription | Pre-churn detection, cancel reasons, LTV × LTD offers |
| **`revenue-health-analyzer`** | **Portfolio / financial-metrics** | **NRR, cohorts, waterfall, renewal cliff** |
| `dunning-agent` | Payment failure | Dunning recovery prioritisation |

The three retention-adjacent plugins are complementary: `analyst-agent`
gives the broad health picture, this plugin diagnoses *whether revenue
is staying*, and `retention-agent` decides *what to do per customer*.
