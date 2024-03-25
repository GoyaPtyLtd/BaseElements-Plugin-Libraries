#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libcrypto.a
rm macOS/libssl.a

rm macOS/libssh2.a

rm macOS/libcurl.a

# Remove old headers

rm -rf Headers/openssl/*
rm -rf Headers/libssh2/*
rm -rf Headers/curl/*

#====openssl====

# Switch to our build directory

cd ../source/macOS/openssl

# Remove old build directory contents
 
mkdir _build_macos
mkdir _build_macos_x86_64
mkdir _build_macos_arm64
rm -rf _build_macos/*
rm -rf _build_macos_x86_64/*
rm -rf _build_macos_arm64/*

# Build

CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-x86_64-cc no-engine no-shared --prefix="${$(pwd)}/_build_macos_x86_64"
make install_sw
make distclean

CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-arm64-cc no-engine no-shared --prefix="${$(pwd)}/_build_macos_arm64"
make install_sw

lipo -create "_build_macos_x86_64/lib/libcrypto.a" "_build_macos_arm64/lib/libcrypto.a" -output "_build_macos/libcrypto.a"
lipo -create "_build_macos_x86_64/lib/libssl.a" "_build_macos_arm64/lib/libssl.a" -output "_build_macos/libssl.a"

# Copy the header and library files.

cp -R _build_macos_x86_64/include/openssl "${SRCROOT}/Headers"

cp _build_macos/libcrypto.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/libssl.a "${SRCROOT}/Libraries/macOS"

#====libssh2====

# Switch to our build directory

cd ../libssh

# Remove old build directory contents
 
mkdir _build_macos
mkdir "${SRCROOT}/Headers/libssh2"
rm -rf _build_macos/*

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${SRCROOT}/Headers -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/macOS/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${$(pwd)}/_build_macos" -exec-prefix="${$(pwd)}/_build_macos" --with-libz --with-crypto=openssl
make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/* "${SRCROOT}/Headers/libssh2"

cp _build_macos/lib/libssh2.a "${SRCROOT}/Libraries/macOS"

#====curl====

# Switch to our build directory

cd ../curl

# Remove old build directory contents
 
mkdir _build_macos
mkdir "${SRCROOT}/Headers/curl"
rm -rf _build_macos/*

# Build

./configure --host=x86_64-apple-darwin CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -isysroot $(xcrun -sdk macosx --show-sdk-path)" CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/libssh2 -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/macOS" LIBS="-ldl" --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --without-libpsl --without-brotli --without-zstd --prefix="${$(pwd)}/_build_macos"

# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/curl "${SRCROOT}/Headers/"
cp _build_macos/lib/libcurl.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
