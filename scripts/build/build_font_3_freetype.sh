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

rm -f Libraries/${PLATFORM}/libfreetype.a

rm -rf Headers/freetype2
mkdir Headers/freetype2

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf freetype
mkdir freetype
tar -xf ../freetype.tar.gz -C freetype --strip-components=1
cd freetype

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then
	
	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --with-png=no --with-bzip2=no --with-harfbuzz=no --with-brotli=no --with-png=no --with-zlib=no \
	--prefix=${PREFIX}

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --disable-shared --with-png=no --with-bzip2=no --with-harfbuzz=no --with-brotli=no --with-png=no --with-zlib=no \
	--prefix=${PREFIX}

	make -j$(($(nproc) + 1))
fi

make install

# Copy the header and library files.

cp -R _build/include/freetype2/* "${OUTPUT}/Headers/freetype2"
cp _build/lib/libfreetype.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"
