#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libcurl.a

# Switch to our build directory

cd ../source/linux
rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib -I${SRCROOT}/Headers/libssh2  -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/linux" LIBS="-ldl" ./configure --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --prefix="${PREFIX}"

make -j install

# Copy the library files.

cp _build_linux/lib/libcurl.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

