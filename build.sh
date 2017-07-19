#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep TOOLCHAIN_PATH= ./config.buildscripts)
eval $(grep VER= ./config.buildscripts)
eval $(grep ONLYZIMAGE= ./config.buildscripts)
eval $(grep DEFCONFIG= ./config.buildscripts)

function modules {
  STRIP="$TOOLCHAIN_PATH/bin/arm-eabi-strip"
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

function variant {
if [ "$DEVICE" == "mako" ]; then
echo "1. AOSP"
echo "2. LOS"
echo -n "Select build variant: "
read typ
case "$typ" in
  2)
  checkvar=$(grep -c "case MDP_YCBYCR_H2V1:" drivers/video/msm/mdp4_overlay.c)
  if [ "$checkvar" != 0 ]; then
  echo "Patches already included, compiling.."
  else
    patch -p1 -i ./CM/0001-msm_fb-display-Add-support-to-YCBYCR-MDP-format
    patch -p1 -i ./CM/0001-msm-rotator-Add-support-to-YCBYCR-rotator-format
    patch -p1 -i ./CM/YUV_format-to-MDP_CM
    export LOS=true
  fi
  ;;
esac
fi
}

DIR=$(pwd)

export CROSS_COMPILE="$TOOLCHAIN_PATH/bin/arm-eabi-"
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

variant
make $DEFCONFIG
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
  mako) $MKBOOTIMG --kernel $ZIMAGE --ramdisk $KERNEL_DIR/root.fs --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=mako lpj=67677 user_debug=31" --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x01600000 -o $KERNEL_DIR/boot.img
esac

fi
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
else
echo "Compilation failed! Fix the errors!"
fi

if [ "$typ" == "2" ]; then
  git reset --hard HEAD
fi
