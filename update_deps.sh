#!/bin/bash

set -e

# Android
for pair in \
    arm64-v8a:aarch64 \
    armeabi-v7a:armv7 \
    x86_64:x86-64 \
    x86:x86 \
; do
    IFS=":" read -r a b <<< "$pair"
    cd android/app/src/main/jniLibs/$a
    wget https://github.com/java-native-access/jna/raw/master/dist/android-$b.jar -O android-$b.jar
    unzip -o -j android-$b.jar "libjnidispatch.so"
    cd -
done
