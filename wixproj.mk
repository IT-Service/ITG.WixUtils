#
# GNU make Makefile for build GOST 2.304-81 MSI module (msm)
# 
# The build machine must have WiX 4.0 installed 
# 

.SECONDARY:;

.DELETE_ON_ERROR:;

ProjectName				?= $(notdir $(CURDIR))
TargetName				?= $(ProjectName)

WXIFILES				?=

ProjectDir				?= $(CURDIR)/
OutputDir				?= bin/
IntermediateOutputDir	?= obj/
Configuration			?= Release
Platform				?= x86
Culture					?= ru-ru
Cultures				?= $(Culture)
SuppressICEs			?= ICEM09
SuppressWarnings		?= 1085 1086

#TargetExt				?= .msi
TargetFileName			?= $(TargetName)$(TargetExt)
TargetFullName			?= $(OutputPath)$(TargetFileName)

ifndef WIXUTILSLIB

WixUtilsTargetName		:= ITG.WixUtils
WixUtilsProjectDir		:= ../$(WixUtilsTargetName)/
WixUtilsOutputPath		:= $(WixUtilsProjectDir)bin/$(Configuration)
WixUtilsTargetFullName	:= $(WixUtilsOutputPath)/$(WixUtilsTargetName).wixlib
vpath %.wixlib $(WixUtilsOutputPath)
DEPENDENCIES			+= $(WixUtilsTargetFullName)
STDLIBS					?=

$(WixUtilsTargetFullName): ;
	$(MAKE) -C $(WixUtilsProjectDir)

cleanwixutils: ;
	$(MAKE) -C $(WixUtilsProjectDir) clean

endif

WXSFILES				?= $(wildcard *.wxs)
WXLFILES				?= $(wildcard *.wxl) $(foreach culture,$(Cultures),$(wildcard $(culture)/*.wxl))

SPACE					:= $(empty) $(empty)

ifdef MSBuildExtensionsPath32
	WixTargetsPath		?= $(MSBuildExtensionsPath32)\WiX Toolset\v4\Wix.targets
endif
ifdef MSBuildExtensionsPath
	WixTargetsPath		?= $(MSBuildExtensionsPath)\WiX Toolset\v4\Wix.targets
endif

OutputPath				?= $(OutputDir)$(Configuration)/
OutputPathWithCulture	?= $(OutputDir)$(Configuration)/$(Culture)/
IntermediateOutputPath	?= $(IntermediateOutputDir)$(Configuration)/
IntermediateOutputPathWithCulture	?= $(IntermediateOutputDir)$(Configuration)/$(Culture)/

MAKETARGETDIR			:= cd $(dir ${@D}) && mkdir $(notdir ${@D})
WIXDIR					?= $(WIX)bin/
CANDLE					?= "$(WIXDIR)candle.exe"
LIGHT					?= "$(WIXDIR)light.exe"
LIT						?= "$(WIXDIR)lit.exe"
PATHSEP					:=;

.PHONY: clean cleanwixproj

cleanwixproj:
	rm -rf $(OutputDir)
	rm -rf $(IntermediateOutputDir)

ifdef WIXUTILSLIB
clean: cleanwixproj
else
clean: cleanwixproj cleanwixutils
endif

vpath %.wixobj $(IntermediateOutputDir)$(Configuration)

$(IntermediateOutputPath)%.wixobj: %.wxs $(WXIFILES);
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

.LIBPATTERNS			:= %.wixlib
WIXOBJFILES				:= $(patsubst %.wxs,$(IntermediateOutputPath)%.wixobj,$(WXSFILES))

vpath %.msi $(OutputDir)$(Configuration)\$(Culture)
vpath %.msm $(OutputDir)$(Configuration)\$(Culture)
vpath %.wixlib $(OutputDir)$(Configuration)

%.msi %.msm:;
	$(LIGHT) \
		-nologo \
		-sice:$(SuppressICEs) \
		-out $@ \
		-cultures:$(Culture) \
		$(foreach locfile,$(filter %.wxl,$^),-loc $(locfile) ) \
		$(filter %.wixobj,$^) \
		$(filter %.wixlib,$^) \
		$(foreach wixext,$(WIXEXTENSIONS),-ext "$(WIXDIR)$(wixext).dll" )

%.wixlib:;
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
