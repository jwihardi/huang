# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1 shell-completion systemd tmpfiles

DESCRIPTION="Multizone bidirectional nftables firewall"
HOMEPAGE="https://github.com/FoobarOy/foomuuri https://foomuuri.foobar.fi/latest/"
SRC_URI="https://github.com/FoobarOy/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+dbus +http prometheus systemd xml"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=net-firewall/nftables-1.0.0
	virtual/tmpfiles
	dbus? (
		sys-auth/polkit
		$(python_gen_cond_dep '
			dev-python/dbus-python[${PYTHON_USEDEP}]
			dev-python/pygobject:3[${PYTHON_USEDEP}]
		')
	)
	http? ( $(python_gen_cond_dep 'dev-python/urllib3[${PYTHON_USEDEP}]') )
	prometheus? ( $(python_gen_cond_dep 'dev-python/prometheus-client[${PYTHON_USEDEP}]') )
	systemd? ( $(python_gen_cond_dep 'dev-python/python-systemd[${PYTHON_USEDEP}]') )
	xml? ( $(python_gen_cond_dep 'dev-python/lxml[${PYTHON_USEDEP}]') )
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_compile() {
	:
}

src_test() {
	emake -C test RUN="${EPYTHON}" test
}

src_install() {
	emake \
		DESTDIR="${D}" \
		BINDIR="${EPREFIX}/usr/sbin" \
		SYSTEMD_SYSTEM_LOCATION="$(systemd_get_systemunitdir)" \
		install

	python_fix_shebang "${ED}/usr/sbin/foomuuri"
	newbashcomp misc/foomuuri-bash-completion foomuuri

	insinto /etc/foomuuri
	newins "${FILESDIR}/foomuuri.conf" foomuuri.conf
	fperms 0600 /etc/foomuuri/foomuuri.conf
	newinitd "${FILESDIR}/foomuuri.initd" foomuuri
	keepdir /var/lib/foomuuri
	if ! use dbus; then
		rm \
			"${D}$(systemd_get_systemunitdir)/foomuuri-dbus.service" \
			"${ED}/usr/share/dbus-1/system.d/fi.foobar.Foomuuri-FirewallD.conf" \
			"${ED}/usr/share/dbus-1/system.d/fi.foobar.Foomuuri1.conf" \
			"${ED}/usr/share/foomuuri/dbus-firewalld.conf" \
			"${ED}/usr/share/polkit-1/actions/fi.foobar.Foomuuri1.policy" || die
	fi

	# Runtime creation is handled by tmpfiles or the OpenRC service.
	rmdir "${ED}/run/foomuuri" "${ED}/run" || die

	if use prometheus; then
		emake -C prometheus \
			DESTDIR="${D}" \
			SYSTEMD_SYSTEM_LOCATION="$(systemd_get_systemunitdir)" \
			install
		python_fix_shebang "${ED}/usr/bin/prometheus-foomuuri-exporter"
	else
		rm "${ED}/usr/share/man/man1/prometheus-foomuuri-exporter.1" || die
	fi

	dodoc CHANGELOG.md README.md
}

pkg_postinst() {
	tmpfiles_process foomuuri.conf
}
