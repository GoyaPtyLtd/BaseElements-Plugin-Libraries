#!/bin/bash
#
#=======================================================================
#
# This just does a cleanout of the Output directory, ready to start building into.
#
# You would only use this if you've been building for a while and then wanted to start fresh.
#
#=======================================================================

cd ../Output

find ./Headers -not -name 'README.md' -delete

find ./Libraries/iOS -not -name 'README.md' -delete
find ./Libraries/linux -not -name 'README.md' -delete
find ./Libraries/linuxARM -not -name 'README.md' -delete
find ./Libraries/macOS -not -name 'README.md' -delete
find ./Libraries/win64 -not -name 'README.md' -delete

