---
name: Release
about: When ready to cut a release
title: Release X.Y.Z
labels: release
assignees: ""
---

- [ ] Confirm the staging environment is healthy (including Green checkmark on last [CI build](https://github.com/azavea/pfb-network-connectivity/actions/workflows/ci.yml)) and your local environment is on the `develop` branch and up to date
- [ ] Start a new release branch:

```bash
git flow release start X.Y.Z
```

- [ ] Rotate `CHANGELOG.md` (following [Keep a Changelog](https://keepachangelog.com/) principles)
- [ ] Ensure outstanding changes are committed:

```bash
git status # Is the git staging area clean?
git add CHANGELOG.md
git commit -m "X.Y.Z"
```

- [ ] Finish and merge the release branch:
  - When prompted, keep default commit messages
  - Use `X.Y.Z` as the tag message

```bash
git flow release finish -p X.Y.Z
```

- [ ] This will kick off a new develop build and staging deploy. Wait until that is fully done (Green checkbox on [build](https://github.com/azavea/pfb-network-connectivity/actions/workflows/ci.yml)) and [staging](https://staging.pfb.azavea.com/) is working from it.
- [ ] Start a new [Deploy Production workflow](https://github.com/azavea/pfb-network-connectivity/actions/workflows/deploy_production.yml) with the SHA (see command below) of `release/X.Y.Z` that was tested on staging

```bash
git rev-parse --short=16 HEAD
```

- [ ] Run migrations, if applicable, following [these instructions](https://github.com/azavea/pfb-network-connectivity/tree/develop/deployment#migrations)
