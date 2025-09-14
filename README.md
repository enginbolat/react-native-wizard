# React Native Wizard 🚀

A comprehensive React Native project starter wizard that helps you create new React Native projects with ease. Supports both Expo and React Native Community CLI workflows.

## Features ✨

- **Dual Workflow Support**: Choose between Expo or React Native Community CLI
- **Smart Package Manager Detection**: Automatically detects and supports npm, yarn, and pnpm
- **Interactive CLI**: Beautiful command-line interface with colored output
- **Version Selection**: Choose specific React Native versions or use the latest stable
- **iOS Simulator Integration**: Automatically selects and launches iOS simulators
- **Development Tools**: Optional ESLint and Prettier setup
- **Build Testing**: Test iOS and Android builds after project creation

## Installation 📦

```bash
npm install -g @enginnblt/react-native-wizard
```

## Usage 🎯

After installation, you can run the wizard from anywhere:

```bash
rn-wizard
```

The wizard will guide you through:

1. **Project Type Selection**: Choose between Expo or React Native Community CLI
2. **Project Configuration**: Set project name, version, package manager, etc.
3. **Post-Setup Options**: Configure development tools or test builds

## Requirements 🔧

- Node.js 14.0.0 or higher
- For iOS development: Xcode and iOS Simulator
- For Android development: Android Studio and Android SDK
- Optional: `gum` or `fzf` for enhanced CLI experience

## Supported Package Managers 📦

- **npm** (default)
- **yarn**
- **pnpm**

## Supported React Native Versions 📌

- React Native 0.70.0 - 0.81.0
- Latest stable versions
- Automatic version validation

## Environment Variables 🌍

- `DEBUG=1`: Enable debug mode for verbose output

## Examples 💡

### Create an Expo project:
```bash
rn-wizard
# Select "Expo"
# Choose package manager
# Enter project name
# Select post-setup options
```

### Create a React Native CLI project:
```bash
rn-wizard
# Select "React Native Community CLI"
# Enter project name
# Choose React Native version
# Select package manager
# Configure additional options
```

## Troubleshooting 🔍

### Common Issues:

1. **Permission denied**: Make sure the script has execute permissions
   ```bash
   chmod +x start-cli.sh
   ```

2. **Package manager not found**: The wizard will attempt to install missing package managers automatically

3. **iOS Simulator issues**: Ensure Xcode and iOS Simulator are properly installed

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

MIT License - see LICENSE file for details.

## Author 👨‍💻

Created by [enginnblt](https://github.com/enginnblt)

---

**Note**: This tool is designed to streamline React Native project creation. It handles the complexity of project setup while giving you full control over the configuration.
