PREFIX ?= /usr/local
ARCH := $(shell uname -m | sed 's/arm64/arm64/' | sed 's/x86_64/x86_64/')
BUILD_DIR := .build/$(ARCH)-apple-macosx/release
APP_DIR := $(PREFIX)/NgrokToolbar.app

.PHONY: build install clean

build:
	swift build -c release --disable-sandbox

install: build
	mkdir -p $(PREFIX)/bin
	cp $(BUILD_DIR)/NgrokTools $(PREFIX)/bin/ngrok-toolbar
	mkdir -p $(APP_DIR)/Contents/MacOS
	mkdir -p $(APP_DIR)/Contents/Resources
	cp $(BUILD_DIR)/NgrokTools $(APP_DIR)/Contents/MacOS/NgrokTools
	cp Info.plist $(APP_DIR)/Contents/Info.plist
	test -f AppIcon.icns && cp AppIcon.icns $(APP_DIR)/Contents/Resources/AppIcon.icns || true
	test -d $(BUILD_DIR)/NgrokTools_NgrokTools.bundle && cp -R $(BUILD_DIR)/NgrokTools_NgrokTools.bundle $(APP_DIR)/ || true

clean:
	swift package clean
	rm -rf .build
