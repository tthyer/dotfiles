---
name: prune-worktrees
description: Find and remove stale worktrees whose branches have been merged or whose PRs were closed
allowed-tools: Bash, Read
---

# Prune Stale Worktrees

Identify worktrees with branches that have already been merged or had their PRs closed, and offer to remove them. This supplements `wt step prune`, which can miss squash-merged branches when the same files were later changed on the default branch.

## Step 1: List worktrees and their PR status

Run `git worktree list` to get all worktrees. For each non-primary worktree, extract the branch name and check its PR status using `gh pr list --head <branch> --state all`.

Categorize each worktree:
- **Merged**: PR state is `MERGED`
- **Closed**: PR state is `CLOSED` (not merged)
- **Open**: PR state is `OPEN`
- **No PR**: No PR found for the branch

## Step 2: Present findings

Show the user a table with columns: worktree name, branch, PR number, PR status. Group by category (merged, closed, open, no PR).

## Step 3: Remove stale worktrees

Ask the user which categories to clean up (merged, closed, or both). Then run `wt remove -D <branch> -y` for each confirmed worktree.

If a removal fails due to untracked files, retry with `wt remove -D -f <branch> -y`.

## Notes

- Always ask before removing. Never remove worktrees autonomously.
- "Open" and "No PR" worktrees should not be removed unless the user explicitly requests it.
- The `-D` flag is needed because squash-merged branches are not recognized as merged by git.
