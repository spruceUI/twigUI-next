# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="dsperate-sa"
PKG_VERSION="v1.9.0"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/beebono/DSperate/"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libzip zip wayland"
PKG_LONGDESC="An attempt at reimplementing DraStic-level performance with modern features"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_INSTALL_PREFIX=/usr \
			-DCMAKE_SYSROOT=${SYSROOT_PREFIX} \
			-DCMAKE_TOOLCHAIN_FILE=${CMAKE_CONF} \
			-DCMAKE_BUILD_TYPE=Release \
			-DDSPERATE_JIT=ON \
			-DDSPERATE_NEON=ON \
			-DDSPERATE_HEADLESS=OFF \
			-DDSPERATE_SDL=ON \
			-DDSPERATE_WAYLAND=ON \
			-DDSPERATE_TESTS=OFF"

makeinstall_target() {
  cp "${PKG_BUILD}"/.${TARGET_NAME}/src/frontend/sdl/dsperate "${PKG_BUILD}"/
  ${STRIP} "${PKG_BUILD}"/dsperate
}