# SPDX-License-Identifier: GPL-2.0

PKG_NAME="android-tools"
PKG_VERSION="4.2.2+git20130218"
PKG_SHA256="9bfba987e1351b12aa983787b9ae4424ab752e9e646d8e93771538dc1e5d932f"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://launchpad.net/ubuntu/+source/android-tools"
PKG_URL="https://launchpad.net/ubuntu/+archive/primary/+files/android-tools_${PKG_VERSION}.orig.tar.xz"
PKG_SOURCE_DIR="android-tools"
PKG_DEPENDS_TARGET="toolchain pkg-config:host openssl zlib libxcrypt"
PKG_DEPENDS_UNPACK="android-tools-debian"
PKG_LONGDESC="adbd, the Android Debug Bridge daemon, from AOSP 4.2.2"
PKG_TOOLCHAIN="manual"

# Buildroot's android-tools package, adbd only; patches/ are buildroot's, and
# apply after Ubuntu's own series. adbd.mk links -lcrypt, which glibc no
# longer provides; hence libxcrypt.

post_unpack() {
  mkdir -p ${PKG_BUILD}/debian
  cp -a $(get_build_dir android-tools-debian)/* ${PKG_BUILD}/debian
}

pre_patch() {
  for p in $(cat ${PKG_BUILD}/debian/patches/series); do
    patch -d ${PKG_BUILD} -p1 < ${PKG_BUILD}/debian/patches/${p}
  done
}

make_target() {
  mkdir -p ${PKG_BUILD}/build-adbd
  make -C ${PKG_BUILD}/build-adbd -f ${PKG_BUILD}/debian/makefiles/adbd.mk SRCDIR=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/build-adbd/adbd ${INSTALL}/usr/bin
}
