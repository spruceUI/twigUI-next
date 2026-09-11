# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="ppsspp-sa"
PKG_VERSION="1.20.2"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="${PKG_SITE}/releases/download/v${PKG_VERSION}/ppsspp-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libzip SDL2 zlib"
PKG_LONGDESC="A PSP emulator for Android, Windows, Mac, Linux and iOS, written in C++"

CHEAT_DB_VERSION="7c9fe1ae71155626cea767aed53f968de9f4051f"

PKG_CMAKE_OPTS_TARGET=" -DUSE_SYSTEM_FFMPEG=ON \
                        -DUSE_FFMPEG=YES \
                        -DCMAKE_BUILD_TYPE=Release \
                        -DCMAKE_SYSTEM_NAME=Linux \
                        -DUSE_SYSTEM_LIBPNG=OFF \
                        -DANDROID=OFF \
                        -DWIN32=OFF \
                        -DAPPLE=OFF \
                        -DCMAKE_CROSSCOMPILING=ON \
                        -DUSING_QT_UI=OFF \
                        -DUNITTEST=OFF \
                        -DSIMULATOR=OFF \
                        -DHEADLESS=OFF \
                        -DUSE_DISCORD=OFF"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd glew"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=OFF \
			   -DUSING_GLES2=OFF"

elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=ON \
                           -DUSING_EGL=OFF \
                           -DUSING_GLES2=ON"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_VULKAN_DISPLAY_KHR=ON \
                           -DVULKAN=ON \
                           -DUSING_X11_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DVULKAN=OFF \
                           -DUSE_VULKAN_DISPLAY_KHR=OFF \
                           -DUSING_X11_VULKAN=OFF"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=OFF"
fi

pre_configure_target() {
  sed -i 's/\-O[23]//g' ${PKG_BUILD}/CMakeLists.txt
  sed -i "s|include_directories(/usr/include/drm)|include_directories(${SYSROOT_PREFIX}/usr/include/drm)|" ${PKG_BUILD}/CMakeLists.txt

  export CPPFLAGS="${CPPFLAGS} -Wno-error -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1"
  export CXXFLAGS="${CXXFLAGS} -Wno-error -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1"
  export CFLAGS="${CFLAGS} -Wno-error -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1"
}

pre_make_target() {
  # fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  PPSSPP_BIN="${PKG_BUILD}"/.${TARGET_NAME}/PPSSPPSDL

  ${STRIP} ${PPSSPP_BIN}
  mv ${PPSSPP_BIN} "${PKG_BUILD}"/PPSSPPSDL_Pixel2

  rm -rf "${PKG_BUILD}"/assets/
  mv "${PKG_BUILD}"/.${TARGET_NAME}/assets/ "${PKG_BUILD}"/assets/

  curl -Lo "${PKG_BUILD}"/cheat.db https://raw.githubusercontent.com/Saramagrean/CWCheat-Database-Plus-/${CHEAT_DB_VERSION}/cheat.db
}
