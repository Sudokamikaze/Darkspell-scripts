#!/bin/bash

eval $(grep CLEAN_TOOLCHAIN_PATH= ./config.buildscripts)

toolchain="$HOME/$CLEAN_TOOLCHAIN_PATH"

DIR=$(pwd)
KERNEL_DIR="$DIR"
make ARCH=arm CROSS_COMPILE="$toolchain/bin/arm-linux-gnueabihf-" -j5 clean mrproper
rm -rf $KERNEL_DIR/ramdisk.cpio
rm -rf $KERNEL_DIR/root.fs
rm -rf $KERNEL_DIR/boot.img
rm -rf Darkspell-Flasher-*
