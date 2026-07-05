PKG_NAME="picodrive-lr"
PKG_VERSION="f0d4a0118a9733a1f10bce5a4ac772c474f9300d"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/picodrive"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain core-info"
PKG_LONGDESC="Libretro implementation of PicoDrive. (Sega Megadrive/Genesis/Sega Master System/Sega GameGear/Sega CD/32X)"
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="-gold"
PKG_TOOLCHAIN="make"

PKG_PATCH_DIRS="${PROJECT}"

pre_configure_target() {
  export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
}

configure_target() {
  :
}

make_target() {
  cd ${PKG_BUILD}
  make -f Makefile.libretro
}

makeinstall_target() {
  cp "$(get_build_dir core-info)"/picodrive_libretro.info "${PKG_BUILD}"/
  ${STRIP} "${PKG_BUILD}"/picodrive_libretro.so
}
