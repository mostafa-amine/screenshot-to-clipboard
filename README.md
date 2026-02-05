# Screenshot to Clipboard

Automatically copies macOS screenshots to your clipboard the moment they're saved, so you can paste them instantly with **Cmd+V**.

## The Problem

macOS saves screenshots as files on your Desktop (or a custom folder), but doesn't put them on the clipboard. If you want to paste a screenshot into Slack, iMessage, or an email, you have to manually open the file and copy it first.

> **Note:** macOS does have a built-in shortcut to capture directly to clipboard *without* saving a file: **Cmd+Ctrl+Shift+3** (full screen) or **Cmd+Ctrl+Shift+4** (selection). However, this skips saving the file entirely — you only get the clipboard copy. This script gives you **both**: a saved file *and* an automatic clipboard copy.

## How It Works

The script uses `fswatch` to watch your screenshot folder. When a new screenshot appears, it copies the image to your clipboard using AppleScript.

## Prerequisites

Install `fswatch` via Homebrew:

```bash
brew install fswatch
```

## Quick Start (Manual)

Run the script directly in Terminal:

```bash
chmod +x screenshot-to-clipboard.sh
./screenshot-to-clipboard.sh
```

Take a screenshot with **Cmd+Shift+4**, then **Cmd+V** to paste it anywhere. Press **Ctrl+C** to stop.

## Run Permanently (LaunchAgent)

To have the script start automatically on login and run in the background:

**1. Copy the script to a safe location**

macOS restricts LaunchAgent access to protected folders like Desktop, so the script needs to live somewhere unrestricted:

```bash
mkdir -p ~/bin
cp screenshot-to-clipboard.sh ~/bin/
chmod 755 ~/bin/screenshot-to-clipboard.sh
```

**2. Create the LaunchAgent plist**

Create the file `~/Library/LaunchAgents/com.user.screenshot-to-clipboard.plist` with the following contents:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.screenshot-to-clipboard</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/YOUR_USERNAME/bin/screenshot-to-clipboard.sh</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/screenshot-to-clipboard.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/screenshot-to-clipboard.err</string>
</dict>
</plist>
```

Replace `YOUR_USERNAME` with your macOS username (run `whoami` if unsure).

**3. Load the agent**

```bash
chmod 644 ~/Library/LaunchAgents/com.user.screenshot-to-clipboard.plist
launchctl load ~/Library/LaunchAgents/com.user.screenshot-to-clipboard.plist
```

The script will now run automatically every time you log in.

**4. Verify it's running**

```bash
launchctl list | grep screenshot
```

If something isn't working, check the logs:

```bash
cat /tmp/screenshot-to-clipboard.log
cat /tmp/screenshot-to-clipboard.err
```

## Managing with sctrl (Screenshot Control)

The project includes `sctrl.sh`, a control script for quickly enabling and disabling the service. Install it alongside the main script:

```bash
cp sctrl.sh ~/bin/
chmod +x ~/bin/sctrl.sh
```

Usage:

```bash
~/bin/sctrl.sh start    # enable the service
~/bin/sctrl.sh stop     # disable the service
~/bin/sctrl.sh status   # check if running
```

Optionally, add aliases to your `~/.zshrc` for quicker access:

```bash
echo 'alias sc-stop="~/bin/sctrl.sh stop"' >> ~/.zshrc
echo 'alias sc-start="~/bin/sctrl.sh start"' >> ~/.zshrc
echo 'alias sc-status="~/bin/sctrl.sh status"' >> ~/.zshrc
source ~/.zshrc
```

Then just type `sc-stop`, `sc-start`, or `sc-status` from anywhere.

## Remove Permanently

```bash
~/bin/sctrl.sh stop
rm ~/Library/LaunchAgents/com.user.screenshot-to-clipboard.plist
rm ~/bin/screenshot-to-clipboard.sh
rm ~/bin/sctrl.sh
```

## Configuration

Edit the top of `screenshot-to-clipboard.sh` to customize:

- **`WATCH_DIR`** — the folder to watch (default: `$HOME/Desktop`)
- **`COPY_DELAY`** — seconds to wait before copying, to ensure the file is fully written (default: `0.3`)

## Bonus Tip

Disable the 5-second screenshot thumbnail preview so screenshots save instantly:

```bash
defaults write com.apple.screencapture show-thumbnail -bool false && killall SystemUIServer
```

To re-enable it later:

```bash
defaults write com.apple.screencapture show-thumbnail -bool true && killall SystemUIServer
```
