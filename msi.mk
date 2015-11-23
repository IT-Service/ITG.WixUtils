#
# GNU make Makefile for build .msi
# 

TargetExt				:= .msi

include $(join $(dir $(lastword $(MAKEFILE_LIST))),wixproj.mk)

.PHONY: msi

msi: wixproj
