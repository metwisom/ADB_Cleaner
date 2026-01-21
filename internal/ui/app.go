package ui

import (
	"fmt"
	"strings"
	"time"

	"github.com/adb-cleaner/adb-cleaner/internal/adb"
	"github.com/adb-cleaner/adb-cleaner/internal/packages"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/progress"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Styles
var (
	titleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FAFAFA")).
			Background(lipgloss.Color("#7D56F4")).
			Padding(0, 1)

	statusStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FAFAFA")).
			Background(lipgloss.Color("#F25D94")).
			Padding(0, 1)

	successStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#04B575"))
	errorStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("#F43F5E"))
	warningStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#F59E0B"))
	infoStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("#3B82F6"))

	selectedStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#7D56F4"))
	normalStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("#FAFAFA"))

	safeStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("#04B575"))
	riskyStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("#F59E0B"))
	dangerStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#F43F5E"))
)

// PackageItem represents a package in list
type PackageItem struct {
	pkg *packages.Package
}

func (p PackageItem) Title() string {
	return p.pkg.Name
}

func (p PackageItem) Description() string {
	desc := p.pkg.Description
	if desc == "" {
		desc = "No description"
	}

	risk := ""
	switch p.pkg.RiskLevel {
	case "SAFE":
		risk = "[SAFE]"
	case "RISKY":
		risk = "[RISKY]"
	case "DANGER":
		risk = "[DANGER]"
	}

	installed := ""
	if p.pkg.Installed {
		installed = " ✓"
	}

	return fmt.Sprintf("%s %s%s", risk, desc, installed)
}

func (p PackageItem) FilterValue() string {
	return p.pkg.Name + " " + p.pkg.Description
}

// Model represents application model
type Model struct {
	adbClient      *adb.Client
	packageManager *packages.Manager
	device         *adb.Device
	packages       []*packages.Package
	list           list.Model
	progress       progress.Model
	searchInput    textinput.Model
	logMessages    []string
	width          int
	height         int
	state          AppState
	selectedCount  int
	successCount   int
	failCount      int
	skipCount      int
	currentIndex   int
	dryRun         bool
}

// AppState represents current application state
type AppState int

const (
	StateList AppState = iota
	StateConfirm
	StateProgress
	StateDone
	StateSearch
)

// Messages
type tickMsg time.Time
type progressMsg struct {
	pkg    string
	status string
}
type doneMsg struct {
	success int
	failed  int
	skipped int
}

// NewApp creates a new application
func NewApp(adbClient *adb.Client, pkgManager *packages.Manager, pkgs []*packages.Package, device *adb.Device) *Model {
	// Create list items
	items := make([]list.Item, len(pkgs))
	for i, pkg := range pkgs {
		items[i] = PackageItem{pkg: pkg}
	}

	// Initialize list
	listModel := list.New(items, list.NewDefaultDelegate(), 0, 0)
	listModel.Title = "Packages to Remove"
	listModel.SetShowStatusBar(false)
	listModel.SetFilteringEnabled(false)

	// Initialize progress
	progressModel := progress.New(progress.WithDefaultGradient())

	// Initialize search input
	searchInput := textinput.New()
	searchInput.Placeholder = "Search packages..."
	searchInput.CharLimit = 50

	return &Model{
		adbClient:      adbClient,
		packageManager: pkgManager,
		device:         device,
		packages:       pkgs,
		list:           listModel,
		progress:       progressModel,
		searchInput:    searchInput,
		state:          StateList,
		logMessages:    make([]string, 0),
		dryRun:         false,
	}
}

// Init initializes model
func (m *Model) Init() tea.Cmd {
	return tea.Batch(
		tea.EnterAltScreen,
		m.tickCmd(),
	)
}

