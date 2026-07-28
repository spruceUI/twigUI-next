# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://rocknix.org)

PKG_NAME="libgpiod"
PKG_VERSION="43c1e96cf46f65c5c8d34eac9c51bbf1f57b878c"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git"
PKG_URL="https://github.com/brgl/libgpiod/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libgpiod: C library and tools for interacting with the linux GPIO character device"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET="-Dtools=enabled"