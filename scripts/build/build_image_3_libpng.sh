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

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS=" -I${OUTPUT}/Headers/zlib" LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules --disable-arm-neon \
	--prefix="${PREFIX}"

	make install

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	CPPFLAGS=" -I${OUTPUT}/Headers/zlib" LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))
	make install

fi

# Copy the header and library files.

cp -R _build/include/libpng16/* "${OUTPUT}/Headers/libpng"

cp _build/lib/libpng16.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
