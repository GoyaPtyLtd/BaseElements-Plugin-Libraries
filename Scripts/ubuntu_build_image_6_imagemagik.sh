#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/linux/libMagick++-7.Q16HDRI.a
rm -f Libraries/linux/libMagickCore-7.Q16HDRI.a
rm -f Libraries/linux/libMagickWand-7.Q16HDRI.a

# Switch to our build directory

cd ../source/linux
rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CFLAGS="-I${OUTPUT}/Headers/turbojpeg" CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" \
CXXFLAGS="-I${OUTPUT}/Headers/turbojpeg" LDFLAGS="-L${OUTPUT}/Libraries/linux -ljpeg" \
./configure --disable-shared --prefix="${PREFIX}" \
--without-utilities --disable-docs --enable-zero-configuration --disable-dependency-tracking \
--with-quantum-depth=16 --enable-hdri --without-bzlib --disable-openmp --disable-assert --without-zlib \
PKG_CONFIG_PATH="$(pwd)" JPEG_LIBS="-L${OUTPUT}/Libraries/linux -ljpeg"

make -j install

# Copy the library files.

cp _build_linux/lib/libMagick++-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_linux/lib/libMagickCore-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_linux/lib/libMagickWand-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
