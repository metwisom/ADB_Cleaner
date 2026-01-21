package adb

import (
	"bufio"
	"bytes"
	"fmt"
	"os/exec"
	"strings"
)

// Client represents an ADB client
type Client struct {
	adbPath string
}

// Device represents an Android device
type Device struct {
	ID             string
	Manufacturer   string
	Model          string
	AndroidVersion string
	UserID         string
}

// NewClient creates a new ADB client
func NewClient(adbPath string) *Client {
	if adbPath == "" {
		adbPath = "adb"
	}
	return &Client{adbPath: adbPath}
}

// IsAvailable checks if ADB is available
func (c *Client) IsAvailable() bool {
	cmd := exec.Command(c.adbPath, "version")
	err := cmd.Run()
	return err == nil
}

// GetDevice returns the connected device information
func (c *Client) GetDevice() (*Device, error) {
	// Check if device is connected
	cmd := exec.Command(c.adbPath, "devices")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to check devices: %w", err)
	}

	// Parse devices output
	scanner := bufio.NewScanner(bytes.NewReader(output))
	found := false
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.Contains(line, "device") && !strings.HasPrefix(line, "List") {
			found = true
			break
		}
	}

	if !found {
		return nil, fmt.Errorf("no device found or device not authorized")
	}

	// Get device info
	device := &Device{}

	// Get manufacturer
	manufacturer, err := c.runShellCommand("getprop", "ro.product.manufacturer")
	if err == nil {
		device.Manufacturer = strings.TrimSpace(manufacturer)
	}

	// Get model
	model, err := c.runShellCommand("getprop", "ro.product.model")
	if err == nil {
		device.Model = strings.TrimSpace(model)
	}

	// Get Android version
	version, err := c.runShellCommand("getprop", "ro.build.version.release")
	if err == nil {
		device.AndroidVersion = strings.TrimSpace(version)
	}

	// Get user ID (default to 0)
	device.UserID = "0"

	return device, nil
}

// ListPackages returns a list of installed packages
func (c *Client) ListPackages() ([]string, error) {
	cmd := exec.Command(c.adbPath, "shell", "pm", "list", "packages")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to list packages: %w", err)
	}

	var packages []string
	scanner := bufio.NewScanner(bytes.NewReader(output))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.HasPrefix(line, "package:") {
			pkg := strings.TrimPrefix(line, "package:")
			packages = append(packages, pkg)
		}
	}

	return packages, nil
}

// ListSystemPackages returns only system packages
func (c *Client) ListSystemPackages() ([]string, error) {
	cmd := exec.Command(c.adbPath, "shell", "pm", "list", "packages", "-s")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to list system packages: %w", err)
	}

	var packages []string
	scanner := bufio.NewScanner(bytes.NewReader(output))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.HasPrefix(line, "package:") {
			pkg := strings.TrimPrefix(line, "package:")
			packages = append(packages, pkg)
		}
	}

	return packages, nil
}

// ListThirdPartyPackages returns only third-party packages
func (c *Client) ListThirdPartyPackages() ([]string, error) {
	cmd := exec.Command(c.adbPath, "shell", "pm", "list", "packages", "-3")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to list third-party packages: %w", err)
	}

	var packages []string
	scanner := bufio.NewScanner(bytes.NewReader(output))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.HasPrefix(line, "package:") {
			pkg := strings.TrimPrefix(line, "package:")
			packages = append(packages, pkg)
		}
	}

	return packages, nil
}

// UninstallPackage removes a package for the current user
func (c *Client) UninstallPackage(pkg string, userID string) (bool, error) {
	cmd := exec.Command(c.adbPath, "shell", "pm", "uninstall", "--user", userID, pkg)
	output, err := cmd.CombinedOutput()
	if err != nil {
		outputStr := string(output)
		if strings.Contains(outputStr, "Success") {
			return true, nil
		}
		return false, fmt.Errorf("failed to uninstall %s: %w", pkg, err)
	}

	return true, nil
}

// IsPackageInstalled checks if a package is installed
func (c *Client) IsPackageInstalled(pkg string) (bool, error) {
	cmd := exec.Command(c.adbPath, "shell", "pm", "list", "packages", pkg)
	output, err := cmd.Output()
	if err != nil {
		return false, fmt.Errorf("failed to check package: %w", err)
	}

	return strings.Contains(string(output), "package:"+pkg), nil
}

// GetPackageInfo returns package information
func (c *Client) GetPackageInfo(pkg string) (map[string]string, error) {
	cmd := exec.Command(c.adbPath, "shell", "dumpsys", "package", pkg)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to get package info: %w", err)
	}

	info := make(map[string]string)
	scanner := bufio.NewScanner(bytes.NewReader(output))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.Contains(line, "versionName=") {
			parts := strings.Split(line, "versionName=")
			if len(parts) > 1 {
				info["versionName"] = strings.Split(parts[1], " ")[0]
			}
		}
		if strings.Contains(line, "versionCode=") {
			parts := strings.Split(line, "versionCode=")
			if len(parts) > 1 {
				info["versionCode"] = strings.Split(parts[1], " ")[0]
			}
		}
	}

	return info, nil
}

// runShellCommand executes a shell command on the device
func (c *Client) runShellCommand(args ...string) (string, error) {
	cmdArgs := append([]string{"shell"}, args...)
	cmd := exec.Command(c.adbPath, cmdArgs...)
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(output)), nil
}
