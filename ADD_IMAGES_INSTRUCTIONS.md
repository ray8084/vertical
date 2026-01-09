# How to Add Images Folder to Xcode (ONE TIME ONLY)

Follow these steps to add the Images folder to your Xcode project:

## Step 1: Clean Build
1. In Xcode: **Product > Clean Build Folder** (⌘⇧K)

## Step 2: Close Xcode (Important!)
Close Xcode completely before adding files.

## Step 3: Add Images Folder
1. **Re-open Xcode** with your VerticalApp project
2. **Right-click** on the **`VerticalApp`** folder (blue icon) in the Project Navigator (left sidebar)
3. Select **"Add Files to 'VerticalApp'..."**
4. Navigate to: `VerticalApp/Images` folder
5. **IMPORTANT SETTINGS:**
   - ✅ **UNCHECK** "Copy items if needed" (files are already there)
   - ✅ Select **"Create folder references"** (NOT "Create groups")
     - This creates a BLUE folder icon (folder reference)
     - NOT a yellow folder (group)
   - ✅ Check **"Add to targets: VerticalApp"**
6. Click **"Add"**

## Step 4: Verify
After adding, you should see:
- A **blue folder** named "Images" in your project navigator
- All the image files inside it

## Step 5: Build
- **Product > Build** (⌘B)
- Should build without "Multiple commands produce" errors

## If You Still Get Errors:
1. **Remove the Images folder** from Xcode:
   - Right-click Images folder → Delete → "Remove Reference"
2. Clean build folder (⌘⇧K)
3. Follow steps above again

**DO NOT** add the Images folder more than once, and **DO NOT** use "Create groups" - always use "Create folder references".
