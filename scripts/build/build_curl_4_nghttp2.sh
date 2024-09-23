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

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libnghttp2.a

rm -rf Headers/nghttp2
mkdir Headers/nghttp2

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf nghttp2
mkdir nghttp2
tar -xf ../nghttp2.tar.xz -C nghttp2 --strip-components=1
cd nghttp2

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
	./configure --enable-lib-only --enable-shared=no --enable-static \
	--prefix="${PREFIX}" \
	--host=x86_64-apple-darwin

	make -j${JOBS}

elif [[ $OS = 'Linux' ]]; then

	./configure --enable-lib-only \
	--prefix="${PREFIX}"

	make -j${JOBS}

fi

make install

# Copy the header and library files.

cp -R _build/include/nghttp2/* "${OUTPUT}/Headers/nghttp2"

cp _build/lib/libnghttp2.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd "${SRCROOT}"

