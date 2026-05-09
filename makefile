# Makefile
APP_NAME = K8Switcher
BUILD_DIR = .build/release
BUNDLE_ID = com.local.k8switcher
LAUNCH_AGENT = ~/Library/LaunchAgents/$(BUNDLE_ID).plist
GUI_UID = $(shell id -u)

build:
	swift build -c release

bundle: build
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_NAME).app/Contents/MacOS/
	cp Info.plist $(APP_NAME).app/Contents/

clean:
	rm -rf $(APP_NAME).app
	swift package clean

run: bundle
	pkill $(APP_NAME) || true
	open $(APP_NAME).app

install: bundle
	pkill $(APP_NAME) || true
	cp -r $(APP_NAME).app /Applications/
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(LAUNCH_AGENT)
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(LAUNCH_AGENT)
	@echo '<plist version="1.0"><dict>' >> $(LAUNCH_AGENT)
	@echo '    <key>Label</key><string>$(BUNDLE_ID)</string>' >> $(LAUNCH_AGENT)
	@echo '    <key>ProgramArguments</key>' >> $(LAUNCH_AGENT)
	@echo '    <array><string>/Applications/$(APP_NAME).app/Contents/MacOS/$(APP_NAME)</string></array>' >> $(LAUNCH_AGENT)
	@echo '    <key>RunAtLoad</key><true/>' >> $(LAUNCH_AGENT)
	@echo '    <key>KeepAlive</key><true/>' >> $(LAUNCH_AGENT)
	@echo '</dict></plist>' >> $(LAUNCH_AGENT)
	launchctl bootout gui/$(GUI_UID)/$(BUNDLE_ID) || true
	launchctl bootstrap gui/$(GUI_UID) $(LAUNCH_AGENT)

uninstall:
	launchctl bootout gui/$(GUI_UID)/$(BUNDLE_ID) || true
	rm -rf /Applications/$(APP_NAME).app
	rm -f $(LAUNCH_AGENT)
	pkill $(APP_NAME) || true

.PHONY: build bundle clean run install uninstall
