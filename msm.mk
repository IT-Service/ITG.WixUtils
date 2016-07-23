#
# GNU make Makefile for build .msm
# 

TargetExt				:= .msm

include $(join $(dir $(lastword $(MAKEFILE_LIST))),wixproj.mk)

.PHONY: msm
msm: $(TargetFullName)
