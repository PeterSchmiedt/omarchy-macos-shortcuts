# omarchy-macos-shortcuts

macOS-style keyboard shortcuts and natural scrolling for [Omarchy](https://omarchy.org/).

On Omarchy, the Cmd key (SUPER) belongs to the window manager: Cmd+F goes full screen, Cmd+T floats the window, Cmd+Tab switches workspace. This project gives Cmd back to your apps, the way macOS does, and moves Omarchy's window management to Mac-shaped keys.

- Everything stays in your home directory. It needs no sudo and changes nothing under `/usr` or `/etc`.
- It works on top of Omarchy's defaults. Omarchy updates keep working, and a check warns you if an update collides with these shortcuts.
- Requires Omarchy 4 (Lua Hyprland config). Built for Mac keyboards; see [PC keyboards](#pc-keyboards) for others.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/PeterSchmiedt/omarchy-macos-shortcuts/main/install.sh | bash
```

The shortcuts are active immediately; you don't need to log out. Here's what the installer does:

1. Clones this repo to `~/.local/share/omarchy-macos-shortcuts`.
2. Links `~/.config/hypr/macos` to its `hypr/` folder.
3. Adds two marked blocks to `~/.config/hypr/hyprland.lua`.
4. Installs an Omarchy post-update hook.
5. Reloads Hyprland. If Hyprland reports config errors, it puts everything back.

Before the first install, it saves a copy of your `hyprland.lua` as `hyprland.lua.macos-backup`.

Prefer to read before you run? Look at [`install.sh`](install.sh), or clone and run it yourself:

```bash
git clone https://github.com/PeterSchmiedt/omarchy-macos-shortcuts.git ~/.local/share/omarchy-macos-shortcuts
~/.local/share/omarchy-macos-shortcuts/install.sh
```

## Update

Run the same one-line install again. It pulls the latest version and refreshes the config blocks. Running it repeatedly is safe. It also restores the blocks if something removed them, for example `omarchy refresh hyprland`.

## Uninstall

```bash
~/.local/share/omarchy-macos-shortcuts/install.sh uninstall
```

This removes the config blocks, the link and the hook, then reloads Hyprland so Omarchy's defaults come back. It asks before deleting the downloaded copy.

## Shortcuts

Press **Ctrl+Opt+/** to see every binding. The ones from this project start with `Mac:`.

### Cmd goes to the app

| Keys | Sends | Notes |
| --- | --- | --- |
| Cmd+A … Cmd+Z | Ctrl+A … Ctrl+Z | All letters except Q and M |
| Cmd+Shift+A … Cmd+Shift+Z | Ctrl+Shift+A … Ctrl+Shift+Z | Cmd+Shift+T reopens a tab, Cmd+Shift+Z redoes |
| Cmd+= / Cmd+- / Cmd+0 | Ctrl+= / Ctrl+- / Ctrl+0 | App zoom |

In terminals, Cmd+letter sends **Ctrl+Shift+letter** (Cmd+T is a new tab). Cmd+C and Cmd+V copy and paste, and the physical Ctrl+C still interrupts.

Cmd+W sends Ctrl+W, which closes a tab, as on a Mac. To close an app, use Cmd+Q. Terminals without tabs, such as Alacritty, ignore Cmd+W.

### Text navigation

| Keys | Does |
| --- | --- |
| Cmd+Left / Cmd+Right | Start / end of line |
| Cmd+Up / Cmd+Down | Start / end of document |
| Opt+Left / Opt+Right | Previous / next word (Alt+B / Alt+F in terminals) |
| Add Shift to any of the above | Select instead of move |
| Opt+Backspace | Delete previous word |
| Cmd+Backspace | Delete to start of line (Ctrl+U in terminals) |

Opt+Left is now "previous word", so the browser's Alt+Left "back" no longer works. Use the mouse back button or the browser's toolbar.

### Windows, workspaces and system

| Keys | Does | Omarchy had it on |
| --- | --- | --- |
| Cmd+Tab / Cmd+Shift+Tab | Next / previous window | Alt+Tab (still works) |
| Cmd+Q | Quit app (closes all its windows) | – |
| Cmd+Opt+Esc | Force quit the focused app | – |
| Cmd+M | Minimize (to the scratchpad) | Super+Alt+S |
| Ctrl+Down | Show or hide the scratchpad | Super+S |
| Cmd+Ctrl+F | Full screen | Super+F |
| Ctrl+Left / Ctrl+Right | Previous / next workspace | Super+Shift+Tab / Super+Tab |
| Ctrl+1 … Ctrl+0 | Go to workspace 1-10 | Super+1 … Super+0 |
| Ctrl+Shift+1 … Ctrl+Shift+0 | Move window to workspace 1-10 | Super+Shift+1 … Super+Shift+0 |
| Cmd+Space | App launcher | Super+Alt+Space (still works) |
| Cmd+Ctrl+Q | Lock screen | Super+Ctrl+L (still works) |
| Cmd+Shift+3 / 4 / 5 | Screenshot: full screen / region / capture menu | Print |

### Tiling (Ctrl+Opt)

macOS has no tiling, so these go on Ctrl+Opt, like the Rectangle app:

| Keys | Does | Omarchy had it on |
| --- | --- | --- |
| Ctrl+Opt+Arrows | Focus window in that direction | Super+Arrows |
| Ctrl+Opt+Shift+Arrows | Swap window in that direction | Super+Shift+Arrows |
| Ctrl+Opt+T | Toggle floating | Super+T |
| Ctrl+Opt+J | Toggle split | Super+J |
| Ctrl+Opt+G | Toggle grouping | Super+G |
| Ctrl+Opt+P | Pseudo-tile | Super+P |
| Ctrl+Opt+O | Pop window out | Super+O |
| Ctrl+Opt+L | Toggle workspace layout | Super+L |
| Ctrl+Opt+F | Tiled full screen | Super+Ctrl+F |
| Ctrl+Opt+- / Ctrl+Opt+= | Resize window | Super+- / Super+= |
| Ctrl+Opt+Backspace | Toggle transparency | Super+Backspace |
| Ctrl+Opt+Space | Omarchy menu | Super+Space |
| Ctrl+Opt+/ | Keybindings | Super+K |

### What's turned off

- **Omarchy's app-launcher shortcuts** (Super+Shift+B browser, Super+Shift+G Signal, and so on) are off, because those keys are now Cmd+Shift app shortcuts. Open apps with Cmd+Space. To keep the launchers anyway, add `omarchy_preinstalled_bindings = true` near the top of `~/.config/hypr/hyprland.lua`. Any launcher on a key this project uses still gives way to the Mac shortcut.
- **The calculator** moved from Super+Ctrl+Q to the keyboard's calculator key, because Cmd+Ctrl+Q now locks the screen.

### Not included (yet)

The following aren't included yet:
- a visual Cmd+Tab app picker or a Mission Control overview
- Cmd+H (hide)
- Cmd+\` (cycle windows of the same app)
- Cmd+click
- Cmd+1-9 in browsers
- Cmd+Opt+letter and Cmd+Ctrl+letter app shortcuts

## Natural scrolling

The mouse wheel and the touchpad scroll the macOS way: content follows your fingers. To turn this off, put this in `~/.config/hypr/input.lua`. Your file loads after this project, so it wins.

```lua
hl.config({ input = { natural_scroll = false, touchpad = { natural_scroll = false } } })
```

Leave out either half to change only the mouse or only the touchpad.

## Your own bindings win

`~/.config/hypr/bindings.lua` loads after this project. To change a key, unbind it and bind it again there:

```lua
hl.unbind("SUPER + M")
o.bind("SUPER + M", "My thing", "my-command")
```

## PC keyboards

On a PC keyboard, the key next to the space bar is Alt, not Cmd. Install with `--pc-keyboard` to swap Alt and Win, so that key acts as Cmd:

```bash
curl -fsSL https://raw.githubusercontent.com/PeterSchmiedt/omarchy-macos-shortcuts/main/install.sh | bash -s -- --pc-keyboard
```

The choice is remembered when you update. To turn it off again, run the installer with `--no-pc-keyboard`. Omarchy's own keyboard options, such as the compose key, are kept.

## Checking for problems

```bash
~/.local/share/omarchy-macos-shortcuts/bin/omarchy-macos-check
```

The check only reads your configuration and never changes anything. It reports:
- Omarchy default bindings that now sit on a key this project uses. This can happen after an `omarchy update`.
- A missing config block or a broken link, for example after `omarchy refresh hyprland`.
- A PC-keyboard swap that isn't active.

The same check runs automatically after every `omarchy update`. You only get a desktop notification when something is wrong.

**If Omarchy adds a colliding binding**, the Mac shortcut wins and Omarchy's new action has no key. Give it one in `~/.config/hypr/bindings.lua`. The check message names the key and the action. If the new Omarchy binding should replace ours, open an issue so the keymap can be updated.

## How it works

- `hypr/keymap.lua` is the whole keymap as data. `hypr/init.lua` turns it into Hyprland bindings, and `bin/omarchy-macos-check` uses it to find collisions.
- The module loads right after Omarchy's defaults and before your own config. It unbinds the Omarchy keys it takes over and binds its own.
- Key forwarding uses Hyprland's `send_key_state`, the same approach Omarchy uses for its universal copy and paste.
