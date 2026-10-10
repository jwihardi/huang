# Bun source package

`dev-lang/bun-1.4.3` compiles Bun and its pinned fork of WebKit/JavaScriptCore
locally using upstream's `release-local` profile. `dev-lang/bun-bin` installs
upstream's executable instead. The packages block each other because both
provide `/usr/bin/bun`, `bunx`, and shell completions.

The source build uses a private prebuilt Bun to run code generators. That
bootstrap executable is not installed and does not require installing
`bun-bin`. WebKit is checked out at the exact commit pinned by Bun 1.4.3.

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
three ebuild versions per package; the binary package currently retains 1.4.2,
1.4.3, and 9999.

## Validation

Manifests were generated with `pkgdev manifest`. `pkgcheck scan --net`, shell
syntax checks, and `git diff --check` were run. The 1.4.3 bootstrap binary passed
a JavaScript/version smoke test and generated bash, fish, and zsh completions.
The source configure command reached upstream's LLVM version check, but a full
source build/install has not been verified: the validation host has LLVM 22,
and lacks LLVM 23, Ruby, and rustup. Portage's dependency preview also requires
adjusting the host's Ruby target USE flags before installing Ruby.

Remaining pkgcheck reports: Python 3.15 support is available but untested;
`network-sandbox` is a Portage restriction outside pkgcheck's recognized list;
`git-r3` marks the pinned WebKit checkout as a VCS package; and retained binary
version 1.4.2 is superseded by 1.4.3.
