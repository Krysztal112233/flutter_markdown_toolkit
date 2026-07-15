frb-version := "2.13.0-beta.5"
project-root := justfile_directory()
flutter-command := env_var_or_default("FLUTTER_COMMAND", "fvm flutter")
dart-command := env_var_or_default("DART_COMMAND", "fvm dart")

host-platform := if os() == "macos" {
    "macos"
} else if os() == "windows" {
    "windows"
} else {
    "linux"
}

# Install the pinned toolchains and resolve dependencies.
setup:
    fvm install
    cargo install flutter_rust_bridge_codegen --version {{frb-version}} --locked
    rustup toolchain install nightly --component rust-src --target wasm32-unknown-unknown
    {{flutter-command}} pub get
    cd example && {{flutter-command}} pub get

# Regenerate Dart and Rust bridge code.
codegen:
    flutter_rust_bridge_codegen generate --skip-fvm-install

# Run analysis, formatting checks, Rust tests, and a native FRB integration test.
check: codegen fmt-check
    {{flutter-command}} analyze
    cd rust && cargo test --locked
    cd example && {{flutter-command}} test integration_test/simple_test.dart -d {{host-platform}}

# Build the example for a target: linux, macos, windows, android, ios, or web.
build target=host-platform:
    just build-{{target}}

# Build the Android App Bundle.
build-android: codegen
    cd example && {{flutter-command}} build appbundle --release

# Build the unsigned iOS application.
build-ios: codegen
    cd example && {{flutter-command}} build ios --release --no-codesign

# Build the Linux application.
build-linux: codegen
    cd example && {{flutter-command}} build linux --release

# Build the macOS application.
build-macos: codegen
    cd example && {{flutter-command}} build macos --release

# Build the Windows application.
build-windows: codegen
    cd example && {{flutter-command}} build windows --release

# Build the Rust WASM package and Flutter Web application.
build-web: codegen
    cd example && {{flutter-command}} build web --release --no-wasm-dry-run
    flutter_rust_bridge_codegen build-web --release --output "{{project-root}}/example/build/web"

# Verify Dart and Rust formatting without modifying files.
fmt-check:
    {{dart-command}} format --output=none --set-exit-if-changed .
    cd rust && cargo fmt --all -- --check

# Format Dart and Rust source files.
fmt:
    {{dart-command}} format .
    cd rust && cargo fmt --all
