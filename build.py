#!/bin/python

import configparser
import subprocess
import os
import patch

class BUILD:
    __parser = configparser.ConfigParser()
    __config_file = "config.buildscripts"
    __askpatch = ""
    __patched = ""
    __defconfig = ""
    __toolchain_path = ""

    def __init__(self):
        self.__parser.read(self.__config_file)
        self.__toolchain_path = self.__parser['BUILD']['TOOLCHAIN_PATH']
        self.__askpatch = self.__parser['DEVICE_PROPS']['PATCH']
        self.__defconfig = self.__parser['BUILD']['DEFCONFIG']
        self.build()

    def patcher(self):
        self.__patched = input('Apply LOS patches?[Y/N]: ')
        if self.__patched == "Y" or self.__patched == "y":
            subprocess.call(['patch', '-p1', '-i', './CM/0001-msm_fb-display-Add-support-to-YCBYCR-MDP-format'])
            subprocess.call(['patch', '-p1', '-i', './CM/0001-msm-rotator-Add-support-to-YCBYCR-rotator-format'])
            subprocess.call(['patch', '-p1', '-i', './CM/YUV_format-to-MDP_CM'])
        else: 
            print('Building without LOS patches...')


    def build(self):
        if self.__askpatch == "True":
            self.patcher()
        
        os.environ["ARCH"] = "arm"
        os.environ["SUBARCH"] = "arm"
        os.environ["KBUILD_BUILD_USER"] = "Sudokamikaze"
        os.environ["KBUILD_BUILD_HOST"] = "Youth"
        os.environ["CROSS_COMPILE"] = self.__toolchain_path
        subprocess.call(['make',self.__defconfig])
        try:
            make = subprocess.call(['make -j5'], shell=True)
        except KeyboardInterrupt:
            print('CTRL+C pressed, exiting...')
            os.sys.exit(1)

        if make != 0:
            print('Build was failed')
        else:
            print('OK!')

classcall = BUILD()