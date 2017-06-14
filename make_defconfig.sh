#!/bin/bash
ITSME=$(git config user.name)
eval $(grep DEVICE= ./config.buildscripts)
N=sudokamikaze

export ARCH=arm
export SUBARCH=arm
make "$N"_"$DEVICE"_defconfig
make menuconfig
make savedefconfig && cp defconfig arch/arm/configs/"$N"_"$DEVICE"_defconfig
rm defconfig

case "$ITSME" in
  Sudokamikaze | sudokamikaze)
echo -n "Do you wan't to commit? [Y/N]: "
read douwant
case "$douwant" in
  y|Y)
echo -n "defconfig: "
read commitmsg
git add arch/arm/configs/"$N"_"$DEVICE"_defconfig
git commit -S -m "defconfig: $commitmsg"
;;
  n|N) exit
;;
esac
;;
esac
