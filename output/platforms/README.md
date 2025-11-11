This directory contains platform-specific build outputs.

Each subdirectory follows the naming pattern: `{os}{version}-{arch}/`
Examples:
- `ubuntu24.04-x86_64/`
- `ubuntu24.04-aarch64/`
- `macos-arm64-x86_64/`

Each platform directory contains:
- `include/` - Header files (not tracked in git)
- `lib/` - Library files (not tracked in git)
- `src/` - Extracted source code (not tracked in git)
- `frameworks/` - macOS frameworks (macOS only, not tracked in git)

