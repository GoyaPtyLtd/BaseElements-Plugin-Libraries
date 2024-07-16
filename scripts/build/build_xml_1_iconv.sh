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

rm -f Libraries/${PLATFORM}/libiconv.a
rm -f Libraries/${PLATFORM}/libcharset.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/iconv
	mkdir Headers/iconv
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libiconv
mkdir libiconv
tar -xf ../libiconv.tar.gz -C libiconv --strip-components=1
cd libiconv

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

cp -R _build/include/* "${OUTPUT}/Headers/iconv"

cp _build/lib/libiconv.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libcharset.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}

