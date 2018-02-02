# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python3_{4,5,6} )

inherit cmake-utils eutils flag-o-matic python-any-r1

DESCRIPTION="MJPG-streamer, MJPGs from Linux-UVC compatible webcams and RPi"
HOMEPAGE="https://github.com/sarnold/mjpg-streamer"

if [[ ${PV} == "9999" ]] ; then
        EGIT_REPO_URI="https://github.com/sarnold/mjpg-streamer.git"
        EGIT_BRANCH="master"
        inherit git-r3
        KEYWORDS=""
else
        EGIT_REPO_URI="https://github.com/sarnold/mjpg-streamer.git"
	EGIT_COMMIT="8cc9d22c1e79905d529a248ccf05bbf0625e0bf3"
	inherit git-r3
	KEYWORDS="~x86 ~amd64 ~arm ~arm64"
fi

LICENSE="GPL-2"
SLOT="0"

INPUT_PLUGINS="input_testpicture input_control input_file input_uvc"
OUTPUT_PLUGINS="output_file output_udp output_http output_autofocus output_rtsp"
IUSE_PLUGINS="${INPUT_PLUGINS} ${OUTPUT_PLUGINS}"
IUSE="input_testpicture input_control +input_file input_uvc output_file
	output_udp +output_http output_autofocus output_rtsp v4l"

REQUIRED_USE="|| ( ${INPUT_PLUGINS} )
	|| ( ${OUTPUT_PLUGINS} )
	v4l? ( input_uvc )"

RDEPEND="virtual/jpeg
	v4l? ( input_uvc? ( media-libs/libv4l ) )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	input_testpicture? ( media-gfx/imagemagick )"

S="${WORKDIR}/${P}/mjpg-streamer-experimental"

src_configure() {
	append-cxxflags -std=gnu++11
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}

	sed -i -e 's|usr/lib|usr/$(get_libdir)|g' /etc/init.d/${PN}
}

pkg_postinst() {
	elog "Remember to set an input and output plugin for mjpg-streamer."

	echo
	elog "An example webinterface has been installed into"
	elog "/usr/share/mjpg-streamer/www for your usage."
}
