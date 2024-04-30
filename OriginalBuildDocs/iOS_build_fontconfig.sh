#!/bin/bash

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm Libraries/iOS/iPhoneOS/libfontconfig.a
rm Libraries/iOS/iPhoneOS/libfreetype.a
rm Libraries/iOS/iPhoneOS/libpodofo.a

rm Libraries/iOS/iPhoneOSSimulator/libfontconfig.a
rm Libraries/iOS/iPhoneOSSimulator/libfreetype.a
rm Libraries/iOS/iPhoneOSSimulator/libpodofo.a

# Starting folder

cd ../source/iOS
export SRCROOT=`pwd`

iphoneos="13.2"

#====freetype====

rm -rf freetype
mkdir freetype
tar -xf ../freetype.tar.gz -C boost --strip-components=1
cd freetype
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --enable-static --prefix="${$(pwd)}/_build_ios"
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --enable-static --host="aarch64-apple-darwin" --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --enable-static --host="aarch64-apple-darwin" --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libfreetype.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libfreetype.a"
lipo -create "_build_iosSimulatorArm/lib/libfreetype.a" "_build_iosSimulatorx86/lib/libfreetype.a" -output "_build_iosSimulator/libfreetype.a"
cp _build_iosSimulator/libfreetype.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libfreetype.a"

# Return to source/iOS directory

cd "${SRCROOT}"

#====fontconfig====

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C boost --strip-components=1
cd fontconfig
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86


# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -lbz2 -lz -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-docs --enable-static --prefix="${$(pwd)}/_build_ios" FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/iOS/iPhoneOS -lfreetype" 
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -lbz2 -lz -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-docs --enable-static --prefix="${$(pwd)}/_build_iosSimulatorArm" FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -lfreetype" 
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -lbz2 -lz -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-docs --enable-static --prefix="${$(pwd)}/_build_iosSimulatorx86" FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -lfreetype" 
make
make distclean

# Copy the library files.

cp _build_ios/lib/libfontconfig.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libfontconfig.a"
lipo -create "_build_iosSimulatorArm/lib/libfontconfig.a" "_build_iosSimulatorx86/lib/libfontconfig.a" -output "_build_iosSimulator/libfontconfig.a"
cp _build_iosSimulator/libfontconfig.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libfontconfig.a"

# Return to source/iOS directory

cd "${SRCROOT}"

#====podofo====

rm -rf podofo
mkdir podofo
tar -xf ../podofo.tar.gz -C boost --strip-components=1
cd podofo
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="./_build_ios" -DWANT_FONTCONFIG:BOOL=TRUE -DCMAKE_BUILD_TYPE=RELEASE -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/iOS/libfreetype.a" -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/iOS/iPhone" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make install
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="./_build_iosSimulatorArm" -DWANT_FONTCONFIG:BOOL=TRUE -DCMAKE_BUILD_TYPE=RELEASE -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/iOS/libfreetype.a" -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/iOS/iPhoneOSSimulator" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make install
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="./_build_iosSimulatorx86" -DWANT_FONTCONFIG:BOOL=TRUE -DCMAKE_BUILD_TYPE=RELEASE -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/iOS/libfreetype.a" -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/iOS/iPhoneOSSimulator" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make install
make distclean

# Copy the library files.

cp _build_ios/lib/libpodofo.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libpodofo.a"
lipo -create "_build_iosSimulatorArm/lib/libpodofo.a" "_build_iosSimulatorx86/lib/libpodofo.a" -output "_build_iosSimulator/libpodofo.a"
cp _build_iosSimulator/libpodofo.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libpodofo.a"

# Return to source/iOS directory

cd "${SRCROOT}"
