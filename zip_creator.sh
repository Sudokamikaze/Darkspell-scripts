#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep CONFIG_LOCALVERSION= ./arch/arm/configs/pulshen_"$DEVICE"_defconfig)
eval $(grep VER= ./config.buildscripts)
eval $(grep BRANCH= ./config.buildscripts)
DATE=$(date +%d-%m-%Y)

rm -rf Darkspell-Flasher-*
git clone https://github.com/Sudokamikaze/Darkspell-Flasher-"$DEVICE".git -b "$BRANCH" && cd Darkspell-Flasher-"$DEVICE"

case "$DEVICE" in
  taoshan)
cp ../arch/arm/boot/zImage tools/
cp ../drivers/staging/prima/firmware_bin/WCNSS_qcom_cfg.ini system/etc/firmware/wlan/prima/
  ;;
  grouper)
  cp ../arch/arm/boot/zImage tools/
  ;;
esac

function zipcreate {
 case "$DEVICE" in
   taoshan)
   if [ "$VER" == "LP" ]; then
   cp ../modules_dir/*.ko system/lib/modules
 fi
   zip Darkspell-Stable.zip -r META-INF presets system tools
   ;;
   grouper)
   zip Darkspell-Stable.zip -r META-INF tools
   ;;
esac
}

function sign {
  mv Darkspell-Stable.zip signer/
  echo Signing zip file
  cd signer && java -jar signapk.jar testkey.x509.pem testkey.pk8 Darkspell-Stable.zip Darkspell-Stable-signed.zip
  rm Darkspell-Stable.zip
  mv Darkspell-Stable-signed.zip ../$DATE$CONFIG_LOCALVERSION-$VER-$DEVICE.zip
  cd ..
}

zipcreate
sign
echo "You may grab zip file from Darkspell-Flasher directory"
cd ..
