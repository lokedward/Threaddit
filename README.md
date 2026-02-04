# Threaddit

A personal wardrobe inventory app for iOS that lets you digitize and organize your closet.

## Requirements

- **Xcode 15.0+**
- **iOS 17.0+** (SwiftData requirement)
- macOS Sonoma 14.0+ (for development)

## Setup Instructions

### Option 1: Create Project in Xcode (Recommended)

1. Open **Xcode** and create a new project:
   - Select **App** template
   - Product Name: `Threaddit`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
   
2. Delete the generated `ContentView.swift` and `Item.swift` (if created)

3. Copy all files from this `Threaddit/` folder into your Xcode project:
   - Drag the `Models/`, `Views/`, `Services/` folders and `ThreadditApp.swift` into the project navigator
   - Ensure "Copy items if needed" is checked
   - Select "Create groups"

4. Replace the generated `Info.plist` with the one from this folder (for camera/photo permissions)

5. Replace `Assets.xcassets` contents with those from this folder

6. Build and run on iOS 17+ simulator or device

### Option 2: Use Swift Package (Advanced)

If you prefer, you can create a Swift Package and use these files as source.

## Project Structure

```
Threaddit/
├── ThreadditApp.swift          # App entry point with SwiftData container
├── Info.plist                  # Privacy permissions
├── Assets.xcassets/            # App icons and colors
├── Models/
│   ├── ClothingItem.swift      # Main item model
│   └── Category.swift          # User-editable categories
├── Services/
│   └── ImageStorageService.swift  # Image persistence
└── Views/
    ├── ContentView.swift       # Root navigation
    ├── HomeView.swift          # Main closet view with shelves
    ├── CategoryShelfView.swift # Horizontal item row
    ├── CategoryGridView.swift  # Full category grid
    ├── ItemThumbnailView.swift # Reusable thumbnail
    ├── AddItemView.swift       # Add new item flow
    ├── ItemDetailView.swift    # View/edit/delete item
    ├── SearchView.swift        # Global search
    ├── SettingsView.swift      # App settings
    └── CategoryManagementView.swift  # Manage categories
```

## Features

- ✅ Add clothing items with photos from camera or library
- ✅ Organize by customizable categories
- ✅ Search by name, brand, or tags
- ✅ Add size and brand metadata
- ✅ Dark/Light mode support
- ✅ Export data as JSON
- ✅ Fully offline - all data stored locally

## Privacy

Threaddit stores all data locally on your device using SwiftData. Images are saved to the app's Documents directory. No data is sent to external servers.
