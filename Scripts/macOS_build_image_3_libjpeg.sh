#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libjpeg.a
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

export PREFIX=`pwd`+'_build_macos'
export PREFIX_ios=`pwd`+'_build_ios'
export PREFIX_iosSimulator=`pwd`+'_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --host=x86_64 --prefix="${PREFIX}"  --disable-shared --enable-static
make -s -j install
make distclean

# Build iOS

iphoneos="13.2"

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="${PREFIX_ios}" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphoneos-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make -s -j install
make distclean

# Build Simulator arm64

ARCH="arm64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="${PREFIX_iosSimulatorArm}" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make -s -j install
make distclean

# Build Simulator x86

ARCH="x86_64"
IOS_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
cmake -G "Unix Makefiles" -DCMAKE_OSX_SYSROOT=${IOS_SDK} -DCMAKE_INSTALL_PREFIX="${PREFIX_iosSimulatorx86}" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch ${ARCH} -miphonesimulator-version-min=$iphoneos -stdlib=libc++" -DCMAKE_CXX_STANDARD=11
make -s -j install
make distclean

# Build Simulator fat Binary

lipo -create "${PREFIX_iosSimulatorArm}/lib/libturbojpeg.a" "${PREFIX_iosSimulatorx86}/lib/libturbojpeg.a" -output "${PREFIX_iosSimulator}/libturbojpeg.a"
lipo -create "${PREFIX_iosSimulatorArm}/lib/libjpeg.a" "${PREFIX_iosSimulatorx86}/lib/libjpeg.a" -output "${PREFIX_iosSimulator}/libjpeg.a"

# Copy the header and library files.

cp -R ./${PREFIX}/include "${OUTPUT}/Headers/libjpeg"

cp ./${PREFIX}/lib/libjpeg.a "${OUTPUT}/Libraries/macOS"
cp ./${PREFIX_ios}/lib/libjpeg.a "${OUTPUT}/Libraries/iOS/iPhoneOS"
cp ./${PREFIX_iosSimulator}/lib/libjpeg.a "${OUTPUT}/Libraries/iOS/iPhoneOSSimulator"

# Return to source directory

cd ${SRCROOT}
