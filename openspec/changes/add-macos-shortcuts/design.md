# Design

## Context

Omarchy 4.x (verified on 4.0.6 with Hyprland 0.56.2) configures Hyprland in Lua. The parts this design depends on:

- **Load order.** `~/.config/hypr/hyprland.lua` runs `dofile(bootstrap.lua)`, then `require("default.hypr.omarchy")`, then the user's modules (`hypr.monitors`, `hypr.input`, `hypr.bindings`, ...).
- **Module path.** `bootstrap.lua` puts `~/.config/?.lua` and `$OMARCHY_PATH/?.lua` on `package.path`, but not `?/init.lua`. On every reload it also clears modules under the `hypr.` prefix.
- **Default bindings.** They live in `$OMARCHY_PATH/default/hypr/bindings/{clipboard,tiling,utilities,media,voxtype,applications}.lua`. All of them use `o.bind(keys, description, dispatcher, opts)`, and some are generated in loops (workspaces 1-10).
- **Launcher bindings.**
  - `applications.lua` lines 12+ are gated by `o.preinstalled_bindings_enabled()`, which reads the global `omarchy_preinstalled_bindings`. That global must be set *before* `require("default.hypr.omarchy")`.
  - Lines 2-8 (SUPER+RETURN, SUPER+SHIFT+B/F/N/RETURN) are not gated.
