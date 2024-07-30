#!/bin/bash

cd ../../..
START=$(pwd)

cd BaseElements-Plugin-Libraries/Output/Headers || exit 1
SRC=$(pwd)

DST="${START}/BaseElements-Plugin/Headers"

echo ""
echo "Copying headers from source:"
echo "  ${SRC}/"
echo "to destination:"
echo "  ${DST}/"
echo ""

# For each SRC dir, check if it exists in DST. If it does, remove it from DST
# before copying the new one from SRC.
for src_dir in "${SRC}"/*/; do
    dir_basename=$(basename "$src_dir")
    if [[ -d "${DST}/${dir_basename}" ]]; then
        #echo "Removing old: $dir_basename"
        rm -rf "${DST:?}/${dir_basename}"
    fi
    #echo "Copying new: $dir_basename"
    cp -r "$src_dir" "$DST/$dir_basename"
done
