#!/bin/bash

cd ../../..

export START=`pwd`

cd BaseElements-Plugin-Libraries/Output

export OUTPUT=`pwd`

cp Source/duktape/src/duk_config.h "${START}/BaseElements-Plugin/Source/duktape"
cp Source/duktape/src/duktape.c "${START}/BaseElements-Plugin/Source/duktape"
cp Source/duktape/src/duktape.h "${START}/BaseElements-Plugin/Source/duktape"
