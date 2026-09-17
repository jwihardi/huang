# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module git-r3

DESCRIPTION="CLI anime streamer with AniList integration and Discord Rich Presence"
HOMEPAGE="https://github.com/Wraient/curd"
EGIT_REPO_URI="https://github.com/Wraient/curd.git"
# The repository's only Git LFS object is an unused Windows executable.

LICENSE="GPL-3"
SLOT="0"
IUSE="rofi"

RDEPEND="
	media-video/mpv
	x11-misc/xdg-utils
	rofi? (
		media-gfx/ueberzugpp
		x11-misc/rofi
	)
"

src_compile() {
	ego build -mod=vendor -o curd ./cmd/curd
}

src_test() {
	ego test -mod=vendor ./...
}

src_install() {
	dobin curd
	dodoc README.md docs/providers.md
}
