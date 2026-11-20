# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="System call and log analyzer"
HOMEPAGE="https://stratoshark.org/"

LICENSE="metapackage"
SLOT="0"
IUSE="+modules"

if [[ ${PV} == *9999* ]]; then
	RDEPEND="=net-analyzer/wireshark-9999[stratoshark]"
else
	KEYWORDS="~amd64"
	RDEPEND="=net-analyzer/wireshark-5.0.0_rc2*[stratoshark]"
fi

PDEPEND="modules? ( =dev-debug/scap-driver-0.26.1* )"
