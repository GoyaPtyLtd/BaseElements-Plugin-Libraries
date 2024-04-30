#!/bin/bash

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm Libraries/iOS/iPhoneOS/libssl.a
rm Libraries/iOS/iPhoneOS/libcrypto.a
rm Libraries/iOS/iPhoneOS/libssh2.a
rm Libraries/iOS/iPhoneOS/libcurl.a

rm Libraries/iOS/iPhoneOSSimulator/libssl.a
rm Libraries/iOS/iPhoneOSSimulator/libcrypto.a
rm Libraries/iOS/iPhoneOSSimulator/libssh2.a
rm Libraries/iOS/iPhoneOSSimulator/libcurl.a

# Starting folder

cd ../source/iOS
export SRCROOT=`pwd`

iphoneos="13.2"

#====openssl====

rm -rf openssl
mkdir openssl
tar -xf ../openssl.tar.gz -C boost --strip-components=1
cd openssl
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
export CFLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
export LDFLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
./configure darwin64-arm64-cc no-engine no-hw no-shared --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
export LDFLAGS="-arch ${ARCH} -miphonesimulator-version-min=${iphoneos} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
./configure darwin64-x86_64-cc no-engine no-hw no-shared --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libssl.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libssl.a"
ccp _build_ios/lib/libcrypto.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libcrypto.a"

lipo -create "_build_iosSimulatorArm/lib/libssl.a" "_build_iosSimulatorx86/lib/libssl.a" -output "_build_iosSimulator/libssl.a"
lipo -create "_build_iosSimulatorArm/lib/libcrypto.a" "_build_iosSimulatorx86/lib/libcrypto.a" -output "_build_iosSimulator/libcrypto.a"

p _build_iosSimulator/libssl.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libssl.a"
cp _build_iosSimulator/libcrypto.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libcrypto.a"

# Return to source/iOS directory

cd "${SRCROOT}"

#====libssh2====

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C boost --strip-components=1
cd libssh
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -miphoneos-version-min=$iphoneos -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -miphoneos-version-min=$iphoneos"
./configure --disable-shared --host="aarch64-apple-darwin" --with-openssl --with-libz --disable-examples-build -without-libssl-prefix --disable-debug --prefix="${$(pwd)}/_build_ios"
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -miphonesimulator-version-min=$iphoneos -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -miphonesimulator-version-min=$iphoneos"
./configure --disable-shared --host="aarch64-apple-darwin" --with-openssl --with-libz --disable-examples-build -without-libssl-prefix --disable-debug --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -miphonesimulator-version-min=$iphoneos -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk -miphonesimulator-version-min=$iphoneos"
./configure --disable-shared --host="aarch64-apple-darwin" --with-openssl --with-libz --disable-examples-build -without-libssl-prefix --disable-debug --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libssh2.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libssh2.a"
lipo -create "_build_iosSimulatorArm/lib/libssh2.a" "_build_iosSimulatorx86/lib/libssh2.a" -output "_build_iosSimulator/libssh2.a"
cp _build_iosSimulator/libssh2.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libssh2.a"

# Return to source/iOS directory

cd "${SRCROOT}"

#====curl====

rm -rf libcurl
mkdir libcurl
tar -xf ../libcurl.tar.gz -C boost --strip-components=1
cd libcurl
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

# Build iOS

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -I${OUTPUT}/Headers/libssh2 -I${OUTPUT}/Headers/openssl -miphoneos-version-min=$iphoneos -isysroot ${IOS_SDK}"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOS -isysroot ${IOS_SDK} -miphoneos-version-min=$iphoneos"
./configure --disable-shared --host="aarch64-apple-darwin" --with-ssl --with-libz --with-libssh2 --prefix="${$(pwd)}/_build_ios"
make
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -I${OUTPUT}/Headers/libssh2 -I${OUTPUT}/Headers/openssl -miphonesimulator-version-min=$iphoneos -isysroot ${IOS_SDK}"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --disable-shared --host="aarch64-apple-darwin" --with-ssl --with-libz --with-libssh2 --prefix="${$(pwd)}/_build_iosSimulatorArm"
make
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export CFLAGS="-arch ${ARCH} -I${OUTPUT}/Headers -I${OUTPUT}/Headers/libssh2 -I${OUTPUT}/Headers/openssl -miphonesimulator-version-min=$iphoneos -isysroot ${IOS_SDK}"
export LDFLAGS="-arch ${ARCH} -L${OUTPUT}/Libraries/iOS/iPhoneOSSimulator -isysroot ${IOS_SDK} -miphonesimulator-version-min=$iphoneos"
./configure --disable-shared --host="aarch64-apple-darwin" --with-ssl --with-libz --with-libssh2 --prefix="${$(pwd)}/_build_iosSimulatorx86"
make
make distclean

# Copy the library files.

cp _build_ios/lib/libcurl.a "${OUTPUT}/Libraries/iOS/iPhoneOS/libcurl.a"
lipo -create "_build_iosSimulatorArm/lib/libcurl.a" "_build_iosSimulatorx86/lib/libcurl.a" -output "_build_iosSimulator/libcurl.a"
cp _build_iosSimulator/libcurl.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator/libcurl.a"

# Return to source/iOS directory

cd "${SRCROOT}"

