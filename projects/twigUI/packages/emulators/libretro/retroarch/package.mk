# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retroarch"
PKG_VERSION="1.22.2"
PKG_LICENSE="GPLv3"
PKG_LONGDESC="a pipedream"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

DOWNLOAD_URL="https://github.com/spruceUI/RA/releases/download/beta-main/ra64.pixel2"

make_target() {
  mkdir -p "${PKG_BUILD}"
  curl -LO --output-dir "${PKG_BUILD}" ${DOWNLOAD_URL}
}
