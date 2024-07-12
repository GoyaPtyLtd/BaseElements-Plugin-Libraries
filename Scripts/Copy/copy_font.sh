#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libfreetype.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libfontconfig.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libpodofo.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/freetype2/" "${START}/BaseElements-Plugin/Headers/freetype2"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/fontconfig/" "${START}/BaseElements-Plugin/Headers/fontconfig"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/podofo/" "${START}/BaseElements-Plugin/Headers/podofo"

#PODOFO also uses : libxml, libssl, libcrypto, libjpeg, libpng16