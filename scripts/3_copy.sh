#!/bin/bash

set -e

# ============================================================================
# PART 1: Source Build Common (reuses platform detection and paths)
# ============================================================================

# Source the build common script for platform detection and output paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/build/_build_common.sh" "$@"

# ============================================================================
# PART 2: Plugin Directory Discovery
# ============================================================================

# Discover the BaseElements-Plugin directory from .env file
discover_plugin_root() {
    local env_file="${PROJECT_ROOT}/.env"
    
    # Check for .env file
    if [[ ! -f "${env_file}" ]]; then
        print_error "ERROR: .env file not found at ${env_file}"
        print_error ""
        print_error "       Please create a .env file in the project root with:"
        print_error "       PLUGIN_ROOT=/path/to/BaseElements-Plugin"
        exit 1
    fi
    
    # Read PLUGIN_ROOT from .env file
    local plugin_root=$(grep -E '^PLUGIN_ROOT=' "${env_file}" | cut -d'=' -f2- | sed 's/^["'\'']//;s/["'\'']$//' | head -1)
    
    if [[ -z "${plugin_root}" ]]; then
        print_error "ERROR: PLUGIN_ROOT not found in .env file"
        print_error ""
        print_error "       Please add to ${env_file}:"
        print_error "       PLUGIN_ROOT=/path/to/BaseElements-Plugin"
        exit 1
    fi
    
    # Resolve any relative paths and expand ~
    plugin_root="${plugin_root/#\~/$HOME}"
    if [[ "${plugin_root}" != /* ]]; then
        # Relative path - resolve relative to PROJECT_ROOT
        plugin_root="$(cd "${PROJECT_ROOT}" && cd "${plugin_root}" && pwd)"
    else
        # Absolute path - just resolve
        plugin_root="$(cd "${plugin_root}" && pwd)"
    fi
    
    # Check if path exists
    if [[ ! -d "${plugin_root}" ]]; then
        print_error "ERROR: PLUGIN_ROOT directory does not exist: ${plugin_root}"
        print_error ""
        print_error "       Please check the path in ${env_file}"
        exit 1
    fi
    
    echo "${plugin_root}"
}

PLUGIN_ROOT="$(discover_plugin_root)"
export PLUGIN_ROOT

# ============================================================================
# PART 3: Plugin Destination Paths
# ============================================================================

EXTERNAL_DIR="${PLUGIN_ROOT}/external"
PLUGIN_PLATFORM_DIR="${PLUGIN_ROOT}/external/${PLATFORM}"
PLUGIN_LIB_DIR="${PLUGIN_ROOT}/external/${PLATFORM}/lib"
PLUGIN_HEADERS_DIR="${PLUGIN_ROOT}/external/${PLATFORM}/include"
PLUGIN_SOURCE_DIR="${PLUGIN_ROOT}/external/${PLATFORM}/src"

export PLUGIN_LIB_DIR
export PLUGIN_HEADERS_DIR
export PLUGIN_SOURCE_DIR

# ============================================================================
# PART 4: Copy Operations
# ============================================================================

print_header "Copy Configuration"
print_info "  OS: ${OS}"
print_info "  ARCH: ${ARCH}"
print_info "  PLATFORM: ${PLATFORM}"
print_info "  PROJECT_ROOT: ${PROJECT_ROOT}"
print_info "  OUTPUT_DIR: ${OUTPUT_DIR}"
print_info "  OUTPUT_INCLUDE: ${OUTPUT_INCLUDE}"
print_info "  OUTPUT_LIB: ${OUTPUT_LIB}"
print_info "  OUTPUT_SRC: ${OUTPUT_SRC}"
print_info "  PLUGIN_ROOT: ${PLUGIN_ROOT}"
print_info "  PLUGIN_LIB_DIR: ${PLUGIN_LIB_DIR}"
print_info "  PLUGIN_HEADERS_DIR: ${PLUGIN_HEADERS_DIR}"
print_info "  PLUGIN_SOURCE_DIR: ${PLUGIN_SOURCE_DIR}"

echo ""

# Remove platform-specific directory
print_header "Remove platform-specific directory"
print_info "Platform: ${PLATFORM}"
print_info "Path to remove: ${PLUGIN_PLATFORM_DIR}"
if [[ $INTERACTIVE -eq 1 ]]; then
    interactive_prompt "Ready to remove platform-specific directory"
fi
rm -rf "${PLUGIN_PLATFORM_DIR}"
print_success "Platform-specific directory removed"

echo ""

# Copy headers
print_header "Copying headers"
print_info "Source: ${OUTPUT_INCLUDE}/"
print_info "Destination: ${PLUGIN_HEADERS_DIR}/"
if [[ $INTERACTIVE -eq 1 ]]; then
    interactive_prompt "Ready to copy headers"
fi
mkdir -p "${PLUGIN_HEADERS_DIR}"
cp -r "${OUTPUT_INCLUDE}"/* "${PLUGIN_HEADERS_DIR}/" 2>/dev/null || {
    print_error "ERROR: No headers found in ${OUTPUT_INCLUDE}"
    exit 1
}
print_success "Headers copied"

echo ""

# Copy libraries
print_header "Copying libraries"
print_info "Source: ${OUTPUT_LIB}/"
print_info "Destination: ${PLUGIN_LIB_DIR}/"
if [[ $INTERACTIVE -eq 1 ]]; then
    interactive_prompt "Ready to copy libraries"
fi
mkdir -p "${PLUGIN_LIB_DIR}"
# Copy all library files from all subdirectories
find "${OUTPUT_LIB}" -name "*.a" -type f -exec cp {} "${PLUGIN_LIB_DIR}/" \; || {
    print_error "ERROR: No libraries found in ${OUTPUT_LIB}"
    exit 1
}
print_success "Libraries copied"

echo ""

# Copy duktape source files (if they exist)
if [[ -f "${OUTPUT_SRC}/duktape/src/duktape.c" ]] && [[ -f "${OUTPUT_SRC}/duktape/src/duktape.h" ]] && [[ -f "${OUTPUT_SRC}/duktape/src/duk_config.h" ]]; then
    print_header "Copying duktape source files"
    print_info "Source: ${OUTPUT_SRC}/duktape/src/"
    print_info "Destination: ${PLUGIN_SOURCE_DIR}/duktape/"
    if [[ $INTERACTIVE -eq 1 ]]; then
        interactive_prompt "Ready to copy duktape source files"
    fi
    mkdir -p "${PLUGIN_SOURCE_DIR}/duktape"
    cp "${OUTPUT_SRC}/duktape/src/duktape.c" "${PLUGIN_SOURCE_DIR}/duktape/"
    cp "${OUTPUT_SRC}/duktape/src/duktape.h" "${PLUGIN_SOURCE_DIR}/duktape/"
    cp "${OUTPUT_SRC}/duktape/src/duk_config.h" "${PLUGIN_SOURCE_DIR}/duktape/"
    print_success "Duktape source files copied"
else
    print_info "Duktape source files not found, skipping"
fi

echo ""

# Copy FM Plugin SDK (if it exists)
if [[ -d "${OUTPUT_DIR}/PlugInSDK" ]]; then
    print_header "Copying FM Plugin SDK"
    print_info "Source: ${OUTPUT_DIR}/PlugInSDK/"
    print_info "Destination: ${PLUGIN_PLATFORM_DIR}/PlugInSDK/"
    if [[ $INTERACTIVE -eq 1 ]]; then
        interactive_prompt "Ready to copy FM Plugin SDK"
    fi
    cp -R -P "${OUTPUT_DIR}/PlugInSDK" "${PLUGIN_PLATFORM_DIR}/"
    print_success "FM Plugin SDK copied"
else
    print_info "FM Plugin SDK not found, skipping"
fi

echo ""

# Copy FMWrapper headers to include directory (Nick requested this - macOS only)
if [[ $OS = 'Darwin' ]] && [[ -d "${OUTPUT_DIR}/PlugInSDK/Headers/FMWrapper" ]]; then
    print_header "Copying FMWrapper headers to include/"
    print_info "Source: ${OUTPUT_DIR}/PlugInSDK/Headers/FMWrapper/"
    print_info "Destination: ${PLUGIN_HEADERS_DIR}/FMWrapper/"
    if [[ $INTERACTIVE -eq 1 ]]; then
        interactive_prompt "Ready to copy FMWrapper headers"
    fi
    mkdir -p "${PLUGIN_HEADERS_DIR}/FMWrapper"
    cp -r "${OUTPUT_DIR}/PlugInSDK/Headers/FMWrapper"/* "${PLUGIN_HEADERS_DIR}/FMWrapper/"
    print_success "FMWrapper headers copied"
elif [[ $OS = 'Darwin' ]]; then
    print_info "FMWrapper headers not found, skipping"
fi

echo ""
print_success "Copy operations complete"
