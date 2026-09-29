# Live validation: secondmate homes holding local-only projects

I drove the real firstmate CLI scripts from the gate worktree against a disposable lab
home (`bin/fm-lab-home.sh create`) with the gate marker `NO_MISTAKES_GATE=1` still set.
A private lab tmux server (`bin/fm-lab-home.sh tmux-dir`) hosted the secondmate endpoints,
and real git clones served as projects and origins. Each phase script is next to its log.

| Scenario | Script | Log |
|---|---|---|
| Lab projects and registry | phase0-setup.sh | phase0-setup.log |
| S1 seed a local secondmate with local-only (origin and remoteless) plus direct-PR projects | phase1-seed.sh | phase1-seed.log |
| S2 reseed guards (behind clone, origin/HEAD on another branch, source without a default branch, unresolvable posture) and S3 remote seed refusal | phase2-seed-guards.sh | phase2-seed-guards.log |
| S4/S5 backlog handoff: accepted with a clone; refused without one, to a remote route, or through a symlinked projects/<repo> | phase3-handoff.sh | phase3-handoff.log |
| S5d handoff accepted when projects/ itself is a symlink inside the home; wake control | phase4-handoff-more.sh | phase4-handoff-more.log |
| S6 landing inside the secondmate home with its own fm-merge-local.sh; S7 retirement refusal, carry-back, retirement; S8 unresolved posture refusal | phase5-land-and-retire.sh | phase5-land-and-retire.log |
| S7b retirement when the main home has no clone of the project | phase7-retire-no-parent-clone.sh | phase7-retire-no-parent-clone.log |
| Claude primary routing attempt (stopped at the folder-trust dialog) | phase6-primary-setup.sh | phase6-primary-setup.log, phase6-claude-primary-trust-dialog.txt |
| Targeted test file for this change | tests/fm-secondmate-safety.test.sh | fm-secondmate-safety.test.log |
