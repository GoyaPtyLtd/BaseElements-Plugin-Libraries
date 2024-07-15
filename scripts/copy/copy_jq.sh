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

cp Libraries/${PLATFORM}/libjq.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

if [ ${PLATFORM} = 'macOS' ]; then
	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/jq/" "${START}/BaseElements-Plugin/Headers/jq"
fi

