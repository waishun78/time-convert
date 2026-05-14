# TimeConvert

TimeConvert is a macOS menu bar app for converting between Unix epoch values and readable local/UTC timestamps.

## Build And Run

The easiest way to build the app, stop any currently running TimeConvert instance, and launch the new build is:

```bash
./scripts/build-and-run.sh
```

The script creates a local app bundle at:

```text
build/TimeConvert.app
```

It uses the installed Swift compiler directly, so it works on machines with Apple Command Line Tools. If full Xcode is installed and selected, you can also build with:

```bash
xcodebuild -project TimeConvert.xcodeproj -scheme TimeConvert -configuration Debug build
```

If `xcodebuild` reports that the active developer directory is Command Line Tools, install/select full Xcode first:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Usage

Copy a 10-digit epoch seconds value, 13-digit epoch milliseconds value, or a timestamp in `yyyy-MM-dd HH:mm:ss` format. TimeConvert shows the converted result in the menu bar and in the dropdown.
