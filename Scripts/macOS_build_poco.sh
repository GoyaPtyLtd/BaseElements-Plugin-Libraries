#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm Libraries/macOS/libPocoCrypto.a
rm Libraries/macOS/libPocoFoundation.a
rm Libraries/macOS/libPocoZip.a
rm Libraries/macOS/libPocoJSON.a
rm Libraries/macOS/libPocoXML.a
rm Libraries/macOS/libPocoNet.a

# Remove old headers

rm -rf Headers/Poco/*

# Switch to our build directory

cd ../source/macOS/poco

# Remove old build directory contents
 
rm -rf _build_macos
mkdir _build_macos

# Build

./configure --config=Darwin64-clang-libc++ --prefix="${$(pwd)}/_build_macos" --no-sharedlibs --static --poquito --no-tests --no-samples --omit="CppParser,Data,Encodings,MongoDB,PDF,PageCompiler,Redis,Util" --include-path="${SRCROOT}/Headers" --library-path="${SRCROOT}/Libraries/macOS"

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include/Poco "${SRCROOT}/Headers"

cp lib/Darwin/x86_64/libPocoCrypto.a "${SRCROOT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoFoundation.a "${SRCROOT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoZip.a "${SRCROOT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoJSON.a "${SRCROOT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoXML.a "${SRCROOT}/Libraries/macOS"
cp lib/Darwin/x86_64/libPocoNet.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
