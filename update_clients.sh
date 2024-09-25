#!/bin/bash

set -e

# Apple
clientlib=BoilerplateLib
appname=Boilerplate

for platform in ios macos; do
    rm -rf $platform/$clientlib.xcframework
    cp -aR rust/target/bindings/apple/$clientlib.xcframework $platform/
    cp -f  rust/target/bindings/apple/$clientlib.swift $platform/$appname/
done

# Android
rustlib=boilerplate

for platform in arm64-v8a armeabi-v7a x86_64 x86; do
    mkdir -p android/app/src/main/jniLibs/$platform
    cp -f rust/target/bindings/android/$platform/lib$rustlib.so android/app/src/main/jniLibs/$platform/
done
rm -rf android/app/src/main/java/uniffi
cp -aR rust/target/bindings/android/uniffi android/app/src/main/java/
