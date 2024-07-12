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

rm -f Libraries/${PLATFORM}/libssh2.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libssh2
	mkdir Headers/libssh2
fi

# Switch to our build directory

cd ../source/${PLATFORM}

export OPENSSL=`pwd`'/openssl/_build'

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-zlib \
	--with-crypto=openssl --with-libssl-prefix=${OPENSSL} \
	--prefix="${PREFIX}"
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS=-fPIC \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-zlib \
	--with-crypto=openssl --with-libssl-prefix=${OPENSSL} \
	--prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/* "${OUTPUT}/Headers/libssh2"
fi

cp _build/lib/libssh2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
