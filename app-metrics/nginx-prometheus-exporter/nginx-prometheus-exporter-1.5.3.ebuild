# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion systemd

DESCRIPTION="Prometheus exporter for NGINX and NGINX Plus"
HOMEPAGE="https://github.com/nginx/nginx-prometheus-exporter"
SRC_URI="
	amd64? ( https://github.com/nginx/${PN}/releases/download/v${PV}/${PN}_${PV}_linux_amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/nginx/${PN}/releases/download/v${PV}/${PN}_${PV}_linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
"
S=${WORKDIR}

LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="acct-user/nobody"

QA_PREBUILT="usr/bin/${PN}"

src_unpack() {
	case ${ARCH} in
		amd64|arm64) unpack "${P}-${ARCH}.tar.gz" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac
}

src_prepare() {
	default
	gzip -d manpages/${PN}.1.gz || die
}

src_test() {
	./${PN} --version || die
}

src_install() {
	dobin ${PN}
	doman manpages/${PN}.1
	newbashcomp completions/${PN}.bash ${PN}
	newzshcomp completions/${PN}.zsh _${PN}
	dodoc README.md

	newconfd "${FILESDIR}/${PN}.confd" ${PN}
	newinitd "${FILESDIR}/${PN}.initd" ${PN}
	systemd_dounit "${FILESDIR}/${PN}.service"
}
