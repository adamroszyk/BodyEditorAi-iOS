# BodyEditorAi iOS App

This project contains an experimental iOS application used to test AI-powered photo editing. The Xcode project lives in the **HairStyle** directory.

## Requirements
- Xcode 15 or later
- iOS 17 SDK

## Configuration
The app communicates with an external API. The endpoint is defined in `Info.plist` under the `API_URL` key. Update this value to point to your own backend.

## Building
Open `HairStyle.xcodeproj` in Xcode and build the `HairStyle` target.

## Tests
A basic XCTest target is provided in `HairStyleTests`. Run tests with:

```bash
xcodebuild -scheme HairStyle -sdk iphonesimulator test
```

## Tasks
Development tasks are now tracked via the repository's issue tracker. The legacy `ToDo.txt` file has been removed.

