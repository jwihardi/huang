# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="Hyprland GUI utilities, successor to hyprland-qtutils"
HOMEPAGE="https://github.com/hyprwm/hyprland-guiutils"

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

RDEPEND="
	!gui-libs/hyprland-qtutils
	>=gui-libs/hyprtoolkit-0.4.0:=
	>=gui-libs/hyprutils-0.2.4:=
	dev-libs/glib:2
	>=dev-libs/hyprlang-0.6.0:=
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pixman
"

DEPEND="${RDEPEND}"

BDEPEND="
	|| ( >=sys-devel/gcc-${_MIN_GCC_VER}:* >=llvm-core/clang-${_MIN_CLANG_VER}:* )
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
