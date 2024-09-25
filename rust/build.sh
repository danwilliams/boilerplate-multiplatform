#!/bin/bash

# Useful references:
#
#   - https://forgen.tech/en/blog/post/building-an-ios-app-with-rust-using-uniffi
#   - https://rhonabwy.com/2023/02/10/creating-an-xcframework/
#   - https://forums.developer.apple.com/forums/thread/666335
#   - https://forums.developer.apple.com/forums/thread/673387
#   - https://codethoughts.io/posts/2024-06-24-setting-up-uniffi-for-ios-simulators-and-watchos/
#   - https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle


set -e

rustlib=boilerplate
clientlib=BoilerplateLib
arm64e=0                  # Set to 1 to enable arm64e targets

# Ensure required targets are installed
rustup target add \
    aarch64-apple-darwin \
    x86_64-apple-darwin \
    aarch64-apple-ios \
    aarch64-apple-ios-sim \
    x86_64-apple-ios \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android \
;
if [ "$arm64e" -eq 1 ]; then
    rustup target add \
        arm64e-apple-darwin \
        arm64e-apple-ios \
    ;
fi

# Build everything for default target
cargo build --release

# Build client library for client targets
cargo build --release -p $rustlib --target aarch64-apple-darwin   # MacOS Apple Silicon
cargo build --release -p $rustlib --target x86_64-apple-darwin    # MacOS Intel
cargo build --release -p $rustlib --target aarch64-apple-ios      # iOS
cargo build --release -p $rustlib --target aarch64-apple-ios-sim  # iOS Simulator, Apple Silicon
cargo build --release -p $rustlib --target x86_64-apple-ios       # iOS Simulator, Intel

if [ "$arm64e" -eq 1 ]; then
    cargo build --release -p $rustlib --target arm64e-apple-darwin    # MacOS Apple Silicon with pointer authentication
    cargo build --release -p $rustlib --target arm64e-apple-ios       # iOS with pointer authentication
fi

cargo ndk --platform 34 \
    -t arm64-v8a \
    -t armeabi-v7a \
    -t x86_64 \
    -t x86 \
    -- build --release -p $rustlib

# Generate bindings for client targets
dylib=target/release/lib$rustlib.dylib
cargo run --release --bin uniffi-bindgen generate --library $dylib --language swift  --out-dir target/bindings/apple
cargo run --release --bin uniffi-bindgen generate --library $dylib --language kotlin --out-dir target/bindings/android

## Prepare target directories
mkdir -p \
    target/bindings/apple/{macos,ios,ios-sim} \
    target/bindings/android/{arm64-v8a,armeabi-v7a,x86_64,x86} \
;
mv -f target/bindings/apple/${clientlib}FFI.modulemap target/bindings/apple/module.modulemap
for platform in macos ios ios-sim; do
    cp -f target/bindings/apple/{module.modulemap,$clientlib.swift,${clientlib}FFI.h} target/bindings/apple/$platform/
done
cp -f target/aarch64-linux-android/release/lib$rustlib.so   target/bindings/android/arm64-v8a/
cp -f target/armv7-linux-androideabi/release/lib$rustlib.so target/bindings/android/armeabi-v7a/
cp -f target/x86_64-linux-android/release/lib$rustlib.so    target/bindings/android/x86_64/
cp -f target/i686-linux-android/release/lib$rustlib.so      target/bindings/android/x86/

# Merge binaries for platforms that have multiple architectures
if [ "$arm64e" -eq 1 ]; then
    lipo -create \
        target/aarch64-apple-darwin/release/lib$rustlib.a \
        target/arm64e-apple-darwin/release/lib$rustlib.a \
        target/x86_64-apple-darwin/release/lib$rustlib.a \
        -output target/bindings/apple/macos/lib$rustlib.a
else
    lipo -create \
        target/aarch64-apple-darwin/release/lib$rustlib.a \
        target/x86_64-apple-darwin/release/lib$rustlib.a \
        -output target/bindings/apple/macos/lib$rustlib.a
fi
lipo -create \
    target/aarch64-apple-ios-sim/release/lib$rustlib.a \
    target/x86_64-apple-ios/release/lib$rustlib.a \
    -output target/bindings/apple/ios-sim/lib$rustlib.a
if [ "$arm64e" -eq 1 ]; then
    lipo -create \
        target/aarch64-apple-ios/release/lib$rustlib.a \
        target/arm64e-apple-ios/release/lib$rustlib.a \
        -output target/bindings/apple/ios/lib$rustlib.a
else
    cp -f target/aarch64-apple-ios/release/lib$rustlib.a target/bindings/apple/ios/
fi

# Create the XCFramework
rm -rf target/bindings/apple/$clientlib.xcframework
xcodebuild -create-xcframework \
    -library target/bindings/apple/macos/lib$rustlib.a   -headers target/bindings/apple/macos \
    -library target/bindings/apple/ios/lib$rustlib.a     -headers target/bindings/apple/ios \
    -library target/bindings/apple/ios-sim/lib$rustlib.a -headers target/bindings/apple/ios-sim \
    -output target/bindings/apple/$clientlib.xcframework
