# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="emulators"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_SECTION="virtual"
PKG_LONGDESC="Emulation metapackage."
PKG_TOOLCHAIN="manual"

PKG_EMUS="retroarch core-info portmaster dsperate-sa flycast-sa flycast2024-sa drastic-trngaje-sa ppsspp-sa yabasanshiro-sa"

LIBRETRO_CORES="a5200-lr ardens-lr atari800-lr bluemsx-lr cap32-lr chailove-lr chimerasnes-lr crocods-lr dosbox-pure-lr easyrpg-lr \
                ecwolf-lr fake08-lr fbalpha2012-lr fbneo-lr fceumm-lr flycast2021-lr fmsx-lr freechaf-lr freeintv-lr fuse-lr \
                gambatte-lr gametank-lr gearcoleco-lr gearsystem-lr genesis-plus-gx-lr gme-lr gpsp-lr gw-lr handy-lr hatari-lr \
                km-ludicrousn64-2k22-xtreme-amped-lr mame2003-plus-lr beetle-lynx-lr beetle-ngp-lr beetle-pce-fast-lr \
                beetle-supafaust-lr beetle-supergrafx-lr beetle-vb-lr beetle-wswan-lr mgba-lr mupen64plus-nx-lr neocd-lr nestopia-lr \
                np2kai-lr o2em-lr parallel-n64-lr pcsx_rearmed-lr picodrive-lr pokemini-lr potator-lr prboom-lr prosystem-lr \
                puae2021-lr px68k-lr quicknes-lr race-lr sameduck-lr snes9x-lr stella2014-lr swanstation-lr tgbdual-lr tic80-lr \
                tyrquake-lr uae4arm-lr vecx-lr vice-lr virtualjaguar-lr yabasanshiro-lr"

PKG_DEPENDS_TARGET="${PKG_EMUS} ${LIBRETRO_CORES}"