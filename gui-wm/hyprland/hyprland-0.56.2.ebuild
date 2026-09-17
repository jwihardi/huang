# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake fcaps toolchain-funcs flag-o-matic

DESCRIPTION="A dynamic tiling Wayland compositor that doesn't sacrifice on its looks"
HOMEPAGE="https://github.com/hyprwm/Hyprland"

if [[ "${PV}" = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/releases/download/v${PV}/source-v${PV}.tar.gz -> ${P}.gh.tar.gz"
	S="${WORKDIR}/${PN}-source"

	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0/$(ver_cut 1-3)"
IUSE="+guiutils hyprpm systemd uwsm X +dbus-session"

REQUIRED_USE="uwsm? ( systemd )"

# Minimum required gcc and clang versions.
_MIN_GCC_VER=15
_MIN_CLANG_VER=19

# hyprpm (hyprland plugin manager) requires the dependencies at runtime
# so that it can clone, compile and install plugins.
HYPRPM_RDEPEND="
	app-alternatives/ninja
	>=dev-build/cmake-3.30
	dev-vcs/git
	virtual/pkgconfig
"
RDEPEND="
	hyprpm? ( ${HYPRPM_RDEPEND} )
	dev-cpp/tomlplusplus
	>=dev-lang/lua-5.5:5.5=
	dev-libs/glib:2
	>=dev-libs/hyprlang-0.6.7:=
	dev-libs/libei:=
	>=dev-libs/libinput-1.29:=
	>=dev-libs/hyprgraphics-0.5.1:=
	dev-libs/re2:=
	dev-cpp/muParser:=
	>=dev-libs/udis86-1.7.2
	>=dev-libs/wayland-1.22.91
	dev-util/glslang:=
	>=gui-libs/aquamarine-0.9.5:=
	>=gui-libs/hyprcursor-0.1.9:=
	>=gui-libs/hyprutils-0.14.0:=
	>=gui-libs/hyprwire-0.2.1:=
	media-libs/lcms:=
	media-libs/libglvnd
	media-libs/mesa
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/libdrm
	>=x11-libs/libxkbcommon-1.11.0
	x11-libs/pango
	x11-libs/pixman
	x11-libs/libXcursor
	guiutils? ( gui-libs/hyprland-guiutils:= )
	X? (
		x11-libs/libxcb:0=
		x11-base/xwayland
		x11-libs/xcb-util-errors
		x11-libs/xcb-util-wm
	)
	dbus-session? ( sys-apps/dbus )
"
# dev-cpp/glaze should be only needed with hyprpm, but is needed by other
# headers.
DEPEND="
	${RDEPEND}
	>=dev-cpp/glaze-7.0.0:=
	<dev-cpp/glaze-8.0.0
	>=dev-libs/hyprland-protocols-0.6.4
	>=dev-libs/wayland-protocols-1.49
"
BDEPEND="
	|| ( >=sys-devel/gcc-${_MIN_GCC_VER}:* >=llvm-core/clang-${_MIN_CLANG_VER}:* )
	app-misc/jq
	dev-build/cmake
	>=dev-util/hyprwayland-scanner-0.4.5
	virtual/pkgconfig
"

FILECAPS=(
	cap_sys_nice usr/bin/Hyprland
)

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
	if use hyprpm; then
		PATCHES+=("${FILESDIR}/hyprland-0.56.0-hyprpm-set-lua.patch")
	fi
	# Apply the following patch unless compiled with GCC 16 or newer.
	# Building Hyprland with Clang using libstdc++ provided by GCC 15 hits the
	# same compilation error.
	# https://codeberg.org/hyproverlay/hyproverlay/issues/95#issuecomment-19928755
	if ! ( tc-is-gcc && ver_test "$(gcc-version)" -ge 16 ); then
		PATCHES+=("${FILESDIR}/hyprland-0.56.0-gcc15-compile-fix.patch")
	fi

	if use dbus-session; then
		sed -i \
			"s|^Exec=|Exec=/usr/libexec/hyprland-dbus-run-session-if-needed |" \
			example/hyprland.desktop.in || die
	fi

	cmake_src_prepare
}

src_configure() {
	local lua_pc=lua5.5
	local lua_cflags
	lua_cflags=$($(tc-getPKG_CONFIG) --cflags "${lua_pc}") || die

	# Keep hyprpm's out-of-tree builds on the same Lua ABI as Hyprland.
	append-cxxflags \
		"-DHYPRPM_GENTOO_LUA_PCFILE=\\\"/usr/$(get_libdir)/pkgconfig/${lua_pc}.pc\\\"" \
		"-DHYPRPM_EXTRA_CFLAGS=\\\"${lua_cflags}\\\"" \
		"-DHYPRPM_EXTRA_CXXFLAGS=\\\"${lua_cflags}\\\""

	local mycmakeargs=(
		"-DBUILD_TESTING=OFF" # if enabled, creates a file inside /lib
							  # causing an error with multilib
		-DNO_HYPRPM="$(usex !hyprpm)"
		-DNO_SYSTEMD="$(usex !systemd)"
		-DNO_XWAYLAND="$(usex !X)"
	)
	use systemd && mycmakeargs+=( -DNO_UWSM="$(usex !uwsm)" )
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use dbus-session; then
		exeinto /usr/libexec
		doexe "${FILESDIR}/hyprland-dbus-run-session-if-needed"
	fi
}
