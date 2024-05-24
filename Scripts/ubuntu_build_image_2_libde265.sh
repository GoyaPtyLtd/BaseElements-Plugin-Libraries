#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and Headers

rm Libraries/linux/libde265.a
rm -rf Headers/libde265/*

# Switch to our build directory and clean out anything old

cd ../source/linux
rm -rf libde265
mkdir libde265
tar -xf ../libde265.tar.gz  -C libde265 --strip-components=1
cd libde265
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

autoupdate
autoreconf -fi
./autogen.sh

./configure --prefix="${PREFIX}" --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-sse --disable-dependency-tracking
make -s -j install

# Copy the header and library files.

cp ./_build_linux/lib/libde265.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
