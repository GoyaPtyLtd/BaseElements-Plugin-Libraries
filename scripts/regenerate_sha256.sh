#!/bin/bash
# Generates SHA256 hashes for all files in the source/ directory.
# Output is written to source/SHA256SUMS in standard format.
# This file should be committed to the repository for verification.

set -e

# Source common build functionality (colors, helpers)
source "$(dirname "$0")/build/_build_common.sh"

# Get script directory and change to source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/../source"

if [[ ! -d "$SOURCE_DIR" ]]; then
    print_error "ERROR: Source directory not found: ${SOURCE_DIR}"
    exit 1
fi

cd "$SOURCE_DIR" || {
    print_error "ERROR: Failed to change to source directory"
    exit 1
}

print_header "Generating SHA256 hashes for source archives"

# Check if sha256sum is available (Linux) or shasum (macOS)
if command -v sha256sum >/dev/null 2>&1; then
    SHA256_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
    SHA256_CMD="shasum -a 256"
else
    print_error "ERROR: Neither sha256sum nor shasum is available"
    exit 1
fi

# Generate SHA256SUMS file for all files (excluding README.md and SHA256SUMS itself)
print_info "Generating SHA256SUMS..."

# Remove old SHA256SUMS if it exists
rm -f "SHA256SUMS"

# Generate hashes for all files except README.md and SHA256SUMS
find . -maxdepth 1 -type f ! -name "README.md" ! -name ".DS_Store" ! -name "SHA256SUMS" -print0 | sort -z | while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    print_info "  Computing hash for ${filename}..."
    $SHA256_CMD "$file" >> "SHA256SUMS"
done

# Sort the file by filename for consistency
sort -k 2 "SHA256SUMS" > "SHA256SUMS.tmp"
mv "SHA256SUMS.tmp" "SHA256SUMS"

echo ""
print_success "SHA256 hashes generated successfully!"
print_info "  File: ${SOURCE_DIR}/SHA256SUMS"
echo ""
print_info "Next steps:"
print_info "  1. Review SHA256SUMS to ensure all hashes are correct"
print_info "  2. Commit SHA256SUMS to the repository"

