# Contributing to ADB Cleaner (Go Edition)

Thank you for your interest in contributing to ADB Cleaner! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)

---

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

---

## 🚀 Getting Started

### Prerequisites

- Go 1.21 or higher
- Git
- ADB (for testing)
- Text editor or IDE (VS Code, GoLand, etc.)

### Setting Up Development Environment

1. **Fork and Clone:**
   ```bash
   # Fork the repository on GitHub
   git clone https://github.com/YOUR_USERNAME/adb-cleaner.git
   cd adb-cleaner
   ```

2. **Add Upstream Remote:**
   ```bash
   git remote add upstream https://github.com/adb-cleaner/adb-cleaner.git
   ```

3. **Install Dependencies:**
   ```bash
   go mod download
   ```

4. **Build the Project:**
   ```bash
   go build -o adb-cleaner ./cmd/adb-cleaner
   ```

5. **Run Tests:**
   ```bash
   go test ./...
   ```

---

## 🔄 Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Changes

- Write clean, readable code
- Follow Go best practices
- Add tests for new features
- Update documentation

### 3. Test Your Changes

```bash
# Run tests
go test ./...

# Build and run
go build -o adb-cleaner ./cmd/adb-cleaner
./adb-cleaner
```

### 4. Commit Changes

```bash
git add .
git commit -m "feat: add new feature"
```

**Commit Message Format:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(ui): add package search functionality

Implement search mode with F5 key.
Users can now filter packages by name or description.

Closes #123
```

```
fix(adb): handle device disconnection gracefully

Add proper error handling when device is disconnected
during debloating process.

Fixes #456
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## 📝 Coding Standards

### Go Guidelines

1. **Follow Effective Go:**
   - Use `gofmt` for formatting
   - Follow naming conventions
   - Keep functions small and focused

2. **Error Handling:**
   - Always handle errors
   - Use descriptive error messages
   - Wrap errors with context

   ```go
   // Good
   if err != nil {
       return fmt.Errorf("failed to load packages: %w", err)
   }

   // Bad
   if err != nil {
       return err
   }
   ```

3. **Comments:**
   - Exported functions must have comments
   - Explain "why" not "what"
   - Use godoc format

   ```go
   // LoadPackages loads packages from the specified file.
   // Returns a slice of Package pointers or an error if the file cannot be read.
   func (m *Manager) LoadPackages(filename string) ([]*Package, error) {
       // ...
   }
   ```

4. **Package Structure:**
   - `internal/` for private code
   - `pkg/` for public libraries
   - Keep packages focused

### TUI Guidelines

1. **User Experience:**
   - Provide clear feedback
   - Use consistent colors
   - Handle edge cases gracefully

2. **Performance:**
   - Avoid blocking the UI
   - Use goroutines for long operations
   - Update UI incrementally

3. **Accessibility:**
   - Support keyboard navigation
   - Provide clear labels
   - Use high contrast colors

---

## 🧪 Testing

### Writing Tests

```go
package packages

import (
    "testing"
)

func TestLoadPackages(t *testing.T) {
    manager := NewManager()
    
    pkgs, err := manager.LoadPackages("testdata/packages.txt")
    if err != nil {
        t.Fatalf("LoadPackages failed: %v", err)
    }
    
    if len(pkgs) == 0 {
        t.Error("Expected packages, got none")
    }
}
```

### Running Tests

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests with verbose output
go test -v ./...

# Run specific test
go test -run TestLoadPackages ./internal/packages
```

### Test Coverage

```bash
# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

---

## 📚 Documentation

### Code Documentation

- Document exported functions and types
- Provide usage examples
- Keep documentation up to date

### README Updates

When adding new features:
- Update the feature list
- Add usage examples
- Update configuration options

### API Documentation

For public APIs:
- Provide clear descriptions
- Include parameter details
- Show return values

---

## 📤 Submitting Changes

### Pull Request Checklist

Before submitting a PR:

- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] New features include tests
- [ ] Documentation is updated
- [ ] Commit messages follow convention
- [ ] PR description is clear

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How did you test your changes?

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
```

---

## 🐛 Reporting Bugs

When reporting bugs, include:

1. **Environment:**
   - OS and version
   - Go version
   - ADB version
   - Device model and Android version

2. **Steps to Reproduce:**
   - Clear steps to reproduce the issue
   - Expected behavior
   - Actual behavior

3. **Logs:**
   - Relevant log output
   - Error messages

---

## 💡 Feature Requests

When requesting features:

1. **Use Case:**
   - Describe the problem you're solving
   - Explain why this feature is needed

2. **Proposed Solution:**
   - Describe how you envision the feature
   - Include mockups or examples if applicable

3. **Alternatives:**
   - Describe any alternatives you've considered

---

## 📖 Resources

- [Effective Go](https://golang.org/doc/effective_go.html)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Bubble Tea Documentation](https://github.com/charmbracelet/bubbletea)
- [Go Project Layout](https://github.com/golang-standards/project-layout)

---

## ❓ Questions?

- Open a [discussion](https://github.com/adb-cleaner/adb-cleaner/discussions)
- Check existing [issues](https://github.com/adb-cleaner/adb-cleaner/issues)
- Read the [documentation](README_GO.md)

---

Thank you for contributing to ADB Cleaner! 🎉
