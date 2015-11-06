#
# GNU make Makefile for build GOST 2.304-81 MSI module (msm)
# 
# The build machine must have WiX 4.0 installed 
# 

.PHONY: clean msm msi

.SECONDARY:;

.DELETE_ON_ERROR:;

ProjectName				?= $(notdir $(CURDIR))
TargetName				?= $(ProjectName)

WXIFILES				?=

WIXLIBS					?= ITG.WixUtils
vpath %.wixlib ../ITG.WixUtils/bin/Release

ProjectDir				?= $(CURDIR)/
OutputDir				?= bin/
IntermediateOutputDir	?= obj/
Configuration			?= Release
Platform				?= x86
Culture					?= ru-ru
SuppressICEs			?= ICEM09
SuppressWarnings		?= 1085 1086

#TargetExt				?= .msi
TargetFileName			?= $(TargetName)$(TargetExt)
TargetFullName			?= $(OutputPath)$(TargetFileName)

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
IntermediateOutputPath	?= $(IntermediateOutputDir)$(Configuration)/

MAKETARGETDIR			:= cd $(dir ${@D}) && mkdir $(notdir ${@D})
WIXDIR					?= %ProgramFiles(x86)%/WiX Toolset v4.0/bin/
CANDLE					?= "$(WIXDIR)candle.exe"
LIGHT					?= "$(WIXDIR)light.exe"
LIT						?= "$(WIXDIR)lit.exe"
PATHSEP					:=;

clean:
	rm -rf $(OutputDir)
	rm -rf $(IntermediateOutputDir)

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

vpath %.msi $(OutputDir)$(Configuration)
vpath %.msm $(OutputDir)$(Configuration)
vpath %.wixlib $(OutputDir)$(Configuration)

%.msi %.msm:;
	$(LIGHT) \
		-nologo \
		-sice:$(SuppressICEs) \
		-out $@ \
		-cultures:$(subst $(SPACE),;,$(Cultures)) \
		$(foreach locfile,$(filter %.wxl,$^),-loc $(locfile) ) \
		$(filter %.wixobj,$^) \
		$(filter %.wixlib,$^)

%.wixlib:;
	$(LIT) \
		-nologo \
		$(foreach warning,$(SuppressWarnings),-sw$(warning)) \
		-out $@ \
		$(foreach locfile,$(filter %.wxl,$^),-loc $(locfile) ) \
		$(filter %.wixobj,$^) \
		$(filter %.wixlib,$^)

$(TargetFullName): $(WIXOBJFILES) $(WXLFILES) $(foreach lib,$(WIXLIBS), -l$(lib))
