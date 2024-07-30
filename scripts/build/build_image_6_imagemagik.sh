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

export TURBOJPEGarm=`pwd`'/libturbojpeg/_build_arm64/lib/pkgconfig'
export LIBPNGarm=`pwd`'/libpng/_build_arm64/lib/pkgconfig'

export TURBOJPEGx86=`pwd`'/libturbojpeg/_build_arm64/lib/pkgconfig'
export LIBPNGx86=`pwd`'/libpng/_build_arm64/lib/pkgconfig'

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libde265/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libheif/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/fontconfig/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/freetype/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libopenjp2/_build/lib/pkgconfig'

rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'

	PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${TURBOJPEGarm}:${LIBPNGarm} \
	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	CXXFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
	--with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
	--without-utilities --without-zlib --without-xml --without-lzma --with-quantum-depth=16 \
    --enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--host=x86_64-apple-darwin --prefix="${PREFIX_arm64}"

	make
	make -j$(nproc) install
	make -s -j distclean
	
	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${TURBOJPEGx86}:${LIBPNGx86} \
	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	CXXFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
	--with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
	--without-utilities --without-zlib --without-xml --without-lzma --with-quantum-depth=16 \
	--enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--host=x86_64-apple-darwin --prefix="${PREFIX_x86_64}"
	
	make
	make -j$(nproc) install
	make -s -j distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libMagick++-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagick++-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagick++-7.Q16HDRI.a"
	
	lipo -create "${PREFIX_x86_64}/lib/libMagickCore-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickCore-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickCore-7.Q16HDRI.a"
	
	lipo -create "${PREFIX_x86_64}/lib/libMagickWand-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickWand-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickWand-7.Q16HDRI.a"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
	--with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
	--without-utilities --without-zlib --without-xml --without-lzma --with-quantum-depth=16 \
	--enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--prefix="${PREFIX}" \

	make -j$(($(nproc) + 1))
	make install

fi


# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_x86_64/include/ImageMagick-7/* "${OUTPUT}/Headers/ImageMagick-7"
else
	cp -R _build/include/ImageMagick-7/* "${OUTPUT}/Headers/ImageMagick-7"
fi

cp _build/lib/libMagick++-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"
cp _build/lib/libMagickCore-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"
cp _build/lib/libMagickWand-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"

cd ${SRCROOT}
