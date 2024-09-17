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

cp Libraries/${PLATFORM}/libiconv.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libcharset.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libxml2.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libxslt.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libexslt.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

if [ ${PLATFORM} = 'macOS' ]; then

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/iconv/" "${START}/BaseElements-Plugin/Headers/iconv"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libxml/" "${START}/BaseElements-Plugin/Headers/libxml"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libxslt/" "${START}/BaseElements-Plugin/Headers/libxslt"

fi
