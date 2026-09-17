# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="Aquamarine is a very light linux rendering backend library"
HOMEPAGE="https://github.com/hyprwm/aquamarine"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"

# Minimum required gcc and clang versions.
_MIN_GCC_VER=15
_MIN_CLANG_VER=19

# Upstream states that the simpleWindow test is broken, see bug 936653
RESTRICT="test"
RDEPEND="
	>=dev-libs/libinput-1.30.0
	dev-libs/wayland
	>=dev-util/hyprwayland-scanner-0.4.5
	>=gui-libs/hyprutils-0.8.4:=
	media-libs/libdisplay-info:=
	media-libs/libglvnd
	media-libs/mesa[opengl]
	sys-apps/hwdata
	>=sys-auth/seatd-0.8.0
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/pixman
	virtual/libudev
"
DEPEND="
	${RDEPEND}
	dev-libs/wayland-protocols
"

BDEPEND="
	|| ( >=sys-devel/gcc-${_MIN_GCC_VER}:* >=llvm-core/clang-${_MIN_CLANG_VER}:* )
	dev-util/wayland-scanner
	virtual/pkgconfig
"

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

src_prepare() {
	sed -i "/add_compile_options(-O3)/d" "${S}/CMakeLists.txt" || die
	cmake_src_prepare
}
