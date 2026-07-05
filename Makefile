APP_NAME   = ohwell
BUNDLE_ID  = com.ohwell.app
BUILD_DIR  = .build/ui-test-app
APP_PATH   = $(BUILD_DIR)/$(APP_NAME).app

# ── Unit tests (fast, no .app needed) ─────────────────────────────────────────
.PHONY: test
test:
	swift test --filter ohwellTests

# ── Build .app bundle for UI tests ────────────────────────────────────────────
.PHONY: build-app
build-app:
	@echo "Building $(APP_NAME).app..."
	@mkdir -p $(APP_PATH)/Contents/MacOS
	@mkdir -p $(APP_PATH)/Contents/Resources
	swift build --configuration release 2>&1 | grep -v "^warning"
	@cp .build/release/$(APP_NAME) $(APP_PATH)/Contents/MacOS/$(APP_NAME)
	@cp Sources/ohwell/Info.plist $(APP_PATH)/Contents/Info.plist
	@# Ad-hoc sign so Accessibility APIs work
	@codesign --force --sign - $(APP_PATH)
	@echo "Built: $(APP_PATH)"

# ── Run UI tests ───────────────────────────────────────────────────────────────
# Open Package.swift in Xcode once to generate .xcodeproj-equivalent scheme,
# then run: make ui-test
# Or pass a specific test name: make ui-test T=testAddTaskAppearsInList
.PHONY: ui-test
ui-test: build-app
	@echo "Running UI tests..."
	xcodebuild test \
	  -scheme $(APP_NAME) \
	  -destination "platform=macOS" \
	  -only-testing:ohwellUITests$(if $(T),/OhWellUITests/$(T),) \
	  2>&1 | xcpretty || xcodebuild test \
	  -scheme $(APP_NAME) \
	  -destination "platform=macOS" \
	  -only-testing:ohwellUITests$(if $(T),/OhWellUITests/$(T),)

# ── Run all tests (unit + UI) ──────────────────────────────────────────────────
.PHONY: test-all
test-all: test ui-test

.PHONY: clean
clean:
	rm -rf .build/ui-test-app
	swift package clean
