# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mpv"
PKG_VERSION="41f6a645068483470267271e1d09966ca3b9f413" # 0.41.0
PKG_SHA256="068960e89211f2adc80af03f637fa393fb5e407d3dd23592c8fe8c5490bb7ae4"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/mpv-player/mpv"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ffmpeg-rockchip SDL2 luajit libass libplacebo"
PKG_LONGDESC="Video player based on MPlayer/mplayer2 https://mpv.io"

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MESON_OPTS_TARGET+=" -Dgl=disabled -Degl=enabled"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MESON_OPTS_TARGET+=" -Dgl=enabled -Degl=disabled"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_MESON_OPTS_TARGET+=" -Dwayland=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dwayland=disabled"
fi

PKG_MESON_OPTS_TARGET+=" -Dsdl2-gamepad=enabled"
