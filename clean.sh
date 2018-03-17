#!/bin/bash

eval $(grep TOOLCHAIN_PATH= ./config.buildscripts)
eval $(grep VER= ./config.buildscripts)

DIR=$(pwd)
KERNEL_DIR="$DIR"
make ARCH=arm CROSS_COMPILE="$TOOLCHAIN_PATH/bin/arm-eabi-" -j5 clean mrproper
rm -rf $KERNEL_DIR/ramdisk.cpio
rm -rf $KERNEL_DIR/root.fs
rm -rf $KERNEL_DIR/boot.img
rm -rf Darkspell-Flasher-*
rm -rf AnyKernel2*
if [ "$VER" == "LP" ]; then
rm -rf $KERNEL_DIR/modules_dir/*
fi
