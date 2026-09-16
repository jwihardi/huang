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
	>=dev-python/argcomplete-1.9.4[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.16[${PYTHON_USEDEP}]
	>=dev-python/packaging-26[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.6[${PYTHON_USEDEP}]
	>=dev-python/userpath-1.6[${PYTHON_USEDEP}]
	uv? ( >=dev-python/uv-0.9.17 )
"
BDEPEND="
	>=dev-python/docutils-0.21[${PYTHON_USEDEP}]
	>=dev-python/hatch-vcs-0.4[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest-mock[${PYTHON_USEDEP}]
		>=dev-python/setuptools-68[${PYTHON_USEDEP}]
		dev-vcs/git
	)
"

EPYTEST_PLUGINS=( mock )
distutils_enable_tests pytest

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

python_test() {
	local -x PIP_NO_INDEX=1
	local EPYTEST_DESELECT=(
		# These require upstream's large wheel cache for integration tests.
		tests/test_common.py::test_remove_stale_venv_resources_keeps_files_pipx_does_not_own
		tests/test_execute.py::test_execute_runs_recorded_app
		tests/test_execute.py::test_execute_rejects_unknown_app
		tests/test_execute.py::test_execute_rejects_missing_recorded_app
		tests/test_pipx_metadata_file.py::test_package_install
		tests/test_pipx_metadata_file.py::test_package_inject
		tests/test_result_contract.py::test_contract_success_envelope
	)

	# Skip creation of the wheel-backed local PyPI server. PIP_NO_INDEX keeps
	# accidental installer calls offline while the unit tests run.
	epytest --net-pypiserver \
		tests/test_animate.py \
		tests/test_backends.py \
		tests/test_cache.py \
		tests/test_common.py \
		tests/test_completions.py \
		tests/test_docs_urls.py \
		tests/test_emojis.py \
		tests/test_environment.py \
		tests/test_execute.py \
		tests/test_imports.py \
		tests/test_interpreter.py \
		tests/test_main.py \
		tests/test_max_logs.py \
		tests/test_package_specifier.py \
		tests/test_paths.py \
		tests/test_pipx_metadata_file.py \
		tests/test_result_contract.py \
		tests/test_script.py \
		tests/test_subprocess_env.py \
		tests/test_transaction.py \
		tests/test_util.py \
		tests/test_venv_inspect.py
}
