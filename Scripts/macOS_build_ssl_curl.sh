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
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'

# Build macOS

CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-x86_64-cc no-engine no-shared --prefix="${PREFIX}_x86_64"
make install
make distclean

CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-arm64-cc no-engine no-shared --prefix="${PREFIX}_arm64"
make install

lipo -create "${PREFIX}_x86_64/lib/libcrypto.a" "${PREFIX}_arm64/lib/libcrypto.a" -output "${PREFIX}/libcrypto.a"
lipo -create "${PREFIX}_x86_64/lib/libssl.a" "${PREFIX}_arm64/lib/libssl.a" -output "${PREFIX}/libssl.a"

# Copy the header and library files.

cp -R "${PREFIX}/include/openssl" "${OUTPUT}/Headers"

cp "${PREFIX}/libcrypto.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/libssl.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====libssh2====

# Switch to our build directory

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" LDFLAGS="-L${OUTPUT}/Libraries/macOS/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${PREFIX}" -exec-prefix="${PREFIX}" --with-libz --with-crypto=openssl
make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include/*" "${OUTPUT}/Headers/libssh2"
cp "${PREFIX}/lib/libssh2.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====curl====

# Switch to our build directory

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

./configure --host=x86_64-apple-darwin CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -isysroot $(xcrun -sdk macosx --show-sdk-path)" CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/libssh2 -I${OUTPUT}/Headers/openssl" LDFLAGS="-L${OUTPUT}/Libraries/macOS" LIBS="-ldl" --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --without-libpsl --without-brotli --without-zstd --prefix="${PREFIX}"

# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others

make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include/curl" "${OUTPUT}/Headers/"
cp "${PREFIX}/lib/libcurl.a" "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}

