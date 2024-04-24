#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libcrypto.a
rm Libraries/macOS/libssl.a

rm Libraries/macOS/libssh2.a

rm Libraries/macOS/libcurl.a

# Remove old headers

rm -rf Headers/openssl/*
rm -rf Headers/libssh2/*
rm -rf Headers/curl/*

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

#====openssl====

# Switch to our build directory

rm -rf openssl
mkdir openssl
tar -xf ../openssl.tar.gz -C openssl --strip-components=1
cd openssl
mkdir _build_macos
mkdir _build_macos_x86_64
mkdir _build_macos_arm64

# Build

CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-x86_64-cc no-engine no-shared --prefix="${$(pwd)}/_build_macos_x86_64"
make install
make distclean

CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-arm64-cc no-engine no-shared --prefix="${$(pwd)}/_build_macos_arm64"
make install

lipo -create "_build_macos_x86_64/lib/libcrypto.a" "_build_macos_arm64/lib/libcrypto.a" -output "_build_macos/libcrypto.a"
lipo -create "_build_macos_x86_64/lib/libssl.a" "_build_macos_arm64/lib/libssl.a" -output "_build_macos/libssl.a"

# Copy the header and library files.

cp -R _build_macos_x86_64/include/openssl "${OUTPUT}/Headers"

cp _build_macos/libcrypto.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libssl.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====libssh2====

# Switch to our build directory

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh
mkdir _build_macos

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" LDFLAGS="-L${OUTPUT}/Libraries/macOS/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${$(pwd)}/_build_macos" -exec-prefix="${$(pwd)}/_build_macos" --with-libz --with-crypto=openssl
make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/* "${OUTPUT}/Headers/libssh2"
cp _build_macos/lib/libssh2.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====curl====

# Switch to our build directory

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl
mkdir _build_macos

# Build

./configure --host=x86_64-apple-darwin CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -isysroot $(xcrun -sdk macosx --show-sdk-path)" CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/libssh2 -I${OUTPUT}/Headers/openssl" LDFLAGS="-L${OUTPUT}/Libraries/macOS" LIBS="-ldl" --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --without-libpsl --without-brotli --without-zstd --prefix="${$(pwd)}/_build_macos"

# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/curl "${OUTPUT}/Headers/"
cp _build_macos/lib/libcurl.a "${OUTPUT}/Libraries/macOS"

# Return to source/macOS directory

cd ${SRCROOT}

