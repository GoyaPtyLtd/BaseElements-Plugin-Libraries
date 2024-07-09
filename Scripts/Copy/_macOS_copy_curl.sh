#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libcrypto.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libssl.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libssh2.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libcurl.a "${START}/BaseElements-Plugin/Libraries/macOS"

cp Libraries/macOS/libPocoCrypto.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoFoundation.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoJSON.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoNet.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoPDF.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoXML.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoZip.a "${START}/BaseElements-Plugin/Libraries/macOS"


rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/openssl/" "${START}/BaseElements-Plugin/Headers/openssl"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libssh2/" "${START}/BaseElements-Plugin/Headers/libssh2"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/curl/" "${START}/BaseElements-Plugin/Headers/curl"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/Poco/" "${START}/BaseElements-Plugin/Headers/Poco"
