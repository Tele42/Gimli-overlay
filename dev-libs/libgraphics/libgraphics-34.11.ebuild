# By Eroen, 2012-2013
# Distributed under the terms of the ISC license
# $Header: $

EAPI=5

inherit games versionator scons-utils multilib

DF_PN="df"
DF_PV="$(replace_all_version_separators '_')"
DF_P="${DF_PN}_${DF_PV}"

DESCRIPTION="General purpose library used for games-simulation/dwarffortress"
HOMEPAGE="https://github.com/Baughn/Dwarf-Fortress--libgraphics-"
SRC_URI="http://www.bay12games.com/dwarves/${DF_P}_linux.tar.bz2"

# LGPL-2.1 (for sdl) and fmod are explicitly claimed by the readme.
LICENSE="DwarfFortress fmod LGPL-2.1 BitstreamVera"
SLOT="0"
KEYWORDS="~amd64"
IUSE="egg"

DEPEND_SCONS="virtual/pkgconfig"

DEPEND_INCLUDE="media-libs/glew
	virtual/glu
	media-libs/libsdl
	media-libs/libsndfile
	media-libs/openal
	media-libs/sdl-image
	media-libs/sdl-ttf
	sys-libs/ncurses
	x11-libs/gtk+"

COMMON_DEPEND="!games-simulation/dwarffortress[libgraphics]
	egg? ( games-util/dfhack[egg] )
	app-emulation/emul-linux-x86-gtklibs
	app-emulation/emul-linux-x86-sdl
	|| ( virtual/glu[abi_x86_32(-)] app-emulation/emul-linux-x86-opengl )
	|| ( media-libs/glew[abi_x86_32(-)] app-emulation/emul-linux-x86-opengl )
	|| ( sys-libs/zlib[abi_x86_32(-)] app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )"

	#|| ( media-libs/libsdl app-emulation/emul-linux-x86-sdl )
	#|| ( media-libs/sdl-image app-emulation/emul-linux-x86-sdl )
	#|| ( media-libs/sdl-ttf app-emulation/emul-linux-x86-sdl )
	#|| ( x11-libs/gtk+ app-emulation/emul-linux-x86-gtklibs )

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	${DEPEND_SCONS}
	${DEPEND_INCLUDE}"

S="${WORKDIR}/${DF_PN}_linux"

pkg_setup() {
	multilib_toolchain_setup x86
	games_pkg_setup
}

src_prepare() {
	rm -r data raw || die
	rm g_src/{find_files.cpp,music_and_sound_fmodex.cpp,music_and_sound_fmodex.h} \
		g_src/template.h || die
	rm libs/{Dwarf_Fortress,libgcc_s.so.1,libgraphics.so,libstdc++.so.6} || die
	if use egg; then
		epatch "${FILESDIR}/0001-Add-something-eggy.patch"
		cp "${FILESDIR}/SConscript-egg" "g_src/SConscript" || die
	else
		cp "${FILESDIR}/SConscript" "g_src/SConscript" || die
	fi
	cp "${FILESDIR}/SConstruct" "SConstruct" || die
}

src_compile() {
	LIBPATH="$(games_get_libdir)" escons || die
}

src_install() {
	dogameslib.so "libs/libgraphics.so" || die
}
