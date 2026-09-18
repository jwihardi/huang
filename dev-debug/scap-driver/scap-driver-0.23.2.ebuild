# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake linux-mod-r1

DESCRIPTION="Kernel module for Falco, Sysdig, and Stratoshark"
HOMEPAGE="https://github.com/falcosecurity/libs"
SRC_URI="https://github.com/falcosecurity/libs/archive/${PV}.tar.gz -> falcosecurity-libs-${PV}.tar.gz"
S="${WORKDIR}/libs-${PV}"

LICENSE="Apache-2.0 GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-libs/uthash
	virtual/libelf:=
	virtual/zlib:=
"

CONFIG_CHECK="HAVE_SYSCALL_TRACEPOINTS ~TRACEPOINTS"

# This is the driver tag associated with falcosecurity-libs 0.23.2.
DRIVER_VERSION="9.1.0+driver"

PATCHES=( "${FILESDIR}/0.23.2-properly-use-LD.patch" )

src_configure() {
	local mycmakeargs=(
		-DUSE_BUNDLED_DEPS=ON
		-DUSE_BUNDLED_LIBELF=OFF
		-DUSE_BUNDLED_UTHASH=OFF
		-DUSE_BUNDLED_ZLIB=OFF
		-DCREATE_TEST_TARGETS=OFF
		-DDRIVER_VERSION="${DRIVER_VERSION}"
	)

	cmake_src_configure
}

src_compile() {
	local modlist=( scap=:"${BUILD_DIR}"/driver/src )
	local modargs=( KERNELDIR="${KV_OUT_DIR}" )

	linux-mod-r1_src_compile
}
