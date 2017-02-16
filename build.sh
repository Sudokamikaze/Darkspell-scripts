#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep TOOLCHAIN_PATH= ./config.buildscripts)
eval $(grep VER= ./config.buildscripts)
eval $(grep ONLYZIMAGE= ./config.buildscripts)

function modules {
  local check=$(ls | grep modules_dir)

if [ "$check" != "modules_dir" ]; then
  cd $KERNEL_DIR && mkdir modules_dir
fi

  MODULES_DIR="$DIR/modules_dir"
  echo "Copying modules"
  cd $KERNEL_DIR
  rm $MODULES_DIR/*
  find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
  cd $MODULES_DIR
  echo "Stripping modules for size"
  $STRIP --strip-unneeded *.ko
  zip -9 modules *
  cd $KERNEL_DIR
}

DIR=$(pwd)

# Define here your toolchain path
toolchain="$HOME/$TOOLCHAIN_PATH"
export CROSS_COMPILE="$toolchain/bin/arm-eabi-"
STRIP="$toolchain/bin/arm-eabi-strip"
ZIMAGE="$DIR/arch/arm/boot/zImage"
KERNEL_DIR="$DIR"
MKBOOTIMG="$DIR/tools/mkbootimg"
MKBOOTFS="$DIR/tools/mkbootfs"
BUILD_START=$(date +"%s")

export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="Sudokamikaze"
export KBUILD_BUILD_HOST="QUVNTNM"
DATE=$(date +%Y-%m-%d:%H:%M:%S)
if [ -a $KERNEL_DIR/arch/arm/boot/zImage ];
then
rm $ZIMAGE
fi

make pulshen_"$DEVICE"_defconfig
make -j5

if [ -a $ZIMAGE ];
then

if [ "$VER" == "LP" ]; then
  modules
fi

if [ "$ONLYZIMAGE" == "false" ]; then
echo "Creating boot image"
$MKBOOTFS ramdisk/ > $KERNEL_DIR/ramdisk.cpio
cat $KERNEL_DIR/ramdisk.cpio | gzip > $KERNEL_DIR/root.fs

case "$DEVICE" in
  taoshan) $MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=qcom androidboot.selinux=permissive user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 maxcpus=2" --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x02000000 -o $KERNEL_DIR/boot.img
  ;;
  grouper) $MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs --cmdline "androidboot.selinux=permissive" --base 0x10000000 --pagesize 2048 -o $KERNEL_DIR/boot.img
  ;;
esac

fi
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
else
echo "Compilation failed! Fix the errors!"
fi
