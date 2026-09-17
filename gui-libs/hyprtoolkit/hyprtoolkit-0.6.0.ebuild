# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="A modern C++ Wayland-native GUI toolkit"
HOMEPAGE="https://github.com/hyprwm/hyprtoolkit"

if [[ "${PV}" = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/archive/refs/tags/v${PV}/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/${PN}-${PV}"

	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"
IUSE="test"
RESTRICT="!test? ( test )"

# Minimum required gcc and clang versions.
_MIN_GCC_VER=15
_MIN_CLANG_VER=19

BDEPEND="
	|| ( >=sys-devel/gcc-${_MIN_GCC_VER}:* >=llvm-core/clang-${_MIN_CLANG_VER}:* )
	test? ( dev-cpp/gtest )
"
DEPEND="
	>=dev-libs/hyprgraphics-0.4.0:=
	>=dev-libs/hyprlang-0.6.0:=
	>=dev-util/hyprwayland-scanner-0.4.5
	>=gui-libs/aquamarine-0.10.0:=
	>=gui-libs/hyprutils-0.14.2:=
	dev-libs/glib:2
	dev-libs/iniparser
	dev-libs/wayland
	dev-libs/wayland-protocols
	media-libs/libglvnd
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/pixman
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}

pkg_setup() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc && ver_test $(gcc-version) -lt ${_MIN_GCC_VER} ; then
		eerror "Compiler is sys-devel/gcc-$(gcc-version), requires >=sys-devel/gcc-${_MIN_GCC_VER}."
		die "Active compiler is too old for this package."
	elif tc-is-clang && ver_test $(clang-version) -lt ${_MIN_CLANG_VER} ; then
		eerror "Compiler is llvm-core/clang-$(clang-version), requires >=llvm-core/clang-${_MIN_CLANG_VER}."
		die "Active compiler is too old for this package."
	fi
}
