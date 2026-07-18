# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="iniparser"
PKG_VERSION="4bef811283e0ec1658c60e09950bd5a1ddc92e4b"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.com/iniparser/iniparser"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="iniParser is a simple C library offering ini file parsing services."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release"
