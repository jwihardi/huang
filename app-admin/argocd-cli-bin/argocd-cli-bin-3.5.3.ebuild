# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Command-line interface for Argo CD"
HOMEPAGE="https://argo-cd.readthedocs.io/ https://github.com/argoproj/argo-cd"
SRC_URI="amd64? ( https://github.com/argoproj/argo-cd/releases/download/v${PV}/argocd-linux-amd64 -> ${P}-amd64 )"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

QA_PREBUILT="usr/bin/argocd"

src_unpack() {
	cp "${DISTDIR}/${P}-${ARCH}" "${S}/argocd" || die
	chmod +x "${S}/argocd" || die
}

src_install() {
	dobin argocd

	local shell
	for shell in bash fish zsh; do
		"${S}/argocd" completion "${shell}" > "${T}/argocd.${shell}" \
			|| die "failed to generate ${shell} completion"
	done

	newbashcomp "${T}/argocd.bash" argocd
	newfishcomp "${T}/argocd.fish" argocd.fish
	newzshcomp "${T}/argocd.zsh" _argocd
}
