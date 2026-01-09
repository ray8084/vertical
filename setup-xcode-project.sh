#!/bin/bash

# Script to help set up the Xcode project for Vertical iOS App

echo "Setting up Vertical iOS App..."
echo ""

# Create Xcode project using xcodegen if available, or provide manual instructions
if command -v xcodegen &> /dev/null; then
    echo "XcodeGen found. Generating Xcode project..."
    xcodegen generate
else
    echo "XcodeGen not found. Please set up the project manually in Xcode:"
    echo ""
    echo "1. Open Xcode"
    echo "2. Select 'Create a new Xcode project'"
    echo "3. Choose 'iOS' > 'App'"
    echo "4. Configure the project:"
    echo "   - Product Name: VerticalApp"
    echo "   - Team: Select your team"
    echo "   - Organization Identifier: com.yourname (or your domain)"
    echo "   - Interface: SwiftUI"
    echo "   - Language: Swift"
    echo "5. Save the project in the current directory"
    echo "6. Delete the default ContentView.swift that Xcode creates"
    echo "7. Add all files from VerticalApp/ directory to your project"
    echo "   - Drag VerticalApp folder into Xcode"
    echo "   - Make sure 'Copy items if needed' is unchecked"
    echo "   - Select 'Create groups'"
    echo "8. Make sure VerticalApp.swift is set as the app entry point"
    echo ""
fi

echo "Setup complete!"