- **Clipboard forwarding.** `clipboard.lua` already forwards SUPER+C/V/X with `hl.dsp.send_key_state` down/up events 50 ms apart. That works around Hyprland send_shortcut leaving keys stuck (hyprwm/Hyprland#14099). It detects terminals by the `terminal` window tag from `apps/terminals.lua`. The helpers are `local`, so they can't be reused.
- **Available pieces:**
  - `o.bind` accepts `{ repeating = true }`.
  - `default.hypr.require_optional` provides `.module(name)`, which requires a module only if it exists on `package.path`.
  - The `lua` interpreter is a hard dependency of the `hyprland` package, so it's present on every Omarchy system.
- **Hooks.** `omarchy-hook` runs every non-`.sample` file in `~/.config/omarchy/hooks/post-update.d/` with bash.

## Goals / Non-Goals

**Goals:**
- One declarative keymap file is the single source of truth. The Hyprland module, the collision check and the README all read it.
- Every behaviour in the specs is reachable without root, and uninstall leaves no trace.
- When the Omarchy version is unknown, the module degrades safely: Omarchy's defaults still load, and the user gets warnings.

**Non-Goals:**
- A visual app switcher, an overview or expose view, Cmd+H (hide), Cmd+` (same-app window cycling), Cmd+click, Cmd+1-9 sent to apps, and Cmd+Opt or Cmd+Ctrl letter combinations sent to apps.
- Any per-application remapping beyond the terminal or non-terminal split.
- Support for Omarchy releases that still use hyprlang `.conf` bindings (pre-Lua).

## Decisions

### D1. Repository layout and the single keymap table

```
install.sh                 # bootstrap + install / update / uninstall / --pc-keyboard
bin/omarchy-macos-check    # collision check (bash wrapper around lua)
hypr/
  init.lua                 # entry: loads keymap, applies unbinds then binds
  keymap.lua               # DATA ONLY: claims, forwards, actions, expected displacements
  send.lua                 # key forwarding (down/up pattern, terminal branch)
  actions.lua              # quit-app, delete-to-line-start, etc.
check/collect.lua          # sandbox that evaluates Omarchy binding files with stubs
hooks/post-update.hook     # calls bin/omarchy-macos-check --notify
```

`keymap.lua` returns plain tables. For example `forward = { { "SUPER", "A" }, ... }` is expanded from the A-Z list minus the reserved letters (Q, M). Other entries are `{ keys = "CTRL + ALT + T", action = "float_toggle" }`, and `displaces = { "SUPER + F", ... }` lists the Omarchy keys we expect to take over.

The bindings are generated from this table, which makes the v1 coverage goal checkable by reading one file. *Alternative considered:* hand-written `o.bind` lines. That would be about 150 lines that drift out of sync with the check.

### D2. Injected block and load order

The installer adds two marked regions to `hyprland.lua`:

```lua
-- >>> omarchy-macos-shortcuts (pre)
if omarchy_preinstalled_bindings == nil then omarchy_preinstalled_bindings = false end
-- <<< omarchy-macos-shortcuts (pre)
require("default.hypr.omarchy")
-- >>> omarchy-macos-shortcuts
require("default.hypr.require_optional").module("hypr.macos.init")
-- <<< omarchy-macos-shortcuts
require("hypr.monitors") ... require("hypr.bindings")
```

The pre block only sets the launcher flag if the user hasn't set it already. The module loads right after Omarchy's defaults and before the user's `hypr.bindings`, so user overrides still win.

`require_optional` turns a missing or deleted clone into a no-op, which satisfies the "missing module" requirement. We require `hypr.macos.init` because `package.path` has no `?/init.lua`. Modules under `hypr.` are already reloaded by `bootstrap.lua`.

*Alternative considered:* a separate `~/.config/hypr/macos.lua` shim. It adds one more file to manage and gives no benefit.

If the anchor line `require("default.hypr.omarchy")` can't be found, because the user has restructured `hyprland.lua`, the installer stops with instructions instead of guessing where to insert.

### D3. Key forwarding

`send.lua` re-implements Omarchy's pattern:

```
bind  SUPER + A  (repeating = true)
        |
        v
  is active window tagged "terminal"?
     no  --> send_key_state {mods=CTRL,       key=A, down} ... 50ms ... up
     yes --> send_key_state {mods=CTRL SHIFT, key=A, down} ... 50ms ... up
             (C -> CTRL+Insert, V -> SHIFT+Insert, as Omarchy does)
```

We send explicit `mods` to the focused surface, so the physically held SUPER doesn't merge into the injected chord. The comment in clipboard.lua says a virtual keyboard (wtype) fails for exactly this reason. Repeat comes from the bind's `repeating = true` flag, and each repeat runs the same down/up pair. That's why the "held shortcuts" requirement has a dedicated test task.

*Alternatives considered:*
- `hl.dsp.send_shortcut`. It has the stuck-key bug.
- keyd or kanata. They need root, and they're out of scope for v1.

### D4. Text navigation

These keys forward the same way as D3, using the target keys from the `text-navigation` spec:
- Cmd+Backspace is two sends: Shift+Home, then BackSpace. In terminals it sends Ctrl+U.
- In terminals, Opt+Left/Right send Alt+B and Alt+F (readline word jump).

Plain ALT+Left/Right have no Omarchy binding today. ALT+TAB is left alone.

### D5. Window actions

These use Hyprland dispatchers through `hl.dsp`, the same calls Omarchy uses in `tiling.lua`:
- workspaces: `focus({workspace})` and `window.move({workspace})`
- full screen: `window.fullscreen`
- minimize: `window.move({workspace="special:scratchpad"})`, plus `workspace.toggle_special`
- float, split, pseudo, group: the existing calls

**Cmd+Q** has no single dispatcher. `actions.lua` reads the active window's class, lists clients with `hyprctl clients -j`, and closes each window of that class. It closes them, which lets the app prompt about unsaved work. It does not kill them.

**Force quit (Cmd+Opt+Escape)** kills the active window's PID.

**Screenshots** call `omarchy-capture-screenshot`, `omarchy-capture-region` and Omarchy's capture menu. Their exact arguments are confirmed during implementation from `--help`.

**Lock** calls `omarchy-system-lock`.

### D6. Unbinding

`init.lua` calls `hl.unbind(key)` for every key in `displaces`, and before every key it binds, before binding. Unbinding a key that is already unbound is harmless. This means Omarchy can't end up with two bindings on one key.

The cost is that a *new* Omarchy binding on a claimed key would be silently replaced. That is exactly what the collision check (D8) reports.

### D7. Installer

`install.sh` is POSIX-ish bash with `set -euo pipefail`. It works in two modes:
- Piped from curl: it clones, or `git pull --ff-only`s, the repo into `~/.local/share/omarchy-macos-shortcuts` and re-execs itself from the clone. Every run therefore uses the matching version of the module.
- Run from the clone: it continues with the steps below.

Steps:
1. Preflight: `omarchy version` exists, `hyprland.lua` contains the anchor line, and `git`, `hyprctl` and `lua` are available.
2. Back up `hyprland.lua` to `hyprland.lua.macos-backup`.
3. Symlink `~/.config/hypr/macos`, pointing at `<clone>/hypr`. An existing non-symlink path is an error.
4. Insert or refresh the marked blocks with a small awk script that removes then re-inserts them, so the result is the same however many times it runs.
5. Copy the hook to `post-update.d/omarchy-macos-shortcuts.hook`.
6. Run `hyprctl reload`, then `hyprctl configerrors`. On errors, restore the backup, reload, print the errors and exit 1.

`uninstall`:
1. Remove the blocks.
2. Reload.
3. Remove the hook and the symlink.
4. Optionally remove the clone, asking first.

### D8. Collision check

`check/collect.lua` runs under the system `lua`. It sets `package.path` the same way `bootstrap.lua` does and stubs `hl`: every `hl.dsp.*` call returns a placeholder, and `hl.unbind` and `hl.get_active_window` do nothing. It defines `o.bind`, which records `(keys, description)`.

It then loads Omarchy's binding files with `omarchy_preinstalled_bindings = false`. That gives the true default set, including loop-generated bindings, without reading Hyprland's live state, which already has our overlay applied.

The check compares that set against `keymap.lua`:
- **Collision:** a default binding whose keys we claim but which isn't listed in `displaces`.
- **Stale entry:** a key listed in `displaces` that Omarchy no longer binds. This is reported as info only.

The check also verifies that the marked block and symlink exist. With `--notify` (used by the hook), problems go to `notify-send` and a clean run stays silent.

*Alternative considered:* regex-parsing the `.lua` files. It misses the loop-generated workspace bindings.

### D9. PC keyboard swap

`--pc-keyboard` adds `macos_pc_keyboard = true` to the pre block. `init.lua` then re-applies `hl.config({ input = { kb_options = <omarchy options> .. ",altwin:swap_alt_win" } })`.

`init.lua` reads Omarchy's current option string with `hl.get_config("input.kb_options")`, which Omarchy itself uses for `cursor.zoom_factor`. It appends the swap only if it isn't already there. Nothing is rebuilt, so the string can't drift from Omarchy's. Nothing in `input.lua` changes, and uninstall removes the flag along with the block. The check verifies that the live `input:kb_options` contains the swap whenever the flag is set.

### D10. Natural scrolling

`init.lua` calls `hl.config({ input = { natural_scroll = true, touchpad = { natural_scroll = true } } })`. Omarchy's default (`default/hypr/input.lua`) sets `touchpad.natural_scroll = false` and leaves the mouse at Hyprland's default, `false`. Our module loads after Omarchy's defaults and before the user's `hypr.input` (D2), so:
- it overrides Omarchy's default;
- a `natural_scroll` value in the user's own `input.lua` still wins;
- uninstall removes the module, and the next reload falls back to Omarchy and user values.

Nothing in `input.lua` is edited. The setting lives in `keymap.lua` as an `input` table, so it's documented next to the shortcuts.

*Alternative considered:* per-device rules (`hl.device`) to apply it to mice only. That's unnecessary, because macOS applies one direction to both, and the user asked for the macOS default.

## Risks / Trade-offs

- **[Risk] Mouse users who don't expect it find the wheel suddenly reversed.** → The README and the installer's closing message both say how to turn it off in `input.lua`.

- **[Risk] Omarchy renames or moves bindings between releases.** → D6 overrides them anyway. D8 reports the new collisions after each `omarchy update`.
- **[Risk] The stuck-key and repeat behaviour of `send_key_state` under held keys isn't proven for every letter.** → A dedicated test task holds Cmd+Z, then types plain text, then repeats this in a terminal. If repeat misbehaves, repeat is turned off for that key and the limitation is documented. Repeat isn't worth stuck keys.
- **[Risk] Ctrl+Left/Right and Ctrl+digit now switch workspaces, so apps that use them (word jump in Linux-native apps, tab N in some apps) lose them.** → This is intended Mac behaviour. Opt+arrows provide word jump instead (text-navigation spec).
- **[Risk] Cmd+W now closes a tab (Ctrl+W), not the window. Terminals without tabs, such as Alacritty, ignore Ctrl+Shift+W.** → Cmd+Q still closes the app. Documented in the README.
- **[Risk] A user's own `kb_options` in `input.lua` loads after the module and drops the swap.** → It only matters with `--pc-keyboard`. The check reports when the flag is set but the live option lacks `altwin:swap_alt_win`.
- **[Decision during implementation] Rollback on a broken update.** If the module brought by an update fails to load, restoring the previous `hyprland.lua` isn't enough, because it already loads the module. The installer then also removes its blocks, so Omarchy's defaults load cleanly. See the installation spec.
- **[Decision during implementation] Extra relocations.** Super+Backspace (transparency) moves to Ctrl+Opt+Backspace and Super+Ctrl+F (tiled full screen) moves to Ctrl+Opt+F, because Cmd+Backspace and Cmd+Ctrl+F are now claimed. Super+Ctrl+Q (calculator) has no new home; the XF86Calculator key still works. Delete-to-line-start is a two-step key sequence in `keymap.lua`, not a function in `actions.lua`.
- **[Trade-off] `curl | bash` runs whatever `main` holds.** → The script stays short, and the README links to it and documents the clone-and-inspect path.
- **[Trade-off] Turning off preinstalled launcher bindings removes about 20 shortcuts some users rely on.** → Users can set `omarchy_preinstalled_bindings = true` in their own `hyprland.lua`, which the pre block respects. The ungated SUPER+SHIFT+B/F/N are always unbound, because they are Cmd+Shift app keys.

## Migration Plan

There's no existing installation to migrate.

- **Rollout:** publish to `main`, with the curl line in the README.
- **Rollback for a user:** `~/.local/share/omarchy-macos-shortcuts/install.sh uninstall`, or delete the marked blocks by hand and run `hyprctl reload`. `hyprland.lua.macos-backup` keeps the pre-install file.

## Open Questions

- The exact arguments for full-screen versus region capture in `omarchy-capture-screenshot` and `omarchy-capture-region`, and the name of the capture-menu command. Confirm from `--help` during implementation. This doesn't change the specs.
- Whether `hl.unbind` accepts the same key-string format as `o.bind` for mouse bindings. Not needed in v1, because no mouse binding is claimed.
