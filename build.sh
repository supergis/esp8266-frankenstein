#!/bin/bash

export PATH=/home/supermap/OpenThings/esp-open-sdk/xtensa-lx106-elf/bin:$PATH
echo $PATH

echo "================================="
echo "Building frankenstein for ESP8266..."
echo "================================="

echo "clean..."
make clean
make

CWD="/../firmware/esp.frankenstein.bin"
OUTPUTBIN=$(pwd)$CWD

FILE_00000="./images/antares-0x00000.bin"
FILE_0A000="./images/antares-0x0a000.bin"
FILE_7C000="./../../esp-open-sdk/esp_iot_sdk_v0.9.5/bin/esp_init_data_default.bin"
FILE_7E000="./../../esp-open-sdk/esp_iot_sdk_v0.9.5/bin/blank.bin"

FILE_00000_SIZE=$(stat -c%s $FILE_00000)
FILE_0A000_SIZE=$(stat -c%s $FILE_0A000)
FILE_7C000_SIZE=$(stat -c%s $FILE_7C000)
FILE_7E000_SIZE=$(stat -c%s $FILE_7E000)

echo "build blank flash image"
IMAGESIZE=$((0x7E000 + FILE_7E000_SIZE))
#thank igr for this tip
dd if=/dev/zero bs=1 count="$IMAGESIZE" conv=notrunc | LC_ALL=C tr "\000" "\377" > "$OUTPUTBIN"

echo "patch image with bins"
dd if="$FILE_00000" of="$OUTPUTBIN" bs=1 seek=0 count="$FILE_00000_SIZE" conv=notrunc
JUMP=$((0x0A000))
dd if="$FILE_0A000" of="$OUTPUTBIN" bs=1 seek="$JUMP" count="$FILE_0A000_SIZE" conv=notrunc  
JUMP=$((0x7C000))
dd if="$FILE_7C000" of="$OUTPUTBIN" bs=1 seek="$JUMP" count="$FILE_7C000_SIZE" conv=notrunc  
JUMP=$((0x7E000))
dd if="$FILE_7E000" of="$OUTPUTBIN" bs=1 seek="$JUMP" count="$FILE_7E000_SIZE" conv=notrunc  
 
echo ">>build image [frankenstein] finished."
echo "Output To: "$OUTPUTBIN

cd ../../


