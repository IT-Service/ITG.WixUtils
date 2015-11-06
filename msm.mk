#
# GNU make Makefile for build .wixlib
# 

TargetExt				:= .msm

include $(join $(dir $(lastword $(MAKEFILE_LIST))),wixproj.mk)

.PHONY: msm

msm: wixproj
