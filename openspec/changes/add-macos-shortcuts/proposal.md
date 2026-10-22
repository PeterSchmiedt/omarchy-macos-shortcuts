# Proposal

## Why

People who move from macOS to Omarchy keep pressing Mac shortcuts, and on Omarchy most of them do the wrong thing. On Omarchy, SUPER (the Mac's Cmd key) is the window-manager modifier, so Cmd+F goes full screen, Cmd+T toggles floating and Cmd+Tab switches workspace. We want one public script that any Omarchy user can run to get Mac-style shortcuts. It must not touch Omarchy's packaged files, and it must keep working across `omarchy update`.

## What Changes

- Add a Hyprland Lua module that overlays Omarchy's default bindings. It unbinds the defaults that clash and adds Mac-style bindings in their place. Omarchy's defaults stay loaded.
- **Cmd = app shortcuts.** Cmd+letter and Cmd+Shift+letter are sent to the focused app as Ctrl+letter and Ctrl+Shift+letter. Terminals get Ctrl+Shift+letter instead, with copy and paste matching how Omarchy handles them in terminals today.
- **Mac text navigation.** Cmd and Opt combined with the arrows or Backspace become the Linux equivalents: Home/End, word jump, delete word, and delete line.
- **Window management moves to Mac-shaped keys:**
  - Workspaces go to Ctrl+arrows and Ctrl+1-9.
  - Full screen goes to Cmd+Ctrl+F.
  - The scratchpad goes to Cmd+M.
  - Cmd+Tab cycles windows.
  - Cmd+Space opens the app launcher.
  - Cmd+Q closes every window of the focused app.
  - Cmd+Shift+3/4/5 take screenshots.
  - Cmd+Ctrl+Q locks the screen.
  - Tiling-only actions with no Mac equivalent go to Ctrl+Opt+key.
- **BREAKING (for the user's muscle memory, not their files).** About 30 of Omarchy's default SUPER bindings move. Omarchy's preinstalled app-launcher shortcuts are turned off (`omarchy_preinstalled_bindings = false`), and apps are opened from the Cmd+Space launcher instead.
- **One-line install.** `curl … | bash` clones the repo to `~/.local/share/omarchy-macos-shortcuts`, symlinks the module into `~/.config/hypr/macos`, and adds a marked block to `~/.config/hypr/hyprland.lua`. It then validates with `hyprctl configerrors` and rolls back if there are errors. Running it again is safe, and `uninstall` reverses every step.
- **Collision check.** A check command and an Omarchy post-update hook warn when Omarchy starts using a key this module claims, or when the marked block has been removed (for example by `omarchy refresh hyprland`).
- **v1 coverage goal:** every letter with Cmd and with Cmd+Shift, the Mac text-navigation keys, and the window keys listed above. Out of scope for v1: Cmd+Opt and Cmd+Ctrl combinations sent to apps, Cmd+click, a visual Cmd+Tab picker, a Mission Control overview, and Cmd+H (hide).
- Optional `--pc-keyboard` flag swaps Alt and Win for non-Mac keyboards. It is off by default.
- **Natural scrolling.** The mouse wheel and the touchpad both scroll in the macOS "natural" direction: content follows the fingers, so scrolling down moves the page up. This is the one non-shortcut input change in v1. Users can turn it back off in their own `~/.config/hypr/input.lua`.

## Capabilities

### New Capabilities

- `app-shortcuts`: Cmd and Cmd+Shift letter shortcuts are sent to the focused app as their Linux Ctrl equivalents, with a separate mapping for terminals.
- `text-navigation`: Mac cursor-movement and deletion shortcuts (Cmd/Opt with arrows and Backspace) in text fields and editors.
- `window-management-shortcuts`: Mac-style keys for workspaces, full screen, minimize to scratchpad, window cycling, quit, lock, screenshots and launcher, plus the Ctrl+Opt layer for tiling actions.
- `installation`: one-line install, update, uninstall and rollback of the shortcuts on an Omarchy system, including the optional PC-keyboard swap.
- `collision-check`: detects when Omarchy's own bindings, or a missing config block, conflict with the installed shortcuts, and reports it.
- `natural-scrolling`: macOS-style scroll direction for mouse wheels and touchpads.

### Modified Capabilities

None. This is a new project with no existing specs.

## Impact

- **Files written on the user's machine:**
  - `~/.local/share/omarchy-macos-shortcuts/`: the clone.
  - `~/.config/hypr/macos`: a symlink to the clone.
  - `~/.config/hypr/hyprland.lua`: one marked block is added.
  - `~/.config/omarchy/hooks/post-update.d/`: one hook script.
  - The PC-keyboard swap is a flag inside the marked block, so `input.lua` is not edited.
- **Not touched:** `/usr/share/omarchy/`, `/etc`, system packages. No sudo is needed.
- **Dependencies:** none beyond what Omarchy ships (`git`, `curl`, `hyprctl`, Hyprland's Lua config, `omarchy menu keybindings --print`).
- **Compatibility:** targets Omarchy 4.x (Lua Hyprland config). Omarchy releases that change default bindings are caught by the collision check rather than guaranteed.
- **Repository:** new `install.sh`, Hyprland Lua module(s), check and uninstall commands, README.
