#!/bin/bash

eval $(grep DEVICE= ./config.buildscripts)
eval $(grep KERNELNAME= ./config.buildscripts)
eval $(grep MODULES= ./config.buildscripts)
eval $(grep BRANCH= ./config.buildscripts)
DATE=$(date +%d-%m-%Y)

function pack_ramdisk {
    if [ "$DEVICE" == "mako" ]; then
        echo -n "Unlegacy patch needed?[Y/N]: "
        read unlegacy
        case "$unlegacy" in
            y|Y) with_unlegacy=true ;;
        esac
        case "$KERNELNAME" in
            "SINAI-N4") 
                if [ "$with_unlegacy" == "true" ]; then
                    mv kernel_files/sinai/unlegacy/anykernel.sh ./
                else
                    mv kernel_files/sinai/anykernel.sh ./
                fi
                mv kernel_files/sinai/init.sinai.rc ramdisk/
                ;;
            "QuantaR")
                mv kernel_files/quanta/anykernel.sh ./
                case "$(grep -c "case MDP_YCBYCR_H2V1:" ../drivers/video/msm/mdp4_overlay.c)" in
                    0) mv kernel_files/quanta/init.quanta.rc ramdisk/ ;;
                    *) mv kernel_files/quanta/init.quanta.rc_cm ramdisk/init.quanta.rc ;;
                esac
                ;;
        esac
        mv kernel_files/fstab.mako ramdisk
        rm -rf kernel_files
        rm ramdisk/placeholder
        fi
        create_zip
}

function create_zip {
    zip Kernel.zip -r *
    if [ "$DEVICE" == "mako" ]; then
        case "$(grep -c "case MDP_YCBYCR_H2V1:" ../drivers/video/msm/mdp4_overlay.c)" in
            0) mv Kernel.zip "$KERNELNAME"_"$DEVICE"_"$DATE".zip
               ;;
            *) mv Kernel.zip "$KERNELNAME"_"LOS"-"$DEVICE"_"$DATE".zip
               ;;
        esac
    elif [ "$DEVICE" == "grouper" ]; then
        mv Kernel.zip "$KERNELNAME"_"$DEVICE"_"$DATE".zip
    fi
}

function anykernel_flasher {
git clone git@github.com:Sudokamikaze/AnyKernel2-SINAI.git -b $BRANCH && cd AnyKernel2-SINAI
cp ../arch/arm/boot/zImage ./
pack_ramdisk
echo "Done, grab your file in flasher directory"
}

anykernel_flasher

