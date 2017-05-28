#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep CONFIG_LOCALVERSION= ./arch/arm/configs/sudokamikaze_"$DEVICE"_defconfig)
eval $(grep VER= ./config.buildscripts)
eval $(grep BRANCH= ./config.buildscripts)
eval $(grep FLASHER= ./config.buildscripts)
DATE=$(date +%d-%m-%Y)

function darkspell_flasher {
  git clone https://github.com/Sudokamikaze/Darkspell-Flasher-"$DEVICE".git -b "$BRANCH" && cd Darkspell-Flasher-*

  if [ "$VER" == "LP" ]; then
  cp ../modules_dir/*.ko system/lib/modules
  fi

  case "$DEVICE" in
    taoshan)
    cp ../arch/arm/boot/zImage tools/
    cp ../drivers/staging/prima/firmware_bin/WCNSS_qcom_cfg.ini system/etc/firmware/wlan/prima/
    ;;
    grouper)
    cp ../arch/arm/boot/zImage tools/
    ;;
esac
zip Darkspell.zip -r *

mv Darkspell-Stable.zip signer/
cd signer && java -jar signapk.jar testkey.x509.pem testkey.pk8 Darkspell.zip Darkspell-Stable-signed.zip
rm Darkspell.zip
mv Darkspell-Stable-signed.zip ../$VER$CONFIG_LOCALVERSION-$DEVICE-$DATE.zip
cd ..
echo "Done, grab your file in flasher directory"
}

function anykernel_flasher {
git clone git@github.com:Sudokamikaze/AnyKernel2_mako.git -b $BRANCH && cd AnyKernel2_mako
cp ../arch/arm/boot/zImage ./
zip Sinai.zip -r *
mv Sinai.zip $VER$CONFIG_LOCALVERSION-$DEVICE-$DATE.zip
echo "Done, grab your file in flasher directory"
}

case "$FLASHER" in
  anykernel) anykernel_flasher
  exit
  ;;
  darkspell) darkspell_flasher
  exit
  ;;
esac
