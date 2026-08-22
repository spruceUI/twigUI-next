# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="image"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/spruceUI/twigUI"

PKG_SECTION="virtual"
PKG_LONGDESC="Root package used to build and create a minimal image for twigUI"

PKG_DEPENDS_TARGET="toolchain squashfs-tools:host dosfstools:host fakeroot:host kmod:host \
                    mtools:host populatefs:host libc gcc linux linux-drivers linux-firmware \
                    ${BOOTLOADER} busybox lsof umtprd util-linux usb-modeswitch jq socat \
                    p7zip file initramfs grep util-linux btrfs-progs zstd lz4 empty lzo libzip \
                    bash coreutils autostart quirks gzip six pyudev rocknix twig"

PKG_UI_TOOLS="grim"

PKG_GRAPHICS="imagemagick SDL_image"

PKG_FONTS="corefonts"

PKG_MULTIMEDIA="ffmpeg-rockchip mpv"

PKG_SOUND="libao alsa pulseaudio pipewire wireplumber SDL2_mixer cava"

PKG_TOOLS="patchelf i2c-tools evtest rsync show_msg libgpiod"

PKG_DEBUG="debug"

PKG_GAMESUPPORT="rocknix-hotkey jstest-sdl gamecontrollerdb sdljoytest control-gen evsieve gptokeyb2"

PKG_NETWORK="iwd networkmanager netbase ethtool openssh iw wireless-regdb"

PKG_EXTRA="psutil pyserial Pillow py-sdl2 rumble sdl12-compat"

PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} ${PKG_FONTS} ${PKG_SOUND} ${PKG_GRAPHICS} ${PKG_MULTIMEDIA} misc-packages"
PKG_DEPENDS_TARGET+=" ${PKG_UI_TOOLS} ${PKG_DEBUG} ${PKG_GAMESUPPORT} ${PKG_NETWORK} ${PKG_EXTRA}"

# GL demos and tools
[[ ! -z "${OPENGL_SUPPORT}" ]] && PKG_DEPENDS_TARGET+=" mesa-demos"

# 32Bit package support
[ "${ENABLE_32BIT}" == true ] && PKG_DEPENDS_TARGET+=" lib32"

# EXFAT support
[ "${EXFAT}" = "yes" ] && PKG_DEPENDS_TARGET+=" exfatprogs"

# NTFS 3G support
[ "${NTFS3G}" = "yes" ] && PKG_DEPENDS_TARGET+=" ntfs-3g_ntfsprogs"

# Devtools... (not for Release)
[ "${TESTING}" = "yes" ] && PKG_DEPENDS_TARGET+=" testing"

# htop
[ "${HTOP_TOOL}" = "yes" ] && PKG_DEPENDS_TARGET+=" htop"

true
