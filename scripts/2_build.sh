#!/bin/bash

# Note: We build with clang on Linux (not GCC) to ensure consistency.
# To verify libraries were built with clang, run from output/platforms/{platform}/lib/:
#   for i in *.a; do echo "++ Checking: $i"; strings -a $i | grep GCC | grep -v except_table; done
# Expected: Only "++ Checking: ..." messages, no GCC version strings.
# If you see "GCC: (Ubuntu ...)" output, that library was built with GCC instead of clang.

set -e

# Parse arguments
INTERACTIVE=0
while [[ $# -gt 0 ]]; do
    case $1 in
        --interactive|-i)
            INTERACTIVE=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--interactive|-i]"
            exit 1
            ;;
    esac
done

# Source shared platform detection and export variables for sub-scripts
source "$(dirname "$0")/build/_build_common.sh"

echo "_build_common.sh: Platform detection complete"
echo "  OS: ${OS}"
echo "  ARCH: ${ARCH}"
echo "  PLATFORM: ${PLATFORM}"
echo "  JOBS: ${JOBS}"
echo "  PROJECT_ROOT: ${PROJECT_ROOT}"
echo "  SOURCE_ARCHIVES: ${SOURCE_ARCHIVES}"
echo "  OUTPUT_DIR: ${OUTPUT_DIR}"
echo "  OUTPUT_INCLUDE: ${OUTPUT_INCLUDE}"
echo "  OUTPUT_LIB: ${OUTPUT_LIB}"
echo "  OUTPUT_SRC: ${OUTPUT_SRC}"

if [[ $INTERACTIVE -eq 1 ]]; then
    echo ""
    echo "Interactive mode enabled - you will be prompted before each build"
    export INTERACTIVE_FLAG="--interactive"
else
    export INTERACTIVE_FLAG=""
fi

echo ""
echo "Building all libraries for platform: ${PLATFORM}"

cd build
#./build_jq.sh ${INTERACTIVE_FLAG}


# ./build_duktape.sh


# ./build_curl.sh
# ./build_font.sh
# ./build_image.sh
# ./build_xml.sh

# ./build_boost.sh

# ./build_podofo.sh

# cd ..
