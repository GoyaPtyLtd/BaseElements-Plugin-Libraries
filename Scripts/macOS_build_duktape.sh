#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old source

rm -rf Source/duktape/*

# Switch to our build directory

cd ../source/macOS/duktape

# Copy the source files.

cp -R src "${SRCROOT}/Source/duktape"

# Return to source/macOS directory

cd "START"
