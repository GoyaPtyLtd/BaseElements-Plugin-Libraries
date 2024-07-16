#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'
elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libMagick++-7.Q16HDRI.a
rm -f Libraries/${PLATFORM}/libMagickCore-7.Q16HDRI.a
rm -f Libraries/${PLATFORM}/libMagickWand-7.Q16HDRI.a

rm -rf Headers/ImageMagick-7
mkdir Headers/ImageMagick-7

cd ../source/${PLATFORM}

rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers/turbojpeg" \
	CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" \
	CXXFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15  -I${OUTPUT}/Headers/turbojpeg" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM} -ljpeg" \
	./configure --disable-shared --prefix="${PREFIX}" \
	--without-utilities --disable-docs --disable-dependency-tracking --with-quantum-depth=16 \
    --enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--without-zlib --without-xml --without-lzma \
	JPEG_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -ljpeg"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-I${OUTPUT}/Headers/turbojpeg" \
	CPPFLAGS="-I${OUTPUT}/Headers/turbojpeg" \
	CXXFLAGS="-I${OUTPUT}/Headers/turbojpeg" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM} -ljpeg" \
	./configure --disable-shared --prefix="${PREFIX}" \
	--without-utilities --disable-docs --disable-dependency-tracking --with-quantum-depth=16 \
	--enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--without-zlib --without-xml --without-lzma \
	JPEG_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -ljpeg"

fi

make
make -j install

# Copy the header and library files.

cp -R _build/include/ImageMagick-7/* "${OUTPUT}/Headers/ImageMagick-7"

cp _build/lib/libMagick++-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"
cp _build/lib/libMagickCore-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"
cp _build/lib/libMagickWand-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"

cd ${SRCROOT}
