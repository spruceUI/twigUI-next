# SPDX-License-Identifier: GPL-3.0-or-later

PKG_NAME="pokedaisy-lr"
PKG_VERSION="a48ad733cd360a672e1a29d6c9e5e199101b4188"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/thwonp/pokedaisy-lr"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Game Boy, Game Boy Color and GBA player, with a live companion for Pokémon games and ROM hacks."
PKG_TOOLCHAIN='manual'

make_target() {
  cd ${PKG_BUILD}/
  cmake -S libretro -B build-arm64 -DCMAKE_BUILD_TYPE=Release
  cmake --build build-arm64 -j$(nproc)
}

makeinstall_target() {
  LR_SO="${PKG_BUILD}"/build-arm64/pokedaisy_libretro.so

  ${STRIP} "${LR_SO}"
  cp "${LR_SO}" "${PKG_BUILD}"/
}
