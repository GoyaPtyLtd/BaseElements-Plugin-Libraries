#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libopenjp2.a
rm -rf Headers/libopenjp2
mkdir Headers/libopenjp2

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libopenjp2
mkdir libopenjp2
tar -xf ../libopenjp2.tar.gz  -C libopenjp2 --strip-components=1
cd libopenjp2
mkdir _build_linux
export PREFIX=`pwd`+'_build_linux'

# Build

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_INCLUDE_PATH:path="${OUTPUT}/Headers" -DCMAKE_LIBRARY_PATH:path="${OUTPUT}/Libraries/linux" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ ./
make install DESTDIR="$PREFIX"

# Copy the header and library files.

cp ./_build_linux/usr/local/lib/libopenjp2.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
