# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Extremely fast, in-memory serialization and reflection library for C++"
HOMEPAGE="https://github.com/stephenberry/glaze"
SRC_URI="https://github.com/stephenberry/glaze/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples fuzzing test"
RESTRICT="!test? ( test )"

DEPEND="
	test? (
		dev-cpp/asio
		>=dev-cpp/eigen-3.4:=
		>=dev-cpp/ut2-glaze-1.2.1
	)
"

PATCHES=(
	"${FILESDIR}/${P}-unbundle-test-deps.patch"
)

src_configure() {
	local developer_mode=OFF
	if use test || use fuzzing; then
		developer_mode=ON
	fi

	local mycmakeargs=(
		-DCMAKE_SKIP_INSTALL_RULES=OFF
		-Dglaze_DEVELOPER_MODE=${developer_mode}
		-Dglaze_ENABLE_FUZZING=$(usex fuzzing)
		-Dglaze_BUILD_EXAMPLES=$(usex examples)
	)
	if use test; then
		mycmakeargs+=(
			-DBUILD_TESTING=ON
			-Dglaze_USE_BUNDLED_ASIO=OFF
			-Dglaze_BUILD_NETWORKING_TESTS=OFF
			-Dglaze_BUILD_PERFORMANCE_TESTS=OFF
			-Dglaze_ENABLE_SANITIZERS=OFF
		)
	elif use fuzzing; then
		mycmakeargs+=( -DBUILD_TESTING=OFF )
	fi

	cmake_src_configure
}
