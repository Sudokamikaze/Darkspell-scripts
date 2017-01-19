#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep CONFIG_LOCALVERSION= ./arch/arm/configs/pulshen_"$DEVICE"_defconfig)
eval $(grep VER= ./config.buildscripts)
eval $(grep BRANCH= ./config.buildscripts)

rm -rf Darkspell-Flasher-*
git clone https://github.com/Sudokamikaze/Darkspell-Flasher-"$DEVICE".git -b "$BRANCH" && cd Darkspell-Flasher-"$DEVICE"

case "$DEVICE" in
  taoshan)
cp ../arch/arm/boot/zImage tools/
cp ../drivers/staging/prima/firmware_bin/WCNSS_qcom_cfg.ini system/etc/firmware/wlan/prima/
  ;;
  grouper)
cp ../boot.img ./
  ;;
esac

DATE=$(date +%d-%m-%Y)
zip Darkspell-Stable.zip -r META-INF presets system tools
mv Darkspell-Stable.zip signer/
echo Signing zip file
cd signer && java -jar signapk.jar testkey.x509.pem testkey.pk8 Darkspell-Stable.zip Darkspell-Stable-signed.zip
echo Done!
rm Darkspell-Stable.zip
mv Darkspell-Stable-signed.zip ../$DATE-$CONFIG_LOCALVERSION-$VER-$DEVICE.zip
cd ..
echo -n "Do you wan't to push zip to sdcard? [Y/N]: "
read push
case "$push" in
  y|Y) adb shell mkdir /storage/E53B-ACF6/Darkspell
  adb push $DATE-$CONFIG_LOCALVERSION-$VER-$DEVICE.zip /storage/E53B-ACF6/Darkspell/
  ;;
  n|N) echo You may grab your zip file in Darkspell-Flasher-$DEVICE directory
  ;;
esac
