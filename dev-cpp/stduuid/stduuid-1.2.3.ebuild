# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++17 cross-platform single-header UUID library"
HOMEPAGE="https://github.com/mariusbancila/stduuid"
SRC_URI="https://github.com/mariusbancila/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+system-uuid test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/ms-gsl
	system-uuid? ( sys-apps/util-linux )
"
DEPEND="${RDEPEND}"

src_prepare() {
	# Use Gentoo's GSL implementation instead of installing the bundled copy.
	sed -e '/install(DIRECTORY gsl DESTINATION include)/d' \
		-i CMakeLists.txt || die

	# Correct the upstream package version and honor the selected libdir.
	sed -e 's/VERSION "1.0"/VERSION "'"${PV}"'"/' \
		-e "s:DESTINATION lib/cmake:DESTINATION $(get_libdir)/cmake:g" \
		-i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DUUID_BUILD_TESTS=$(usex test)
		-DUUID_ENABLE_INSTALL=ON
		-DUUID_SYSTEM_GENERATOR=$(usex system-uuid)
	)

	cmake_src_configure
}
