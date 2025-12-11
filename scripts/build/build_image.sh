#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

print_header "Building image stack (all dependencies)"

# Clean all image dependencies as a safeguard (even though each script cleans its own)
print_info "Cleaning all image dependency directories..."
IMAGE_DEPS=("libturbojpeg" "libde265" "libpng" "libheif" "libopenjp2" "ImageMagick-7")
for dep in "${IMAGE_DEPS[@]}"; do
    rm -rf "${OUTPUT_INCLUDE}/${dep}"
    rm -rf "${OUTPUT_LIB}/${dep}"
    rm -rf "${OUTPUT_SRC}/${dep}"
done
print_info "Cleanup complete"

# Build all image dependencies in order
# Pass interactive flag if it was set
INTERACTIVE_FLAG=""
if [[ $INTERACTIVE -eq 1 ]]; then
    INTERACTIVE_FLAG="--interactive"
fi

SCRIPT_DIR="$(dirname "$0")"
"${SCRIPT_DIR}/build_zlib.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_image_1_libturbojpeg.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_image_2_libde265.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_image_3_libpng.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_image_4_libheif.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_image_5_libopenjp2.sh" ${INTERACTIVE_FLAG}
"${SCRIPT_DIR}/build_image_6_imagemagik.sh" ${INTERACTIVE_FLAG}

print_success "Image stack build complete"
