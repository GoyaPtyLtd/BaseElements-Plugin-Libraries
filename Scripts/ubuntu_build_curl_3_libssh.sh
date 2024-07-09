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

rm -f Libraries/macOS/libssh2.a

# Switch to our build directory

cd ../source/linux
rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CFLAGS="-fPIC -I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib" LDFLAGS="-L${SRCROOT}/Libraries/linux/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${PREFIX}"
make -j install

# Copy the library files.

cp _build_linux/lib/libssh2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
