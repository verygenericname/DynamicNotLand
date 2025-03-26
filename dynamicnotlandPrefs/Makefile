TARGET := iphone:clang:16.5:16.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = dynamicnotlandPrefs

dynamicnotlandPrefs_FILES = DNPRootListController.m
dynamicnotlandPrefs_FRAMEWORKS = UIKit
dynamicnotlandPrefs_PRIVATE_FRAMEWORKS = Preferences
dynamicnotlandPrefs_INSTALL_PATH = /Library/PreferenceBundles
dynamicnotlandPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
