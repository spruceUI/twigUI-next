# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL_image"
PKG_VERSION="SDL-1.2"
PKG_LICENSE="Zlib"
PKG_SITE="http://www.libsdl.org/"
PKG_URL="https://github.com/libsdl-org/SDL_image/archive/refs/heads/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain sdl12-compat zlib libpng tiff libjpeg-turbo"
PKG_LONGDESC="Image decoding for many popular formats for Simple Directmedia Layer."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--with-sdl-prefix=${SYSROOT_PREFIX}/usr \
						   --enable-shared \
						   --enable-static \
						   --disable-sdltest"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -ljpeg -lm -lz"
}

post_configure_target() {
  sed -i "s|-I/usr/include/SDL|-I${SYSROOT_PREFIX}/usr/include/SDL|" ${PKG_BUILD}/.${TARGET_NAME}/Makefile
}