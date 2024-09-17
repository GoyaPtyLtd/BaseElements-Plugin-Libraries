#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'

    number=$(sysctl -n hw.ncpu 2>/dev/null)
    export CPU_CORES=${number:-1}

elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

SRCROOT=$(pwd)
cd ../../Output
OUTPUT=$(pwd)

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libnghttp2.a

rm -rf Headers/nghttp2
mkdir Headers/nghttp2

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf nghttp2
mkdir nghttp2
tar -xf ../nghttp2.tar.xz -C nghttp2 --strip-components=1
cd nghttp2

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
	./configure --enable-lib-only --enable-shared=no --enable-static \
	--prefix="${PREFIX}" \
	--host=x86_64-apple-darwin 

	make -j "${CPU_CORES}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	./configure --enable-lib-only \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))

fi

make install

# Copy the header and library files.

cp -R _build/include/nghttp2/* "${OUTPUT}/Headers/nghttp2"

cp _build/lib/libnghttp2.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd "${SRCROOT}"

