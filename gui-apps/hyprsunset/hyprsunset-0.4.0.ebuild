# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="An application to enable a blue-light filter on Hyprland"
HOMEPAGE="https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/"

if [[ "${PV}" = *9999 ]]; then
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

RDEPEND="
	dev-libs/wayland
	>=gui-libs/hyprutils-0.2.3:=
	gui-wm/hyprland:=
"

DEPEND="
	${RDEPEND}
	>=dev-libs/hyprland-protocols-0.4.0
	dev-libs/wayland-protocols
	>=dev-util/hyprwayland-scanner-0.4.0
	dev-util/wayland-scanner
"

BDEPEND="
	|| ( >=sys-devel/gcc-${_MIN_GCC_VER}:* >=llvm-core/clang-${_MIN_CLANG_VER}:* )
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
