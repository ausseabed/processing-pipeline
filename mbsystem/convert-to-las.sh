#!/bin/bash

env
set -x

echo Starting translate of "$INPUT_FILE"
LOCALNAME_SRC=`echo "$INPUT_FILE" | sed "s/.*\///" `
echo Translate to "$LOCALNAME_SRC"
LAS_ENDING_FILE_NAME=`echo "$LOCALNAME_SRC" | sed "s/\.[^\.]\+$/.las/"`
echo Intermediate name "$LAS_ENDING_FILE_NAME"

/usr/local/bin/aws s3 cp "$INPUT_FILE" "$LOCALNAME_SRC"

FORMAT=`mbformat -K -L -I "$1"`

# The grep command removes any values from <-0.999,-0.999> to <0.999,0.999> (see RM-242)
mblist -MA -U1 -OXYZ -F"$FORMAT" -I "$1" | grep -v "[ ]-\?0\.[^- ]\+[ ]\+-\?0\..*" | txt2las -stdin -itxt -parse xyz -longlat -o "$LAS_ENDING_FILE_NAME"

/usr/local/bin/aws s3 cp "$LAS_ENDING_FILE_NAME" "$DESTINATION_FILE"
