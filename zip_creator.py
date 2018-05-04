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
        self.__currdate = str(now.day) + "-" + str(now.month) + "-" + str(now.year)
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
        print('Clonning repo...')
        try:
            Repo.clone_from("https://github.com/Sudokamikaze/AnyKernel2-SINAI.git", "./AnyKernel2-SINAI")
        except:
            shutil.rmtree("AnyKernel2-SINAI")
            Repo.clone_from("https://github.com/Sudokamikaze/AnyKernel2-SINAI.git", "./AnyKernel2-SINAI")

        os.chdir("AnyKernel2-SINAI")
        subprocess.call(['git', 'checkout', self.__branch])
        shutil.rmtree('.git')
        self.pack_ramdisk()
    
    def patcher(self, askua):
        if os.path.isfile('patched') == True:
            self.__patched = 3
        else:
            if askua == True:
                self.__ua_patches = str(input('Unlegacy patch? [Y/N]: '))
            if self.__ua_patches == "Y" or self.__ua_patches == "y":
                self.__patched = 2
            else:
                self.__patched = 0

    def pack_ramdisk(self):
        shutil.copy2("../arch/arm/boot/zImage", './')
        if self.__device == "mako":
            self.patcher(askua=True)
            if self.__patched == 2:
                shutil.move("anykernel.sh_un", "anykernel.sh")     
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