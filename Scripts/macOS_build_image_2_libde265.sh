#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and Headers

rm Libraries/macOS/libde265.a
rm -rf Headers/libde265/*

# Switch to our build directory and clean out anything old

cd ../source/macOS
rm -rf libde265
mkdir libde265
tar -xf ../libde265.tar.gz  -C libde265 --strip-components=1
cd libde265
mkdir _build_macos

# Build

#cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="./_build_macos" -DCMAKE_C_FLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_SDL:BOOL=FALSE -DENABLE_SHERLOCK265:BOOL=FALSE -DENABLE_DECODER:BOOL=FALSE -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING="10.13" ./

autoupdate
autoreconf -fi
./autogen.sh


./configure --host arm64-apple-darwin --prefix="${$(pwd)}/_build_macos" CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" --disable-arm --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-sse --disable-dependency-tracking

#./configure CC="gcc -arch arm64 -arch x86_64" \
#            CXX="g++ -arch arm64 -arch x86_64" \
#            CPP="gcc -E" CXXCPP="g++ -E"

#./configure CC="gcc -arch x86_64 -arch arm64" CXX="g++ -arch x86_64 -arch arm64" CPP="gcc -E" CXXCPP="g++ -E"

#make -s -j install

# Copy the header and library files.

#cp -R ./_build_macos/include/libde265 "${OUTPUT}/Headers/libde265"
#cp ./_build_macos/lib/libde265.a "${OUTPUT}/Libraries/macOS"

# Return to source/macOS directory

cd ${SRCROOT}
