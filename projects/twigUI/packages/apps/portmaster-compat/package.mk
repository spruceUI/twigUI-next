# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="portmaster-compat"
PKG_VERSION="2026.09.13-0343"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/PortsMaster/PortMaster-GUI"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/PortMaster.zip"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey gamecontrollerdb oga_controls control-gen xmlstarlet list-guid gst-plugins-base zip"
PKG_LONGDESC="Portmaster - a simple tool that allows you to download various game ports"
PKG_TOOLCHAIN="manual"

COMPAT_URL="https://github.com/ROCKNIX/packages/raw/main/compat.tar.gz" #f0f5e94

makeinstall_target() {
  export STRIP=true

  mkdir -p ${INSTALL}/usr/lib/compat
    curl -Lo ${PKG_BUILD}/compat.tar.gz ${COMPAT_URL}
    tar -xvf ${PKG_BUILD}/compat.tar.gz -C ${INSTALL}/usr/lib
    rm -rf ${INSTALL}/usr/lib/compat/libSDL2-2.0.so.0*
}
