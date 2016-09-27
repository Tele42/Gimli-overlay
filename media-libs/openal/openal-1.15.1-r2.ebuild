# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit git-2 cmake-multilib

MY_P="jack-backend"

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html"
EGIT_REPO_URI="git://gitorious.org/small-hacks/openal-jack.git"
EGIT_BRANCH="${MY_P}"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa alstream coreaudio debug jack oss portaudio pulseaudio sse neon realtime"

RDEPEND="alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )
	alstream? ( virtual/ffmpeg )
	jack? ( media-sound/jack-audio-connection-kit )
	portaudio? ( >=media-libs/portaudio-19_pre[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-sound/pulseaudio )
	abi_x86_32? (
		amd64? (
			alstream? ( app-emulation/emul-linux-x86-medialibs )
			pulseaudio? ( app-emulation/emul-linux-x86-soundlibs )
		)
	)"
DEPEND="${RDEPEND}
	oss? ( virtual/os-headers )"

S=${WORKDIR}/${MY_P}

DOCS="alsoftrc.sample env-vars.txt hrtf.txt README"

src_unpack() {
	git-2_src_unpack
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use alsa ALSOFT_BACKEND_ALSA)
		$(cmake-utils_use jack ALSOFT_BACKEND_JACK)
		$(cmake-utils_use alstream EXAMPLES)
		$(cmake-utils_use coreaudio)
		$(cmake-utils_use oss ALSOFT_BACKEND_OSS)
		$(cmake-utils_use portaudio ALSOFT_BACKEND_PORTAUDIO)
		$(cmake-utils_use pulseaudio ALSOFT_BACKEND_PULSEAUDIO)
		$(cmake-utils_use sse ALSOFT_CPUEXT_SSE)
		$(cmake-utils_use neon ALSOFT_CPUEXT_NEON)
		$(cmake-utils_use realtime RT_PRIO_VAR)
		)

	cmake-multilib_src_configure
}
