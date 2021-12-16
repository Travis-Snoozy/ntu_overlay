# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="AMD Optimizing C/C++ and Fortran Compilers (AOCC)"
HOMEPAGE="https://developer.amd.com/amd-aocc/"
SRC_URI="${P}.tar"

LICENSE="|| ( all-rights-reserved Apache-2.0-with-LLVM-exceptions )"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="bindist fetch mirror"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default

	# QA fixes (Removes libalm/libamdlibm and ORC compiler-rt-sanitizer due to TEXTRELs, etc)
	rm -f "${S}/lib/libalm."*
	rm -f "${S}/lib/libamdlibm."*
	rm -f "${S}/lib/clang/13.0.0/lib/linux/libclang_rt.orc-x86_64.a"
	rm -f "${S}/lib/libdevice/libbc-hostrpc-amdgcn.a"

	# Purge i386/IA-32 files
	find "${S}" -name "*ia32*" -type f -delete
	find "${S}" -name "*i386*" -type f -delete
}

src_install() {
	dodir "/opt/aocc-compiler"

	cp -aR "${S}/bin" "${D}/opt/aocc-compiler/"

	cp -aR "${S}/lib" "${D}/opt/aocc-compiler/"
	cp -aR "${S}/libexec" "${D}/opt/aocc-compiler/"

	cp -aR "${S}/ompd" "${D}/opt/aocc-compiler/"

	cp -aR "${S}/include" "${D}/opt/aocc-compiler/"

	cp -aR "${S}/share" "${D}/opt/aocc-compiler/"

	cp -aR "${S}/"*.TXT "${D}/opt/aocc-compiler/"
	cp -aR "${S}/"*.pdf "${D}/opt/aocc-compiler/"
}