// Update updates model
func (m *Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmd tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyCtrlC:
			return m, tea.Quit

		case tea.KeyEnter:
			switch m.state {
			case StateList:
				m.state = StateConfirm
			case StateConfirm:
				m.state = StateProgress
				return m, m.startDebloat()
			case StateDone:
				return m, tea.Quit
			}

		case tea.KeyEsc:
			if m.state == StateSearch {
				m.state = StateList
			}

		case tea.KeyUp:
			if m.state == StateList {
				m.list.CursorUp()
			}

		case tea.KeyDown:
			if m.state == StateList {
				m.list.CursorDown()
			}

		case tea.KeySpace:
			if m.state == StateList {
				if idx := m.list.Index(); idx >= 0 && idx < len(m.packages) {
					m.packages[idx].Selected = !m.packages[idx].Selected
					m.updateSelectedCount()
					m.list.SetItem(idx, PackageItem{pkg: m.packages[idx]})
				}
			}

		case tea.KeyF1:
			if m.state == StateList {
				m.packageManager.SelectAll()
				m.updateList()
				m.updateSelectedCount()
			}

		case tea.KeyF2:
			if m.state == StateList {
				m.packageManager.DeselectAll()
				m.updateList()
				m.updateSelectedCount()
			}

		case tea.KeyF3:
			if m.state == StateList {
				m.packageManager.SelectInstalled()
				m.updateList()
				m.updateSelectedCount()
			}

		case tea.KeyF4:
			if m.state == StateList {
				m.packageManager.SelectByRiskLevel("SAFE")
				m.updateList()
				m.updateSelectedCount()
			}

		case tea.KeyF5:
			if m.state == StateList {
				m.state = StateSearch
				m.searchInput.Focus()
				return m, textinput.Blink
			}

		default:
			// Handle rune input for search
			if m.state == StateSearch {
				m.searchInput, cmd = m.searchInput.Update(msg)
				m.filterPackages()
			}
		}

	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.list.SetWidth(msg.Width - 4)
		m.list.SetHeight(msg.Height - 10)

	case tickMsg:
		return m, m.tickCmd()

	case progressMsg:
		m.addLog(fmt.Sprintf("[%s] %s", msg.status, msg.pkg))

	case doneMsg:
		m.successCount = msg.success
		m.failCount = msg.failed
		m.skipCount = msg.skipped
		m.state = StateDone
	}

	// Update components based on state
	switch m.state {
	case StateList:
		m.list, cmd = m.list.Update(msg)
	case StateSearch:
		m.searchInput, cmd = m.searchInput.Update(msg)
	}

	return m, cmd
}

// View renders model
func (m *Model) View() string {
	var content strings.Builder

	// Header
	content.WriteString(m.renderHeader())
	content.WriteString("\n")

	// Main content based on state
	switch m.state {
	case StateList:
		content.WriteString(m.renderList())
		content.WriteString("\n")
		content.WriteString(m.renderHelp())
	case StateConfirm:
		content.WriteString(m.renderConfirm())
	case StateProgress:
		content.WriteString(m.renderProgress())
	case StateDone:
		content.WriteString(m.renderDone())
	case StateSearch:
		content.WriteString(m.renderSearch())
	}

	return content.String()
}

func (m *Model) renderHeader() string {
	return fmt.Sprintf("%s %s %s %s",
		titleStyle.Render("ADB Cleaner v2.0"),
		infoStyle.Render(fmt.Sprintf("Device: %s %s", m.device.Manufacturer, m.device.Model)),
		infoStyle.Render(fmt.Sprintf("Android: %s", m.device.AndroidVersion)),
		statusStyle.Render(fmt.Sprintf("Selected: %d/%d", m.selectedCount, len(m.packages))),
	)
}

func (m *Model) renderList() string {
	return m.list.View()
}

func (m *Model) renderHelp() string {
	help := lipgloss.NewStyle().Foreground(lipgloss.Color("#6B7280")).Render(
		"↑/↓: Navigate | Space: Toggle | F1: Select All | F2: Deselect All | F3: Select Installed | F4: Select Safe | F5: Search | Enter: Confirm | Ctrl+C: Quit",
	)
	return help
}

func (m *Model) renderConfirm() string {
	var content strings.Builder

	content.WriteString("\n")
	content.WriteString(titleStyle.Render("Confirm Removal"))
	content.WriteString("\n\n")

	selected := m.packageManager.GetSelectedPackages()
	content.WriteString(fmt.Sprintf("You are about to remove %d packages.\n\n", len(selected)))

	if m.dryRun {
		content.WriteString(warningStyle.Render("DRY RUN MODE - No packages will be removed"))
		content.WriteString("\n\n")
	}

	content.WriteString("Press Tab to toggle dry run mode\n")
	content.WriteString("Press Enter to continue\n")
	content.WriteString("Press Esc to go back\n")

	return content.String()
}

