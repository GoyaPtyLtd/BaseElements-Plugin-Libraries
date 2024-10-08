#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---


# Build package.
#
# Almost every package will need to define a build() function.
#
# Only a virtual package does not define a build() function. It is just used
# as a way to group DEPENDENCIES in the "package" file.
#
# Uses global variables:
#   PACKAGE_SRC      - from fetch()
#   PLATFORM
#   PLATFORM_INCLUDE
#   PLATFORM_LIBS
#   PLATFORM_FRAMEWORKS
#   BUILD_LOG
build() {
    cd "${PACKAGE_SRC}" || exit 1


    # This is all a bit of a kludge, I would hope we can build this as a
    # static library instead - GAV

    print_ok "Installing duktape source files."
    rsync -rq src/* "${PLATFORM_INCLUDE}/duktape/"
}

# Clean output files.
#
# Uses global variables:
#   HEADERS                 - package variable
#   LIBRARIES               - package variable
#   FRAMEWORKS              - package variable
#   PLATFORM_INCLUDE
#   PLATFORM_LIBS
#   PLATFORM_FRAMEWORKS
clean_output() {
    # The builtin version of this function will clean out whatever is
    # listed in the HEADERS, LIBRARIES and FRAMEWORKS variables in the
    # "package" file. If more than this is needed to remove all output
    # from the package build, then this is the place to do that.

    # Call builtin version of this function.
    builtin_clean_output

    # Now do any custom output clean up.
    rm -rf "${PLATFORM_INCLUDE}/duktape"
}

# Check output files / directories exist. Used to determine if the package
# has been installed (and does not need to be built).
#
# Uses global variables:
#   PLATFORM
#   HEADERS                 - package variable
#   LIBRARIES               - package variable
#   FRAMEWORKS              - package variable
#   PLATFORM_INCLUDE
#   PLATFORM_LIBS
#   PLATFORM_FRAMEWORKS
#
# Returns 0 (true) if all output exist, 1 if any are missing.
check_output() {

    declare -a duktape_sources=(
        duk_config.h
        duktape.c
        duktape.h
    )

    if [[ ! -d "${PLATFORM_INCLUDE}/duktape" ]]; then
        return 1
    fi

    local checkfile
    for checkfile in "${duktape_sources[@]}"; do
        if [[ ! -f "${PLATFORM_INCLUDE}/duktape/${checkfile}" ]]; then
            return 1
        fi
    done

    print_ok "Duktape source files exist."

    return 0
}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
