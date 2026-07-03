################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#      Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
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

PKG_NAME="km-ludicrousn64-2k22-xtreme-amped-lr"
PKG_VERSION="529760a2a44c03e6a1a3f33fd4d62fd5e2cb27f6"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/KMFDManic/ludicrous-2k22-xtreme-amped"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host"
PKG_LONGDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"
PKG_PATCH_DIRS+=" ${DEVICE}"

if [ "${OPENGL}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
  PKG_MAKE_OPTS_TARGET+=" GLES=0 GL_LIB=\"-lGL\""
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" GLES=1 GL_LIB=\"-lGLESv2\""
fi

pre_configure_target() {
  export CFLAGS="${CFLAGS} -fcommon -Wno-error=incompatible-pointer-types -std=gnu17"

  case ${ARCH} in
    aarch64)
      PKG_MAKE_OPTS_TARGET+=" OS_LINUX=1 platform=${DEVICE}"
    ;;
  esac

  sed -i 's/\-O[23]/-Ofast/' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  ${STRIP} "${PKG_BUILD}"/km_ludicrousn64_2k22_xtreme_amped_libretro.so
  cp "${PKG_BUILD}"/info/km_ludicrousn64_2k22_xtreme_amped_libretro.info "${PKG_BUILD}"/
}
