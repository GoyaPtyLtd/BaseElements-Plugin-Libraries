#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
	PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        PLATFORM='linuxARM'
    elif [[ $ARCH = 'x86_64' ]]; then
        PLATFORM='linux'
    fi
fi
if [[ "${PLATFORM}X" = 'X' ]]; then     # $PLATFORM is empty
	echo "!! Unknown OS/ARCH: $OS/$ARCH"
	exit 1
fi


SRCROOT=$(pwd)
cd ../../Output
OUTPUT=$(pwd)

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf duktape
mkdir duktape
tar -xf ../duktape.tar.xz -C duktape --strip-components=1
cd duktape

# Copy the source files.

cp -R src "${OUTPUT}/Source/duktape"

# Return to source directory

cd "${SRCROOT}"
