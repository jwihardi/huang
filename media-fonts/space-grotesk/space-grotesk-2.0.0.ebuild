# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Proportional sans-serif typeface based on Space Mono"
HOMEPAGE="https://github.com/floriankarsten/space-grotesk"
SRC_URI="https://github.com/floriankarsten/space-grotesk/releases/download/${PV}/SpaceGrotesk-${PV}.zip -> ${P}.zip"
S="${WORKDIR}/SpaceGrotesk-${PV}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

BDEPEND="app-arch/unzip"

FONT_S="${S}/otf"
FONT_SUFFIX="otf"

src_install() {
	font_src_install
	dodoc OFL.txt
}
