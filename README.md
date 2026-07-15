# flutter_markdown_toolkit

A cross-platform Flutter package using flutter_rust_bridge 2.13 and Native Assets.

## Project structure

- `rust`: Rust crate and Flutter-facing APIs.
- `hook`: Native Assets build hook used on Android, iOS, Linux, macOS, and Windows.
- `lib`: Public Dart API and generated bridge code.
- `example`: Six-platform Flutter application used for development and integration tests.

## Development

Install the pinned Flutter, Rust, and flutter_rust_bridge toolchains, then run the checks:

```shell
just setup
just check
```

After changing an API under `rust/src/api`, regenerate the bridge:

```shell
just codegen
```

Build the example for the local desktop platform with `just build`, or select a target explicitly, such as `just build web` or `just build android`.

Native builds invoke `hook/build.dart` automatically. Web is handled separately: the build recipe creates the Flutter Web application, then compiles Rust to WASM directly into the final `example/build/web/pkg` output.

The Web build uses nightly Rust with `rust-src` and `wasm32-unknown-unknown`; `just setup` installs those prerequisites, while FRB installs `wasm-pack` on first use if needed.
