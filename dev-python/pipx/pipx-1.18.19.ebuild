# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )
PYTHON_REQ_USE="ensurepip(+)"

inherit distutils-r1

DESCRIPTION="Install and run Python applications in isolated environments"
HOMEPAGE="
	https://pipx.pypa.io/stable/
	https://github.com/pypa/pipx/
	https://pypi.org/project/pipx/
"
SRC_URI="https://github.com/pypa/pipx/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="uv"

RDEPEND="
	>=dev-python/argcomplete-3.7.2[${PYTHON_USEDEP}]
	>=dev-python/filelock-4.2[${PYTHON_USEDEP}]
	>=dev-python/packaging-26.3[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.12.2[${PYTHON_USEDEP}]
	>=dev-python/userpath-1.9.2[${PYTHON_USEDEP}]
	uv? ( >=dev-python/uv-0.12.22 )
"
BDEPEND="
	>=dev-python/docutils-0.21.2[${PYTHON_USEDEP}]
	>=dev-python/hatch-fancy-pypi-readme-25.1[${PYTHON_USEDEP}]
	>=dev-python/hatchling-1.32.4[${PYTHON_USEDEP}]
	>=dev-python/hatch-vcs-0.5[${PYTHON_USEDEP}]
	test? (
		dev-python/flit-core[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-2.4[${PYTHON_USEDEP}]
		dev-python/pytest-mock[${PYTHON_USEDEP}]
		>=dev-python/setuptools-68[${PYTHON_USEDEP}]
		dev-vcs/git
	)
"

EPYTEST_PLUGINS=( pytest-mock pytest-timeout )
distutils_enable_tests pytest

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

src_prepare() {
	# Skip upstream release-wheel SBOM generation; Portage records the
	# separately packaged runtime dependencies.
	sed -i '/"python-sbom\[hatch\]/d; /build.hooks.python-sbom =/d' pyproject.toml || die
	distutils-r1_src_prepare
}

python_test() {
	local -x PIP_NO_INDEX=1
	local EPYTEST_DESELECT=(
		# These install packages using upstream's wheel cache.
		tests/test_pipx_metadata_file.py::test_package_install
		tests/test_pipx_metadata_file.py::test_package_inject
		tests/test_result_contract.py::test_contract_success_envelope
	)

	# Run unit-test modules; installer integration tests need a wheel cache.
	# Skip creation of the wheel-backed local PyPI server. PIP_NO_INDEX keeps
	# accidental installer calls offline while the unit tests run.
	epytest --net-pypiserver \
		tests/test_animate.py \
		tests/test_backends.py \
		tests/test_cache.py \
		tests/test_completions.py \
		tests/test_docs_urls.py \
		tests/test_emojis.py \
		tests/test_environment.py \
		tests/test_imports.py \
		tests/test_interpreter.py \
		tests/test_max_logs.py \
		tests/test_package_specifier.py \
		tests/test_paths.py \
		tests/test_pipx_metadata_file.py \
		tests/test_result_contract.py \
		tests/test_subprocess_runner.py \
		tests/test_util.py \
		tests/test_venv_inspect.py
}
