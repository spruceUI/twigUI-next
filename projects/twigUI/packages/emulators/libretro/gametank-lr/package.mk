# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gametank-lr"
PKG_LICENSE="Zlib"
PKG_VERSION="fa073d4617fa6a7af14f2a8c7d4b7176d8393180"
PKG_SITE="https://github.com/dwbrite/gametank-sdk"
# PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo rust"
PKG_LONGDESC="rust rust rust rust rust rust rust gametank rust rust rust"
PKG_TOOLCHAIN="manual"

make_target() {
  wget https://github.com/christianhaitian/retroarch-cores/raw/refs/heads/master/aarch64/libgametank_libretro.so.zip
  unzip ${PKG_BUILD}/libgametank_libretro.so.zip
  wget https://raw.githubusercontent.com/dwbrite/gametank-sdk/refs/heads/master/emulator/libretro/gametank_libretro.info
}

# make_target() {
#   unset CMAKE

#   export CC=${TARGET_NAME}-gcc
#   export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${SYSROOT_PREFIX} --target=${TARGET_NAME}"

#   cd ${PKG_BUILD}/emulator/libretro/
#   cargo build \
#     --target ${TARGET_NAME} \
#     --release
# }

# makeinstall_target() {
#   LR_SO=${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/libgametank_libretro.so
#   ${STRIP} "${LR_SO}"

#   cp "${LR_SO}" "${PKG_BUILD}"/
#   cp ${PKG_BUILD}/tools/emulator/libretro/gametank_libretro.info "${PKG_BUILD}"/
# }
