#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries and Headers

rm macOS/libde265.a
rm -rf Headers/libde265/*

# Switch to our build directory and clean out anything old

cd ../source/macOS

rm -rf libde265
mkdir libde265

tar -xf libde265.tar.gz  -C libde265 --strip-components=1

cd libde265
 
rm -rf _build_macos
mkdir _build_macos

# Build

autoupdate
autoreconf -fi
./autogen.sh

./configure --prefix="$(pwd)/_build_macos" CFLAGS="-arch x86_64 -arch arm64 -stdlib=libc++ -mmacosx-version-min=10.15" --disable-shared --enable-static --disable-dec265 --disable-sherlock265

#./configure CC="gcc -arch arm64 -arch x86_64" \
#            CXX="g++ -arch arm64 -arch x86_64" \
#            CPP="gcc -E" CXXCPP="g++ -E"

#./configure CC="gcc -arch x86_64 -arch arm64" CXX="g++ -arch x86_64 -arch arm64" CPP="gcc -E" CXXCPP="g++ -E"

#make -s -j install

# Copy the header and library files.

#cp -R ./_build_macos/include/libde265 "${SRCROOT}/Headers/libde265"
#cp ./_build_macos/lib/libde265.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

#cd "START"
