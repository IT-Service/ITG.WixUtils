#
# GNU make Makefile for build ITGWixUtils
# 

.DEFAULT_GOAL			:= all

.PHONY: all

ProjectName				:= ITG.WixUtils
Cultures				:= ru-ru en-us
WIXLIBS					:=

include wixlib.mk

all: wixlib
