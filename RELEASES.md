# Creating a Release

## Quick Start

Create and push a version tag from the commit you want to release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically build on 4 platforms (Ubuntu 22.04 & 24.04, x86_64 & aarch64) and create a release with all artifacts.

**Important:** The tag points to a specific commit. The build uses the code at that commit, regardless of which branch you create the tag from. For example:
- Tag `v1.0.0` on commit `abc123` → builds code at `abc123`
- Tag `v1.0.0` on main branch → builds main's code at that point
- Tag `v1.0.0` on feature branch → builds that feature branch's code

Make sure the tag points to the commit you want to release.

## Tag Format

Tags must start with `v`:
- ✅ `v1.0.0`, `v2.1.3`
- ❌ `1.0.0` (missing `v` prefix)

## Release Artifacts

Each release includes 4 tarballs (one per platform): `external-{platform}.tar.gz`

## Manual Build (No Release)

Go to **Actions** → **Build and Release Libraries** → **Run workflow** to build without creating a release.

