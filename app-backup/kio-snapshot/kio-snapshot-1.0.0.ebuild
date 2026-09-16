# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KFMIN=6.23.0
QTMIN=6.8.0
ECM_TEST=true
inherit ecm

DESCRIPTION="Btrfs filesystem snapshot integration for KDE applications"
HOMEPAGE="https://invent.kde.org/system/kio-snapshot"
SRC_URI="https://github.com/KDE/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0 LGPL-2+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-qt/qtbase-${QTMIN}:6
	>=kde-frameworks/ki18n-${KFMIN}:6
	>=kde-frameworks/kio-${KFMIN}:6
	>=kde-frameworks/solid-${KFMIN}:6
	sys-fs/btrfs-progs
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	ecm_src_configure
}

src_test() {
	# The worker integration tests require a separately mounted Btrfs fixture.
	ecm_src_test -R UrlParsingTest
}
