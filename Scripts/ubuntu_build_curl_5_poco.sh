#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/linux/libPocoCrypto.a
rm -f Libraries/linux/libPocoFoundation.a
rm -f Libraries/linux/libPocoJSON.a
rm -f Libraries/linux/libPocoNet.a
rm -f Libraries/linux/libPocoPDF.a
rm -f Libraries/linux/libPocoZip.a
rm -f Libraries/linux/libPocoXML.a

# Switch to our build directory

cd ../source/linux
rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'


./configure --cflags=-fPIC --typical --static --no-tests --no-samples --include-path="${OUTPUT}/Headers" --prefix="${PREFIX}" --poquito --omit=CppParser,Data,Encodings,MongoDB,PageCompiler,Redis,Util

make -j install

# Copy the library files.

cp _build_macos/lib/libPocoCrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_macos/lib/libPocoFoundation.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_macos/lib/libPocoJSON.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_macos/lib/libPocoNet.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_macos/lib/libPocoPDF.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_macos/lib/libPocoXML.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_macos/lib/libPocoZip.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

