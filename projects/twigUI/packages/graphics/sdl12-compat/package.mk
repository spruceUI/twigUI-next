# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="sdl12-compat"
PKG_VERSION="04ba42c412991558a39a3bd7651b20f756c380c5"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/libsdl-org/sdl12-compat"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 glu"
PKG_LONGDESC="An SDL-1.2 compatibility layer that uses SDL 2.0 behind the scenes."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release -DSDL12DEVEL=ON -DSTATICDEVEL=ON"
