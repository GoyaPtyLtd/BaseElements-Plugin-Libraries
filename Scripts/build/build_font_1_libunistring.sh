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

cd ..
export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libunistring.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libunistring
	mkdir Headers/libunistring
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libunistring
mkdir libunistring
tar -xf ../libunistring.tar.gz -C libunistring --strip-components=1
cd libunistring

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --enable-static --enable-shared=NO --prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --enable-static --enable-shared=NO --prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/* "${OUTPUT}/Headers/libunistring"
fi

cp _build/lib/libunistring.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}