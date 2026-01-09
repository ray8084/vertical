# How to Create Xcode Project for Vertical App

Follow these steps to create and open the project in Xcode:

## Step 1: Open Xcode

Launch Xcode on your Mac.

## Step 2: Create New Project

1. In Xcode, select **File > New > Project** (or press `⌘⇧N`)
2. Select **iOS** at the top
3. Choose **App** template
4. Click **Next**

## Step 3: Configure Project

Fill in the project details:
- **Product Name:** `VerticalApp`
- **Team:** Select your development team (or leave as "None" for now)
- **Organization Identifier:** `com.yourname` (or your domain, e.g., `com.vertical`)
- **Bundle Identifier:** This will auto-fill as `com.yourname.VerticalApp`
- **Interface:** Choose **Storyboard** (we'll remove it)
- **Language:** **Swift**
- **Use Core Data:** Unchecked
- **Include Tests:** Your choice (recommended: checked)

Click **Next**

## Step 4: Save Project

1. Navigate to this directory: `/Users/ray/Documents/GitHub/vertical`
2. **Important:** Uncheck "Create Git repository" (we already have one)
3. Click **Create**

## Step 5: Remove Default Files

1. In Xcode's project navigator (left sidebar), select and delete:
   - `ViewController.swift`
   - `Main.storyboard`
   - `SceneDelegate.swift` (we have our own version)

   (Right-click > Delete, then choose "Move to Trash")

## Step 6: Add Existing Files

1. Right-click on the **VerticalApp** folder (blue icon) in the project navigator
2. Select **Add Files to "VerticalApp"...**
3. Navigate to the `VerticalApp` folder in the file browser
4. Select all files and folders inside `VerticalApp`:
   - `AppDelegate.swift`
   - `SceneDelegate.swift`
   - `Info.plist`
   - `LaunchScreen.storyboard`
   - `Models` folder
   - `ViewControllers` folder
   - `Assets.xcassets` folder
5. **Important settings:**
   - ✅ Check "Copy items if needed" (leave unchecked - files are already here)
   - Select **"Create groups"** (not "Create folder references")
   - ✅ Make sure "Add to targets: VerticalApp" is checked
6. Click **Add**

## Step 7: Configure Project Settings

1. Select the **VerticalApp** project (blue icon at the top of navigator)
2. Select the **VerticalApp** target under "TARGETS"
3. Go to the **General** tab:
   - **Display Name:** `Vertical`
   - **Deployment Info:** iOS 15.0
   - Under **Deployment Info**, remove "Main" from the **Main Interface** field (make it blank)
   - Scroll to **App Icons and Launch Screen**:
     - **Launch Screen File:** Select `LaunchScreen` from dropdown

4. Go to the **Info** tab:
   - Make sure `Info.plist` is selected as the Info.plist File

5. Go to the **Build Settings** tab:
   - Search for "Swift Language Version"
   - Set it to **Swift 5**

6. Go to the **Signing & Capabilities** tab:
   - Check **"Automatically manage signing"**
   - Select your **Team** (if you have one)

## Step 8: Verify Entry Point

1. Open `AppDelegate.swift`
2. Make sure it has `@main` attribute (it should)
3. The file should look correct

## Step 9: Build and Run

1. Select a simulator (e.g., iPhone 15) from the device selector at the top
2. Press `⌘R` or click the **Run** button
3. The app should build and launch with an empty screen!

## Troubleshooting

**If you get build errors:**
- Make sure all files are added to the target (check File Inspector for each file)
- Clean build folder: **Product > Clean Build Folder** (`⌘⇧K`)
- Make sure Swift version is set correctly

**If the app doesn't launch:**
- Check that `SceneDelegate.swift` is properly configured
- Verify `Info.plist` has the SceneDelegate configuration
- Make sure Launch Screen is set to `LaunchScreen`

## Alternative: Use XcodeGen (Optional)

If you prefer to generate the project automatically:

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate the project:
   ```bash
   cd /Users/ray/Documents/GitHub/vertical
   xcodegen generate
   ```

3. Open the project:
   ```bash
   open VerticalApp.xcodeproj
   ```
