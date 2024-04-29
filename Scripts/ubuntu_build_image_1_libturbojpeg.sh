#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libturbojpeg.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libturbojpeg
mkdir libturbojpeg
tar -xf ../libturbojpeg.tar.gz  -C libturbojpeg --strip-components=1
cd libturbojpeg
mkdir _build_linux

# Build

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="./_build_linux" -DBUILD_SHARED_LIBS=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ ./
make install DESTDIR="./_build_linux"

# Copy the header and library files.

cp _build_linux/lib/libturbojpeg.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
