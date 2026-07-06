# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="drastic-trngaje-sa"
PKG_LICENSE="Proprietary:DRASTIC.pdf"
PKG_VERSION="rocknix"
PKG_LONGDESC="This project was launched to overcome the limitations of screen output and input fixed as base with the drastic-steward 32-bit source developed for miyoomini by steward-fu."
PKG_URL="https://github.com/trngaje/advanced_drastic/releases/download/rocknix/advanced_drastic_rocknix_260120.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  cp "${PKG_BUILD}"/advanced_drastic/drastic "${PKG_BUILD}"/drastic64

  cp "${PKG_BUILD}"/advanced_drastic/libs/rk3326/libSDL2-2.0.so.0 "${PKG_BUILD}"/
  cp "${PKG_BUILD}"/advanced_drastic/libs/libadvdrastic.so "${PKG_BUILD}"/
}