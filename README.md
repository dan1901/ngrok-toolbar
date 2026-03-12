# ngrok Toolbar

A macOS menu bar app for managing ngrok tunnels, sessions, endpoints, and domains — without opening the browser dashboard.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Tunnel Management** — View active tunnels, create new ones, stop running tunnels
- **Live Traffic Inspector** — Real-time HTTP request/response logs per tunnel (like `ngrok inspect`)
- **Session Control** — View agent sessions, restart or stop them
- **Endpoint & Domain Viewer** — Browse endpoints and reserved domains
- **Tunnel History** — Quick re-launch previously used tunnel configurations
- **Detachable Window** — Pop out from menu bar into a resizable standalone window
- **Auto Polling** — Configurable refresh interval (10–60s) with change detection
- **Notifications** — Desktop alerts for tunnel connect/disconnect events
- **Secure Storage** — API key stored in macOS Keychain
- **Auto-detect Config** — Reads ngrok API key from `~/.config/ngrok/ngrok.yml` automatically

## Install

### Homebrew

```bash
brew tap dan1901/tap
brew install ngrok-toolbar
```

### Manual Build

```bash
git clone https://github.com/dan1901/ngrok-toolbar.git
cd ngrok-toolbar/NgrokTools
swift build -c release

# Create app bundle
mkdir -p ../build/NgrokToolbar.app/Contents/MacOS
cp .build/release/NgrokTools ../build/NgrokToolbar.app/Contents/MacOS/
cp Info.plist ../build/NgrokToolbar.app/Contents/
codesign -s - -f ../build/NgrokToolbar.app

open ../build/NgrokToolbar.app
```

## Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **ngrok CLI** installed (`brew install ngrok`)
- **ngrok API Key** (not authtoken) — get one at [dashboard.ngrok.com/api-keys](https://dashboard.ngrok.com/api-keys)

> **Note:** `authtoken` (used for `ngrok config add-authtoken`) is different from an API Key. This app requires an **API Key** to access the ngrok REST API.

## Usage

1. Launch the app — it appears as a network icon in the menu bar
2. On first launch, enter your ngrok API Key in Settings
3. Browse tunnels, sessions, endpoints, and domains via tabs
4. Click a tunnel card to view live HTTP traffic
5. Use "New Tunnel" to start a tunnel directly from the app
6. Click the window icon to detach into a standalone window

### Keyboard Shortcuts

| Action | Description |
|--------|-------------|
| Click menu bar icon | Toggle popover |
| Detach button | Pop out to window / return to menu bar |

## Configuration

The app looks for your ngrok API key in these locations (in order):

1. macOS Keychain (saved via Settings)
2. `~/.config/ngrok/ngrok.yml` → `api_key` field
3. `~/Library/Application Support/ngrok/ngrok.yml`
4. `~/.ngrok2/ngrok.yml`

## Architecture

```
NgrokTools/
├── Sources/NgrokTools/
│   ├── App/              # AppDelegate, main entry point
│   ├── Models/           # API response models
│   ├── Services/         # API client, Keychain, polling, tunnel launcher
│   ├── ViewModels/       # MVVM view models
│   └── Views/            # SwiftUI views
├── Tests/
├── Info.plist
└── Package.swift
```

- **Swift Package Manager** — no Xcode project needed
- **MVVM** architecture with SwiftUI
- **ngrok Cloud API** (`api.ngrok.com`) for tunnel/session/endpoint data
- **ngrok Local API** (`127.0.0.1:4040+`) for live traffic inspection
- Multi-process aware — auto-scans inspect ports 4040–4049

## License

MIT — see [LICENSE](LICENSE)
