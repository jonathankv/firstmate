# Live validation: let a secondmate home hold a `local-only` project

Branch `fm/sep28-firstmate-secondmate-local-only-support`, base 6b0f5a0, target ca40017.
Every live scenario ran against a disposable lab home minted with `bin/fm-lab-home.sh create`
(marker allowance, gate env `NO_MISTAKES_GATE=1` left in place) and a private tmux server on
`tmux -L fm-lab` under the lab's `tmux/` socket dir. The default tmux server, the real fleet
home, and the primary checkout were never addressed; the lab was removed in the same turn.

| Scenario | Result | Evidence |
|---|---|---|
| Four new automated tests (seed accepts local-only with origin, remoteless, refuses stale clone; teardown refuses unlanded work) | pass | `automated-tests-local-only.log` |
| S1 seed `alpha [local-only]` whose main home clone is checked out on `hotfix` and whose local `main` is ahead of a stale origin | pass: clone on `main` at the main home's tip 86dd6fc (origin has ef36ff1), `origin/HEAD -> origin/main`, origin URL carried over, route registered, sub-registry synced | `seed-scenarios.transcript` |
| S2 seed remoteless `beta [local-only]` checked out on `feature` | pass: clone on `main` at the source tip, no origin remote | `seed-scenarios.transcript` |
| S3 seed `gamma [local-only]` with only a `trunk` branch | pass: refused "cannot determine default branch", no home created, no route | `seed-scenarios.transcript` |
| S4 seed `delta [local-only forge=bogus]` | pass: parser refusal surfaced, seed refused, no home created | `seed-scenarios.transcript` |
| S5 seed `epsilon [bogus-mode]` | observed: parser maps the unknown token to `no-mistakes off` with a warning (pre-existing), seed then refused for the missing origin | `seed-scenarios.transcript` |
| S6 reseed `alpha` into the same home | pass: existing up-to-date clone accepted, one route line | `landing-scenarios.transcript` |
| S7 main home lands a commit on `beta` `main` after seeding, then reseeds | pass: refused "is behind ... bring it up to date", clone and route left intact; after `git pull --ff-only <main clone> main` the reseed succeeds | `landing-scenarios.transcript` |
| S8 land a `local-only` ship task inside the design home with that home's own `bin/fm-merge-local.sh` | pass: `main` fast-forwarded 86dd6fc -> cd48d8a inside the secondmate home | `landing-scenarios.transcript` |
| S9a non-forced `bin/fm-teardown.sh design` while the secondmate clone holds cd48d8a and the parent does not | pass: refused, names `project alpha: 1 commit(s) on main`, prints the `git bundle` carry-back; home, spawn record, route and tmux window untouched | `teardown-scenarios.transcript`, `teardown-refusal.err` |
| S9b run the printed carry-back verbatim | pass: parent clone gains `refs/heads/secondmate/design/main` = cd48d8a | `teardown-scenarios.transcript` |
| S9c `bin/fm-teardown.sh design` again | pass: retirement completes, home removed, spawn record and route gone, `firstmate:fm-design` window killed on the lab server, parent still holds cd48d8a | `teardown-scenarios.transcript`, `teardown-retire.out` |

Recipes: `lab-setup.sh`, `seed-scenarios.sh`, `landing-scenarios.sh`, `teardown-scenarios.sh`.
