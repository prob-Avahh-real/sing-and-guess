.PHONY: help generate build test clean open

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

generate: ## Generate Xcode project from project.yml
	xcodegen generate

open: ## Open in Xcode
	open *.xcodeproj

build: ## Build for simulator
	xcodebuild -project *.xcodeproj -scheme $$(xcodebuild -project *.xcodeproj -list 2>/dev/null | grep -A1 Schemes | tail -1 | xargs) -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

test: ## Run tests
	xcodebuild -project *.xcodeproj -scheme $$(xcodebuild -project *.xcodeproj -list 2>/dev/null | grep -A1 Schemes | tail -1 | xargs) -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test

clean: ## Clean build artifacts
	xcodebuild -project *.xcodeproj -scheme $$(xcodebuild -project *.xcodeproj -list 2>/dev/null | grep -A1 Schemes | tail -1 | xargs) clean
	rm -rf ~/Library/Developer/Xcode/DerivedData/*
