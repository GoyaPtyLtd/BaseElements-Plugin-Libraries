#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libheif.a
rm -rf Headers/libheif

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libheif
mkdir libheif
tar -xf ../libheif.tar.gz  -C libheif --strip-components=1
cd libheif

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF -DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF -DLIBDE265_INCLUDE_DIR="${OUTPUT}/Headers/libde265/" -DLIBDE265_LIBRARY="${OUTPUT}/Libraries/macOS/libde265.a" ./
make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include" "${OUTPUT}/Headers/libheif"
cp "${PREFIX}/lib/libheif.a" "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
