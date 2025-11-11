#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

print_header "Building xml stack (all dependencies)"

# Clean all xml dependencies as a safeguard (even though each script cleans its own)
print_info "Cleaning all xml dependency directories..."
XML_DEPS=("iconv" "libxml" "libxslt" "libexslt")
for dep in "${XML_DEPS[@]}"; do
    rm -rf "${OUTPUT_INCLUDE}/${dep}"
    rm -rf "${OUTPUT_LIB}/${dep}"
    rm -rf "${OUTPUT_SRC}/${dep}"
done
print_info "Cleanup complete"

# Build all xml dependencies in order
# Pass interactive flag if it was set
INTERACTIVE_FLAG=""
if [[ $INTERACTIVE -eq 1 ]]; then
    INTERACTIVE_FLAG="--interactive"
fi

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_xml_1_iconv.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_xml_2_libxml2.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_xml_3_libxslt.sh" ${INTERACTIVE_FLAG}

print_success "XML stack build complete"
