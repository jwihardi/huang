# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake linux-mod-r1

DESCRIPTION="Kernel module for Falco, Sysdig, and Stratoshark"
HOMEPAGE="https://github.com/falcosecurity/libs"
SRC_URI="https://github.com/falcosecurity/libs/archive/${PV}.tar.gz -> falcosecurity-libs-${PV}.tar.gz"
S="${WORKDIR}/libs-${PV}"
CMAKE_USE_DIR="${S}/driver"

LICENSE="Apache-2.0 GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-libs/uthash
	virtual/libelf:=
	virtual/zlib:=
"

CONFIG_CHECK="HAVE_SYSCALL_TRACEPOINTS TRACEPOINTS"

# This is the driver tag associated with falcosecurity-libs 0.26.1.
DRIVER_VERSION="11.0.1+driver"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_MODULE_PATH="${S}/cmake/modules"
		-DENABLE_DKMS=OFF
		-DDRIVER_VERSION="${DRIVER_VERSION}"
	)

	cmake_src_configure
}

src_compile() {
	local modlist=( scap=:"${BUILD_DIR}"/src )
	local modargs=( KERNELDIR="${KV_OUT_DIR}" )

	linux-mod-r1_src_compile
}
