# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.85.0"

inherit cargo git-r3 pam

DESCRIPTION="Memory-safe implementation of sudo and su"
HOMEPAGE="https://github.com/trifectatechfoundation/sudo-rs"
EGIT_REPO_URI="https://github.com/trifectatechfoundation/sudo-rs.git"

LICENSE="|| ( Apache-2.0 MIT )"
# Dependent crate licenses
LICENSE+=" || ( Apache-2.0 MIT )"
SLOT="0"
IUSE="pam su system-names"

RDEPEND="
	sys-libs/pam
	system-names? (
		!app-admin/sudo
		su? (
			!sys-apps/util-linux[su]
			!sys-apps/shadow[su]
			pam? ( sys-apps/util-linux[pam] )
		)
	)
"
DEPEND="${RDEPEND}"

QA_FLAGS_IGNORED="usr/bin/.*"

DOCS=( README.md SECURITY.md CHANGELOG.md )

PATCHES=( "${FILESDIR}/${PN}-0.2.8-tests.patch" )

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_prepare() {
	local -a targets
	local target

	if ! use system-names; then
		find "${S}" -type f \( -name '*.rs' -o -name Cargo.toml \) -print0 \
			| xargs -0 sed -r -e 's:"(sudo|visudo|su)":"\1-rs":g; s:"sudo-i":"sudo-rs-i":g' -i || die

		readarray -t targets < <(find src/bin -name '*.rs')
		for target in "${targets[@]}"; do
			mv "${target}" "${target//.rs/-rs.rs}" || die
		done
	fi

	if ! use su; then
		local su_target="src/bin/su$(usex system-names '' '-rs').rs"
		rm "${su_target}" || die
	fi

	default
}

src_install() {
	cargo_src_install

	local ext=$(usex system-names '' '-rs')
	local -a binaries=( sudo${ext} )
	use su && binaries+=( su${ext} )

	dodoc "${DOCS[@]}"

	local man dest
	for man in docs/man/*.?.man; do
		if [[ ${man##*/} == su.* ]] && ! use su; then
			continue
		fi
		dest="${man##*/}"
		dest="${dest%.man}"
		dest="${dest/./${ext}.}"
		newman "${man}" "${dest}"
	done

	fperms 4755 $(printf -- '/usr/bin/%s\n' "${binaries[@]}")
	dosym sudo${ext} /usr/bin/sudoedit${ext}

	insinto /etc
	doins "${FILESDIR}/sudoers-rs"
	fperms 0440 /etc/sudoers-rs
	keepdir /etc/sudoers.d

	if use pam; then
		pamd_mimic system-auth sudo${ext} auth account session
		pamd_mimic system-auth sudo${ext}-i auth account session
		use su && pamd_mimic system-auth su${ext}-l auth account session
	fi
}
