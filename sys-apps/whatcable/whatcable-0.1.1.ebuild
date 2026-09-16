# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

MY_PN="${PN}-linux"

DESCRIPTION="Tool that reports the capabilities of connected USB devices and cables"
HOMEPAGE="https://github.com/Zetaphor/whatcable-linux"
SRC_URI="https://github.com/Zetaphor/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug +plasma"

RDEPEND="
	dev-qt/qtbase:6=
	virtual/libudev:=
	plasma? (
		dev-qt/qtdeclarative:6=
		kde-frameworks/kcoreaddons:6=
		kde-frameworks/ki18n:6=
		kde-frameworks/kpackage:6=
		kde-plasma/libplasma:6=
		|| (
			kde-frameworks/breeze-icons:*
			kde-frameworks/oxygen-icons:*
		)
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	plasma? ( kde-frameworks/extra-cmake-modules )
"

src_prepare() {
	cmake_src_prepare

	# Upstream forgot to update the project version for the 0.1.1 tag.
	sed -e "s/VERSION 0\.1\.0/VERSION ${PV}/" -i CMakeLists.txt || die

	# Prevent KDECMakeSettings from trying to query a nonexistent Git checkout.
	mkdir po || die
}

src_configure() {
	use debug || append-cppflags -DQT_NO_DEBUG

	local mycmakeargs=(
		$(cmake_use_find_package plasma ECM)
	)

	if use plasma; then
		mycmakeargs+=(
			-DECM_DISABLE_APPSTREAMTEST=ON
			-DKDE_INSTALL_USE_QT_SYS_PATHS=ON
			-DKDE_INSTALL_DOCBUNDLEDIR="${EPREFIX}/usr/share/help"
			-DKDE_INSTALL_INFODIR="${EPREFIX}/usr/share/info"
			-DKDE_INSTALL_LIBDIR="$(get_libdir)"
			-DKDE_INSTALL_LIBEXECDIR="${EPREFIX}/usr/libexec"
			-DKDE_INSTALL_MANDIR="${EPREFIX}/usr/share/man"
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use plasma; then
		# The build-only staging tree contains a duplicate copy of the sources.
		rm -r "${ED}/usr/share/plasma/plasmoids/org.kde.whatcable/plugin" || die
	fi
}
