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

rm -f Libraries/${PLATFORM}/libpng.a

rm -rf Headers/libpng
mkdir Headers/libpng

# Switch to our build directory

cd ../source/${PLATFORM}

export ZLIB=`pwd`'/zlib/_build'

rm -rf libpng
mkdir libpng
tar -xf ../libpng.tar.gz  -C libpng --strip-components=1
cd libpng

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS=" -I${OUTPUT}/Headers/zlib" LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules --disable-arm-neon \
	--prefix="${PREFIX}"

elif [[ $OS = 'linux' ]]; then

	CFLAGS="-fPIC" \
	CPPFLAGS=" -I${OUTPUT}/Headers/zlib" LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules \
	--prefix="${PREFIX}"

fi

make -j${JOBS}
make install

# Copy the header and library files.

cp -R _build/include/libpng16/* "${OUTPUT}/Headers/libpng"

cp _build/lib/libpng16.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"
