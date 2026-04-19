# claude-bot-popup

A floating, borderless macOS popup with a custom mascot image and a speech bubble that holds your notification text. Built to wire into [Claude Code](https://docs.anthropic.com/en/docs/claude-code) hooks so the assistant can tap you on the shoulder without using the standard NotificationCenter banner.

## Why

macOS notifications:

- live in NotificationCenter and can be silenced or queued behind Do Not Disturb
- always render with Apple's chrome (rounded rect, sender icon, dismiss button)
- can't show a custom mascot in the left-side icon slot without repackaging the sender app

This is the opposite: a tiny transparent window with just your image and a speech bubble. No Apple chrome, no NotificationCenter entry, ignores mouse events so it doesn't block clicks underneath. Auto-dismisses after a configurable duration.

## Requirements

- macOS (tested on 14+)
- Python 3.11+ with [PyObjC](https://pyobjc.readthedocs.io/) (`pyobjc-core`, `pyobjc-framework-Cocoa`)
- `jq` (only if you wire it into Claude Code's `Notification` hook to extract the message)

## Install

```sh
git clone https://github.com/alechn/claude-bot-popup.git
cd claude-bot-popup
./install.sh
```

`install.sh` will:

1. Install PyObjC into the Homebrew Python 3.11 user site
2. Drop `claude-notify` into `~/.claude/bin/`
3. Prompt you for the path to your mascot PNG and copy it to `~/.claude/notification-bot.png`

> **Bring your own bot image.** This repo does not ship a mascot to avoid distributing artwork that may belong to someone else. Any PNG with a transparent background works — square or wide both look fine.

## Use

```sh
~/.claude/bin/claude-notify --message "Hello world" --duration 4 --sound Glass
```

Flags:

| Flag | Default | Notes |
|---|---|---|
| `-m`, `--message` | `Notification` | The text rendered inside the bubble. Wraps automatically. |
| `-d`, `--duration` | `4.0` | Seconds on screen before fade-out. |
| `-s`, `--sound` | _(none)_ | Any system sound name from `/System/Library/Sounds/` (e.g. `Glass`, `Pop`, `Tink`). |

## Wire into Claude Code

Add to `~/.claude/settings.json` — see [examples/settings.json](examples/settings.json) for the full snippet.

The two hooks worth adding:

- **`Notification`** — fires when Claude needs your attention. The `claude-notify-attention` wrapper compresses the event message into a bot-voice status (e.g. `"I need permission"`, `"I'm waiting"`).
- **`Stop`** — fires when Claude finishes a response. The `claude-notify-stop` wrapper reads the hook's stdin to find the transcript path, finds the timestamp of the last user prompt (filtering out tool_result events that share the `user` type), and shows `"done, cooked for 43s"`-style elapsed time.

Both wrappers detach the popup with `nohup ... & disown` so they don't block Claude from continuing.

## Customizing

Open `~/.claude/bin/claude-notify` and edit:

- `bot_w` — bot width in points; everything else scales relative to font size
- font size on the `NSFont.systemFontOfSize_weight_(...)` line
- the `window_frame` math to anchor the popup somewhere other than top-right
- `radius`, `pad_h`, `pad_v` for bubble shape

## Uninstall

```sh
rm -rf ~/.claude/bin/claude-notify ~/.claude/bin/claude-notify-stop ~/.claude/bin/claude-notify-attention ~/.claude/notification-bot.png
```

Then remove the `Notification` and `Stop` blocks from `~/.claude/settings.json`.

## License

MIT — see [LICENSE](LICENSE).
