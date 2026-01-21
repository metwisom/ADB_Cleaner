package packages

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"time"
)

// Package represents a package to be removed
type Package struct {
	Name        string
	Description string
	Category    string
	RiskLevel   string // SAFE, RISKY, DANGER
	Installed   bool
	Selected    bool
}

// Manager manages packages
type Manager struct {
	packages []*Package
}

// NewManager creates a new package manager
func NewManager() *Manager {
	return &Manager{
		packages: make([]*Package, 0),
	}
}

// LoadPackages loads packages from a file
func (m *Manager) LoadPackages(filename string) ([]*Package, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open packages file: %w", err)
	}
	defer file.Close()

	var packages []*Package
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Parse package line
		// Format: package_name # Description | Category | RiskLevel
		pkg := &Package{
			Name:      line,
			Selected:  false,
			Installed: false,
		}

		// Check if line has metadata
		if strings.Contains(line, "#") {
			parts := strings.SplitN(line, "#", 2)
			pkg.Name = strings.TrimSpace(parts[0])
			metadata := strings.TrimSpace(parts[1])

			// Parse metadata
			if strings.Contains(metadata, "|") {
				metaParts := strings.Split(metadata, "|")
				if len(metaParts) >= 1 {
					pkg.Description = strings.TrimSpace(metaParts[0])
				}
				if len(metaParts) >= 2 {
					pkg.Category = strings.TrimSpace(metaParts[1])
				}
				if len(metaParts) >= 3 {
					pkg.RiskLevel = strings.TrimSpace(metaParts[2])
				}
			} else {
				pkg.Description = metadata
			}
		}

		packages = append(packages, pkg)
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading packages file: %w", err)
	}

	m.packages = packages
	return packages, nil
}

// UpdateInstalledStatus updates the installed status of packages
func (m *Manager) UpdateInstalledStatus(installedPackages []string) {
	installedMap := make(map[string]bool)
	for _, pkg := range installedPackages {
		installedMap[pkg] = true
	}

	for _, pkg := range m.packages {
		pkg.Installed = installedMap[pkg.Name]
	}
}

// GetPackages returns all packages
func (m *Manager) GetPackages() []*Package {
	return m.packages
}

// GetSelectedPackages returns selected packages
func (m *Manager) GetSelectedPackages() []*Package {
	var selected []*Package
	for _, pkg := range m.packages {
		if pkg.Selected {
			selected = append(selected, pkg)
		}
	}
	return selected
}

// SelectAll selects all packages
func (m *Manager) SelectAll() {
	for _, pkg := range m.packages {
		pkg.Selected = true
	}
}

// DeselectAll deselects all packages
func (m *Manager) DeselectAll() {
	for _, pkg := range m.packages {
		pkg.Selected = false
	}
}

// SelectByRiskLevel selects packages by risk level
func (m *Manager) SelectByRiskLevel(riskLevel string) {
	for _, pkg := range m.packages {
		if pkg.RiskLevel == riskLevel {
			pkg.Selected = true
		}
	}
}

// SelectByCategory selects packages by category
func (m *Manager) SelectByCategory(category string) {
	for _, pkg := range m.packages {
		if pkg.Category == category {
			pkg.Selected = true
		}
	}
}

// SelectInstalled selects only installed packages
func (m *Manager) SelectInstalled() {
	for _, pkg := range m.packages {
		if pkg.Installed {
			pkg.Selected = true
		}
	}
}

// ToggleSelection toggles the selection of a package
func (m *Manager) ToggleSelection(index int) {
	if index >= 0 && index < len(m.packages) {
		m.packages[index].Selected = !m.packages[index].Selected
	}
}

// GetTotalCount returns the total number of packages
func (m *Manager) GetTotalCount() int {
	return len(m.packages)
}

// GetSelectedCount returns the number of selected packages
func (m *Manager) GetSelectedCount() int {
	count := 0
	for _, pkg := range m.packages {
		if pkg.Selected {
			count++
		}
	}
	return count
}

// GetInstalledCount returns the number of installed packages
func (m *Manager) GetInstalledCount() int {
	count := 0
	for _, pkg := range m.packages {
		if pkg.Installed {
			count++
		}
	}
	return count
}

// SaveBackup saves a backup of selected packages
func (m *Manager) SaveBackup(backupDir string) error {
	if backupDir == "" {
		backupDir = "backups"
	}

	timestamp := time.Now().Format("20060102_150405")
	backupFile := fmt.Sprintf("%s/backup_%s.txt", backupDir, timestamp)

	file, err := os.Create(backupFile)
	if err != nil {
		return fmt.Errorf("failed to create backup file: %w", err)
	}
	defer file.Close()

	for _, pkg := range m.packages {
		if pkg.Selected {
			_, err := file.WriteString(fmt.Sprintf("%s|%s|%s|%s\n",
				pkg.Name, pkg.Description, pkg.Category, pkg.RiskLevel))
			if err != nil {
				return fmt.Errorf("failed to write backup: %w", err)
			}
		}
	}

	return nil
}

// LoadBackup loads packages from a backup file
func (m *Manager) LoadBackup(backupFile string) error {
	file, err := os.Open(backupFile)
	if err != nil {
		return fmt.Errorf("failed to open backup file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		parts := strings.Split(line, "|")
		if len(parts) < 1 {
			continue
		}

		name := parts[0]
		for _, pkg := range m.packages {
			if pkg.Name == name {
				pkg.Selected = true
				break
			}
		}
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("error reading backup file: %w", err)
	}

	return nil
}

// SearchPackages searches for packages by name or description
func (m *Manager) SearchPackages(query string) []*Package {
	query = strings.ToLower(query)
	var results []*Package

	for _, pkg := range m.packages {
		if strings.Contains(strings.ToLower(pkg.Name), query) ||
			strings.Contains(strings.ToLower(pkg.Description), query) {
			results = append(results, pkg)
		}
	}

	return results
}

// FilterByRiskLevel filters packages by risk level
func (m *Manager) FilterByRiskLevel(riskLevel string) []*Package {
	var results []*Package
	for _, pkg := range m.packages {
		if pkg.RiskLevel == riskLevel {
			results = append(results, pkg)
		}
	}
	return results
}

// FilterByCategory filters packages by category
func (m *Manager) FilterByCategory(category string) []*Package {
	var results []*Package
	for _, pkg := range m.packages {
		if pkg.Category == category {
			results = append(results, pkg)
		}
	}
	return results
}

// GetCategories returns all unique categories
func (m *Manager) GetCategories() []string {
	categories := make(map[string]bool)
	for _, pkg := range m.packages {
		if pkg.Category != "" {
			categories[pkg.Category] = true
		}
	}

	var result []string
	for cat := range categories {
		result = append(result, cat)
	}

	return result
}

// GetRiskLevels returns all unique risk levels
func (m *Manager) GetRiskLevels() []string {
	levels := make(map[string]bool)
	for _, pkg := range m.packages {
		if pkg.RiskLevel != "" {
			levels[pkg.RiskLevel] = true
		}
	}

	var result []string
	for level := range levels {
		result = append(result, level)
	}

	return result
}
