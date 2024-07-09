#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/linux/libPocoCrypto.a
rm -f Libraries/linux/libPocoFoundation.a
rm -f Libraries/linux/libPocoZip.a
rm -f Libraries/linux/libPocoJSON.a
rm -f Libraries/linux/libPocoXML.a
rm -f Libraries/linux/libPocoNet.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

./configure --cflags=-fPIC --typical --static --no-tests --no-samples --include-path="${OUTPUT}/Headers" --prefix="${PREFIX}" --poquito --omit=CppParser,Data,Encodings,MongoDB,PDF,PageCompiler,Redis,Util
make -j install

# Copy the library files.

cp lib/Darwin/x86_64/libPocoCrypto.a "${OUTPUT}/Libraries/linux"
cp lib/Darwin/x86_64/libPocoFoundation.a "${OUTPUT}/Libraries/linux"
cp lib/Darwin/x86_64/libPocoZip.a "${OUTPUT}/Libraries/linux"
cp lib/Darwin/x86_64/libPocoJSON.a "${OUTPUT}/Libraries/linux"
cp lib/Darwin/x86_64/libPocoXML.a "${OUTPUT}/Libraries/linux"
cp lib/Darwin/x86_64/libPocoNet.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}

