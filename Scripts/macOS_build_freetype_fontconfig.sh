#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libfreetype.a
rm macOS/libfontconfig.a

# Remove old headers

rm -rf Headers/freetype2/*
rm -rf Headers/fontconfig/*

#====freetype2====

# Switch to our build directory

cd ../source/macOS/freetype

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --with-png=no --with-bzip2=no --with-harfbuzz=no --with-png=no --with-zlib=no --prefix="$(pwd)/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/freetype2 "${SRCROOT}/Headers"
cp _build_macos/lib/libfreetype.a "${SRCROOT}/Libraries/macOS"

#====fontconfig====

# Switch to our build directory

cd ../fontconfig

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" ./configure --disable-shared --prefix="$(pwd)/_build_macos" FREETYPE_CFLAGS="-I${SRCROOT}/Headers/freetype2" FREETYPE_LIBS="-L${SRCROOT}/Libraries/macOS -lfreetype" LDFLAGS="-L${SRCROOT}/Libraries/macOS"

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/fontconfig "${SRCROOT}/Headers"
cp _build_macos/lib/libfontconfig.a "${SRCROOT}/Libraries/macOS"

#====podofo====

# Switch to our build directory

cd ../podofo

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

cmake -G "Unix Makefiles" -DWANT_FONTCONFIG:BOOL=TRUE -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="./_build_macos" -DPODOFO_BUILD_STATIC:BOOL=TRUE -DFREETYPE_INCLUDE_DIR="${SRCROOT}/Headers/freetype2" -DFREETYPE_LIBRARY_RELEASE="${SRCROOT}/Libraries/macOS/libfreetype.a" -DFONTCONFIG_LIBRARIES="${SRCROOT}/Libraries" -DFONTCONFIG_INCLUDE_DIR="${SRCROOT}/Headers" -DFONTCONFIG_LIBRARY_RELEASE="${SRCROOT}/Libraries/macOS/libfontconfig.a" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 -DCXX_STANDARD_REQUIRED=ON ./

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/podofo "${SRCROOT}/Headers"
cp _build_macos/lib/libpodofo.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
