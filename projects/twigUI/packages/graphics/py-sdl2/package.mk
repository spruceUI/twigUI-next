# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="py-sdl2"
PKG_VERSION="0.9.17"
PKG_LICENSE="Public Domain"
PKG_SITE="https://github.com/py-sdl/py-sdl2"
PKG_URL="https://github.com/py-sdl/py-sdl2/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 SDL2 SDL2_image SDL2_ttf SDL2_gfx"
PKG_LONGDESC="Python ctypes wrapper around SDL2."
PKG_TOOLCHAIN="python"

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib -L${SYSROOT_PREFIX}/lib"
  export LDSHARED="${CC} -shared"
}

make_target() {
  python3 setup.py build
}

makeinstall_target() {
  python3 setup.py install --root=${INSTALL} --prefix=/usr
}

post_makeinstall_target() {
  find ${INSTALL}/usr/lib/python*/site-packages/ -name "*.py" -exec rm -rf {} ";"
}
