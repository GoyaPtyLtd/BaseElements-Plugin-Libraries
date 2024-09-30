#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
		PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        HOST='x86_64-apple-darwin'
    elif [[ $ARCH = 'x86_64' ]]; then
        HOST='aarch64-apple-darwin'
    fi
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        PLATFORM='linuxARM'
    elif [[ $ARCH = 'x86_64' ]]; then
        PLATFORM='linux'
    fi
fi
if [[ "${PLATFORM}X" = 'X' ]]; then     # $PLATFORM is empty
	echo "!! Unknown OS/ARCH: $OS/$ARCH"
	exit 1
fi


SRCROOT=$(pwd)
cd ../../Output
OUTPUT=$(pwd)

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libMagick++-7.Q16HDRI.a
rm -f Libraries/${PLATFORM}/libMagickCore-7.Q16HDRI.a
rm -f Libraries/${PLATFORM}/libMagickWand-7.Q16HDRI.a

rm -rf Headers/ImageMagick-7
mkdir Headers/ImageMagick-7

cd ../source/${PLATFORM}

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/zlib/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libpng/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libde265/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libheif/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/fontconfig/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/freetype/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libopenjp2/_build/lib/pkgconfig'
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:`pwd`'/libturbojpeg/_build/lib/pkgconfig'

rm -rf ImageMagick
mkdir ImageMagick
tar -xf ../ImageMagick.tar.gz  -C ImageMagick --strip-components=1
cd ImageMagick

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'

	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	CXXFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	CPPFLAGS=" -I${OUTPUT}/Headers/libturbojpeg" LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
	--with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
	--without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
    --enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--host="${HOST}" \
	--prefix="${PREFIX_arm64}"

	make -j${JOBS}
	make install
	make -s distclean

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	CXXFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS=" -I${OUTPUT}/Headers/libturbojpeg" LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
	--with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
	--without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
	--enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--host="${HOST}" \
	--prefix="${PREFIX_x86_64}"

	make -j${JOBS}
	make install
	make -s distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libMagick++-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagick++-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagick++-7.Q16HDRI.a"
	lipo -create "${PREFIX_x86_64}/lib/libMagickCore-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickCore-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickCore-7.Q16HDRI.a"
	lipo -create "${PREFIX_x86_64}/lib/libMagickWand-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickWand-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickWand-7.Q16HDRI.a"

elif [[ $OS = 'Linux' ]]; then

	CFLAGS="-fPIC" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
	--with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
	--without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
	--enable-zero-configuration -enable-hdri --without-bzlib --disable-openmp --disable-assert \
	--prefix="${PREFIX}" \

	make -j${JOBS}
	make install

fi


# Copy the header and library files.

if [[ $PLATFORM = 'macOS' ]]; then
	cp -R _build_x86_64/include/ImageMagick-7/* "${OUTPUT}/Headers/ImageMagick-7"
else
	cp -R _build/include/ImageMagick-7/* "${OUTPUT}/Headers/ImageMagick-7"
fi

cp _build/lib/libMagick++-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"
cp _build/lib/libMagickCore-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"
cp _build/lib/libMagickWand-7.Q16HDRI.a "${OUTPUT}/Libraries/${PLATFORM}/"

cd "${SRCROOT}"
