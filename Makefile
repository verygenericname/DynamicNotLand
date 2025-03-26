TARGET := iphone:clang:16.5:14.5
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DynamicNotLand

DynamicNotLand_FILES = Tweak.xm
DynamicNotLand_CFLAGS = -fobjc-arc
DynamicNotLand_FRAMEWORKS = CydiaSubstrate SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += dynamicnotlandPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
