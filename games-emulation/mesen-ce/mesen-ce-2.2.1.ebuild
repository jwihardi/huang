# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="Multi-system emulator for NES, SNES, GB, GBA, PCE, SMS/GG, and WS"
HOMEPAGE="https://github.com/nesdev-org/MesenCE"
SRC_URI="
	https://github.com/nesdev-org/MesenCE/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	amd64? ( https://github.com/nesdev-org/MesenCE/releases/download/${PV}/Mesen_${PV}_Linux_x64.zip -> ${P}-amd64.zip )
	arm64? ( https://github.com/nesdev-org/MesenCE/releases/download/${PV}/Mesen_${PV}_Linux_ARM64.zip -> ${P}-arm64.zip )
"
S="${WORKDIR}/MesenCE-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	media-libs/libsdl2[joystick,sound,video]
	virtual/zlib
"
BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/Mesen"

src_unpack() {
	unpack "${P}.tar.gz"
	case ${ARCH} in
		amd64|arm64) unpack "${P}-${ARCH}.zip" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac
}

src_compile() {
	:
}

src_install() {
	newbin "${WORKDIR}/Mesen" Mesen
	newicon -s 48 Linux/appimage/Mesen.48x48.png Mesen.png
	domenu Linux/appimage/Mesen.desktop
	dodoc README.md
}
