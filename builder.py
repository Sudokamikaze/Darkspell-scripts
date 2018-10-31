#!/bin/python

from os import path, environ
from sys import exit, argv, stderr
from configparser import ConfigParser
from argparse import ArgumentParser
from subprocess import call
from socket import gethostname
from shutil import rmtree

argparser = ArgumentParser()
confparser = ConfigParser()


class MAINW:
    __config_path="config.buildscripts"
    __askpatch = confparser['DEVICE_PROPS']['PATCH']
    __patched = ""
    __defconfig = confparser['BUILD']['DEFCONFIG']
    __toolchain_path = confparser['BUILD']['TOOLCHAIN_PATH']

    def __init__(self):
        argparser.add_argument("-B", "--build", help="Builds kernel", action="store_true")
        argparser.add_argument("-C", "--clean", help="Cleans work directory", action="store_true")
        environ["ARCH"] = "arm"
        environ["SUBARCH"] = "arm"
        environ["KBUILD_BUILD_USER"] = "Sudokamikaze"
        environ["KBUILD_BUILD_HOST"] = gethostname()
        environ["CROSS_COMPILE"] = self.__toolchain_path
        confparser.read(self.__config_path)
        if len(argv) == 1:
            argparser.print_help(stderr)
            exit(1)
        elif argparser.parse_args().build:
            self.build()
        elif argparser.parse_args().clean:
            self.clean()
             
    def patch(self):
        self.__patched = input('Apply LOS or BINDER patches?[L/B/N]: ')
        if self.__patched == "L" or self.__patched == "l":
            call(['patch', '-p1', '-i', './PATCHES/CM/0001-msm_fb-display-Add-support-to-YCBYCR-MDP-format'])
            call(['patch', '-p1', '-i', './PATCHES/CM/0001-msm-rotator-Add-support-to-YCBYCR-rotator-format'])
            call(['patch', '-p1', '-i', './PATCHES/CM/YUV_format-to-MDP_CM'])
            f = open('patched_los', "w+")
            f.close()
        elif self.__patched == "B" or self.__patched == "b":
            call(['patch', '-p1', '-i', './PATCHES/BINDER/support_for_8_byte_types'])
            call(['patch', '-p1', '-i', './PATCHES/BINDER/kconfig_change'])
            call(['patch', '-p1', '-i', './PATCHES/BINDER/correct_size_of_struct'])
            call(['patch', '-p1', '-i', './PATCHES/BINDER/fix_warnings'])
            call(['patch', '-p1', '-i', './PATCHES/BINDER/defconfig_binder'])
             
    def build(self):
        if self.__askpatch == "True":
            self.patcher()
        call(['make',self.__defconfig])
        try:
            make = call(['make -j5'], shell=True)
        except KeyboardInterrupt:
            print('CTRL+C pressed, exiting...')
            exit(1)

        if make != 0:
            print('Build was failed')
        else:
            print('OK!')

    def clean(self):
        call(['make -j5 clean mrproper'])
        rmtree('AnyKernel2-SINAI')
        if path.exists('patched_los') or path.exists('patched_ua'):
            call(['git reset --hard HEAD'])
