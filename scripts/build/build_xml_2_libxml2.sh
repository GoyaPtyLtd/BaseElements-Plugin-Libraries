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

rm -f Libraries/${PLATFORM}/libxml2.a

rm -rf Headers/libxml
mkdir Headers/libxml

# Switch to our build directory

cd ../source/${PLATFORM}

export ICONV=`pwd`'/libiconv/_build'

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.xz -C libxml --strip-components=1
cd libxml

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --with-threads --with-sax1 --without-python --without-zlib --without-lzma \
	--with-iconv="${ICONV}" \
	--prefix="${PREFIX}"

elif [[ $OS = 'linux' ]]; then

	CFLAGS=-fPIC \
	./configure --disable-shared --with-threads --with-sax1 --without-python --without-zlib --without-lzma \
	--prefix="${PREFIX}"

fi

make -j${JOBS}
make install

# Copy the header and library files.

if [[ $PLATFORM = 'macOS' ]]; then
	#This affects when you're compiling in XCode later - it will look for the system iconv, this makes it use our one.
	sed -i '' -e 's|#include <iconv/iconv\.h\>|#include <iconv\.h>|g' "${PREFIX}/include/libxml2/libxml/encoding.h"
fi

cp -R _build/include/libxml2/libxml/* "${OUTPUT}/Headers/libxml"
cp _build/lib/libxml2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"
