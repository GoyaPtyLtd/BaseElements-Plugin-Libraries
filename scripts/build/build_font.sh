#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

print_header "Building font stack (all dependencies)"

# Clean all font dependencies as a safeguard (even though each script cleans its own)
print_info "Cleaning all font dependency directories..."
FONT_DEPS=("libunistring" "libexpat" "freetype2" "fontconfig")
for dep in "${FONT_DEPS[@]}"; do
    rm -rf "${OUTPUT_INCLUDE}/${dep}"
    rm -rf "${OUTPUT_LIB}/${dep}"
    rm -rf "${OUTPUT_SRC}/${dep}"
done
print_info "Cleanup complete"

# Build all font dependencies in order
# Pass interactive flag if it was set
INTERACTIVE_FLAG=""
if [[ $INTERACTIVE -eq 1 ]]; then
    INTERACTIVE_FLAG="--interactive"
fi

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_font_1_libunistring.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_font_2_libexpat.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_font_3_freetype.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_font_4_fontconfig.sh" ${INTERACTIVE_FLAG}

print_success "Font stack build complete"
