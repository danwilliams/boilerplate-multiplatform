# Boilerplate multi-platform application template

This repository is a simple multi-platform template, containing:

  - Rust library and webserver, using [Terracotta](https://crates.io/crates/terracotta).
  - MacOS application
  - iOS application
  - Android application

The Rust library is exported using UniFFI, and the FFI bindings are made
available to the following clients:

  - MacOS
  - iOS
  - Android
  - Web

This results in a clean starting-point and reference for setting up similar
projects. Using the providing build scripts it is easy to update the Rust
library for the mobile clients:

  - `cargo build` and other Cargo commands to do standard Rust-specific things
  - `./rust/build.sh` to build the Rust library for all platforms
  - `./update_clients.sh` to update the clients with the new Rust library
  - `./update_deps.sh` to occasionally update Android dependencies

These operations should form a good basis for expansion.
