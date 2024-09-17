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

cp Libraries/${PLATFORM}/libjq.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

if [ ${PLATFORM} = 'macOS' ]; then
	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/jq/" "${START}/BaseElements-Plugin/Headers/jq"
fi

