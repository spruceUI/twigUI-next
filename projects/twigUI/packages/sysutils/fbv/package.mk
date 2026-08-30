# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="fbv"
PKG_VERSION="7c2000804226ca860ca80f3baa993582e29aa1a2"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/amadvance/fbv"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="libpng libjpeg-turbo"
PKG_LONGDESC="Simple program to view pictures on a Linux framebuffer device"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
  cd ${PKG_BUILD}
  ./autogen.sh
}
