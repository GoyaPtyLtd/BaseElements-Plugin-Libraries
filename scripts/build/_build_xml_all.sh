#!/bin/bash
set -e

print_header "Building xml stack (all dependencies)"

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_iconv.sh"
"${SCRIPT_DIR}/build_libxml2.sh"
"${SCRIPT_DIR}/build_libxslt.sh"

print_success "XML stack build complete"
