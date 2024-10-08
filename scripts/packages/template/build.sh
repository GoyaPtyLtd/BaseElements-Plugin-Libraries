#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

# Fetch source package.
#
# Uses global variables:
#   PACKAGE_NAME            - from package dirname
#   SOURCE_URL              - package variable
#   SOURCE_HASH             - package variable
#   PACKAGE_DOWNLOAD_DIR
#   SOURCE_PLATFORM_ROOT
#
# Sets global variables:
#   PACKAGE_FILE            - Full path to downloaded package.
#
# Returns 0 (true) if the file was downloaded, 1 if it already exists.
#fetch() {
#}

# Unpack source package. Only called when ${PACKAGE_SOURCE_DIR} is missing/empty.
#
# Uses global variables:
#   PACKAGE_FILE            - from fetch()
#   PACKAGE_SOURCE_DIR
#unpack() {
#}

# Build package.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR      - from fetch()
#   OS
#   PLATFORM
#   FRAMEWORKS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   HEADERS_ROOT
#   BUILD_LOG
#build() {
#    print_ok "Build Task test."
#    (
#        echo "I am the build process ...."
#        sleep 5;
#        echo "... build process done."
#
#        exit 0
#    ) >> "${BUILD_LOG}" 2>&1 &
#    wait_progress $!
#    return_code=$?
#    if [[ $return_code -eq 0 ]]; then
#        print_ok "Build Task test done, rc: $return_code"
#    else
#        print_error "Build Task test failed, rc: $return_code"
#    fi
#}

# Clean source package.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR
#clean_source() {
#}

# Clean output files.
#
# Uses global variables:
#   LIBRARIES
#   FRAMEWORKS
#   HEADERS
#   LIBRARIES_DIR
#   FRAMEWORKS_ROOT
#   HEADERS_ROOT
#clean_output() {
#}

# Check output files / directories exist. Used to determine if the package
# has been installed.
#
# Uses global variables:
#   PLATFORM
#   LIBRARIES
#   FRAMEWORKS
#   HEADERS
#   LIBRARIES_DIR
#   FRAMEWORKS_ROOT
#   HEADERS_ROOT
#
# Returns 0 if all output exist, 1 if any are missing.
#check_output() {
#}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../../build-functions
# --- BOILERPLATE ---
