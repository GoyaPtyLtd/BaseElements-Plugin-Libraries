#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

print_header "Building curl stack (all dependencies)"

# Clean all curl dependencies as a safeguard (even though each script cleans its own)
print_info "Cleaning all curl dependency directories..."
CURL_DEPS=("zlib" "openssl" "libssh2" "nghttp2" "curl" "poco")
for dep in "${CURL_DEPS[@]}"; do
    rm -rf "${OUTPUT_INCLUDE}/${dep}"
    rm -rf "${OUTPUT_LIB}/${dep}"
    rm -rf "${OUTPUT_SRC}/${dep}"
done
print_info "Cleanup complete"

# Build all curl dependencies in order
# Pass interactive flag if it was set
INTERACTIVE_FLAG=""
if [[ $INTERACTIVE -eq 1 ]]; then
    INTERACTIVE_FLAG="--interactive"
fi

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_zlib.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_curl_2_openssl.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_curl_3_libssh.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_curl_4_nghttp2.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_curl_5_curl.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_curl_6_poco.sh" ${INTERACTIVE_FLAG}

print_success "Curl stack build complete"
