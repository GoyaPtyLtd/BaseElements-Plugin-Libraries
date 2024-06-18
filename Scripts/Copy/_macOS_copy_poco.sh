#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libPocoCrypto.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoFoundation.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoZip.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoJSON.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoXML.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libPocoNet.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/Poco/" "${START}/BaseElements-Plugin/Headers/Poco"
