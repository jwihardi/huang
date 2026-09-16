# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1

DESCRIPTION="GIMP 3 plug-in for scanning through the XSane command-line interface"
HOMEPAGE="https://yingtongli.me/git/gimp-xsanecli/"
SRC_URI="https://bugs.gentoo.org/attachment.cgi?id=955778 -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	media-gfx/gimp[${PYTHON_SINGLE_USEDEP}]
	media-gfx/xsane
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	local plugin_dir="/usr/$(get_libdir)/gimp/3.0/plug-ins/${PN}"

	exeinto "${plugin_dir}"
	newexe xsanecli.py "${PN}"
	python_fix_shebang "${ED}${plugin_dir}/${PN}"

	dodoc README.md CONTRIBUTORS
}
