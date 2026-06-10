BINARY_NAME = mac-notice
APP_NAME = mac-notice.app
BUILD_DIR = .build/debug
APP_DIR = $(BUILD_DIR)/$(APP_NAME)
INSTALL_DIR = /usr/local/bin

.PHONY: build app install uninstall clean run help

build:
	swift build

app: build
	@mkdir -p $(APP_DIR)/Contents/MacOS
	@cp $(BUILD_DIR)/$(BINARY_NAME) $(APP_DIR)/Contents/MacOS/$(BINARY_NAME)
	@cp Sources/mac-notice/Info.plist $(APP_DIR)/Contents/Info.plist
	@echo "アプリバンドルを作成しました: $(APP_DIR)"

install: app
	@mkdir -p $(INSTALL_DIR)
	@cp -r $(APP_DIR) $(INSTALL_DIR)/$(APP_NAME)
	@ln -sf $(INSTALL_DIR)/$(APP_NAME)/Contents/MacOS/$(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "インストール完了: $(INSTALL_DIR)/$(BINARY_NAME)"

uninstall:
	@rm -rf $(INSTALL_DIR)/$(APP_NAME)
	@rm -f $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "アンインストール完了"

clean:
	swift package clean
	@rm -rf $(APP_DIR)

run: app
	@$(APP_DIR)/Contents/MacOS/$(BINARY_NAME) $(ARGS)

help:
	@$(APP_DIR)/Contents/MacOS/$(BINARY_NAME) --help
