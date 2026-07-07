---
name: trial-pulse
description: >
  Rank all active trials by conversion likelihood and recommend the conversion
  nudge per trial. Use when the user asks how trials are converting, wants to
  prioritise trial follow-up, or needs to know which trials are most likely to convert.
  Do NOT use for expired trials or historical conversion rates (use /subscription-kpis).
when_to_use: >
  Trigger on: "how are trials converting", "trial conversion", "which trials to follow up",
  "trial pulse", "rank trials by conversion", "trial priority", "trial follow-up list",
  "most likely to convert".
---

# Trial Pulse

Rank active trials by conversion likelihood and surface the recommended nudge.

## Setup

Resolve org ID via `ZohoBilling_List_all_Organizations`.

## Fetch (run in parallel)

| # | Tool | Purpose |
|---|------|---------|
| 1 | `ZohoBilling_Get_Active_Trials_Report` | All currently active trials |
| 2 | `ZohoBilling_Get_Trial_Conversion_Report` | Historical conversion rate baseline |
| 3 | `ZohoBilling_Get_Customer_Conversion_Rate_Report` | Per-customer conversion signal |
| 4 | `ZohoBilling_Get_Signups_Details_Report` | Signup context (source, date) |

## Conversion scoring

For each trial compute a **conversion likelihood** (0–100):

```
Base: 50

  + Trial > 50% complete (more than halfway through)   → +15
  + Trial end ≤ 7 days away (urgency window)           → +10
  + Plan is higher tier (more to lose at trial end)    → +10
  − Trial end > 21 days away (too early)               → −15
  − Free plan trial (lower intent)                     → −10
```

Clamp to 0–100. Sort descending.

**Nudge recommendation:**
| Score | Nudge |
|---|---|
| ≥ 80 | 🟢 **Convert now** — send conversion offer immediately |
| 60–79 | 📧 **Targeted discount** — offer 20% off first month |
| 40–59 | 📞 **Schedule sales call** — high-touch needed |
| < 40 | ⏳ **Extend trial** — not ready, keep warming |

## Output

```
Trial Pulse — [date]   (N active trials)
Average conversion rate (baseline): XX%
────────────────────────────────────────────────────────────────
 #  Customer          Plan           Days left  Score  Nudge
────────────────────────────────────────────────────────────────
 1  Hot Startup       Enterprise     3d          87    🟢 Convert now
 2  Growing Co        Professional   5d          74    📧 Discount offer
 3  Maybe Corp        Starter        12d         55    📞 Sales call
 4  Early Stage Ltd   Pro            19d         31    ⏳ Extend trial
────────────────────────────────────────────────────────────────
```

## Constraints

- Scoring is heuristic — be transparent that it's an approximation when asked
- Propose-only: no emails, no trial extensions, no conversions

## Edge cases

- Zero active trials: "No active trials at this time"
- Conversion rate data unavailable: use base score 50 for all trials, note data gap
