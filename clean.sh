#!/bin/bash

eval $(grep TOOLCHAIN_PATH= ./config.buildscripts)
eval $(grep VER= ./config.buildscripts)

DIR=$(pwd)
KERNEL_DIR="$DIR"
make ARCH=arm CROSS_COMPILE="$TOOLCHAIN_PATH" -j5 clean mrproper
rm -rf $KERNEL_DIR/ramdisk.cpio
rm -rf $KERNEL_DIR/root.fs
rm -rf $KERNEL_DIR/boot.img
rm -rf Darkspell-Flasher-*
rm -rf AnyKernel2*
if [ -f "./patched_los" ]; then
rm patched
git reset --hard HEAD
elif [ -f "./patched_ua" ]; then
rm patched
git reset --hard HEAD
fi
