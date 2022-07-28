# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO:
# Fix documentation install directory
# Add CNC category to graphical menu drop-down
# Implement USE flags
# Check for PREEMPT_RT
# Maybe RTAI at some point

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

inherit autotools desktop git-r3 python-single-r1 python-utils-r1 toolchain-funcs xdg-utils

DESCRIPTION="An open source CNC machine controller"
HOMEPAGE="https://www.linuxcnc.org/"
EGIT_REPO_URI="https://github.com/LinuxCNC/linuxcnc.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-lang/python-3.8.13[tk]
	dev-lang/tcl
	dev-lang/tk
	$(python_gen_cond_dep '
		>=dev-libs/boost-1.79[python,${PYTHON_USEDEP}]
		dev-python/pyopengl[${PYTHON_USEDEP}]
		dev-python/yapps2[${PYTHON_USEDEP}]
	')
	dev-libs/glib
	dev-libs/libmodbus
	dev-tcltk/blt
	dev-tcltk/bwidget
	dev-tcltk/tclx
	dev-tcltk/tkimg
	media-libs/mesa
	sys-devel/gettext
	sys-libs/ncurses
	sys-libs/readline
	sys-process/procps
	sys-process/psmisc
	virtual/libudev
	virtual/libusb:1
	x11-base/xorg-server
	x11-libs/libXinerama
	x11-libs/gtk+:2
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}"

S_TOP="${S}"
S="${S}/src"

src_prepare() {
	default

	./autogen.sh || die
}

src_configure() {
	local myconf=(
		--enable-non-distributable=yes
	)

	econf "${myconf[@]}"
}

src_install()
{
	default

	python_optimize

	# Install menus and icons (don't know how to make CNC category in menu)
	doicon "${S_TOP}/debian/extras/usr/share/icons/hicolor/scalable/apps/${PN}-logo.svg"
	doicon "${S_TOP}/debian/extras/usr/share/icons/hicolor/scalable/apps/${PN}icon.svg"
	newmenu "${S_TOP}/debian/extras/usr/share/applications/${PN}.desktop" "${PN}.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-documentation.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-gcoderef.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-gettingstarted.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-integratorinfo.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-latency.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-manualpages.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-pncconf.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}-stepconf.desktop"
	domenu "${S_TOP}/debian/extras/usr/share/applications/${PN}.desktop"
}

pkg_postinst() {
	ewarn "WARNING: Non-distributable build has been enabled!"
	ewarn "The LinuxCNC binary you are building may not be distributable"
	ewarn "due to a license incompatibility with LinuxCNC (some portions"
	ewarn "GPL-2 only) and Readline version 6 and greater (GPL-3 or later)."

	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
