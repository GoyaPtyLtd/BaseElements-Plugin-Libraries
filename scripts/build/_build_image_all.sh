#!/bin/bash
set -e

print_header "Building image stack (all dependencies)"

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_zlib.sh"
"${SCRIPT_DIR}/build_libturbojpeg.sh"
"${SCRIPT_DIR}/build_libopenjp2.sh"
"${SCRIPT_DIR}/build_libde265.sh"
"${SCRIPT_DIR}/build_libheif.sh"
"${SCRIPT_DIR}/build_imagemagik.sh"

print_success "Image stack build complete"
