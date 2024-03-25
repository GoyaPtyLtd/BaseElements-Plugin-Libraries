#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libturbojpeg.a

rm macOS/libMagick++-7.Q16HDRI.a
rm macOS/libMagickCore-7.Q16HDRI.a
rm macOS/libMagickWand-7.Q16HDRI.a

# Remove old headers

rm -rf Headers/ImageMagick-7/*
rm -rf Headers/libturbojpeg/*

#====libjpeg====

# Switch to our build directory

cd ../source/macOS/libjpeg

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON

make install DESTDIR="./_build_macos"

# Copy the header and library files.

cp -R ./_build_macos/opt/libjpeg-turbo/include "${SRCROOT}/Headers/libturbojpeg"

cp ./_build_macos/opt/libjpeg-turbo/lib/libturbojpeg.a "${SRCROOT}/Libraries/macOS"

#====ImageMagick====

# Switch to our build directory

cd ../ImageMagick

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

CXX=clang++ CC=clang CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${SRCROOT}/Headers/turbojpeg" CPPFLAGS="-I${SRCROOT}/Headers/turbojpeg" CXXFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15  -I${SRCROOT}/Headers/turbojpeg" LDFLAGS="-L${SRCROOT}/Libraries/macOS -ljpeg" ./configure --disable-shared --prefix="$(pwd)/_build_macos" --without-utilities --disable-docs --enable-zero-configuration --disable-dependency-tracking --with-quantum-depth=16 --enable-hdri --without-bzlib --disable-openmp --disable-assert --without-zlib PKG_CONFIG_PATH="$(pwd)" JPEG_LIBS="-L${SRCROOT}/Headers/Libraries/macOS -ljpeg"

make install

# Copy the header and library files.

cp -R ./_build_macos/include/ImageMagick-7 "${SRCROOT}/Headers/"

cp "_build_macos/lib/libMagick++-7.Q16HDRI.a" "${SRCROOT}/Libraries/macOS/"
cp "_build_macos/lib/libMagickCore-7.Q16HDRI.a" "${SRCROOT}/Libraries/macOS/"
cp "_build_macos/lib/libMagickWand-7.Q16HDRI.a" "${SRCROOT}/Libraries/macOS/"

# Return to source/macOS directory

cd "START"
