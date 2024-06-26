#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/linux/libMagick++-7.Q16HDRI.a
rm -f Libraries/linux/libMagickCore-7.Q16HDRI.a
rm -f Libraries/linux/libMagickWand-7.Q16HDRI.a

rm -rf Headers/ImageMagick-7

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

#CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers/turbojpeg" CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" CXXFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15  -I${OUTPUT}/Headers/turbojpeg" LDFLAGS="-L${OUTPUT}/Libraries/macOS -ljpeg" ./configure --disable-shared --prefix="${PREFIX}" --without-utilities --disable-docs --enable-zero-configuration --disable-dependency-tracking --with-quantum-depth=16 --enable-hdri --without-bzlib --disable-openmp --disable-assert --without-zlib PKG_CONFIG_PATH="$(pwd)" JPEG_LIBS="-L${OUTPUT}/Headers/Libraries/macOS -ljpeg"

CFLAGS="-I${OUTPUT}/Headers/turbojpeg" CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" CXXFLAGS="-I${OUTPUT}/Headers/turbojpeg" LDFLAGS="-L${OUTPUT}/Libraries/linux -ljpeg" ./configure --disable-shared --prefix="${PREFIX}" --without-utilities --disable-docs --enable-zero-configuration --disable-dependency-tracking --with-quantum-depth=16 --enable-hdri --without-bzlib --disable-openmp --disable-assert --without-zlib PKG_CONFIG_PATH="$(pwd)" JPEG_LIBS="-L${OUTPUT}/Headers/Libraries/linux -ljpeg"

make -j install

# Copy the library files.

cp -R ./_build_linux/include/ImageMagick-7 "${OUTPUT}/Headers/"

cp "_build_linux/lib/libMagick++-7.Q16HDRI.a" "${OUTPUT}/Libraries/linux/"
cp "_build_linux/lib/libMagickCore-7.Q16HDRI.a" "${OUTPUT}/Libraries/linux/"
cp "_build_linux/lib/libMagickWand-7.Q16HDRI.a" "${OUTPUT}/Libraries/linux/"

# Return to source directory

cd ${SRCROOT}
