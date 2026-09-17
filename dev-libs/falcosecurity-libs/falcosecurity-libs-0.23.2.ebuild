# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Libraries for inspecting and enriching system call events"
HOMEPAGE="https://github.com/falcosecurity/libs"
SRC_URI="
	https://github.com/falcosecurity/libs/archive/${PV}.tar.gz -> ${P}.tar.gz
	test? (
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/fchdir.scap -> ${P}-fchdir.scap
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/kexec_arm64.scap -> ${P}-kexec_arm64.scap
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/kexec_x86.scap -> ${P}-kexec_x86.scap
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/mkdir.scap -> ${P}-mkdir.scap
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/ptrace.scap -> ${P}-ptrace.scap
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/sample.scap -> ${P}-sample.scap
		https://falco-distribution.s3.eu-west-1.amazonaws.com/fixtures/libs/scap_files/scap_2013.scap -> ${P}-scap_2013.scap
	)
"
S="${WORKDIR}/libs-${PV}"

LICENSE="Apache-2.0 GPL-2 MIT"
SLOT="0/0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/abseil-cpp:=
	dev-cpp/tbb:=
	dev-libs/jsoncpp:=
	dev-libs/re2:=
	dev-libs/uthash
	dev-cpp/valijson
	virtual/libelf:=
	virtual/zlib:=
"
DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gtest )
"
src_configure() {
	if use test; then
		local fixture
		mkdir -p "${BUILD_DIR}"/scap_files || die
		for fixture in fchdir kexec_arm64 kexec_x86 mkdir ptrace sample scap_2013; do
			cp "${DISTDIR}/${P}-${fixture}.scap" \
				"${BUILD_DIR}/scap_files/${fixture}.scap" || die
		done
	fi
	local mycmakeargs=(
		-DFALCOSECURITY_LIBS_VERSION="${PV}"
		-DDRIVER_VERSION="9.1.0+driver"
		-DBUILD_SHARED_LIBS=ON
		-DUSE_BUNDLED_DEPS=OFF
		-DUSE_BUNDLED_DRIVER=ON
		-DBUILD_DRIVER=OFF
		-DENABLE_DKMS=OFF
		-DCREATE_TEST_TARGETS=$(usex test)
		-DENABLE_E2E_TESTS=OFF
		-DENABLE_DRIVERS_TESTS=OFF
		-DENABLE_LIBSCAP_TESTS=OFF
		-DENABLE_LIBSINSP_E2E_TESTS=OFF
		-DBUILD_LIBSCAP_GVISOR=OFF
		-DBUILD_LIBSCAP_EXAMPLES=OFF
		-DBUILD_LIBSINSP_EXAMPLES=OFF
	)

	cmake_src_configure
}

src_test() {
	cmake_build run-unit-test-libsinsp
}
