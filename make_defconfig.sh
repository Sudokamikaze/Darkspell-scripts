#!/bin/bash
ITSME=$(git config user.name)
eval $(grep DEVICE= ./config.buildscripts)

export ARCH=arm
export SUBARCH=arm
make sudokamikaze_"$DEVICE"_defconfig
make menuconfig
make savedefconfig && cp defconfig arch/arm/configs/sudokamikaze_"$DEVICE"_defconfig
rm defconfig

if [ $ITSME == Sudokamikaze ]; then
echo -n "Do you wan't to commit? [Y/N]: "
read douwant
case "$douwant" in
  y|Y)
echo -n "defconfig: "
read commitmsg
git add arch/arm/configs/sudokamikaze_"$DEVICE"_defconfig
git commit -S -m "defconfig: $commitmsg"
;;
  n|N) exit
;;
esac
fi
