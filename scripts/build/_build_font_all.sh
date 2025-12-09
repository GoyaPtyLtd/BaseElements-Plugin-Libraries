#!/bin/bash
set -e

print_header "Building font stack (all dependencies)"

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_libunistring.sh"
"${SCRIPT_DIR}/build_libexpat.sh"
"${SCRIPT_DIR}/build_freetype.sh"
"${SCRIPT_DIR}/build_fontconfig.sh"

print_success "Font stack build complete"
