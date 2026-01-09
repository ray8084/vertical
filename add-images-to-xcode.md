# Adding Images to Xcode Project Manually

Since the Images folder might not be visible in Xcode, here's how to add it:

1. **Open Xcode** and open the VerticalApp project
2. **Right-click on the `VerticalApp` folder** (blue folder icon) in the Project Navigator
3. Select **"Add Files to 'VerticalApp'..."**
4. Navigate to and select the **`Images` folder** inside `VerticalApp/`
5. **Important settings:**
   - ✅ Check **"Copy items if needed"** (unchecked - files are already here)
   - Select **"Create folder references"** (NOT "Create groups") - This is important!
   - ✅ Make sure **"Add to targets: VerticalApp"** is checked
6. Click **Add**

After adding, the Images folder should appear as a blue folder (folder reference) in Xcode.

Then try running the app again - the images should load properly!
