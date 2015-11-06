#
# GNU make Makefile for build .wixlib
# 

.PHONY: wixlib

TargetExt				:= .wixlib

include wixproj.mk

wixlib: $(TargetFullName)
