#!/bin/bash

WATCH_DIR="$HOME/Desktop"
COPY_DELAY=0.3

if ! command -v fswatch &>/dev/null; then
    echo "Error: fswatch is not installed. Install it with: brew install fswatch"
    exit 1
fi

echo "Watching for screenshots in $WATCH_DIR..."
echo "   Press Ctrl+C to stop"
echo ""

LAST_PROCESSED=""

fswatch -i 'Screenshot.*\.png$' -e '.*' "$WATCH_DIR" | while read -r FILEPATH; do
    FILENAME=$(basename "$FILEPATH")
    if [[ "$FILENAME" == .* ]]; then
        continue
    fi

    if [[ "$FILEPATH" == "$LAST_PROCESSED" ]]; then
        continue
    fi
    LAST_PROCESSED="$FILEPATH"

    sleep $COPY_DELAY
    osascript -e "set the clipboard to (read POSIX file \"$FILEPATH\" as «class PNGf»)"
    echo "Copied: $FILENAME"
done
