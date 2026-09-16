# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Open-source pixel-art science-fiction real-time strategy game"
HOMEPAGE="https://www.openhv.net/ https://github.com/OpenHV/OpenHV"
APPIMAGE="OpenHV-${PV}-x86_64.AppImage"
SRC_URI="https://github.com/OpenHV/OpenHV/releases/download/${PV}/${APPIMAGE}"
S=${WORKDIR}

LICENSE="
	Apache-2.0 BSD BSD-2 CC-BY-3.0 CC-BY-4.0 CC-BY-SA-4.0 CC0-1.0
	GPL-3+ ISC LGPL-2.1+ MIT OFL-1.1 public-domain Unicode-DFS-2016 ZLIB
	|| ( FTL GPL-2+ )
"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="splitdebug strip"

RDEPEND="
	dev-libs/icu
	dev-libs/openssl:0=
	dev-util/lttng-ust
	media-libs/alsa-lib
	media-libs/libglvnd
	sys-apps/dbus
	virtual/zlib:=
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
"

QA_PREBUILT="*"

src_unpack() {
	cp "${DISTDIR}/${APPIMAGE}" "${S}" || die
	chmod +x "${S}/${APPIMAGE}" || die
	"${S}/${APPIMAGE}" --appimage-extract || die
}

src_install() {
	cd squashfs-root || die

	dodir /usr/lib
	cp -a usr/lib/openhv "${ED}/usr/lib/" || die

	exeinto /usr/bin
	doexe usr/bin/openhv usr/bin/openhv-server usr/bin/openhv-utility \
		usr/bin/gtk-dialog.py

	insinto /usr/share
	doins -r usr/share/icons usr/share/metainfo usr/share/mime
	domenu usr/share/applications/openhv.desktop

	dodoc usr/lib/openhv/COPYING
}
