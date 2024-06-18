#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libjq.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/jq/" "${START}/BaseElements-Plugin/Headers/jq"
