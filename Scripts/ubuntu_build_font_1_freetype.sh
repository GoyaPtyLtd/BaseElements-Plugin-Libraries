#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libfreetype.a

# Switch to our build directory

cd ../source/linux
rm -rf freetype
mkdir freetype
tar -xf ../freetype.tar.gz -C freetype --strip-components=1
cd freetype

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CFLAGS="-fPIC" ./configure --disable-shared --prefix=${PREFIX}

make -j install

# Copy the library files.

cp _build_linux/lib/libfreetype.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
