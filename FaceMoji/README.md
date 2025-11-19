# FaceMoji

A modern SwiftUI-based Animoji framework for iOS 17+, reimagining face-tracked animations with the latest Apple technologies.

## Overview

FaceMoji is a complete rewrite of the Animoji project using modern Swift and SwiftUI. It provides access to Apple's private AvatarKit framework to create and record Animoji characters with face tracking.

## Features

- ✅ **iOS 17+ SwiftUI**: Built with the latest SwiftUI and Swift 5.9
- ✅ **@Observable**: Modern state management with Observation framework
- ✅ **24+ Animoji Characters**: All available Animoji puppets from iOS 11.1+
- ✅ **Face Tracking**: Real-time face tracking using TrueDepth camera
- ✅ **Clean Architecture**: MVVM + Clean Architecture Lite pattern
- ✅ **Recording**: Record and export Animoji videos with audio
- ✅ **Video Export**: Export recordings to .mov format
- ✅ **Storage Management**: Automatic recording history (max 5 videos)
- ✅ **Background Customization**: 8 preset background colors
- 🚧 **GIF Export** (Coming Soon): Export recordings as animated GIFs
- 🚧 **History UI** (Coming Soon): Browse and manage recordings

## Requirements

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Device**: iPhone X or later (TrueDepth camera required)

## Project Structure

```
FaceMoji/
├── Package.swift                 # Swift Package configuration
├── Sources/FaceMoji/            # Core framework
│   ├── Core/                    # Core functionality
│   │   ├── AvatarKit/          # AvatarKit framework integration
│   │   ├── Recording/          # Recording engine (coming soon)
│   │   └── Storage/            # Storage management (coming soon)
│   ├── Features/               # Feature modules (MVVM)
│   ├── Shared/                 # Shared components
│   │   ├── Components/         # Reusable UI components
│   │   ├── Extensions/         # Swift extensions
│   │   └── Utilities/          # Utility classes
│   └── Models/                 # Data models
├── Examples/FaceMojiExample/   # Example app
└── Tests/FaceMojiTests/        # Unit tests
```

## Installation

### Swift Package Manager

Add FaceMoji to your project using SPM:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/FaceMoji", from: "1.0.0")
]
```

## Usage

### Basic Setup

```swift
import SwiftUI
import FaceMoji

struct ContentView: View {
    @State private var puppets: [PuppetModel] = []

    var body: some View {
        // Your UI here
    }

    func loadPuppets() async {
        do {
            puppets = try await PuppetManager.shared.loadAvailablePuppets()
        } catch {
            print("Failed to load puppets: \(error)")
        }
    }
}
```

### Permissions

Add the following keys to your app's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for face tracking.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for recording audio.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Permission needed to save videos to your photo library.</string>
```

## Development Status

### Sprint 1: Project Setup and Core Infrastructure ✅ COMPLETED

- [x] Create Swift Package structure
- [x] Setup directory structure
- [x] Implement AvatarKit loader
- [x] Create PuppetManager
- [x] Define data models
- [x] Create utility classes (HapticManager, PermissionManager)
- [x] Setup Example App

### Sprint 2: AvatarKit Integration ✅ COMPLETED

- [x] Implement AnimojiRecordView (UIKit wrapper)
- [x] Create AnimojiSceneView (SwiftUI bridge)
- [x] Create ContentViewModel with @Observable
- [x] Implement PuppetGridView component
- [x] Implement RecordingControlsView component
- [x] Update Example App with full UI
- [x] Test puppet loading and switching

### Sprint 5: Recording Functionality ✅ COMPLETED

- [x] Implement AnimojiRecorder (recording engine)
- [x] Create VideoExporter (export and conversion)
- [x] Create RecordingStorage (persistent storage)
- [x] Integrate recording into AnimojiRecordView
- [x] Update ContentViewModel with full recording logic
- [x] Implement AnimojiRecorderDelegate
- [x] Add recording history management (max 5 recordings)

### Upcoming Sprints

- Sprint 6: Error Handling and Polish
- Sprint 7: UX Enhancements (Background selection, Haptics)
- Sprint 8: Advanced Features (GIF export, Recording history UI)
- Sprint 8: Advanced Features

See [SWIFTUI_REWRITE_DESIGN.md](../SWIFTUI_REWRITE_DESIGN.md) for the complete development roadmap.

## Architecture

FaceMoji follows Clean Architecture Lite principles with MVVM pattern:

```
┌─────────────────────┐
│   SwiftUI Views    │ ← User Interface
└──────────┬──────────┘
           │ @Observable
┌──────────▼──────────┐
│    ViewModels       │ ← Business Logic
└──────────┬──────────┘
           │ Services
┌──────────▼──────────┐
│   Core Services     │ ← Framework Integration
└──────────┬──────────┘
           │ Private API
┌──────────▼──────────┐
│   AvatarKit         │ ← Apple Framework
└─────────────────────┘
```

## Available Puppets

### iOS 11.1
monkey, robot, cat, dog, alien, fox, poo, pig, panda, rabbit, chicken, unicorn

### iOS 11.3+
lion, dragon, skull, bear

### iOS 12.0+
tiger, koala, trex, ghost

### iOS 12.2+
giraffe, shark, owl, boar

## Disclaimer

⚠️ **Important**: This project uses Apple's private AvatarKit framework. While it works on devices, **submitting apps using private APIs to the App Store may result in rejection**. This project is intended for:

- Educational purposes
- Internal/enterprise apps
- Research and development
- Personal projects

## Contributing

Contributions are welcome! Please read the development roadmap in `SWIFTUI_REWRITE_DESIGN.md` before starting work.

## License

This project is available under the MIT license. See the LICENSE file for more info.

## Credits

- Original Animoji project: [efremidze/Animoji](https://github.com/efremidze/Animoji)
- Rewritten with SwiftUI by Claude

## Related Projects

- [Animoji](https://github.com/efremidze/Animoji) - Original UIKit implementation
