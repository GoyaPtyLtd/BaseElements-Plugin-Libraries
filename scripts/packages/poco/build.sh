#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

# Uncomment example functions below to override the builtin_* defaults.
#
# Any non-virtual package should at least define build()
#
# See functions named builtin_* in scripts/packages/build-functions for
# default versions of these functions.
#
# When using custom global variables to exchange data between these
# functions, ensure a capitalised prefix of the package name is used
# to prevent clashes. For example, if the package name is "foo", then
# use FOO_ as the variable name prefix.
#
# When using local variables within functions, please ensure they are
# declared as local.
#
# It is also possible to reference any variable stored in the "package" file
# here.

# Fetch source package.
#
# Uses global variables:
#   SOURCE_URL              - package variable
#   SOURCE_HASH             - package variable
#   PACKAGE_NAME
#   PACKAGE_DOWNLOAD_DIR
#
# Sets global variables:
#   PACKAGE_FILE            - Full path to downloaded package.
#
# Returns 0 (true) if the file was downloaded, 1 otherwise.
#
#fetch() {
#    # If more assets are needed than the single SOURCE_URL, then this might
#    # be a good place to do that.
#    #
#    # Consider though, that this might be better handled as a separate package
#    # that is instead listed under DEPENDENCIES in the "package" file.
#
#    local my_url="http://example.com/foo.tar.gz"
#    local my_hash="MD5:86d..."
#    local my_download_dir="/tmp"
#    local my_file="${my_download_dir}/$(basename "${SOURCE_URL}")"
#
#    fetch_and_verify_file "$my_url" "$my_hash" "$my_download_dir"
#    local fetch_result=$?
#
#    echo "Do something with $my_file"
#
#    return $fetch_result
#}

# Unpack source package. Only called when ${PACKAGE_SOURCE_DIR} is missing/empty.
#
# Uses global variables:
#   PACKAGE_FILE            - from fetch()
#   PACKAGE_SOURCE_DIR
#unpack() {
#    # If the source package is more complicated than either a tar file
#    # where the first component of the path is stripped and extracted
#    # into a directory of this packages name, or a zip file that is just
#    # expanded into a directory of this packages name, then this is the place
#    # to do that.
#}

# Build package.
#
# Almost every package will need to define a build() function.
#
# Only a virtual package does not define a build() function. It is just used
# as a way to group DEPENDENCIES in the "package" file.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR      - from fetch()
#   OS
#   PLATFORM
#   HEADERS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   FRAMEWORKS_ROOT
#   BUILD_LOG
build() {
    print_ok "Build Task Test."
    echo "------ Build Task Test ------" >> ${BUILD_LOG}
    (
        echo "I am the build process ...."
        sleep 5;
        echo "... build process done."

        exit 0
    ) >> "${BUILD_LOG}" 2>&1 &
    wait_progress $!
    return_code=$?
    if [[ $return_code -ne 0 ]]; then
        # The build failed, we must exit with a non-zero exit code, and not
        # continue so a user may see the error, inspect the log, and state
        # of the build.
        print_error "Build Task Test failed. Return code: $return_code"
        exit 1
    fi

    print_ok "Build Task Test complete."

    # Finish any other install / copy tasks here.
}

# Clean source package.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR
#clean_source() {
#    # If a custom unpack() was needed, you might need a custom clean up
#    # if more than ${PACKAGE_SOURCE_DIR} and ${BUILD_LOG} should be deleted.
#}

# Clean output files.
#
# Uses global variables:
#   HEADERS                 - package variable
#   LIBRARIES               - package variable
#   FRAMEWORKS              - package variable
#   HEADERS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   FRAMEWORKS_ROOT
#clean_output() {
#    # The builtin version of this function will clean out whatever is
#    # listed in the HEADERS, LIBRARIES and FRAMEWORKS variables in the
#    # "package" file. If more than this is needed to remove all output
#    # from the package build, then this is the place to do that.
#
#    # Call builtin version of this function.
#    builtin_clean_output
#
#    # Now do any custom output clean up.
#}

# Check output files / directories exist. Used to determine if the package
# has been installed (and does not need to be built).
#
# Uses global variables:
#   PLATFORM
#   HEADERS                 - package variable
#   LIBRARIES               - package variable
#   FRAMEWORKS              - package variable
#   HEADERS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   FRAMEWORKS_ROOT
#
# Returns 0 (true) if all output exist, 1 if any are missing.
#check_output() {
#    # The builtin version of this function will check for the existence of
#    # whatever is listed in the HEADERS, LIBRARIES and FRAMEWORKS variables
#    # in the "package" file. If more than this is needed to determine if the
#    # package has been installed, then this is the place to do that.
#
#    # Call builtin version of this function.
#    builtin_check_output
#    local builtin_result=$?
#
#    if [[ $builtin_result -ne 0 ]]; then
#        # No point going further if the builtin version of this function
#        # says output is missing.
#        return 1
#    fi
#
#    # Now do any custom output check. Return 0 if all output exists, 1 if any
#    # are missing.
#}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
