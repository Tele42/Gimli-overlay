# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit cmake-multilib

MY_P=${PN}-soft-${PV}

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html"
SRC_URI="http://kcat.strangesoft.net/openal-releases/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="alsa alstream coreaudio debug neon oss portaudio pulseaudio realtime wave"

# String for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
CPU_FEATURES="cpu_flags_x86_sse:sse cpu_flags_x86_sse2:sse2 cpu_flags_x86_sse4_1:sse4_1"

for i in ${CPU_FEATURES}; do
        IUSE="${IUSE} ${i%:*}"
done


RDEPEND="alsa? ( >=media-libs/alsa-lib-1.0.27.2[${MULTILIB_USEDEP}] )
	alstream? ( virtual/ffmpeg )
	portaudio? ( >=media-libs/portaudio-19_pre20111121-r1[${MULTILIB_USEDEP}] )
	pulseaudio? ( >=media-sound/pulseaudio-2.1-r1[${MULTILIB_USEDEP}] )
	abi_x86_32? (
		amd64? (
			alstream? ( app-emulation/emul-linux-x86-medialibs )	
		)
		!<app-emulation/emul-linux-x86-sdl-20131008-r1
		!app-emulation/emul-linux-x86-sdl[-abi_x86_32(-)]
	)"
DEPEND="${RDEPEND}
	oss? ( virtual/os-headers )"

S=${WORKDIR}/${MY_P}

DOCS="alsoftrc.sample env-vars.txt hrtf.txt README"

src_configure() {
	my_configure() {
		local mycmakeargs=(
			$(cmake-utils_use alsa ALSOFT_BACKEND_ALSA)
			$(cmake-utils_use alsa ALSOFT_REQUIRE_ALSA)
			$(cmake-utils_use coreaudio ALSOFT_BACKEND_COREAUDIO)
			$(cmake-utils_use coreaudio ALSOFT_REQUIRE_COREAUDIO)
			$(cmake-utils_use cpu_flags_x86_sse ALSOFT_CPUEXT_SSE)
			$(cmake-utils_use cpu_flags_x86_sse ALSOFT_REQUIRE_SSE)
			$(cmake-utils_use cpu_flags_x86_sse2 ALSOFT_CPUEXT_SSE2)
			$(cmake-utils_use cpu_flags_x86_sse2 ALSOFT_REQUIRE_SSE2)
			$(cmake-utils_use cpu_flags_x86_sse4_1 ALSOFT_CPUEXT_SSE4_1)
			$(cmake-utils_use cpu_flags_x86_sse4_1 ALSOFT_REQUIRE_SSE4_1)
			$(cmake-utils_use neon ALSOFT_CPUEXT_NEON)
			$(cmake-utils_use neon ALSOFT_REQUIRE_NEON)
			$(cmake-utils_use oss ALSOFT_BACKEND_OSS)
			$(cmake-utils_use oss ALSOFT_REQUIRE_OSS)
			$(cmake-utils_use portaudio ALSOFT_BACKEND_PORTAUDIO)
			$(cmake-utils_use portaudio ALSOFT_REQUIRE_PORTAUDIO)
			$(cmake-utils_use pulseaudio ALSOFT_BACKEND_PULSEAUDIO)
			$(cmake-utils_use pulseaudio ALSOFT_REQUIRE_PULSEAUDIO)
			$(cmake-utils_use realtime RT_PRIO_VAR)
			$(cmake-utils_use wave ALSOFT_BACKEND_WAVE)
			$(cmake-utils_use wave ALSOFT_REQUIRE_WAVE)
		)

		if multilib_is_native_abi; then
			mycmakeargs+=( $(cmake-utils_use alstream EXAMPLES) )
		else
			mycmakeargs+=( "-DALSOFT_EXAMPLES=OFF" )
			mycmakeargs+=( "-DALSOFT_NO_CONFIG_UTIL=ON" )
		fi

		cmake-utils_src_configure
	}

	multilib_parallel_foreach_abi my_configure
}
