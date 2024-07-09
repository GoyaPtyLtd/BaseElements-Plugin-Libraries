#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libPocoCrypto.a
rm -f Libraries/macOS/libPocoFoundation.a
rm -f Libraries/macOS/libPocoJSON.a
rm -f Libraries/macOS/libPocoNet.a
rm -f Libraries/macOS/libPocoXML.a
rm -f Libraries/macOS/libPocoZip.a

rm -rf Headers/Poco
mkdir Headers/Poco

# Switch to our build directory

cd ../source/macOS

rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco

mkdir _build_macos
mkdir _build_macos_x86_64
mkdir _build_macos_arm64
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_x86_64=`pwd`'/_build_macos_x86_64'
export PREFIX_arm64=`pwd`'/_build_macos_arm64'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

./configure --cflags="-mmacosx-version-min=10.15" --prefix="${PREFIX_x86_64}" --no-sharedlibs --static --poquito --no-tests --no-samples --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis,Util" --include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/macOS"

make install -s -j4 POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH=x86_64
# Needs a change to just the POCO_TARGET_OSARCH once the bug in their config is fixed - now needs both so it builds into the right folders
# It is ignoring the target value

make -s -j distclean

./configure --cflags="-mmacosx-version-min=10.15" --prefix="${PREFIX_arm64}" --no-sharedlibs --static --poquito --no-tests --no-samples --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis,Util" --include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/macOS"

make install -s -j4 POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH=x86_64
# Needs a change to just the POCO_TARGET_OSARCH once the bug in their config is fixed - now needs both so it builds into the right folders
# It is ignoring the target value

make -s -j distclean

lipo -create "${PREFIX_x86_64}/lib/libPocoCrypto.a" "${PREFIX_arm64}/lib/libPocoCrypto.a" -output "${PREFIX}/libPocoCrypto.a"
lipo -create "${PREFIX_x86_64}/lib/libPocoFoundation.a" "${PREFIX_arm64}/lib/libPocoFoundation.a" -output "${PREFIX}/libPocoFoundation.a"
lipo -create "${PREFIX_x86_64}/lib/libPocoJSON.a" "${PREFIX_arm64}/lib/libPocoJSON.a" -output "${PREFIX}/libPocoJSON.a"
lipo -create "${PREFIX_x86_64}/lib/libPocoNet.a" "${PREFIX_arm64}/lib/libPocoNet.a" -output "${PREFIX}/libPocoNet.a"
lipo -create "${PREFIX_x86_64}/lib/libPocoXML.a" "${PREFIX_arm64}/lib/libPocoXML.a" -output "${PREFIX}/libPocoXML.a"
lipo -create "${PREFIX_x86_64}/lib/libPocoZip.a" "${PREFIX_arm64}/lib/libPocoZip.a" -output "${PREFIX}/libPocoZip.a"

# Copy the header and library files.

cp -R _build_macos/include/Poco/* "${OUTPUT}/Headers/Poco"

cp _build_macos/libPocoCrypto.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libPocoFoundation.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libPocoJSON.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libPocoNet.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libPocoXML.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libPocoZip.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}

