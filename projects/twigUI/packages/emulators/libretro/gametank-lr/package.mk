# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gametank-lr"
PKG_LICENSE="Zlib"
PKG_VERSION="75f9f6e883c5c5691e0976bdaf1074c3e488aa44"
PKG_SITE="https://github.com/dwbrite/gametank-sdk"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo rust"
PKG_LONGDESC="rust rust rust rust rust rust rust gametank rust rust rust"
PKG_TOOLCHAIN="manual"

make_target() {
  unset CMAKE

  export CC=${TARGET_NAME}-gcc
  export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${SYSROOT_PREFIX} --target=${TARGET_NAME}"

  cargo build \
    --target ${TARGET_NAME} \
    --release
}

makeinstall_target() {
  LR_SO=${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/libgametank_libretro.so
  ${STRIP} "${LR_SO}"

  cp "${LR_SO}" "${PKG_BUILD}"/  
  cp ${PKG_BUILD}/tools/gte/libretro/gametank_libretro.info "${PKG_BUILD}"/
}
