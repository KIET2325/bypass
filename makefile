export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e

TWEAK_NAME = TimeMarkGPSShield
TimeMarkGPSShield_FILES = Tweak.xm
TimeMarkGPSShield_FRAMEWORKS = CoreLocation

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
