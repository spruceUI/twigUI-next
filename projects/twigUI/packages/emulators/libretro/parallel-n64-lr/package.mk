# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="parallel-n64-lr"
PKG_VERSION="a9bcd47628e918cf6707e53f897867b40c0aaf31"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/parallel-n64"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain core-info"
PKG_LONGDESC="Optimized/rewritten Nintendo 64 emulator made specifically for Libretro. Originally based on Mupen64 Plus."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MAKE_OPTS_TARGET+=" GLES=0 GL_LIB=\"-lGL\""
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MAKE_OPTS_TARGET+=" GLES=1 GL_LIB=\"-lGLESv2\""
fi

pre_configure_target() {
  if [ "${ARCH}" = "aarch64" ]; then
    # This is only needed for armv8.2-a targets where we don't use this flag
    # as it prohibits the use of LSE-instructions, this is a package bug most likely
    export CFLAGS="${CFLAGS} -mno-outline-atomics -std=gnu17 -Wno-error=implicit-function-declaration"
    export CXXFLAGS="${CXXFLAGS} -mno-outline-atomics"
    PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}"
  fi
}

makeinstall_target() {
  cp "$(get_build_dir core-info)"/parallel_n64_libretro.info "${PKG_BUILD}"/
  ${STRIP} "${PKG_BUILD}"/parallel_n64_libretro.so
}
