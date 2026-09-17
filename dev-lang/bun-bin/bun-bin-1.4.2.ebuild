# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Fast all-in-one JavaScript runtime, bundler, test runner, and package manager"
HOMEPAGE="https://bun.com/ https://github.com/oven-sh/bun"

MY_BASE_URI="https://github.com/oven-sh/bun/releases/download/bun-v${PV}"
SRC_URI="
	amd64? (
		cpu_flags_x86_avx2? (
			elibc_glibc? ( ${MY_BASE_URI}/bun-linux-x64.zip -> ${P}-amd64.zip )
			elibc_musl? ( ${MY_BASE_URI}/bun-linux-x64-musl.zip -> ${P}-amd64-musl.zip )
		)
		!cpu_flags_x86_avx2? (
			elibc_glibc? ( ${MY_BASE_URI}/bun-linux-x64-baseline.zip -> ${P}-amd64-baseline.zip )
			elibc_musl? ( ${MY_BASE_URI}/bun-linux-x64-musl-baseline.zip -> ${P}-amd64-musl-baseline.zip )
		)
	)
	arm64? (
		elibc_glibc? ( ${MY_BASE_URI}/bun-linux-aarch64.zip -> ${P}-arm64.zip )
		elibc_musl? ( ${MY_BASE_URI}/bun-linux-aarch64-musl.zip -> ${P}-arm64-musl.zip )
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cpu_flags_x86_avx2"

BDEPEND="app-arch/unzip"

RESTRICT="strip test"

QA_PREBUILT="usr/bin/bun"

src_prepare() {
	default

	local binaries=( "${WORKDIR}"/bun-linux-*/bun )
	[[ -x ${binaries[0]} ]] || die "Unable to locate the Bun executable"
	[[ ${#binaries[@]} -eq 1 ]] || die "Found multiple Bun executables"
	cp "${binaries[0]}" "${S}/bun" || die

	local shell
	for shell in bash fish zsh; do
		env HOME="${T}" SHELL=${shell} "${S}/bun" completions ${shell} \
			> "${T}/bun.${shell}" || die "Failed to generate ${shell} completion"
	done
}

src_install() {
	dobin bun
	dosym bun /usr/bin/bunx

	newbashcomp "${T}/bun.bash" bun
	newfishcomp "${T}/bun.fish" bun.fish
	newzshcomp "${T}/bun.zsh" _bun
}
