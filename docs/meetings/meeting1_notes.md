# Meeting 1 Notes: Stakeholder Alignment
Date/Time: 2026-03-04 10:00
Facilitator: Oliver Majano
Attendees: Oliver Majano, Blessing Cheng, Manuel Rafanan, Minn Naung

## Decisions made
- Stakeholder persona: NBA Team Director of Basketball Analytics - someone who advises coaching staff and front office on which stats to emphasize in scouting, game planning, and roster decisions.
- Decision question: "Given how the predictive value of box score statistics has shifted across NBA eras, which statistical categories should a modern team's analytics department prioritize when advising coaching staff and player personnel?"
- Success criteria:
  - SC1: Identify the top 3 most win-correlated stats in the 2020s with decade-over-decade evidence.
  - SC2: Show how at least 2 stats have meaningfully changed in predictive value over time.
  - SC3: Deliver actionable recommendations that separate volume metrics from efficiency metrics.
- Scope exclusions:
  - No player-level analysis (team-game level only).
  - No predictive modeling or win probability tools.
  - No opponent-strength adjustments or playoff/regular-season splits.

## Open questions
- Q1: Should we include the 1950s and 1960s in our visualizations, or start from the 1970s when most stats began being tracked? Team leaning toward 1970s onward for cleaner comparisons.
- Q2: Do we want to address offensive vs. defensive rebounds separately in the brief, or keep it at total rebounds? The data supports splitting them - offensive rebounds are essentially uncorrelated with winning in the 2020s.

## Evidence plan (draft)
- Decision-driving artifacts:
  - Correlation heatmap (all stats x decades)
  - Three-point revolution trend chart
  - Top-quartile win rate comparison table
- Trust check: Verify FG% is the top predictor in every individual decade.
- Assumption test: Confirm 3PA has near-zero correlation vs. 3PM strong positive correlation in the 2020s.

## Action items (summary)
- Oliver: Commit Meeting 1 artifacts, set up sprint board (Due: 2026-03-07)
- Blessing: Correlation heatmap + top-quartile win rate table scripts (Due: 2026-03-07)
- Manuel: run_sprint3.sh entry script + trust check + assumption test (Due: 2026-03-07)
- Minn: Risk register + Decision Brief outline + three-point trend narrative (Due: 2026-03-07)
