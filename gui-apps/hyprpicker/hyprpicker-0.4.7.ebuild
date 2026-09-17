# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="A wlroots-compatible Wayland color picker that does not suck"
HOMEPAGE="https://github.com/hyprwm/hyprpicker"

if [[ "${PV}" = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"

# Minimum required gcc and clang versions.
_MIN_GCC_VER=15
_MIN_CLANG_VER=19

RDEPEND="
	dev-libs/wayland
	>=dev-util/hyprwayland-scanner-0.4.2
	gui-libs/hyprutils:=
	x11-libs/cairo
	x11-libs/libxkbcommon
	x11-libs/pango
"
DEPEND="${RDEPEND}"

BDEPEND="
	|| ( >=sys-devel/gcc-${_MIN_GCC_VER}:* >=llvm-core/clang-${_MIN_CLANG_VER}:* )
	dev-libs/wayland-protocols
	dev-util/wayland-scanner
	media-libs/libglvnd
	media-libs/libjpeg-turbo
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
