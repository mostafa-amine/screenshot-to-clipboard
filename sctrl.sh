#!/bin/bash

LABEL="com.amine.screenshot-to-clipboard"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

case "$1" in
    start)
        launchctl enable "$DOMAIN/$LABEL"
        launchctl bootstrap "$DOMAIN" "$PLIST" 2>/dev/null
        launchctl kickstart "$DOMAIN/$LABEL" 2>/dev/null
        echo "Started."
        ;;
    stop)
        launchctl disable "$DOMAIN/$LABEL"
        launchctl kill SIGTERM "$DOMAIN/$LABEL" 2>/dev/null
        pkill -9 -f screenshot-to-clipboard.sh 2>/dev/null
        pkill -9 -f "fswatch.*Screenshot" 2>/dev/null
        echo "Stopped."
        ;;
    status)
        if launchctl print "$DOMAIN/$LABEL" 2>/dev/null | grep -q "state = running"; then
            echo "Running."
        else
            echo "Not running."
        fi
        ;;
    *)
        echo "Usage: sctrl start | stop | status"
        ;;
esac
