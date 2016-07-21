#
# GNU make Makefile for build GOST 2.304-81 MSI module (msm)
# 
# The build machine must have WiX 4.0 installed 
# 

OUTPUTDIR          := bin

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

ProjectName       ?= $(notdir $(CURDIR))
TargetName        ?= $(ProjectName)

WXIFILES          ?= $(wildcard *.wxi)

ProjectDir        ?= $(CURDIR)/
Configuration     ?= Release
Platform          ?= x86
Culture           ?= ru-ru
Cultures          ?= $(Culture)
SuppressICEs      ?= ICEM09
SuppressWarnings  ?= 1085 1086

#TargetExt        ?= .msi
TargetFileName    ?= $(TargetName)$(TargetExt)
TargetFullName    ?= $(OutputPath)$(TargetFileName)

ifndef WIXUTILSLIB

WixUtilsTargetName     := ITG.WixUtils
WixUtilsProjectDir     := ../$(WixUtilsTargetName)/
WixUtilsOutputPath     := $(WixUtilsProjectDir)$(OUTPUTDIR)/$(Configuration)
WixUtilsTargetFullName := $(WixUtilsOutputPath)/$(WixUtilsTargetName).wixlib
vpath %.wixlib $(WixUtilsOutputPath)
DEPENDENCIES           += $(WixUtilsTargetFullName)
STDLIBS                ?=

$(WixUtilsTargetFullName): ;
	$(MAKE) -C $(WixUtilsProjectDir)

clean::
	@$(MAKE) -C $(WixUtilsProjectDir) clean

else

all: wixlib

DEPENDENCIES           :=
STDLIBS                :=

endif

NUGET_PACKAGES_CONFIG  ?= $(WixUtilsProjectDir)packages.config
NUGET_PACKAGES_DIR     ?= $(WixUtilsProjectDir)packages
include $(ITG_MAKEUTILS_DIR)/nuget.mk

WXSFILES          ?= $(wildcard *.wxs)
WXLFILES          ?= $(wildcard *.wxl) $(foreach culture,$(Cultures),$(wildcard $(culture)/*.wxl))

ifdef MSBuildExtensionsPath32
	WixTargetsPath ?= $(MSBuildExtensionsPath32)\WiX Toolset\v4\Wix.targets
endif
ifdef MSBuildExtensionsPath
	WixTargetsPath ?= $(MSBuildExtensionsPath)\WiX Toolset\v4\Wix.targets
endif

OutputPath ?= $(OUTPUTDIR)/$(Configuration)/
OutputPathWithCulture ?= $(OUTPUTDIR)/$(Configuration)/$(Culture)/
IntermediateOutputPath ?= $(AUXDIR)/$(Configuration)/
IntermediateOutputPathWithCulture ?= $(AUXDIR)/$(Configuration)/$(Culture)/

WIXDIR            := $(NUGET_PACKAGES_DIR)/WiX/tools/
CANDLE            ?= $(WIXDIR)candle.exe
LIGHT             ?= $(WIXDIR)light.exe
LIT               ?= $(WIXDIR)lit.exe

ifdef WindowsSdkDir
  SIGNTOOL        ?= "$(WindowsSdkDir)bin\$(Platform)\signtool.exe"
  SIGN            := signtool \
    sign /a \
    /t http://timestamp.verisign.com/scripts/timstamp.dll
  SIGNTARGET      = $(SIGN) $@
else
  SIGNTARGET      :=
endif

vpath %.wixobj $(AUXDIR)/$(Configuration)

$(IntermediateOutputPath)%.wixobj: %.wxs $(WXIFILES) | $(CANDLE)
	$(CANDLE) \
		-nologo \
		-out $(IntermediateOutputPath) \
		-dConfiguration=$(Configuration) \
		-dOutDir=$(OutputPath) \
		-dPlatform=$(Platform) \
		-dProjectDir=$(ProjectDir) \
		-dProjectName=$(ProjectName) \
		-dTargetDir=$(ProjectDir)$(OutputPath) \
		-dTargetName=$(TargetName) \
		-dTargetExt=$(TargetExt) \
		-dTargetFileName=$(TargetFileName) \
		-dTargetPath=$(ProjectDir)$(OutputPath)$(TargetFileName) \
		-arch $(Platform) \
		$<

.LIBPATTERNS := %.wixlib
WIXOBJFILES  := $(patsubst %.wxs,$(IntermediateOutputPath)%.wixobj,$(WXSFILES))

vpath %.msi $(OUTPUTDIR)/$(Configuration)/$(Culture)
vpath %.msm $(OUTPUTDIR)/$(Configuration)/$(Culture)
vpath %.wixlib $(OUTPUTDIR)/$(Configuration)

%.msi %.msm: | $(LIGHT)
	$(LIGHT) \
		-nologo \
		-sice:$(SuppressICEs) \
		-out $@ \
		-cultures:$(Culture) \
		$(foreach locfile,$(filter %.wxl,$^),-loc $(locfile) ) \
		$(filter %.wixobj,$^) \
		$(filter %.wixlib,$^) \
		$(foreach wixext,$(WIXEXTENSIONS),-ext "$(WIXDIR)$(wixext).dll" )
	$(SIGNTARGET)

%.wixlib: | $(LIT)
	$(LIT) \
		-nologo \
		$(foreach warning,$(SuppressWarnings),-sw$(warning)) \
		-out $@ \
		$(foreach locfile,$(filter %.wxl,$^),-loc $(locfile) ) \
		$(filter %.wixobj,$^) \
		$(filter %.wixlib,$^)

$(TargetFullName): $(WIXOBJFILES) $(WXLFILES) $(foreach lib,$(WIXLIBS), -l$(lib)) $(DEPENDENCIES)

.PHONY: wixproj

wixproj: $(TargetFullName)
