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
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

#cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_C_FLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_SDL:BOOL=FALSE -DENABLE_SHERLOCK265:BOOL=FALSE -DENABLE_DECODER:BOOL=FALSE -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING="10.13" ./

autoupdate
autoreconf -fi
./autogen.sh

./configure --host arm64-apple-darwin --prefix="${PREFIX}" CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" --disable-arm --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-sse --disable-dependency-tracking

#./configure CC="gcc -arch arm64 -arch x86_64" \
#            CXX="g++ -arch arm64 -arch x86_64" \
#            CPP="gcc -E" CXXCPP="g++ -E"

#./configure CC="gcc -arch x86_64 -arch arm64" CXX="g++ -arch x86_64 -arch arm64" CPP="gcc -E" CXXCPP="g++ -E"

#make -s -j install

# Copy the header and library files.

#cp -R "${PREFIX}/include/libde265" "${OUTPUT}/Headers/libde265"
#cp "${PREFIX}/lib/libde265.a" "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
