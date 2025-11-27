#!/bin/bash
# Bash 3 compatible - no bash 4+ features used

# Note: We build with clang on Linux (not GCC) to ensure consistency.
# To verify libraries were built with clang, run from output/platforms/{platform}/lib/:
#   for i in *.a; do echo "++ Checking: $i"; strings -a $i | grep GCC | grep -v except_table; done
# Expected: Only "++ Checking: ..." messages, no GCC version strings.
# If you see "GCC: (Ubuntu ...)" output, that library was built with GCC instead of clang.

set -e

# Parse --build/-b flag before sourcing _build_common.sh
# Accept multiple library names after --build/-b
BUILD_TARGETS=()
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --build|-b)
            shift  # Remove --build/-b flag
            # Collect all library names until we hit another flag (starts with -)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -*)
                        break
                        ;;
                    *)
                        BUILD_TARGETS+=("$1")
                        shift
                        ;;
                esac
            done
            if [[ ${#BUILD_TARGETS[@]} -eq 0 ]]; then
                echo "ERROR: --build/-b requires at least one library name" >&2
                echo "Available libraries: all, jq, duktape, curl, font, image, xml, boost, podofo, fm_plugin_sdk" >&2
                exit 1
            fi
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
# Restore remaining arguments for _build_common.sh
set -- "${ARGS[@]}"

# Source common build functionality (handles --interactive flag, platform detection, colors, helpers)
source "$(dirname "$0")/build/_build_common.sh" "$@"

print_header "Build Configuration"
print_info "  OS: ${OS}"
print_info "  ARCH: ${ARCH}"
print_info "  PLATFORM: ${PLATFORM}"
print_info "  JOBS: ${JOBS}"
print_info "  PROJECT_ROOT: ${PROJECT_ROOT}"
print_info "  SOURCE_ARCHIVES: ${SOURCE_ARCHIVES}"
print_info "  OUTPUT_DIR: ${OUTPUT_DIR}"
print_info "  OUTPUT_INCLUDE: ${OUTPUT_INCLUDE}"
print_info "  OUTPUT_LIB: ${OUTPUT_LIB}"
print_info "  OUTPUT_SRC: ${OUTPUT_SRC}"

if [[ $INTERACTIVE -eq 1 ]]; then
    echo ""
    print_header "Interactive mode enabled - you will be prompted before each build"
    export INTERACTIVE_FLAG="--interactive"
else
    export INTERACTIVE_FLAG=""
fi

echo ""
cd "$(dirname "$0")/build"

# Map library names to build scripts (bash 3 compatible - using function instead of associative array)
get_build_script() {
    case "$1" in
        jq) echo "build_jq.sh" ;;
        duktape) echo "build_duktape.sh" ;;
        curl) echo "build_curl.sh" ;;
        font) echo "build_font.sh" ;;
        image) echo "build_image.sh" ;;
        xml) echo "build_xml.sh" ;;
        boost) echo "build_boost.sh" ;;
        podofo) echo "build_podofo.sh" ;;
        fm_plugin_sdk) echo "build_fm_plugin_sdk.sh" ;;
        *) echo "" ;;
    esac
}

# List of all available libraries (for error messages)
AVAILABLE_LIBS="jq duktape curl font image xml boost podofo fm_plugin_sdk"

# Show usage if no --build flag provided
if [[ ${#BUILD_TARGETS[@]} -eq 0 ]]; then
    echo ""
    print_header "Usage: $0 --build <library> [library2 ...] [--interactive]"
    echo ""
    echo "  or: $0 -b <library> [library2 ...] [-i]"
    echo ""
    echo "Build specific libraries or all libraries:"
    echo ""
    echo "Available libraries: all, jq, duktape, curl, font, image, xml, boost, podofo, fm_plugin_sdk"
    echo ""
    echo "  --build all                Build all libraries"
    echo "  --build jq                 Build only jq"
    echo "  --build boost jq           Build boost and jq"
    echo "  --build jq duktape curl    Build jq, duktape, and curl"
    echo ""
    echo "Options:"
    echo "  --interactive, -i  Enable interactive mode (prompt before each step)"
    echo ""
    exit 1
fi

# Check if "all" is in the list
BUILD_ALL=false
for target in "${BUILD_TARGETS[@]}"; do
    if [[ "$target" == "all" ]]; then
        BUILD_ALL=true
        break
    fi
done

if [[ "$BUILD_ALL" == true ]]; then
    # Build all libraries
    print_header "Building all libraries for platform: ${PLATFORM}"
    ./build_jq.sh ${INTERACTIVE_FLAG}
    ./build_duktape.sh ${INTERACTIVE_FLAG}
    ./build_curl.sh ${INTERACTIVE_FLAG}
    ./build_font.sh ${INTERACTIVE_FLAG}
    ./build_image.sh ${INTERACTIVE_FLAG}
    ./build_xml.sh ${INTERACTIVE_FLAG}
    ./build_boost.sh ${INTERACTIVE_FLAG}
    ./build_podofo.sh ${INTERACTIVE_FLAG}
    ./build_fm_plugin_sdk.sh ${INTERACTIVE_FLAG}
else
    # Build each specified library
    for BUILD_TARGET in "${BUILD_TARGETS[@]}"; do
        BUILD_SCRIPT=$(get_build_script "$BUILD_TARGET")
        if [[ -z "$BUILD_SCRIPT" ]]; then
            print_error "ERROR: Unknown library '${BUILD_TARGET}'"
            echo ""
            echo "Available libraries:"
            echo "  - all"
            for lib in $AVAILABLE_LIBS; do
                echo "  - ${lib}"
            done
            exit 1
        fi
        
        if [[ ! -f "$BUILD_SCRIPT" ]]; then
            print_error "ERROR: Build script not found: ${BUILD_SCRIPT}"
            exit 1
        fi
        
        print_header "Building ${BUILD_TARGET} for platform: ${PLATFORM}"
        ./"${BUILD_SCRIPT}" ${INTERACTIVE_FLAG}
        echo ""
    done
fi

cd ..
