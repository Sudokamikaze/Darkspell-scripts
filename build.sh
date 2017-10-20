#!/bin/bash
eval $(grep DEVICE= ./config.buildscripts)
eval $(grep TOOLCHAIN_PATH= ./config.buildscripts)
eval $(grep ONLYZIMAGE= ./config.buildscripts)
eval $(grep DEFCONFIG= ./config.buildscripts)
eval $(grep PATCH= ./config.buildscripts)
eval $(grep MODULES= ./config.buildscripts)

export CROSS_COMPILE="$TOOLCHAIN_PATH/bin/arm-eabi-"
ZIMAGE="$(pwd)/arch/arm/boot/zImage"
KERNEL_DIR=$(pwd)
MKBOOTIMG="$(pwd)/tools/mkbootimg"
MKBOOTFS="$(pwd)/tools/mkbootfs"
BUILD_START=$(date +"%s")

function boot_creation {
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
}

function patching {
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
  fi
  ;;
esac
}

function build {

if [ "$PATCH" == "true" ]; then
patching
fi

export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="Sudokamikaze"
export KBUILD_BUILD_HOST="Youth"
DATE=$(date +%Y-%m-%d:%H:%M:%S)

if [ -f $KERNEL_DIR/arch/arm/boot/zImage ];
then
echo "Kernel already builded."; exit 1
fi

variant
make $DEFCONFIG
make -j5

if [ -a $ZIMAGE ];
then

if [ "$MODULES" == "true" ];
modules
fi

if [ "$ONLYZIMAGE" == "false" ]; then
boot_creation
fi

BUILD_END=$(date +"%s") && DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
else
echo "Compilation failed! Fix the errors!"
exit 1
fi
}

build
