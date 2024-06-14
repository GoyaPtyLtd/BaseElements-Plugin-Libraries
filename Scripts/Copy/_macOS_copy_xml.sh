#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Libraries/macOS/libboost_atomic.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libboost_date_time.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libboost_filesystem.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libboost_program_options.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libboost_regex.a "${START}/BaseElements-Plugin/Libraries/macOS"
cp Libraries/macOS/libboost_thread.a "${START}/BaseElements-Plugin/Libraries/macOS"

rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/boost/" "${START}/BaseElements-Plugin/Headers/boost"
