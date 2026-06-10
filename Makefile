BINARY_NAME = mac-notice
APP_NAME = mac-notice.app
BUILD_DIR = .build/debug
APP_DIR = $(BUILD_DIR)/$(APP_NAME)
INSTALL_DIR = /usr/local/bin
ICON_SRC = Resources/icon.png
ICON_ICNS = $(BUILD_DIR)/AppIcon.icns
ICONSET_DIR = $(BUILD_DIR)/AppIcon.iconset

.PHONY: build app icon install uninstall clean run help

build:
	swift build

icon: $(ICON_ICNS)

$(ICON_ICNS): $(ICON_SRC)
	@mkdir -p $(ICONSET_DIR)
	@for size in 16 32 128 256 512; do \
		sips -z $$size $$size $(ICON_SRC) --out $(ICONSET_DIR)/icon_$${size}x$${size}.png >/dev/null; \
		sips -z $$((size*2)) $$((size*2)) $(ICON_SRC) --out $(ICONSET_DIR)/icon_$${size}x$${size}@2x.png >/dev/null; \
	done
	@iconutil -c icns $(ICONSET_DIR) -o $(ICON_ICNS)
	@rm -rf $(ICONSET_DIR)
	@echo "アイコンを生成しました: $(ICON_ICNS)"

app: build $(ICON_ICNS)
	@mkdir -p $(APP_DIR)/Contents/MacOS $(APP_DIR)/Contents/Resources
	@cp $(BUILD_DIR)/$(BINARY_NAME) $(APP_DIR)/Contents/MacOS/$(BINARY_NAME)
	@cp Sources/mac-notice/Info.plist $(APP_DIR)/Contents/Info.plist
	@cp $(ICON_ICNS) $(APP_DIR)/Contents/Resources/AppIcon.icns
	@codesign --force -s - $(APP_DIR)
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
