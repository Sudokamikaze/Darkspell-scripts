#!/bin/python

import configparser
import subprocess
from git import Repo
import os
import shutil
import datetime

class ZIPC:
    __parser = configparser.ConfigParser()
    __config_file = "config.buildscripts"
    __device = ""
    __ua_patches = ""
    __branch = ""
    __branding = ""
    __patched = ""

    def __init__(self):
        self.__parser.read(self.__config_file)
        if self.__parser['DEVICE_PROPS']['DEVICE'] == "mako":
            self.__device = "mako"
            self.__branch = self.__parser['DEVICE_PROPS']['BRANCH']
        elif self.__parser['DEVICE_PROPS']['DEVICE'] == "grouper":
            self.__device = "grouper"
            self.__branch = self.__parser['DEVICE_PROPS']['BRANCH']
        self.__branding = self.__parser['DEVICE_PROPS']['KERNELNAME']
        self.prepare_to()

    def prepare_to(self):
        try:
            Repo.clone_from("https://github.com/Sudokamikaze/AnyKernel2-SINAI.git", "./AnyKernel2-SINAI")
        except:
            shutil.rmtree("AnyKernel2-SINAI")
            Repo.clone_from("https://github.com/Sudokamikaze/AnyKernel2-SINAI.git", "./AnyKernel2-SINAI")

        os.chdir("AnyKernel2")
        subprocess.call(["git checkout", self.__branch])
        self.__ua_patches = str(input('Unlegact patch? [Y/N]: '))
        self.pack_ramdisk()
    
    def pack_ramdisk(self):
        self.__patched = subprocess.run(['grep -c "case MDP_YCBYCR_H2V1:" ../drivers/video/msm/mdp4_overlay.c' ], stdout=subprocess.PIPE, universal_newlines=True)
        if self.__device == "mako":
            if self.__branding == "SINAI-N4":
                if self.__ua_patches == "Y" or "y":
                    self.__patched == 2
                    shutil.move("kernel_files/sinai/unlegacy/anykernel.sh", "./")
                else:
                    shutil.move("kernel_files/sinai/anykernel.sh", "./")
                shutil.move("kernel_files/sinai/init.sinai.rc", "ramdisk/")
            elif self.__branding == "QuantaR":
                shutil.move("kernel_files/quanta/anykernel.sh", "./")
                if self.__patched == 0:
                    shutil.move("kernel_files/quanta/init.quanta.rc" "ramdisk/")
                else:
                    shutil.move("kernel_files/quanta/init.quanta.rc_cm", "ramdisk/init.quanta.rc")
            shutil.move("kernel_files/fstab.mako", "ramdisk/")
            shutil.rmtree("kernel_files")
        elif self.__device == "grouper":
            # There's nothing to do
        self.create_zip()

        def create_zip(self):
            subprocess.call(['zip Kernel.zip', '-r *'])
            if self.__patched == 0:
                shutil.move("Kernel.zip", self.__branding + "_" + self.__device + "_" + datetime.date + ".zip")
            elif self.__patched == 2:
                shutil.move("Kernel.zip", self.__branding + "_" + self.__device + "-" + "UA_" + datetime.date + ".zip")        
            else:
                shutil.move("Kernel.zip", self.__branding + "_" + self.__device + "-" + "LOS_" + datetime.date + ".zip")        
classcall = ZIPC()