#!/bin/python

import configparser
import subprocess
from git import Repo
import os
import shutil
import datetime
now = datetime.datetime.now()

class ZIPC:
    __parser = configparser.ConfigParser()
    __config_file = "config.buildscripts"
    __device = ""
    __ua_patches = ""
    __branch = ""
    __branding = ""
    __patched = ""
    __currdate = ""

    def __init__(self):
        self.__currdate = "0" + str(now.day) + "-0" + str(now.month) + "-" + str(now.year)
        self.__parser.read(self.__config_file)
        if os.path.isfile('patched') == True:
            self.__patched = 3
        else:
            self.__patched = 0

        if self.__parser['DEVICE_PROPS']['DEVICE'] == "mako":
            self.__device = "mako"
            self.__branch = self.__parser['DEVICE_PROPS']['BRANCH']
        elif self.__parser['DEVICE_PROPS']['DEVICE'] == "grouper":
            self.__device = "grouper"
            self.__branch = self.__parser['DEVICE_PROPS']['BRANCH']
        self.__branding = self.__parser['DEVICE_PROPS']['KERNELNAME']
        self.prepare_to()

    def prepare_to(self):
        print('Clonning repo...')
        try:
            Repo.clone_from("https://github.com/Sudokamikaze/AnyKernel2-SINAI.git", "./AnyKernel2-SINAI")
        except:
            shutil.rmtree("AnyKernel2-SINAI")
            Repo.clone_from("https://github.com/Sudokamikaze/AnyKernel2-SINAI.git", "./AnyKernel2-SINAI")

        os.chdir("AnyKernel2-SINAI")
        subprocess.call(['git', 'checkout', self.__branch])
        self.pack_ramdisk()
    
    def pack_ramdisk(self):
        shutil.copy2("../arch/arm/boot/zImage", './')
        if self.__device == "mako":
            self.__ua_patches = str(input('Unlegacy patch? [Y/N]: '))
            os.remove('anykernel.sh')
            if self.__branding == "SINAI-N4":
                if self.__ua_patches == "Y" or "y":
                    self.__patched = 2
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
            print('ramdisk is ready')
        elif self.__device == "grouper":
            print('ramdisk is ready')
        self.create_zip()

    def create_zip(self):
        shutil.make_archive('../Kernel', 'zip', './')
        os.chdir('../')
        if self.__patched == 0:
            os.rename('Kernel.zip', self.__branding + "_" + self.__device + "_" + self.__currdate + ".zip")
        elif self.__patched == 2:
            os.rename('Kernel.zip', self.__branding + "_" + self.__device + "-UA_" + self.__currdate + ".zip")        
        elif self.__patched == 3:
            os.rename('Kernel.zip', self.__branding + "_" + self.__device + "-LOS_" + self.__currdate + ".zip")        
        print('Done!')

try:
    classcall = ZIPC()
except KeyboardInterrupt:
    print('Got keyboard interrupt, exiting...')
    os.sys.exit(0)