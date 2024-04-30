#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libheif.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libheif
mkdir libheif
tar -xf ../libheif.tar.gz  -C libheif --strip-components=1
cd libheif
mkdir _build_linux
export PREFIX=`pwd`+'/_build_linux'

# Build

#CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DX265_INCLUDE_DIR="${OUTPUT}/Headers/libde265" X265_LIBRARY="${OUTPUT}/Libraries/linux" ./
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DX265_INCLUDE_DIR="${OUTPUT}/Headers/libde265" X265_LIBRARY="${OUTPUT}/Libraries/linux" ./
make install DESTDIR="${PREFIX}"

# Copy the header and library files.

cp ./_build_linux/lib/libheif.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
