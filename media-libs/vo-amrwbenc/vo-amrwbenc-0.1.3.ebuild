# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

AUTOTOOLS_PRUNE_LIBTOOL_FILES=all

if [[ ${PV} == *9999 ]] ; then
	SCM="git-2"
	EGIT_REPO_URI="git://github.com/mstorsjo/${PN}.git"
	[[ ${PV%9999} != "" ]] && EGIT_BRANCH="release/${PV%.9999}"
	AUTOTOOLS_AUTORECONF=1
fi

inherit autotools-multilib flag-o-matic ${SCM}

DESCRIPTION="VisualOn AMR-WB encoder library"
HOMEPAGE="http://sourceforge.net/projects/opencore-amr/"

if [[ ${PV} == *9999 ]] ; then
	SRC_URI=""
elif [[ ${PV%_p*} != ${PV} ]] ; then # Gentoo snapshot
	SRC_URI="mirror://gentoo/${P}.tar.xz"
else # Official release
	SRC_URI="mirror://sourceforge/opencore-amr/${P}.tar.gz"
fi

LICENSE="Apache-2.0"
SLOT="0"

[[ ${PV} == *9999 ]] || \
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~x64-macos"
IUSE="examples neon static-libs"

src_configure() {
	if [[ ${CHOST} == x86* ]] ; then
		filter-flags -floop-interchange -floop-strip-mine -floop-block
	fi

	if [[ ${CHOST} == armv* ]] ; then
		my_conf="--enable-armv5e"
		if use neon ; then
			replace-flags -mfpu=vfp* -mfpu=neon
			my_conf="--enable-armv7neon"
		fi
	fi

	local myeconfargs=(
		${my_conf}
		$(use_enable examples example)
	)

	autotools-multilib_src_configure
}
