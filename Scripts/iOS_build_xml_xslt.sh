#!/bin/bash

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm Libraries/iOS/iPhoneOS/libiconv.a
rm Libraries/iOS/iPhoneOS/libcharset.a
rm Libraries/iOS/iPhoneOS/libxml2.a
rm Libraries/iOS/iPhoneOS/libxslt.a
rm Libraries/iOS/iPhoneOS/libexslt.a

rm Libraries/iOS/iPhoneOSSimulator/libiconv.a
rm Libraries/iOS/iPhoneOSSimulator/libcharset.a
rm Libraries/iOS/iPhoneOSSimulator/libxml2.a
rm Libraries/iOS/iPhoneOSSimulator/libxslt.a
rm Libraries/iOS/iPhoneOSSimulator/libexslt.a

# Starting folder

cd ../source/iOS
export SRCROOT=`pwd`

iphoneos="13.2"

#====libiconv====

rm -rf libiconv
mkdir libiconv
tar -xf ../libiconv.tar.gz -C boost --strip-components=1
cd libiconv
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export CFLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
export LDFLAGS="-arch ${ARCH} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -miphoneos-version-min=$iphoneos"
./configure iphoneos-cross no-engine no-hw no-shared --prefix="${$(pwd)}/_build_ios"
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libiconv.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libiconv.a"
cp _build_ios/lib/libcharset.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libcharset.a"

lipo -create "_build_iosSimulatorArm/lib/libiconv.a" "_build_iosSimulatorx86/lib/libiconv.a" -output "_build_iosSimulator/libiconv.a"
lipo -create "_build_iosSimulatorArm/lib/libcharset.a" "_build_iosSimulatorx86/lib/libcharset.a" -output "_build_iosSimulator/libcharset.a"

cp _build_iosSimulator/libiconv.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libiconv.a"
cp _build_iosSimulator/libcharset.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libcharset.a"

# Return to source/iOS directory

cd "${SRCROOT}"

#====libxml====

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.gz -C boost --strip-components=1
cd libxml
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOS -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --without-python --without-zlib --with-iconv --prefix="${$(pwd)}/_build_ios"
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --without-python --without-zlib --with-iconv --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --without-python --without-zlib --with-iconv --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libxml2.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libxml2.a"
lipo -create "_build_iosSimulatorArm/lib/libxml2.a" "_build_iosSimulatorx86/lib/libxml2.a" -output "_build_iosSimulator/libxml2.a"
cp _build_iosSimulator/libxml2.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libxml2.a"

# Return to source/iOS directory

cd "${SRCROOT}"

#====libxslt====

rm -rf libxslt
mkdir libxslt
tar -xf ../libxslt.tar.gz -C boost --strip-components=1
cd libxslt
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export LIBXML_CFLAGS="-I${IOS_SDK}/usr/include"
export LIBXML_LIBS="-L${IOS_SDK}/usr/lib -lxml2 -lz -lpthread -licucore -lm"
export CFLAGS="-arch ${ARCH} -I${SRCROOT}/Headers -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -L${SRCROOT}/Libraries/iOS/iPhoneOS -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --target="arm64-apple-ios" --disable-shared --enable-static --without-python --without-crypto --prefix="${$(pwd)}/_build_ios"
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export LIBXML_CFLAGS="-I${IOS_SDK}/usr/include"
export LIBXML_LIBS="-L${IOS_SDK}/usr/lib -lxml2 -lz -lpthread -licucore -lm"
export CFLAGS="-arch ${ARCH} -I${SRCROOT}/Headers -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -L${SRCROOT}/Libraries/iOS/iPhoneOSSimulator -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --without-python --without-crypto --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export LIBXML_CFLAGS="-I${IOS_SDK}/usr/include"
export LIBXML_LIBS="-L${IOS_SDK}/usr/lib -lxml2 -lz -lpthread -licucore -lm"
export CFLAGS="-arch ${ARCH} -I${SRCROOT}/Headers -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
export LDFLAGS="-arch ${ARCH} -L${SRCROOT}/Libraries/iOS/iPhoneOSSimulator -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --host="aarch64-apple-darwin" --disable-shared --enable-static --without-python --without-crypto --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libxslt.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libxslt.a"
cp _build_ios/lib/libexslt.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libexslt.a"

lipo -create "_build_iosSimulatorArm/lib/libxslt.a" "_build_iosSimulatorx86/lib/libxslt.a" -output "_build_iosSimulator/libxslt.a"
lipo -create "_build_iosSimulatorArm/lib/libexslt.a" "_build_iosSimulatorx86/lib/libexslt.a" -output "_build_iosSimulator/libexslt.a"

cp _build_iosSimulator/libxslt.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libxslt.a"
cp _build_iosSimulator/libexslt.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libexslt.a"

# Return to source/iOS directory

cd "${SRCROOT}"
