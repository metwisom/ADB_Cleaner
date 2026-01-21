.PHONY: help build clean test run install deps fmt lint vet all

# Configuration
APP_NAME=adb-cleaner
VERSION=2.0.0
BUILD_DIR=build
DIST_DIR=dist
CMD_DIR=cmd/adb-cleaner

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

deps: ## Download dependencies
	$(GOMOD) download
	$(GOMOD) tidy

clean: ## Clean build directory
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@echo "Done!"

build: deps ## Build for current platform
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME) ./$(CMD_DIR)
	@echo "Build complete: $(BUILD_DIR)/$(APP_NAME)"

build-linux: deps ## Build for Linux (amd64)
	@echo "Building for Linux/amd64..."
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	GOOS=linux GOARCH=amd64 $(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME)-linux-amd64 ./$(CMD_DIR)
	@cd $(BUILD_DIR) && tar -czf ../$(DIST_DIR)/$(APP_NAME)-linux-amd64.tar.gz $(APP_NAME)-linux-amd64 && cd ..
	@echo "Build complete: $(DIST_DIR)/$(APP_NAME)-linux-amd64.tar.gz"

build-linux-arm64: deps ## Build for Linux (arm64)
	@echo "Building for Linux/arm64..."
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	GOOS=linux GOARCH=arm64 $(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME)-linux-arm64 ./$(CMD_DIR)
	@cd $(BUILD_DIR) && tar -czf ../$(DIST_DIR)/$(APP_NAME)-linux-arm64.tar.gz $(APP_NAME)-linux-arm64 && cd ..
	@echo "Build complete: $(DIST_DIR)/$(APP_NAME)-linux-arm64.tar.gz"

build-macos: deps ## Build for macOS (amd64)
	@echo "Building for macOS/amd64..."
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME)-macos-amd64 ./$(CMD_DIR)
	@cd $(BUILD_DIR) && tar -czf ../$(DIST_DIR)/$(APP_NAME)-macos-amd64.tar.gz $(APP_NAME)-macos-amd64 && cd ..
	@echo "Build complete: $(DIST_DIR)/$(APP_NAME)-macos-amd64.tar.gz"

build-macos-arm64: deps ## Build for macOS (arm64)
	@echo "Building for macOS/arm64..."
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME)-macos-arm64 ./$(CMD_DIR)
	@cd $(BUILD_DIR) && tar -czf ../$(DIST_DIR)/$(APP_NAME)-macos-arm64.tar.gz $(APP_NAME)-macos-arm64 && cd ..
	@echo "Build complete: $(DIST_DIR)/$(APP_NAME)-macos-arm64.tar.gz"

build-windows: deps ## Build for Windows (amd64)
	@echo "Building for Windows/amd64..."
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	GOOS=windows GOARCH=amd64 $(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME)-windows-amd64.exe ./$(CMD_DIR)
	@cd $(BUILD_DIR) && zip ../$(DIST_DIR)/$(APP_NAME)-windows-amd64.zip $(APP_NAME)-windows-amd64.exe && cd ..
	@echo "Build complete: $(DIST_DIR)/$(APP_NAME)-windows-amd64.zip"

build-windows-arm64: deps ## Build for Windows (arm64)
	@echo "Building for Windows/arm64..."
	@mkdir -p $(BUILD_DIR) $(DIST_DIR)
	GOOS=windows GOARCH=arm64 $(GOBUILD) -ldflags "-s -w -X main.Version=$(VERSION)" -o $(BUILD_DIR)/$(APP_NAME)-windows-arm64.exe ./$(CMD_DIR)
	@cd $(BUILD_DIR) && zip ../$(DIST_DIR)/$(APP_NAME)-windows-arm64.zip $(APP_NAME)-windows-arm64.exe && cd ..
	@echo "Build complete: $(DIST_DIR)/$(APP_NAME)-windows-arm64.zip"

all: deps ## Build for all platforms
	@echo "Building for all platforms..."
	@$(MAKE) build-linux
	@$(MAKE) build-linux-arm64
	@$(MAKE) build-macos
	@$(MAKE) build-macos-arm64
	@$(MAKE) build-windows
	@$(MAKE) build-windows-arm64
	@echo "All builds complete!"

run: build ## Run the application
	@$(BUILD_DIR)/$(APP_NAME)

test: ## Run tests
	$(GOTEST) -v ./...

fmt: ## Format code
	$(GOCMD) fmt ./...

lint: ## Run linter
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed. Install with: curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$$(go env GOPATH)/bin"; \
	fi

vet: ## Run go vet
	$(GOCMD) vet ./...

install: build ## Install to GOPATH/bin
	@echo "Installing $(APP_NAME)..."
	$(GOCMD) install ./$(CMD_DIR)
	@echo "Installed!"

release: clean all ## Create release
	@echo "Creating release..."
	@echo "Release files in $(DIST_DIR):"
	@ls -lh $(DIST_DIR)