func (m *Model) renderProgress() string {
	var content strings.Builder

	content.WriteString("\n")
	content.WriteString(titleStyle.Render("Removing Packages"))
	content.WriteString("\n\n")

	content.WriteString(m.progress.View())
	content.WriteString("\n\n")

	// Show last few log messages
	logCount := len(m.logMessages)
	start := logCount - 10
	if start < 0 {
		start = 0
	}

	for i := start; i < logCount; i++ {
		content.WriteString(m.logMessages[i])
		content.WriteString("\n")
	}

	return content.String()
}

func (m *Model) renderDone() string {
	var content strings.Builder

	content.WriteString("\n")
	content.WriteString(titleStyle.Render("Debloat Complete"))
	content.WriteString("\n\n")

	content.WriteString(successStyle.Render(fmt.Sprintf("✓ Successfully removed: %d", m.successCount)))
	content.WriteString("\n")
	content.WriteString(errorStyle.Render(fmt.Sprintf("✗ Failed: %d", m.failCount)))
	content.WriteString("\n")
	content.WriteString(warningStyle.Render(fmt.Sprintf("○ Skipped: %d", m.skipCount)))
	content.WriteString("\n\n")

	content.WriteString("Press Enter to exit\n")

	return content.String()
}

func (m *Model) renderSearch() string {
	var content strings.Builder

	content.WriteString("\n")
	content.WriteString(titleStyle.Render("Search Packages"))
	content.WriteString("\n\n")

	content.WriteString("Search: ")
	content.WriteString(m.searchInput.View())
	content.WriteString("\n\n")

	content.WriteString(m.list.View())
	content.WriteString("\n\n")

	content.WriteString("Press Esc to exit search mode")

	return content.String()
}

func (m *Model) tickCmd() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

func (m *Model) startDebloat() tea.Cmd {
	return func() tea.Msg {
		selected := m.packageManager.GetSelectedPackages()
		success := 0
		failed := 0
		skipped := 0

		for _, pkg := range selected {
			if m.dryRun {
				m.addLog(fmt.Sprintf("[DRY-RUN] %s", pkg.Name))
				success++
				continue
			}

			if !pkg.Installed {
				m.addLog(fmt.Sprintf("[SKIP] %s", pkg.Name))
				skipped++
				continue
			}

			installed, err := m.adbClient.IsPackageInstalled(pkg.Name)
			if err != nil || !installed {
				m.addLog(fmt.Sprintf("[SKIP] %s", pkg.Name))
				skipped++
				continue
			}

			ok, err := m.adbClient.UninstallPackage(pkg.Name, m.device.UserID)
			if err != nil || !ok {
				m.addLog(fmt.Sprintf("[FAIL] %s", pkg.Name))
				failed++
			} else {
				m.addLog(fmt.Sprintf("[SUCCESS] %s", pkg.Name))
				success++
			}
		}

		return doneMsg{success: success, failed: failed, skipped: skipped}
	}
}

func (m *Model) updateSelectedCount() {
	m.selectedCount = m.packageManager.GetSelectedCount()
}

func (m *Model) updateList() {
	items := make([]list.Item, len(m.packages))
	for i, pkg := range m.packages {
		items[i] = PackageItem{pkg: pkg}
	}
	m.list.SetItems(items)
}

func (m *Model) filterPackages() {
	query := m.searchInput.Value()
	if query == "" {
		m.updateList()
		return
	}

	filtered := m.packageManager.SearchPackages(query)
	items := make([]list.Item, len(filtered))
	for i, pkg := range filtered {
		items[i] = PackageItem{pkg: pkg}
	}
	m.list.SetItems(items)
}

func (m *Model) addLog(msg string) {
	m.logMessages = append(m.logMessages, msg)
}

// Run starts application
func (m *Model) Run() error {
	p := tea.NewProgram(m)
	_, err := p.Run()
	return err
}
