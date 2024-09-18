#!/bin/bash

cd ../../..
export START=`pwd`

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
	PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
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


cd BaseElements-Plugin-Libraries/Output
export OUTPUT=`pwd`

cp Libraries/${PLATFORM}/libturbojpeg.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libjpeg.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libde265.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libpng16.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libheif.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libopenjp2.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libMagick++-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libMagickCore-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libMagickWand-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libturbojpeg/" "${START}/BaseElements-Plugin/Headers/libturbojpeg"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/ImageMagick-7/" "${START}/BaseElements-Plugin/Headers/ImageMagick-7"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libopenjp2/" "${START}/BaseElements-Plugin/Headers/libopenjp2"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libheif/" "${START}/BaseElements-Plugin/Headers/libheif"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libpng/" "${START}/BaseElements-Plugin/Headers/libpng"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libde265/" "${START}/BaseElements-Plugin/Headers/libde265"
