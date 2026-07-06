# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ppsspp-spruce-sa"
PKG_VERSION="1.20.3"
PKG_LICENSE="GPLv2"
PKG_LONGDESC="PPSSPP standalone builds for SpruceOS"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

DOWNLOAD_URL="https://github.com/spruceUI/PPSSPP-spruce/releases/download/beta-main/PPSSPPSDL_Pixel2"

make_target() {
  mkdir -p "${PKG_BUILD}"
  curl -LO --output-dir "${PKG_BUILD}" ${DOWNLOAD_URL}
}
