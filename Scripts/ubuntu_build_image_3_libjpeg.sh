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

rm -f Libraries/linux/libjpeg.a

# Switch to our build directory

cd ../source/linux
rm -rf libjpeg
mkdir libjpeg
tar -xf ../libjpeg.tar.gz  -C libjpeg --strip-components=1
cd libjpeg

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CFLAGS="-fPIC" ./configure --prefix="${PREFIX}" --disable-shared --enable-static
make -j install

# Copy the header and library files.

cp _build_linux/lib/libjpeg.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
