#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libPocoCrypto.a
rm Libraries/macOS/libPocoFoundation.a
rm Libraries/macOS/libPocoZip.a
rm Libraries/macOS/libPocoJSON.a
rm Libraries/macOS/libPocoXML.a
rm Libraries/macOS/libPocoNet.a

rm -rf Headers/Poco/*

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco
mkdir _build_macos

# Build

./configure --config=Darwin64-clang-libc++ --prefix="${$(pwd)}/_build_macos" --no-sharedlibs --static --poquito --no-tests --no-samples --omit="CppParser,Data,Encodings,MongoDB,PDF,PageCompiler,Redis,Util" --include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/macOS"

make -s -j install

# Copy the header and library files.

cp lib/Darwin/x86_64/libPocoCrypto.a "${OUTPUT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoFoundation.a "${OUTPUT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoZip.a "${OUTPUT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoJSON.a "${OUTPUT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoXML.a "${OUTPUT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoNet.a "${OUTPUT}/Libraries/macOS"

cp -R ./_build_macos/include/Poco "${OUTPUT}/Headers"

# Return to source/macOS directory

cd ${SRCROOT}

