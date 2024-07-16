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

rm -f Libraries/${PLATFORM}/libexpat.a

rm -rf Headers/libexpat
mkdir Headers/libexpat

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libexpat
mkdir libexpat
tar -xf ../expat.tar.xz -C libexpat --strip-components=1
cd libexpat

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS=-fPIC \
	./configure --disable-shared --prefix="${PREFIX}"

fi

make install

# Copy the header and library files.

cp -R _build/include/* "${OUTPUT}/Headers/libexpat"
cp _build/lib/libexpat.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}

