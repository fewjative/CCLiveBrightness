ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = CCLiveBrightness
CCLiveBrightness_FILES = Tweak.xm
CCLiveBrightness_FRAMEWORKS = UIKit
CCLiveBrightness_CFLAGS = -Wno-error
export GO_EASY_ON_ME := 1
include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += CCLiveBrightnessSettings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
