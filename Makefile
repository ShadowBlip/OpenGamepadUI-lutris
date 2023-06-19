PLUGIN_ID ?= $(shell grep 'plugin\.id' plugin.json | awk '{print $$2}' | grep -o '"[^"]\+"' | sed 's/"//g')
PLUGIN_NAME ?= $(shell grep 'plugin\.name' plugin.json | awk '{print $$2}' | grep -o '"[^"]\+"' | sed 's/"//g')

GODOT ?= /usr/bin/godot
OPENGAMEPAD_UI_REPO ?= https://github.com/ShadowBlip/OpenGamepadUI.git
OPENGAMEPAD_UI_BASE ?= ../OpenGamepadUI
EXPORT_PRESETS ?= $(OPENGAMEPAD_UI_BASE)/export_presets.cfg
PLUGINS_DIR := $(OPENGAMEPAD_UI_BASE)/plugins
BUILD_DIR := $(OPENGAMEPAD_UI_BASE)/build
INSTALL_DIR := $(HOME)/.local/share/opengamepadui/plugins

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: dist
dist: build ## Build and package plugin

.PHONY: build
build: $(PLUGINS_DIR)/$(PLUGIN_ID) export_preset ## Build the plugin
	@echo "Exporting plugin package"
	cd $(OPENGAMEPAD_UI_BASE) && $(MAKE) addons
	mkdir -p dist
	touch dist/.gdignore
	$(GODOT) --headless \
		--path $(OPENGAMEPAD_UI_BASE) \
		--export-pack "$(PLUGIN_NAME)" \
		plugins/$(PLUGIN_ID)/dist/$(PLUGIN_ID).zip
	cd dist && sha256sum $(PLUGIN_ID).zip > $(PLUGIN_ID).zip.sha256.txt

.PHONY: install
install: dist ## Installs the plugin
	cp -r dist/* "$(INSTALL_DIR)"
	rm -rf $(INSTALL_DIR)/$(PLUGIN_ID)
	@echo "Installed plugin to $(INSTALL_DIR)"

$(OPENGAMEPAD_UI_BASE):
	git clone $(OPENGAMEPAD_UI_REPO) $@

$(PLUGINS_DIR)/$(PLUGIN_ID): $(OPENGAMEPAD_UI_BASE)
	if ! [ -L $(PLUGINS_DIR)/$(PLUGIN_ID) ]; then ln -s $(PWD) $(PLUGINS_DIR)/$(PLUGIN_ID); fi

.PHONY: export_preset
export_preset: $(OPENGAMEPAD_UI_BASE) ## Configure plugin export preset
	$(eval LAST_PRESET=$(shell grep -oEi '^\[preset\.([0-9]+)]' $(EXPORT_PRESETS) | tail -n 1))
	$(eval LAST_PRESET_NUM=$(shell echo "$(LAST_PRESET)" | grep -oE '([0-9]+)'))
	$(eval PRESET_NUM=$(shell echo "$(LAST_PRESET_NUM)+1" | bc))
	@if grep 'name="$(PLUGIN_NAME)"' $(EXPORT_PRESETS) > /dev/null; then \
		echo "Export preset already configured"; \
	else \
		echo "Preset not configured"; \
		sed 's/PRESET_NUM/$(PRESET_NUM)/g; s/PLUGIN_NAME/$(PLUGIN_NAME)/g; s/PLUGIN_ID/$(PLUGIN_ID)/g' export_presets.cfg >> $(EXPORT_PRESETS); \
	fi
