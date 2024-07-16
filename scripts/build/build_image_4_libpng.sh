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

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libpng
	mkdir Headers/libpng
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libpng
mkdir libpng
tar -xf ../libpng.tar.gz  -C libpng --strip-components=1
cd libpng

mkdir _build
mkdir _build_x86_64
mkdir _build_arm64
export PREFIX=`pwd`'/_build'
export PREFIX_x86_64=`pwd`'/_build_x86_64'
export PREFIX_arm64=`pwd`'/_build_arm64'

# Build

if [ ${PLATFORM} = 'macOS' ]; then
	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules \
	--host="aarch64-apple-darwin" \
	--prefix="${PREFIX_x86_64}"

	make install
	make -s -j distclean

	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules \
	--host="aarch64-apple-darwin" \
	--prefix="${PREFIX_arm64}"

	make install
	make -s -j distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libpng16.a" "${PREFIX_arm64}/lib/libpng16.a" -output "${PREFIX}/lib/libpng16.a"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --disable-shared --disable-dependency-tracking --disable-silent-rules \
	--prefix="${PREFIX}"

	make install

fi

# Copy the header and library files.

cp -R _build_x86_64/include/libpng16/* "${OUTPUT}/Headers/libpng"
cp _build/lib/libpng16.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
