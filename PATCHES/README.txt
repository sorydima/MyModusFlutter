This folder should contain git-format-patch outputs. Since this environment doesn't have
your git repository, please do the following locally to generate patches after copying files:

1. Copy the package contents into your repository root.
2. Create a new branch: git checkout -b sprint/1-full
3. Add files and commit: git add . && git commit -m "sprint(1): add auth, migrate, frontend screens, CI"
4. Generate patches: git format-patch origin/develop --stdout > sprint1-full.patch

You can attach sprint1-full.patch to a PR or apply with 'git am' on the target repo.
