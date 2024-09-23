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

# Remove old libraries

rm -f Libraries/${PLATFORM}/libiconv.a
rm -f Libraries/${PLATFORM}/libcharset.a

rm -rf Headers/iconv
mkdir Headers/iconv

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libiconv
mkdir libiconv
tar -xf ../libiconv.tar.gz -C libiconv --strip-components=1
cd libiconv

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --prefix="${PREFIX}"

elif [[ $OS = 'linux' ]]; then

	CFLAGS=-fPIC \
	./configure --disable-shared --prefix="${PREFIX}"

fi

make -j${JOBS}
make install

# Copy the header and library files.

cp -R _build/include/* "${OUTPUT}/Headers/iconv"

cp _build/lib/libiconv.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libcharset.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"

