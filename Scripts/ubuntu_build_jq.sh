#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libjq.a
rm -rf Headers/jq

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf jq
mkdir jq
tar -xf ../jq.tar.gz  -C jq --strip-components=1
cd jq
mkdir _build_linux
export PREFIX=`pwd`+'/_build_linux'

# Build

autoreconf -i

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared --enable-all-static --enable-pthread-tls --without-oniguruma --prefix="${PREFIX}"

make -s -j install

# Copy the library files.

cp -R ./_build_linux/include "${OUTPUT}/Headers/jq"
cp "_build_linux/lib/libjq.a" "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
