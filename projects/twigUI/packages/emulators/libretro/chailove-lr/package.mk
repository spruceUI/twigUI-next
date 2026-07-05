################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2020      351ELEC team (https://github.com/fewtarius/351ELEC)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="chailove-lr"
PKG_VERSION="9b0b6611a86cd8e48d50e9b894891c22b396b127"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/libretro-chailove"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain core-info"
PKG_LONGDESC="2D Game Framework with ChaiScript (libretro)"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

make_target() {
  make -C .. -f Makefile
}

makeinstall_target() {
  cp "$(get_build_dir core-info)"/chailove_libretro.info "${PKG_BUILD}"/
  ${STRIP} "${PKG_BUILD}"/chailove_libretro.so
}
