# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retroarch"
PKG_VERSION="e5eff6db27cd37c3c318741ee8bb9a3b8b60ec62"
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LICENSE="GPL-3.0-or-later"
PKG_DEPENDS_TARGET="toolchain SDL2 alsa-lib libass openssl freetype zlib core-info ffmpeg-rockchip openal-soft libogg libvorbisidec libvorbis libvpx libpng libdrm pulseaudio miniupnpc flac xz"
PKG_LONGDESC="Reference frontend for the libretro API."

if [ "${PIPEWIRE_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" pipewire"
fi

case ${ARCH} in
  arm)
    true
    ;;
  *)
    PKG_DEPENDS_TARGET+=" empty"
    ;;
esac

PKG_CONFIGURE_OPTS_TARGET="--disable-qt \
                           --enable-alsa \
                           --enable-udev \
                           --disable-discord \
                           --disable-opengl1 \
                           --disable-x11 \
                           --enable-zlib \
                           --enable-freetype \
                           --disable-vg \
                           --disable-sdl \
                           --enable-sdl2 \
                           --enable-kms \
                           --enable-ffmpeg"

case ${ARCH} in
  arm) PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon" ;;
  aarch64) PKG_CONFIGURE_OPTS_TARGET+=" --disable-neon" ;;
esac

case ${DEVICE} in
  RK*) PKG_DEPENDS_TARGET+=" librga" ;;
esac

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland"
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-wayland"
  case ${ARCH} in
    arm)
      true
      ;;
    *)
      PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
      ;;
  esac
else
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-wayland"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ] && [ "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  # --enable-opengles3 required for glcore, --enable-opengles3_1 doesn't auto-select it
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles --enable-opengles3 --enable-opengles3_1"
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengl"
else
  # Full OpenGL
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengl"
  PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengles --disable-opengles3 --disable-opengles3_1 --disable-opengles3_2"
fi

# if [ "${VULKAN_SUPPORT}" = "yes" ]; then
#   PKG_DEPENDS_TARGET+=" ${VULKAN}"
#   PKG_CONFIGURE_OPTS_TARGET+=" --enable-vulkan --enable-vulkan_display"
# else
#   PKG_CONFIGURE_OPTS_TARGET+=" --disable-vulkan"
# fi

pre_configure_target() {
  CFLAGS+=" -DHAVE_FILTERS_BUILTIN"
  TARGET_CONFIGURE_OPTS=""
  cd ${PKG_BUILD}
}

make_target() {
  make HAVE_STATIC_VIDEO_FILTERS=1 HAVE_STATIC_AUDIO_FILTERS=1
  [ $? -eq 0 ] && echo "(retroarch ok)" || { echo "(retroarch failed)" ; exit 1 ; }
}

makeinstall_target() {
  ${STRIP} ${PKG_BUILD}/retroarch
  mv ${PKG_BUILD}/retroarch ${PKG_BUILD}/ra64.pixel2
}
