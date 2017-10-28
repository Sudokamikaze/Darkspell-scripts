#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep KERNELNAME= ./config.buildscripts)
eval $(grep FLASHER= ./config.buildscripts)
eval $(grep MODULES= ./config.buildscripts)
eval $(grep BRANCH= ./config.buildscripts)
DATE=$(date +%d-%m-%Y)

function darkspell_flasher {
  git clone https://github.com/Sudokamikaze/Darkspell-Flasher-"$DEVICE".git -b "$BRANCH" && cd Darkspell-Flasher-*

  if [ "$MODULES" == "true" ]; then
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
mv Darkspell-Stable-signed.zip ../"$KERNELNAME"-"$DEVICE"-"$DATE".zip
cd ..
echo "Done, grab your file in flasher directory"
}

function pack_ramdisk {
  case "$KERNELNAME" in
  "SINAI-N4") 
  mv kernel_files/sinai/anykernel.sh ./
  mv kernel_files/sinai/init.sinai.rc ramdisk/
  mv kernel_files/fstab.mako ramdisk
  ;;
  "QuantaR")
  mv kernel_files/quanta/anykernel.sh ./

  case "$(grep -c "case MDP_YCBYCR_H2V1:" ../drivers/video/msm/mdp4_overlay.c)" in
  0) mv kernel_files/quanta/init.quanta.rc ramdisk/ ;;
  *) mv kernel_files/quanta/init.quanta.rc_cm ramdisk/init.quanta.rc ;;
  esac

  mv kernel_files/fstab.mako ramdisk
  ;;
  esac
rm -rf kernel_files
rm ramdisk/placeholder
}

function anykernel_flasher {
git clone git@github.com:Sudokamikaze/AnyKernel2-SINAI.git -b $BRANCH && cd AnyKernel2-SINAI
cp ../arch/arm/boot/zImage ./
pack_ramdisk
zip Kernel.zip -r *
case "$(grep -c "case MDP_YCBYCR_H2V1:" ../drivers/video/msm/mdp4_overlay.c)" in
  0) mv Kernel.zip "$KERNELNAME"_"$DEVICE"_"$DATE".zip
  ;;
  *) mv Kernel.zip "$KERNELNAME"_"LOS"-"$DEVICE"_"$DATE".zip
  ;;
esac
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
