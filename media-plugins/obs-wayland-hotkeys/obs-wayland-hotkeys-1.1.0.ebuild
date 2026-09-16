# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="OBS Studio plugin providing global hotkeys through the Wayland portal"
HOMEPAGE="https://github.com/leia-uwu/obs-wayland-hotkeys"
SRC_URI="https://github.com/leia-uwu/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-qt/qtbase:6=[dbus,gui,widgets]
	dev-qt/qtwayland:6=
	>=media-video/obs-studio-31.1[wayland]
"
RDEPEND="
	${DEPEND}
	sys-apps/xdg-desktop-portal
"

src_prepare() {
	# Do not turn upstream compiler warnings into build failures.
	sed -e '/-Werror$/d' -i cmake/linux/compilerconfig.cmake || die
	cmake_src_prepare
}
