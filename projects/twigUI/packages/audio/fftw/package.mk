# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="fftw"
PKG_VERSION="3.3.11"
PKG_LICENSE="GPLv2"
PKG_SITE="https://www.fftw.org/"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="C subroutine library for computing the discrete Fourier transform (DFT) in one or more dimensions, of arbitrary input size, and of both real and complex data."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET+=" --enable-shared --enable-armv8-cntvct-el0"
