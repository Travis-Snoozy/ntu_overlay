# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO:
# Fix documentation install directory (upstream bug?)
# Add CNC category to graphical menu drop-down
# Implement USE flags
# Check for PREEMPT_RT
# Maybe RTAI at some point

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

inherit desktop git-r3 python-single-r1 python-utils-r1 xdg-utils

PATCHES=(
	"${FILESDIR}/Makefile.patch"
)

DESCRIPTION="An open source CNC machine controller"
HOMEPAGE="https://www.linuxcnc.org/"
EGIT_REPO_URI="https://github.com/LinuxCNC/linuxcnc.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_impl_dep 'tk(+)')
	$(python_gen_cond_dep '
		>=dev-libs/boost-1.79[python,${PYTHON_USEDEP}]
		dev-python/pygobject[${PYTHON_USEDEP}]
		dev-python/pyopengl[${PYTHON_USEDEP}]
		dev-python/yapps2[${PYTHON_USEDEP}]
	')
	dev-lang/tcl
	dev-lang/tk
	dev-libs/glib
	dev-libs/libmodbus
	dev-tcltk/blt
	dev-tcltk/bwidget
	dev-tcltk/tclx
	sys-devel/gettext
	sys-libs/ncurses
	sys-libs/readline
	sys-process/procps
	sys-process/psmisc
	virtual/libudev
	virtual/libusb:1
	virtual/opengl
	x11-base/xorg-server
	x11-libs/libXinerama
	x11-libs/gtk+:2
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}
	app-text/asciidoc
"

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

	# Create environment required to start LinuxCNC
	local envd="${T}/99linuxcnc"
	cat > "${envd}" <<-EOF
		TCLLIBPATH="/usr/lib/tcltk/linuxcnc"
	EOF

	doenvd "${envd}"

	# Install menus and icons (don't know how to make CNC category in menu)
	doicon "${S_TOP}/debian/extras/usr/share/icons/hicolor/scalable/apps/${PN}-logo.svg"
	doicon "${S_TOP}/debian/extras/usr/share/icons/hicolor/scalable/apps/${PN}icon.svg"
	domenu "${S_TOP}/share/applications/${PN}-latency.desktop"
	domenu "${S_TOP}/share/applications/${PN}-latency-histogram.desktop"
	domenu "${S_TOP}/share/applications/${PN}-pncconf.desktop"
	domenu "${S_TOP}/share/applications/${PN}-stepconf.desktop"
	domenu "${S_TOP}/share/applications/${PN}.desktop"

	# Do not compress documentation, .ini files need to be readily accessible
	docompress -x "/usr/share/doc/${PN}/examples"

	# Force install of nc_files directory to fix broken symlink
	cp -aL "${S_TOP}/nc_files" "${D}/usr/share/doc/${PN}/examples/"
}

pkg_postinst() {
	ewarn "WARNING: Non-distributable build has been enabled!"
	ewarn ""
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
