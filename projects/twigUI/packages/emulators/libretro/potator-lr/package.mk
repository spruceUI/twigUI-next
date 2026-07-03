PKG_NAME="potator-lr"
PKG_VERSION="227c5f6f3ce74d32e9002ce24c1420288559a860"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/potator"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Watara Supervision Emulator based on Normmatt version."
PKG_TOOLCHAIN="make"


make_target() {
  make -C platform/libretro/ platform=aarch64
}

makeinstall_target() {
  LR_SO="${PKG_BUILD}"/platform/libretro/potator_libretro.so

  ${STRIP} "${LR_SO}"
  cp "${LR_SO}" "${PKG_BUILD}"/
}
