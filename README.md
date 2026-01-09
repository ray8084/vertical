# Vertical

A modern iOS app built with UIKit.

## Features

- Clean UIKit interface
- Empty screen app ready for customization
- Modern iOS design patterns using programmatic UI

## Requirements

- iOS 15.0 or later
- Xcode 14.0 or later
- macOS 12.0 or later (for development)

## Quick Start

**👉 See [XCODE_SETUP.md](XCODE_SETUP.md) for detailed step-by-step instructions to create the Xcode project.**

The project includes all source files but needs to be set up in Xcode. Follow the guide in `XCODE_SETUP.md` for complete instructions.

## Setup Instructions

### Option 1: Using XcodeGen (Recommended)

If you have [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed:

```bash
# Install XcodeGen (if not already installed)
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Open the project
open VerticalApp.xcodeproj
```

### Option 2: Manual Setup in Xcode

1. Open Xcode
2. Select **File > New > Project**
3. Choose **iOS > App**
4. Configure the project:
   - **Product Name:** `VerticalApp`
   - **Team:** Select your development team
   - **Organization Identifier:** `com.yourname` (or your domain)
   - **Interface:** Storyboard (we'll remove this)
   - **Language:** Swift
5. Save the project in this directory
6. Delete the default `ViewController.swift` and `Main.storyboard` that Xcode creates
7. In the project settings, remove "Main" from the "Main Interface" field in Deployment Info
8. Add the existing files to your project:
   - Right-click on the project in the navigator
   - Select **Add Files to "VerticalApp"...**
   - Navigate to and select the `VerticalApp` folder
   - Make sure **"Copy items if needed"** is **unchecked**
   - Select **"Create groups"**
   - Click **Add**
9. Set the Launch Screen: In the target's "General" tab, under "App Icons and Launch Screen", set "Launch Screen File" to `LaunchScreen` (without extension)
10. Ensure `AppDelegate.swift` is set as the app entry point (it should have `@main` attribute)
11. Build and run the project (⌘R)

### Setting Up Code Signing

1. Select the `VerticalApp` target in Xcode
2. Go to the **Signing & Capabilities** tab
3. Check **"Automatically manage signing"**
4. Select your **Team** from the dropdown
5. Xcode will automatically configure the bundle identifier

## Project Structure

```
VerticalApp/
├── AppDelegate.swift          # App delegate (entry point)
├── SceneDelegate.swift        # Scene delegate for window management
├── ViewControllers/
│   └── ItemsViewController.swift    # Main view controller (empty screen)
├── Models/
│   └── Item.swift             # Item data model
├── Assets.xcassets/           # App assets (icons, colors)
├── LaunchScreen.storyboard    # Launch screen
└── Info.plist                 # App configuration
```

## Development

### Running the App

1. Select a simulator or connected device
2. Press **⌘R** or click the **Run** button
3. The app will launch in the selected destination

### Building for Release

1. Select **Product > Scheme > VerticalApp**
2. Select **Product > Destination > Any iOS Device**
3. Select **Product > Archive**
4. Follow the prompts to distribute the app

## Architecture

The app follows MVC (Model-View-Controller) architecture:

- **Models:** Data structures (`Item.swift` - currently unused)
- **Views:** UIKit views (UIViewController)
- **Controllers:** View controllers that manage the view

## Customization

You can customize the app by:

- Modifying view controllers in the `ViewControllers/` directory
- Adding new features and functionality
- Customizing the app icon in `Assets.xcassets`
- Styling the launch screen in `LaunchScreen.storyboard`

## Technical Details

- **Framework:** UIKit (programmatic UI, no storyboards except launch screen)
- **Minimum iOS Version:** iOS 15.0
- **Language:** Swift 5.0+
- **Deployment:** Supports iPhone and iPad

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]
