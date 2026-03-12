# Meeting 2 Notes: Decision Review and Finalize Brief
Date/Time: 2026-03-09 10:00
Facilitator: Oliver Majano
Attendees: Oliver Majano, Blessing Cheng, Manuel Rafanan, Minn Naung

## Evidence reviewed
- A1: Correlation heatmap - FG% is the strongest predictor in every decade. Three-pointers made show the biggest positive shift over time. Steals and free throws show clear declines.
- A2: Three-point trend chart - Volume increased 624% from the 1980s to 2020s, but the correlation with winning only became meaningful once accuracy improved. Top-quartile win rate climbed from 44.6% to 66.3%.
- A3: Top-quartile win rate table - FG% and 3PM top-quartile teams win at the highest rates in the 2020s (66%+). Turnovers remain modestly negative across all decades. Free throws and fouls have weakened noticeably.
- Trust check: Confirmed - FG% has the highest point-biserial correlation with winning in every single decade from the 1970s through 2020s. No exceptions.
- Assumption test: Confirmed - 3PA correlation in the 2020s is +0.004 (essentially zero), while 3PM correlation is +0.268. This validates the finding that accuracy, not volume, separates winners from losers.

## Final recommendation (draft)
- R1: Prioritize shooting efficiency above all else. FG% is the most durable and strongest single predictor of winning across all eras (+0.454 in the 2020s). Training time and scheme design should center on creating high-percentage looks.
- R2: Invest in three-point accuracy, not just volume. Every team shoots threes now - what separates winners is making them. Scouting and player development should weight three-point shooting percentage heavily.
- R3: De-emphasize turnover avoidance as a top priority. Turnovers hurt, but the data shows they are a modest predictor (-0.107) and high-turnover teams still win 42-43% of the time. Aggressive, pace-driven play that generates some turnovers is an acceptable tradeoff.

## Final risks and limitations
- L1: Correlations describe population-level tendencies across ~145,000 games, not guarantees for individual games. Apply findings to long-term strategy, not single-game decisions.
- L2: Correlation does not establish causation. Some stats (e.g., steals) may be byproducts of being ahead rather than causes of winning.
- L3: Data does not separate regular season from playoffs, and playoff basketball may have different statistical dynamics.

## Final action items
- Oliver: Review all evidence artifacts for completeness, update sprint board, and coordinate final review of the Decision Brief. (Due: 2026-03-11) DoD: Sprint board updated with final statuses; brief reviewed and approved by full team.
- Blessing: Polish the top-quartile win rate table and ensure all evidence scripts run cleanly end-to-end. (Due: 2026-03-10) DoD: Clean table ready for brief; scripts confirmed to produce all outputs without errors.
- Manuel: Finalize run_sprint3.sh, generate ops_proof.txt, and write up trust check and assumption test results. (Due: 2026-03-10) DoD: Entry script runs end-to-end; ops proof shows background run and monitoring; two write-ups with supporting numbers.
- Minn: Finalize the Decision Brief with all evidence integrated. Commit Meeting 2 artifacts via PR. (Due: 2026-03-11) DoD: Complete 1-2 page brief with all required sections; meeting2 files committed to docs/meetings/.
