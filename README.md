# MandyClean

A native macOS system maintenance tool built with SwiftUI, following an Apple-inspired design system.

## Features

- **Dashboard** — Real-time gauges for RAM, CPU, and disk usage with system information overview
- **RAM Monitor** — Detailed memory breakdown (active, wired, compressed, inactive), process table sorted by memory usage, and Deep Clean (runs `purge` with admin privileges)
- **System Cleanup** — Scans user caches, logs, browser data, Trash, Xcode derived data, and old downloads. Deletes selected items after confirmation
- **App Uninstaller** — Lists installed apps, finds related Library files (Application Support, Caches, Preferences, Containers, etc.), and moves everything to Trash

## Requirements

- **macOS 14.0+** (Sonoma)
- **Xcode 15+**
- **Swift 5.9+**

## Project Setup

### Option 1: Create Xcode Project Manually

1. Open Xcode → File → New → Project → macOS → App
2. Product Name: `MandyClean`
3. Interface: **SwiftUI**, Language: **Swift**
4. Uncheck "Include Tests"
5. Delete the generated `ContentView.swift` and `MandyCleanApp.swift`
6. Drag all files from the `MandyClean/` source folder into the Xcode project navigator
7. In **Signing & Capabilities**:
   - Remove "App Sandbox" capability (or set to `false` in entitlements)
   - Under the entitlements file, point to `Resources/MandyClean.entitlements`
8. Set Deployment Target to **macOS 14.0**
9. Build & Run (⌘R)

### Option 2: Using xcodegen

If you have [xcodegen](https://github.com/yonaskolb/XcodeGen) installed:

```bash
brew install xcodegen
```

Create a `project.yml` in the project root (see below), then run:

```bash
xcodegen generate
open MandyClean.xcodeproj
```

<details>
<summary>project.yml</summary>

```yaml
name: MandyClean
options:
  bundleIdPrefix: com.mandyclean
  deploymentTarget:
    macOS: "14.0"
  xcodeVersion: "15.0"

targets:
  MandyClean:
    type: application
    platform: macOS
    sources:
      - MandyClean
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.mandyclean.app
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: 1
        INFOPLIST_FILE: MandyClean/Resources/Info.plist
        CODE_SIGN_ENTITLEMENTS: MandyClean/Resources/MandyClean.entitlements
        ENABLE_APP_SANDBOX: NO
```

</details>

## Architecture

```
MandyClean/
├── App/
│   └── MandyCleanApp.swift          # @main entry point
├── ContentView.swift                 # NavigationSplitView root
├── Theme/
│   └── AppTheme.swift                # Colors, typography, spacing from DESIGN.md
├── Models/
│   ├── RAMInfo.swift                 # Memory statistics struct
│   ├── SystemProcess.swift           # Process info struct
│   ├── CleanupItem.swift             # Cleanup category/file structs
│   └── InstalledApp.swift            # App + related files structs
├── Services/
│   ├── SystemMonitorService.swift    # RAM/CPU/Disk polling (Mach APIs)
│   ├── ProcessService.swift          # Process list via ps
│   ├── CleanupService.swift          # File scanning & deletion
│   └── AppUninstallerService.swift   # App detection & uninstall
├── ViewModels/
│   ├── RAMViewModel.swift            # Process management & deep clean
│   ├── CleanupViewModel.swift        # Scan/clean workflow
│   └── UninstallerViewModel.swift    # App list & uninstall workflow
├── Views/
│   ├── SidebarView.swift             # Navigation sidebar
│   ├── DashboardView.swift           # Overview gauges & system info
│   ├── RAMView.swift                 # Memory details & process table
│   ├── CleanupView.swift             # Cleanup scanner UI
│   └── UninstallerView.swift         # App uninstaller UI
├── Components/
│   ├── GlassCard.swift               # Glassmorphism card container
│   ├── CircularGauge.swift           # Animated circular progress
│   └── AnimatedButton.swift          # Apple-style CTA buttons
└── Resources/
    ├── MandyClean.entitlements       # Sandbox disabled
    └── Info.plist                    # App metadata
```

**Pattern: MVVM** — Views observe ViewModels via `@ObservedObject`; `SystemMonitorService` is shared via `@EnvironmentObject`.

## Permissions & Entitlements

This app runs **outside the App Sandbox** to access system data and perform cleanup operations:

| Feature | Requirement | How It Works |
|---------|-------------|--------------|
| RAM stats | `host_statistics64` (Mach API) | No special permissions needed |
| CPU stats | `host_statistics` (Mach API) | No special permissions needed |
| Process list | `/bin/ps` | Works without sandbox |
| User caches/logs | `~/Library/` access | Works without sandbox |
| Browser caches | `~/Library/Caches/` | Works without sandbox |
| Trash cleanup | `~/.Trash/` | Works without sandbox |
| Deep Clean RAM | `/usr/sbin/purge` | Prompts for admin password via AppleScript |
| System caches | `/Library/Caches/` | Requires admin or Full Disk Access |
| App uninstall | Move to Trash | Works for user-installed apps |

### For App Store Distribution

If you want to distribute via the App Store, you would need:
- Enable App Sandbox
- Use a **Privileged Helper Tool** (via `SMJobBless`) for operations requiring root
- Request appropriate entitlements for file access

### For Direct Distribution (Recommended)

1. Sign with Developer ID
2. Notarize with `notarytool`
3. Distribute as `.dmg` or `.zip`

## Design System

The UI follows [DESIGN.md](DESIGN.md) strictly:

- **Colors**: Apple Blue `#0071e3` accent, binary light/dark backgrounds
- **Typography**: SF Pro with optical sizing, negative tracking at all sizes
- **Glassmorphism**: `.ultraThinMaterial` with subtle borders and soft shadows
- **Spacing**: 8px base unit, dense micro-adjustments
- **Components**: Pill CTAs (980px radius), glass navigation, circular gauges

Both Light and Dark modes are fully supported through adaptive color functions.
