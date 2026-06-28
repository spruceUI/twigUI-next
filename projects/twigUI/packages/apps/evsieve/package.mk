# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="evsieve"
PKG_LICENSE="GPLv2"
PKG_VERSION="ebd7efe1ee902e70c5943b65a2bf44b9a3c31eb8"
PKG_SITE="https://github.com/KarsMulder/evsieve"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host libevdev cargo rust"
PKG_LONGDESC="A utility for mapping events from Linux event devices."
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
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/evsieve ${INSTALL}/usr/bin
}
