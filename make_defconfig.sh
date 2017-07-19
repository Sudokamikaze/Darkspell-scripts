#!/bin/bash
eval $(grep DEFCONFIG= ./config.buildscripts)

export ARCH=arm
export SUBARCH=arm
make $DEFCONFIG
make menuconfig
make savedefconfig && cp defconfig arch/arm/configs/$DEFCONFIG
rm defconfig
