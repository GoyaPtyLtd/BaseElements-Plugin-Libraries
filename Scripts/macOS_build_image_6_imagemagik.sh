#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libMagick++-7.Q16HDRI.a
rm Libraries/macOS/libMagickCore-7.Q16HDRI.a
rm Libraries/macOS/libMagickWand-7.Q16HDRI.a

rm -rf Headers/ImageMagick-7

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'_build_macos'

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers/turbojpeg" CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" CXXFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15  -I${OUTPUT}/Headers/turbojpeg" LDFLAGS="-L${OUTPUT}/Libraries/macOS -ljpeg" ./configure --disable-shared --prefix="$PREFIX" --without-utilities --disable-docs --enable-zero-configuration --disable-dependency-tracking --with-quantum-depth=16 --enable-hdri --without-bzlib --disable-openmp --disable-assert --without-zlib PKG_CONFIG_PATH="$(pwd)" JPEG_LIBS="-L${OUTPUT}/Headers/Libraries/macOS -ljpeg"

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include/ImageMagick-7 "${OUTPUT}/Headers/"

cp "_build_macos/lib/libMagick++-7.Q16HDRI.a" "${OUTPUT}/Libraries/macOS/"
cp "_build_macos/lib/libMagickCore-7.Q16HDRI.a" "${OUTPUT}/Libraries/macOS/"
cp "_build_macos/lib/libMagickWand-7.Q16HDRI.a" "${OUTPUT}/Libraries/macOS/"

# Return to source directory

cd ${SRCROOT}
