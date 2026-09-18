# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
PYPI_NO_NORMALIZE=1
PYPI_PN="standard_mailcap"

inherit distutils-r1 pypi

DESCRIPTION="Redistribution of Python's removed mailcap standard library module"
HOMEPAGE="
	https://pypi.org/project/standard-mailcap/
	https://github.com/youknowone/python-deadlib/
"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="~amd64"

# The tests import CPython's test.support package, which is not installed by
# default and would require rebuilding every enabled interpreter with USE=test.
RESTRICT="test"
