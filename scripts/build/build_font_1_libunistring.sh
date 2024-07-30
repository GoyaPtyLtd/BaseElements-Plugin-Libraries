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

rm -f Libraries/${PLATFORM}/libunistring.a

rm -rf Headers/libunistring
mkdir Headers/libunistring

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

	make -j$(($(nproc) + 1))
fi

make install

# Copy the header and library files.

cp -R _build/include/* "${OUTPUT}/Headers/libunistring"
cp _build/lib/libunistring.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
