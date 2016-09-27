# By Eroen, 2012-2014
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# $Header: $

EAPI=5

inherit scons-utils toolchain-funcs versionator multilib games

DESCRIPTION="General purpose library used by dwarffortress"
HOMEPAGE="http://www.bay12games.com/dwarves
	http://github.com/Baughn/Dwarf-Fortress--libgraphics-"
SRC_URI="http://www.bay12games.com/dwarves/df_${PV//./_}_linux.tar.bz2"

LICENSE="BSD"
SLOT=${PV}
KEYWORDS="~amd64" # ~x86
IUSE="egg"

HDEPEND="virtual/pkgconfig"
LIBDEPEND="
	|| ( media-libs/glew[abi_x86_32]
		( media-libs/glew
			app-emulation/emul-linux-x86-opengl ) )
	|| ( virtual/glu[abi_x86_32]
		( virtual/glu
			app-emulation/emul-linux-x86-opengl ) )
	|| ( media-libs/libsdl[abi_x86_32]
		( media-libs/libsdl
			app-emulation/emul-linux-x86-sdl ) )
	|| ( media-libs/libsndfile[abi_x86_32]
		( media-libs/libsndfile
			app-emulation/emul-linux-x86-soundlibs ) )
	|| ( media-libs/openal[abi_x86_32]
		( media-libs/openal
			app-emulation/emul-linux-x86-sdl ) )
	|| ( media-libs/sdl-image[abi_x86_32]
		( media-libs/sdl-image
			app-emulation/emul-linux-x86-sdl ) )
	|| ( media-libs/sdl-ttf[abi_x86_32]
		( media-libs/sdl-ttf
			app-emulation/emul-linux-x86-sdl ) )
	|| ( sys-libs/ncurses[abi_x86_32]
		( sys-libs/ncurses
			app-emulation/emul-linux-x86-baselibs ) )
	|| ( sys-libs/zlib[abi_x86_32]
		( sys-libs/zlib
			app-emulation/emul-linux-x86-baselibs ) )
	|| ( x11-libs/gtk+:2[abi_x86_32]
		( x11-libs/gtk+:2
			app-emulation/emul-linux-x86-gtklibs ) )
	egg? ( games-util/dfhack:${SLOT}[egg] )
	"
RDEPEND="${LIBDEPEND}"
DEPEND="${HDEPEND}
	${LIBDEPEND}
	"

S=${WORKDIR}/df_linux

pkg_setup() {
	if use egg && version_is_at_least 4.9 $(gcc-version); then
		ewarn "gcc-4.9 and ${PN} with USE=egg seems incompatible."
		ewarn "If you experience problems, try disabling all compiler"
		ewarn "optimization or switching to an earlier gcc version."
	fi

	multilib_toolchain_setup x86
	games_pkg_setup

	df_LIBPATH=$(games_get_libdir)/dwarffortress-${SLOT}
}

src_prepare() {
	rm -r data raw || die
	rm g_src/{find_files.cpp,music_and_sound_fmodex.cpp,music_and_sound_fmodex.h} \
		g_src/template.h || die
	rm libs/{Dwarf_Fortress,libgcc_s.so.1,libgraphics.so,libstdc++.so.6} || die

	if use egg; then
		epatch "${FILESDIR}"/${PN}-40.24-Add-something-eggy.patch
		cp "${FILESDIR}/SConscript-egg" "g_src/SConscript" || die
	else
		cp "${FILESDIR}/SConscript" "g_src/SConscript" || die
	fi
	cp "${FILESDIR}/SConstruct" "SConstruct" || die
}

src_compile() {
	LIBPATH="${df_LIBPATH}" escons
}

src_install() {
	# libgraphics lacks SONAME, so we keep it out of system libdir.
	exeinto "${df_LIBPATH}"
	doexe "libs/libgraphics.so"
	prepgamesdirs
	# userpriv: portage user will need to link against libraries here.
	fperms o+rx "${df_LIBPATH}"
}
