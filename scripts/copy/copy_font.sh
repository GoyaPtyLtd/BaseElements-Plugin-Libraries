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

cp Libraries/${PLATFORM}/libunistring.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libexpat.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libfreetype.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libfontconfig.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libpodofo.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

if [ ${PLATFORM} = 'macOS' ]; then

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libexpat/" "${START}/BaseElements-Plugin/Headers/libexpat"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/freetype2/" "${START}/BaseElements-Plugin/Headers/freetype2"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libunistring/" "${START}/BaseElements-Plugin/Headers/libunistring"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/fontconfig/" "${START}/BaseElements-Plugin/Headers/fontconfig"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/podofo/" "${START}/BaseElements-Plugin/Headers/podofo"

fi

#PODOFO also uses : libxml, libssl, libcrypto, libjpeg, libpng16