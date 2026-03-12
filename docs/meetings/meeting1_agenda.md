# Meeting 1: Stakeholder Alignment
Team: The Box Score Lab
Date/Time: 2026-03-04 10:00
Duration: 60 minutes
Facilitator (PM): Oliver Majano
Notetaker: Minn Naung

Goal of the meeting:
Align on one stakeholder persona, one decision question, sprint scope, and assigned action items.

1) Quick round (5 min)
- Each person: one sentence on what the stakeholder needs from this dataset.

2) Stakeholder persona (10 min)
- Who are they (role and context)?
- What do they care about (top 3 priorities)?
- What constraints do they have (time, budget, risk tolerance)?

Decision:
Stakeholder persona = NBA Team Director of Basketball Analytics - a front-office analyst who advises coaching staff and player personnel on which statistical categories to prioritize in game planning, player evaluation, and roster construction.

3) Decision question (10 to 15 min)
Draft 2 to 3 candidate decision questions and select one.

Candidates:
- "Which box score stats should a modern NBA coaching staff emphasize to maximize win probability?"
- "How should a team's analytical framework shift its stat priorities given decade-over-decade trends?"
- "What statistical profile best predicts winning in the current NBA era?"

Checklist:
- Answerable with our data: Yes - correlation analysis by decade directly addresses this.
- Relevant to a real decision: Yes - front offices allocate scouting, training, and scheme time based on stat priorities.
- Supportable with 3 to 5 evidence artifacts within 2 weeks: Yes.

Final decision question (one sentence):
> Given how the predictive value of box score statistics has shifted across NBA eras, which statistical categories should a modern team's analytics department prioritize when advising coaching staff and player personnel?

4) Success criteria (5 min)
- SC1: Identify the top 3 most win-correlated statistics in the 2020s with supporting decade-over-decade evidence.
- SC2: Demonstrate how at least 2 statistics have meaningfully changed in predictive value over time (with direction and magnitude).
- SC3: Deliver actionable recommendations that distinguish between volume metrics and efficiency metrics where relevant.

5) Scope exclusions (5 min)
What we will not do this sprint:
- Not doing: Player-level analysis (all analysis is at the team-game level).
- Not doing: Predictive modeling or win probability calculators - this sprint is descriptive and correlational only.
- Not doing: Controlling for opponent strength, schedule difficulty, or playoff vs. regular season splits.

6) Evidence brainstorm (10 min)
Candidate evidence artifacts:
- Artifact 1: Correlation heatmap showing all key stats vs. winning by decade.
- Artifact 2: Three-point revolution trend chart (volume, accuracy, and correlation over time).
- Artifact 3: Top-quartile win rate comparison table across stats and decades.
- Trust check: FG% consistency test - verify that FG% remains the top predictor in every individual decade, not just overall.
- Assumption test: Three-point volume vs. accuracy - confirm that 3PA (attempts) shows near-zero correlation while 3PM (makes) shows strong correlation in the 2020s, supporting the "accuracy, not volume" finding.

7) Risks and limitations (5 to 10 min)
- R1: Missing data in early decades (blocks, steals, turnovers, 3-pointers not tracked before the 1970s–80s) could make cross-decade comparisons incomplete or misleading.
- R2: Correlation does not equal causation - a stat correlated with winning may be a byproduct of other factors (e.g., steals may reflect already being ahead, not causing the lead).
- R3: Single-game correlations may not translate to season-level strategy - a team could lose a game with good FG% due to other factors.
- R4: The dataset does not distinguish between regular season and playoff games, which may have different statistical dynamics.

8) Action items (10 min)
- Oliver: Draft the correlation heatmap and three-point trend chart. Due: 2026-03-07.
- Blessing: Build the top-quartile win rate comparison table. Due: 2026-03-07.
- Manuel: Run the trust check (FG% decade-by-decade verification) and assumption test (3PA vs. 3PM correlation split). Due: 2026-03-07.
- Minn: Draft the risk register and begin outlining the Decision Brief structure. Due: 2026-03-07.

9) Wrap (2 min)
Confirmed stakeholder persona (NBA Analytics Director), decision question, and artifact assignments. Next meeting scheduled for 2026-03-09 to review evidence and finalize the brief.
