# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit multiprocessing python-any-r1 shell-completion toolchain-funcs

DESCRIPTION="Fast all-in-one JavaScript runtime, bundler, test runner, and package manager"
HOMEPAGE="https://bun.com/ https://github.com/oven-sh/bun"

# Keep these in sync with the release tag and scripts/build/deps/webkit.ts.
BUN_COMMIT="a7733435cf40429e3b35c36072769df2052b80f1"
WEBKIT_COMMIT="d6375c72affe0f70222cdcb45012b10f0bf3a9d5"
EGIT_REPO_URI="https://github.com/oven-sh/WebKit.git"
EGIT_COMMIT="${WEBKIT_COMMIT}"
EGIT_MIN_CLONE_TYPE="shallow"
EGIT_CHECKOUT_DIR="${WORKDIR}/WebKit"
EGIT_SUBMODULES=()
inherit git-r3

# Bun is required to run the build generators. This private bootstrap is
# never installed, avoiding a dependency/blocker cycle with dev-lang/bun-bin.
MY_BASE_URI="https://github.com/oven-sh/bun/releases/download/bun-v${PV}"
SRC_URI="
	https://github.com/oven-sh/bun/archive/refs/tags/bun-v${PV}.tar.gz -> ${P}.tar.gz
	amd64? (
		elibc_glibc? ( ${MY_BASE_URI}/bun-linux-x64-baseline.zip -> bun-bin-${PV}-amd64-baseline.zip )
		elibc_musl? ( ${MY_BASE_URI}/bun-linux-x64-musl-baseline.zip -> bun-bin-${PV}-amd64-musl-baseline.zip )
	)
	arm64? (
		elibc_glibc? ( ${MY_BASE_URI}/bun-linux-aarch64.zip -> bun-bin-${PV}-arm64.zip )
		elibc_musl? ( ${MY_BASE_URI}/bun-linux-aarch64-musl.zip -> bun-bin-${PV}-arm64-musl.zip )
	)
"
S="${WORKDIR}/bun-bun-v${PV}"

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 IJG ISC LGPL-2 LGPL-2.1 MIT openssl Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cpu_flags_x86_avx2"
# Upstream fetches its pinned Rust nightly, npm/crate dependencies and native
# dependency sources during configure/build. The full test suite needs network.
RESTRICT="network-sandbox test"

DEPEND="dev-libs/icu:="
RDEPEND="${DEPEND}
	!dev-lang/bun-bin
"
BDEPEND="
	${PYTHON_DEPS}
	app-arch/unzip
	dev-lang/go
	dev-lang/perl
	dev-lang/ruby
	>=dev-build/cmake-3.30
	dev-build/ninja
	dev-util/rustup
	llvm-core/clang:23
	llvm-core/lld:23
	llvm-core/llvm:23
	virtual/pkgconfig
	amd64? ( dev-lang/nasm )
"

# Upstream's build driver selects its own compiler and optimization flags.
QA_FLAGS_IGNORED="usr/bin/bun"

pkg_setup() {
	python-any-r1_pkg_setup
	if tc-is-cross-compiler; then
		die "Cross-compilation is not supported"
	fi
}

src_unpack() {
	default
	git-r3_src_unpack
}

src_configure() {
	export BUN_BUILD_CACHE_DIR="${T}/build-cache"
	export BUN_INSTALL_CACHE_DIR="${T}/bun-install-cache"
	export BUN_WEBKIT_PATH="${WORKDIR}/WebKit"
	export CARGO_HOME="${T}/cargo"
	export RUSTUP_HOME="${T}/rustup"
	export RUSTUP_TOOLCHAIN="nightly-2026-09-15"
	export GIT_SHA="${BUN_COMMIT}"
	# Gentoo installs rustup as rustup-init, without global cargo/rustc proxies.
	mkdir -p "${T}/bin" "${CARGO_HOME}/bin" || die
	local tool
	for tool in rustup rustc rustdoc cargo; do
		ln -s "${BROOT}/usr/bin/rustup-init" "${CARGO_HOME}/bin/${tool}" || die
	done
	local binaries=( "${WORKDIR}"/bun-linux-*/bun )
	[[ ${#binaries[@]} -eq 1 && -x ${binaries[0]} ]] || die "Missing bootstrap Bun"
	ln -s "${binaries[0]}" "${T}/bin/bun" || die
	# Make the required slotted LLVM visible to upstream's version checks.
	export PATH="${T}/bin:${CARGO_HOME}/bin:${BROOT}/usr/lib/llvm/23/bin:${PATH}"
	export CMAKE_BUILD_PARALLEL_LEVEL=$(makeopts_jobs)
	export CARGO_BUILD_JOBS=$(makeopts_jobs)
	python_setup

	rustup toolchain install "${RUSTUP_TOOLCHAIN}" --profile minimal \
		--component rust-src --no-self-update || die
	bun install --frozen-lockfile || die
	local baseline=off
	use amd64 && ! use cpu_flags_x86_avx2 && baseline=on
	bun scripts/build.ts --profile=release-local --canary=off --baseline=${baseline} \
		--build-dir="${S}/build/release" --configure-only || die
}

src_compile() {
	local baseline=off
	use amd64 && ! use cpu_flags_x86_avx2 && baseline=on
	bun scripts/build.ts --profile=release-local --canary=off \
		--baseline=${baseline} \
		--build-dir="${S}/build/release" -j"$(makeopts_jobs)" || die

	# Exercise the locally compiled binary, including its linked JS engine.
	"${S}/build/release/bun" -e \
		"if (Bun.version !== '${PV}' || (1 + 1) !== 2) process.exit(1)" || die
	local shell
	for shell in bash fish zsh; do
		env SHELL="${shell}" "${S}/build/release/bun" completions "${shell}" \
			> "${T}/bun.${shell}" || die
	done
}

src_install() {
	dobin build/release/bun
	dosym bun /usr/bin/bunx
	newbashcomp "${T}/bun.bash" bun
	newfishcomp "${T}/bun.fish" bun.fish
	newzshcomp "${T}/bun.zsh" _bun
	dodoc LICENSE.md
}
