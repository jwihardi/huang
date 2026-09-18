# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Portable CLI for interacting with Git forges and Bugzilla"
HOMEPAGE="https://herrhotzenplotz.de/gcli/ https://github.com/herrhotzenplotz/gcli"
SRC_URI="https://herrhotzenplotz.de/gcli/releases/${P}/${P}.tar.xz"

LICENSE="BSD-2 Unlicense"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libedit lowdown +readline test"

REQUIRED_USE="?? ( libedit readline )"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/openssl:=
	net-misc/curl:=
	libedit? ( dev-libs/libedit:= )
	lowdown? ( app-text/lowdown:= )
	readline? ( sys-libs/readline:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/lex
	app-alternatives/yacc
	virtual/pkgconfig
	test? ( dev-lang/perl )
"

BUILD_DIR="${WORKDIR}/${P}_build"

src_configure() {
	local myconf=(
		--prefix="${EPREFIX}/usr"
	)

	use libedit || myconf+=( --disable-libedit )
	use lowdown || myconf+=( --disable-liblowdown )
	use readline || myconf+=( --disable-libreadline )
	use test || myconf+=( --disable-tests )

	tc-export AR CC RANLIB
	mkdir -p "${BUILD_DIR}" || die
	cd "${BUILD_DIR}" || die
	CC_FOR_BUILD="$(tc-getBUILD_CC)" "${S}/configure" "${myconf[@]}" || die
}

src_compile() {
	emake -C "${BUILD_DIR}"
}

src_test() {
	emake -C "${BUILD_DIR}" check
}

src_install() {
	emake -C "${BUILD_DIR}" DESTDIR="${D}" install
	find "${ED}/usr/share/man" -type f -name '*.gz' -exec gzip -d {} + || die
	einstalldocs
}
