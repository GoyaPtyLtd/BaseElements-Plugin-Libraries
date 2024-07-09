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
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/zlib.a

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf zlib
mkdir zlib
tar -xf ../zlib.tar.xz -C libz --strip-components=1
cd libz

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --static --prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --static --prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

cp _build/lib/zlib.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
