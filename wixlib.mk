#
# GNU make Makefile for build .wixlib
# 

TargetExt				:= .wixlib

include wixproj.mk

.PHONY: wixlib

wixlib: wixproj
