package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// Config represents the application configuration
type Config struct {
	ADBPath        string `json:"adbPath"`
	PackagesFile   string `json:"packagesFile"`
	LogDir         string `json:"logDir"`
	BackupDir      string `json:"backupDir"`
	UserID         string `json:"userId"`
	Theme          string `json:"theme"`
	AutoSelectSafe bool   `json:"autoSelectSafe"`
}

// DefaultConfig returns the default configuration
func DefaultConfig() *Config {
	return &Config{
		ADBPath:        "adb",
		PackagesFile:   "packs.txt",
		LogDir:         "logs",
		BackupDir:      "backups",
		UserID:         "0",
		Theme:          "default",
		AutoSelectSafe: false,
	}
}

// Load loads configuration from file or returns default
func Load() (*Config, error) {
	cfg := DefaultConfig()

	configFile := "config.json"
	if _, err := os.Stat(configFile); err == nil {
		data, err := os.ReadFile(configFile)
		if err != nil {
			return nil, fmt.Errorf("failed to read config file: %w", err)
		}

		if err := json.Unmarshal(data, cfg); err != nil {
			return nil, fmt.Errorf("failed to parse config file: %w", err)
		}
	}

	// Create directories
	if err := os.MkdirAll(cfg.LogDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create log directory: %w", err)
	}

	if err := os.MkdirAll(cfg.BackupDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create backup directory: %w", err)
	}

	return cfg, nil
}

// Save saves configuration to file
func (c *Config) Save() error {
	configFile := "config.json"

	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal config: %w", err)
	}

	if err := os.WriteFile(configFile, data, 0644); err != nil {
		return fmt.Errorf("failed to write config file: %w", err)
	}

	return nil
}

// GetPackagesFile returns the packages file path
func (c *Config) GetPackagesFile() string {
	if filepath.IsAbs(c.PackagesFile) {
		return c.PackagesFile
	}
	return c.PackagesFile
}

// GetLogDir returns the log directory path
func (c *Config) GetLogDir() string {
	if filepath.IsAbs(c.LogDir) {
		return c.LogDir
	}
	return c.LogDir
}

// GetBackupDir returns the backup directory path
func (c *Config) GetBackupDir() string {
	if filepath.IsAbs(c.BackupDir) {
		return c.BackupDir
	}
	return c.BackupDir
}
