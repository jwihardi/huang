# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

COMMIT="1a5aaa4c15edb043c37113a8cddf020235917050"

DESCRIPTION="Font designed to improve reading proficiency"
HOMEPAGE="https://github.com/ThomasJockin/readexpro"
SRC_URI="https://github.com/ThomasJockin/readexpro/archive/${COMMIT}.tar.gz -> ${P}-readexpro.tar.gz"
S="${WORKDIR}/readexpro-${COMMIT}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

FONT_S="${S}/fonts/ttf"
FONT_SUFFIX="ttf"
