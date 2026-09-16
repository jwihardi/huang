# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic optfeature toolchain-funcs

DESCRIPTION="A powerful light-weight programming language designed for extending applications"
HOMEPAGE="https://www.lua.org/"
SRC_URI="https://www.lua.org/ftp/${P}.tar.gz"

LICENSE="MIT"
SLOT="5.5"
KEYWORDS="~amd64"
IUSE="+deprecated readline"

DEPEND="readline? ( sys-libs/readline:= )"
RDEPEND="
	${DEPEND}
	>=app-eselect/eselect-lua-3
	!dev-lang/lua:0
"

src_prepare() {
	default

	# Use Gentoo's prefix and multilib-aware module directory.
	sed -e 's|#define LUA_ROOT.*|#define LUA_ROOT\t"/usr/"|' \
		-e "s|#define LUA_CDIR.*|#define LUA_CDIR\t\"/usr/$(get_libdir)/lua/\" LUA_VDIR \"/\"|" \
		-i src/luaconf.h || die
}

src_configure() {
	append-cppflags -DLUA_USE_POSIX -DLUA_USE_DLOPEN
	use deprecated && append-cppflags -DLUA_COMPAT_MATHLIB
	use readline && append-cppflags -DLUA_USE_READLINE
}

src_compile() {
	local -a system_libs=( -Wl,-E -ldl )
	use readline && system_libs+=( -lreadline )

	emake -C src all \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR) rcu" \
		RANLIB="$(tc-getRANLIB)" \
		MYCFLAGS="${CFLAGS} ${CPPFLAGS} -fPIC" \
		MYLDFLAGS="${LDFLAGS}" \
		CPPFLAGS= \
		SYSCFLAGS= \
		SYSLDFLAGS= \
		SYSLIBS="${system_libs[*]}"

	local libname="liblua${SLOT}.so"
	$(tc-getCC) ${LDFLAGS} -shared \
		-Wl,-soname,"${libname}.0" \
		-o "src/${libname}.0.0.0" \
		-Wl,--whole-archive src/liblua.a -Wl,--no-whole-archive \
		-lm -ldl || die "failed to link the shared library"
	ln -s "${libname}.0.0.0" "src/${libname}" || die
	ln -s "${libname}.0.0.0" "src/${libname}.0" || die

	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o "src/lua${SLOT}" \
		src/lua.o -Lsrc -Wl,-rpath-link,"${S}/src" -l"lua${SLOT}" \
		"${system_libs[@]}" -lm || die "failed to link lua"
	# luac uses private VM symbols that Lua deliberately hides from its ABI.
	# Keep upstream's statically linked compiler instead of exporting them.
	mv src/luac "src/luac${SLOT}" || die
}

src_test() {
	LD_LIBRARY_PATH="${S}/src" "src/lua${SLOT}" -e \
		'assert(_VERSION == "Lua 5.5")' || die "interpreter test failed"
	printf 'return 42\n' | "src/luac${SLOT}" -p - || \
		die "compiler test failed"
}

src_install() {
	dobin "src/lua${SLOT}" "src/luac${SLOT}"

	local libname="liblua${SLOT}.so"
	dolib.so "src/${libname}.0.0.0"
	dosym "${libname}.0.0.0" "/usr/$(get_libdir)/${libname}.0"
	dosym "${libname}.0.0.0" "/usr/$(get_libdir)/${libname}"

	insinto "/usr/include/lua${SLOT}"
	doins src/{lua.h,luaconf.h,lualib.h,lauxlib.h,lua.hpp}

	newman doc/lua.1 "lua${SLOT}.1"
	newman doc/luac.1 "luac${SLOT}.1"
	dodoc README
	docinto html
	dodoc doc/*.{css,html,png}

	local pc_file="${T}/lua${SLOT}.pc"
	cat > "${pc_file}" <<-EOF || die
	prefix=/usr
	exec_prefix=\${prefix}
	libdir=\${exec_prefix}/$(get_libdir)
	includedir=\${prefix}/include/lua${SLOT}
	datarootdir=\${prefix}/share
	datadir=\${datarootdir}

	Name: Lua
	Description: An Extensible Extension Language
	Version: ${PV}
	Libs: -L\${libdir} -llua${SLOT}
	Libs.private: -lm -ldl
	Cflags: -I\${includedir}

	# information required by lua-utils.eclass::_lua_export
	INSTALL_LMOD=\${datadir}/lua/${SLOT}
	INSTALL_CMOD=\${libdir}/lua/${SLOT}
	EOF
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${pc_file}"
}

pkg_postinst() {
	eselect lua set --if-unset "${PN}${SLOT}"

	optfeature "Lua support for Emacs" app-emacs/lua-mode
}
