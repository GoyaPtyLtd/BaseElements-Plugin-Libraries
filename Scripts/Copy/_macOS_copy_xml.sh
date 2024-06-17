#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libiconv.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libcharset.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/iconv/" "${START}/BaseElements-Plugin/Headers/iconv"


cp Libraries/macOS/libxml2.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libxml/" "${START}/BaseElements-Plugin/Headers/libxml"


cp Libraries/macOS/libxslt.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libexslt.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libxslt/" "${START}/BaseElements-Plugin/Headers/libxslt"
