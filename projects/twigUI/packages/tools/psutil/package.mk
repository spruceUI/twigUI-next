# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="psutil"
PKG_VERSION="release-7.2.2"
PKG_LICENSE="BSD 3-Clause"
PKG_SITE="https://github.com/giampaolo/psutil/"
PKG_URL="https://github.com/giampaolo/psutil/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="Cross-platform lib for process and system monitoring in Python."
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
