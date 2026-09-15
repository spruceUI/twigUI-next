# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rkmpp"
PKG_VERSION="c2c1ee502b3a26efebcf843f7a0aeb4d172c6237"
PKG_ARCH="arm aarch64"
PKG_LICENSE="APL"
PKG_SITE="https://github.com/rockchip-linux/mpp"
PKG_URL="https://github.com/rockchip-linux/mpp/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_LONGDESC="rkmpp: Rockchip Media Process Platform (MPP) module"

case ${DEVICE} in
  RK3326*|RK3566)
    PKG_ENABLE_VP9D="ON"
    ;;
esac

PKG_CMAKE_OPTS_TARGET="-DENABLE_VP9D=${PKG_ENABLE_VP9D} \
                       -DHAVE_DRM=ON \
                       -DBUILD_SHARED_LIBS=ON \
                       -DBUILD_TEST=OFF \
                       -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
