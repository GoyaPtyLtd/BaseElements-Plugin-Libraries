#!/bin/bash

cd ../../..
export START=`pwd`

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'
elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

cd BaseElements-Plugin-Libraries/Output
export OUTPUT=`pwd`

cp Libraries/${PLATFORM}/libturbojpeg.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libjpeg.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libMagick++-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libMagickCore-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libMagickWand-7.Q16HDRI.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libopenjp2.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libheif.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libpng16.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libde265.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

if [ ${PLATFORM} = 'macOS' ]; then

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libturbojpeg/" "${START}/BaseElements-Plugin/Headers/libturbojpeg"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/ImageMagick-7/" "${START}/BaseElements-Plugin/Headers/ImageMagick-7"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libopenjp2/" "${START}/BaseElements-Plugin/Headers/libopenjp2"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libheif/" "${START}/BaseElements-Plugin/Headers/libheif"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libpng/" "${START}/BaseElements-Plugin/Headers/libpng"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libde265/" "${START}/BaseElements-Plugin/Headers/libde265"

fi