# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="pyserial"
PKG_VERSION="v3.5"
PKG_LICENSE="BSD 3-Clause"
PKG_SITE="https://github.com/pyserial/pyserial"
PKG_URL="https://github.com/pyserial/pyserial/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="Python serial port access library."
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
  find ${INSTALL}/usr/lib/python*/site-packages/  -name "*.py" -exec rm -rf {} ";"
}
