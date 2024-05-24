#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libPocoCrypto.a
rm -f Libraries/macOS/libPocoFoundation.a
rm -f Libraries/macOS/libPocoZip.a
rm -f Libraries/macOS/libPocoJSON.a
rm -f Libraries/macOS/libPocoXML.a
rm -f Libraries/macOS/libPocoNet.a

rm -rf Headers/Poco
mkdir Headers/Poco

# Switch to our build directory

cd ../source/macOS

rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco

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

./configure --config=Darwin64-clang-libc++ --prefix="${PREFIX}" --no-sharedlibs --static --poquito --no-tests --no-samples --omit="CppParser,Data,Encodings,MongoDB,PDF,PageCompiler,Redis,Util" --include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/macOS"

make -j install

# Copy the header and library files.

cp -R _build_macos/include/Poco/* "${OUTPUT}/Headers/Poco"

cp _build_macos/lib/libPocoCrypto.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libPocoFoundation.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libPocoZip.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libPocoJSON.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libPocoXML.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libPocoNet.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}

