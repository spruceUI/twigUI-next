PKG_NAME="freechaf-lr"
PKG_VERSION="76c7a84f1f7e80f3e6f2bba96fe100cb24e99124"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/FreeChaF"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="FreeChaF is a libretro emulation core for the Fairchild ChannelF / Video Entertainment System designed to be compatible with joypads from the SNES era forward."
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

make_target() {
  make
}

makeinstall_target() {
  ${STRIP} "${PKG_BUILD}"/freechaf_libretro.so
}
