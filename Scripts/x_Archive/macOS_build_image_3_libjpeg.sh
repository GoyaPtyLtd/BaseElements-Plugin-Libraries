#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libjpeg.a
rm -f Libraries/iOS/iPhoneOS/libjpeg.a
rm -f Libraries/iOS/iPhoneOSSimulator/libjpeg.a

rm -rf Headers/libjpeg

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libjpeg
mkdir libjpeg
tar -xf ../libjpeg.tar.gz  -C libjpeg --strip-components=1
cd libjpeg

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

export macOS="10.15"

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=${macOS}" ./configure --host=x86_64 --prefix="${PREFIX}"  --disable-shared --enable-static
make -s -j install
make distclean

# Build iOS - not working as no longer supports cmake
# 
# export iphoneos="15.0"
# 
# export ARCH="arm64"
# export IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
# cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="${PREFIX_ios}" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphoneos-version-min=${iphoneos} -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphoneos-version-min=${iphoneos} -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 ./
# make -s -j install
# make distclean
# 
# # Build Simulator arm64
# 
# export ARCH="arm64"
# export IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
# cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="${PREFIX_iosSimulatorArm}" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 ./
# make -s -j install
# make distclean
# 
# # Build Simulator x86
# 
# export ARCH="x86_64"
# export IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
# cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="${PREFIX_iosSimulatorx86}" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 ./
# make -s -j install
# make distclean
# 
# # Build Simulator fat Binary
# 
# lipo -create "${PREFIX_iosSimulatorArm}/lib/libjpeg.a" "${PREFIX_iosSimulatorx86}/lib/libjpeg.a" -output "${PREFIX_iosSimulator}/libjpeg.a"

# Copy the header and library files.

cp -R "${PREFIX}/include" "${OUTPUT}/Headers/libjpeg"

cp "${PREFIX}/lib/libjpeg.a" "${OUTPUT}/Libraries/macOS"
# cp "${PREFIX_ios}/lib/libjpeg.a" "${OUTPUT}/Libraries/iOS/iPhoneOS"
# cp "${PREFIX_iosSimulator}/lib/libjpeg.a" "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator"

# Return to source directory

cd ${SRCROOT}
