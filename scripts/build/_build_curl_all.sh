#!/bin/bash
set -e

print_header "Building curl stack (all dependencies)"

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_openssl.sh"
"${SCRIPT_DIR}/build_libssh.sh"
"${SCRIPT_DIR}/build_nghttp2.sh"
"${SCRIPT_DIR}/build_curl.sh"
"${SCRIPT_DIR}/build_poco.sh"

print_success "Curl stack build complete"
