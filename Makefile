export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e

TWEAK_NAME = TimeMarkGPSShield
TimeMarkGPSShield_FILES = Tweak.xm
TimeMarkGPSShield_FRAMEWORKS = CoreLocation

# Thêm dòng này để báo cho Theos biết không cần tìm file .plist đóng gói
_THEOS_TARGET_PACKAGE_FORMAT = dylib

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
