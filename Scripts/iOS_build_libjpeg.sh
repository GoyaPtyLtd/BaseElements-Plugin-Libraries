#!/bin/bash

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm Libraries/iOS/iPhoneOS/libturbojpeg.a
rm Libraries/iOS/iPhoneOS/libjpeg.a

rm Libraries/iOS/iPhoneOSSimulator/libturbojpeg.a
rm Libraries/iOS/iPhoneOSSimulator/libjpeg.a

# Starting folder

cd ../source/iOS
export SRCROOT=`pwd`

iphoneos="13.2"

#====freetype====

rm -rf libjpeg
mkdir libjpeg
tar -xf ../libjpeg.tar.gz -C boost --strip-components=1
cd libjpeg
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="./_build_ios" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make install
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="./_build_iosSimulatorArm" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make install
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="./_build_iosSimulatorx86" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make install
make distclean

# TODO check that one of these simulator outputs isn't already a fat binary

# Copy the library files.

cp _build_ios/lib/libturbojpeg.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libturbojpeg.a"
cp _build_ios/lib/libjpeg.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libjpeg.a"

lipo -create "_build_iosSimulatorArm/lib/libturbojpeg.a" "_build_iosSimulatorx86/lib/libturbojpeg.a" -output "_build_iosSimulator/libturbojpeg.a"
lipo -create "_build_iosSimulatorArm/lib/libjpeg.a" "_build_iosSimulatorx86/lib/libjpeg.a" -output "_build_iosSimulator/libjpeg.a"

cp _build_iosSimulator/libturbojpeg.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libturbojpeg.a"
cp _build_iosSimulator/libjpeg.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libjpeg.a"

# Return to source/iOS directory

cd "${SRCROOT}"