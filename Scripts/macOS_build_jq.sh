#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libjq.a
rm -rf Headers/jq

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf jq
mkdir jq
tar -xf ../jq.tar.gz  -C jq --strip-components=1
cd jq
mkdir _build_macos

# Build

autoreconf -i

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared --enable-all-static --enable-pthread-tls --without-oniguruma --prefix="${$(pwd)}/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include "${OUTPUT}/Headers/jq"
cp "_build_macos/lib/libjq.a" "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
