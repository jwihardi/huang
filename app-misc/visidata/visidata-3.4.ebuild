# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 optfeature

DESCRIPTION="Terminal interface for exploring and arranging tabular data"
HOMEPAGE="
	https://www.visidata.org/
	https://github.com/saulpw/visidata/
	https://pypi.org/project/visidata/
"
SRC_URI="https://github.com/saulpw/visidata/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/standard-mailcap[${PYTHON_USEDEP}]
	' python3_{13..14})
"
BDEPEND="
	sys-apps/groff
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )
"

distutils_enable_tests pytest

python_compile() {
	local -x PATH="${S}/bin:${PATH}"
	local -x PYTHONPATH="${S}:${S}/visidata"
	local man_dir="${S}/visidata/man"

	"${PYTHON}" "${man_dir}/parse_options.py" \
		"${T}/vd-cli.inc" "${T}/vd-opts.inc" || die
	soelim -rt -I "${T}" "${man_dir}/vd.inc" > "${T}/vd-pre.1" || die
	preconv -r -e utf8 "${T}/vd-pre.1" > "${man_dir}/vd.1" || die
	cp "${man_dir}/vd.1" "${man_dir}/visidata.1" || die

	distutils-r1_python_compile
}

pkg_postinst() {
	optfeature "Excel .xlsx support" dev-python/openpyxl
	optfeature "Excel .xls support" dev-python/xlrd dev-python/xlwt
	optfeature "HTML and XML support" dev-python/lxml
	optfeature "YAML support" dev-python/pyyaml
	optfeature "OpenDocument spreadsheet support" dev-python/odfpy
	optfeature "HDF5 support" dev-python/h5py
	optfeature "pandas formats, including Stata files" dev-python/pandas
	optfeature "Apache Arrow and Parquet support" dev-python/pyarrow
	optfeature "compressed Zstandard data support" dev-python/zstandard
}
