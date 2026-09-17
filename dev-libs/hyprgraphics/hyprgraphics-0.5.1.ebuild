# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Hyprland graphics / resource utilities"
HOMEPAGE="https://github.com/hyprwm/hyprgraphics"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"
else
	SRC_URI="https://github.com/hyprwm/${PN^}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="
	gnome-base/librsvg:=
	>=gui-libs/hyprutils-0.8.2:=
	media-libs/libheif:=[aom]
	media-libs/libglvnd
	media-libs/libjpeg-turbo:=
	media-libs/libjxl:=
	media-libs/libpng:=
	media-libs/libwebp:=
	x11-libs/cairo:=
	x11-libs/libdrm
	x11-libs/pixman:=
"
DEPEND="${RDEPEND}"
