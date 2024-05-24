#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libjpeg.a
rm -rf Headers/libjpeg

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libjpeg
mkdir libjpeg
tar -xf ../libjpeg.tar.gz  -C libjpeg --strip-components=1
cd libjpeg
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build


CFLAGS="-fPIC" ./configure --prefix="${PREFIX}" --disable-shared --enable-static
make -s -j install

# Copy the header and library files.

cp ./_build_linux/lib/libjpeg.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
