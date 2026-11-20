# Bun source package

`dev-lang/bun` compiles Bun and its pinned fork of WebKit/JavaScriptCore
locally using upstream's `release-local` profile. `dev-lang/bun-bin` installs
upstream's executable instead. The packages block each other because both
provide `/usr/bin/bun`, `bunx`, and shell completions.

The source build uses a private prebuilt Bun to run code generators. That
bootstrap executable is not installed and does not require installing
`bun-bin`. WebKit is checked out at the exact commit pinned by the corresponding Bun release.

This currently follows upstream's networked build: rustup downloads the pinned
Rust nightly, and the build downloads npm packages, Rust crates, and native
dependency sources. Those secondary downloads are not covered by the Portage
Manifest. `RESTRICT=network-sandbox` is therefore necessary. Toolchain and build
caches stay in Portage's temporary build directory. This is not an offline or
fully distfile-vendored build.

LLVM 23, Ruby, Python, rustup, and the other declared build dependencies must be
installed. Upstream controls compiler/optimization flags; arbitrary `CFLAGS`,
`CXXFLAGS`, and `LDFLAGS` from `make.conf` are not applied. The
`cpu_flags_x86_avx2` USE flag selects the x86 CPU baseline. Build parallelism
follows `MAKEOPTS`. Cross-compilation is unsupported.

The ebuild checks the compiled executable's version and JavaScript execution
before generating completions. The full upstream test suite is disabled because
it needs network access and additional test infrastructure.

When bumping the source ebuild, update `BUN_COMMIT`, `WEBKIT_COMMIT`, the Rust
nightly, and the LLVM slot from the corresponding release sources. Keep at most
three ebuild versions per package; the binary package currently retains 1.4.3,
1.4.5, and 9999.

## Validation

For 1.4.5, release archives were fetched and manifests regenerated. The amd64
baseline binary passed version and JavaScript smoke tests. Source pins were
checked against the release sources. A full source build/install remains
unverified; the validation host lacks Ruby and rustup.

`pkgcheck` reports the network-sandbox restriction and the pinned WebKit VCS
checkout. These are expected consequences of the networked source build.
Older releases are retained up to the three-version limit.
