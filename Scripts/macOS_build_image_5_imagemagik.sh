#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libMagick++-7.Q16HDRI.a
rm -f Libraries/macOS/libMagickCore-7.Q16HDRI.a
rm -f Libraries/macOS/libMagickWand-7.Q16HDRI.a

rm -rf Headers/ImageMagick-7
mkdir Headers/ImageMagick-7

# Switch to our build directory

cd ../source/macOS

rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

CXX=clang++ \
CC=clang \
CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers/turbojpeg" \
CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" \
CXXFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15  -I${OUTPUT}/Headers/turbojpeg" \
LDFLAGS="-L${OUTPUT}/Libraries/macOS -ljpeg" \
./configure --disable-shared --prefix="${PREFIX}" --without-utilities --disable-docs \
            --enable-zero-configuration --disable-dependency-tracking --with-quantum-depth=16 \
			--enable-hdri --without-bzlib --disable-openmp --disable-assert --without-zlib --without-xml \
			JPEG_LIBS="-L${OUTPUT}/Libraries/macOS -ljpeg"

make -j install

# Copy the header and library files.

cp -R _build_macos/include/ImageMagick-7/* "${OUTPUT}/Headers/ImageMagick-7"

cp _build_macos/lib/libMagick++-7.Q16HDRI.a "${OUTPUT}/Libraries/macOS/"
cp _build_macos/lib/libMagickCore-7.Q16HDRI.a "${OUTPUT}/Libraries/macOS/"
cp _build_macos/lib/libMagickWand-7.Q16HDRI.a "${OUTPUT}/Libraries/macOS/"

# Return to source directory

cd ${SRCROOT}
