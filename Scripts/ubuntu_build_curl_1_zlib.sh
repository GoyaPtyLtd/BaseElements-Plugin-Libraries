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

rm -f Libraries/linux/libz.a

# Switch to our build directory

cd ../source/linux
rm -rf libz
mkdir libz
tar -xf ../libz.tar.gz -C libz --strip-components=1
cd libz

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CFLAGS="-fPIC" ./configure --static --prefix="${PREFIX}"
make -j install

# Copy the library files.

cp _build_linux/lib/libz.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
