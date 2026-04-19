#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BIN_DIR="$CLAUDE_DIR/bin"
SCRIPT_DEST="$BIN_DIR/claude-notify"
IMAGE_DEST="$CLAUDE_DIR/notification-bot.png"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "claude-bot-popup is macOS-only (uses NSWindow)." >&2
  exit 1
fi

PYTHON="${PYTHON:-/opt/homebrew/bin/python3.11}"
if [[ ! -x "$PYTHON" ]]; then
  PYTHON="$(command -v python3.11 || true)"
fi
if [[ -z "$PYTHON" || ! -x "$PYTHON" ]]; then
  echo "Need Python 3.11. Install with: brew install python@3.11" >&2
  exit 1
fi

echo "Using Python: $PYTHON"
"$PYTHON" -m pip install --user --quiet pyobjc-core pyobjc-framework-Cocoa
"$PYTHON" -c "from AppKit import NSWindow" >/dev/null

mkdir -p "$BIN_DIR"
sed "1s|.*|#!$PYTHON|" "$REPO_DIR/claude-notify" > "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"
echo "Installed: $SCRIPT_DEST"

cp "$REPO_DIR/claude-notify-stop" "$BIN_DIR/claude-notify-stop"
chmod +x "$BIN_DIR/claude-notify-stop"
echo "Installed: $BIN_DIR/claude-notify-stop"

cp "$REPO_DIR/claude-notify-attention" "$BIN_DIR/claude-notify-attention"
chmod +x "$BIN_DIR/claude-notify-attention"
echo "Installed: $BIN_DIR/claude-notify-attention"

if [[ ! -f "$IMAGE_DEST" ]]; then
  echo
  echo "Provide a path to your mascot PNG (transparent background recommended)."
  echo "Press Enter to skip — you can drop one at $IMAGE_DEST later."
  read -r -p "PNG path: " src
  if [[ -n "$src" ]]; then
    src="${src/#\~/$HOME}"
    if [[ -f "$src" ]]; then
      cp "$src" "$IMAGE_DEST"
      echo "Image installed: $IMAGE_DEST"
    else
      echo "Warning: $src not found; skipped." >&2
    fi
  fi
fi

echo
echo "Done. Try it:"
echo "  $SCRIPT_DEST --message \"Hello from the lil bot\" --duration 3 --sound Glass"
echo
echo "To wire into Claude Code hooks, see examples/settings.json"
