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

rm -f Libraries/${PLATFORM}/libssh2.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libssh2
	mkdir Headers/libssh2
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" \
	LDFLAGS="-L${OUTPUT}/Libraries/macOS/" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-libz --without-tests --with-crypto=openssl \
	--prefix="${PREFIX}" -exec-prefix="${PREFIX}"
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib -I${SRCROOT}/Headers/libssh2  -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/linux" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-zlib --without-tests --with-ssl --with-libssh2 \
	--prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/* "${OUTPUT}/Headers/libssh2"
fi

cp _build/lib/libssh2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
