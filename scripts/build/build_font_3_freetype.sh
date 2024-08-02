#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'
elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../../Output
export OUTPUT=`pwd`

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

cd ${SRCROOT}
