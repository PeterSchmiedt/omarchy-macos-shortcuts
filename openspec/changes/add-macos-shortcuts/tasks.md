# Tasks

## 1. Scaffolding and keymap

- [x] 1.1 Create the repo layout from design D1 (`install.sh`, `bin/`, `hypr/`, `check/`, `hooks/`, `README.md` stub) and verify with `ls -R` that every path exists
- [x] 1.2 Write `hypr/keymap.lua` as data only:
  - forwarded letters A-Z minus reserved Q and M, for both Cmd and Cmd+Shift
  - zoom keys
  - text-navigation keys
  - window actions per the window-management spec
  - the `displaces` list of Omarchy keys we take over

  Verify that `lua -e 'dofile("hypr/keymap.lua")'` loads without error and that a one-off script prints no duplicate key across tables.

## 2. Key forwarding (app-shortcuts, text-navigation)

- [x] 2.1 Implement `hypr/send.lua`: the down/up `send_key_state` sender with the 50 ms gap and terminal detection via the `terminal` tag. Verify that `hyprctl reload && hyprctl configerrors` is clean with the module loaded by hand.
- [ ] 2.2 Implement `hypr/init.lua` with forwarding only. It unbinds every claimed key, then binds the Cmd and Cmd+Shift letters and the zoom keys from `keymap.lua` with `repeating = true`. Verify by hand in Chromium: Cmd+A selects all, Cmd+F opens find (not full screen), Cmd+Shift+T reopens a tab, Cmd+Equal zooms.
- [ ] 2.3 Add the terminal branch. Cmd+letter sends Ctrl+Shift+letter. Cmd+C and Cmd+V send Ctrl+Insert and Shift+Insert. Verify in the Omarchy terminal: Cmd+C copies a selection while `sleep 10` keeps running, Cmd+V pastes, and the physical Ctrl+C still interrupts.
- [ ] 2.4 Verify held keys. Hold Cmd+Z for 2 s in a text editor and confirm repeated undo. Release it and type `abc`, and confirm plain `abc` appears. Repeat both in a terminal. If repeat leaves stuck keys, turn repeat off for the affected keys and record the limitation in the README.
- [ ] 2.5 Add the text-navigation bindings, including Cmd+Backspace and the terminal variants (Alt+B/F, Ctrl+U). Verify each scenario in `specs/text-navigation/spec.md` by hand in a browser text field and in a shell.

## 3. Window management shortcuts

- [ ] 3.1 Bind workspaces: Ctrl+Left/Right, Ctrl+0-9 and Ctrl+Shift+0-9. Verify switching to and sending a window to workspaces 4 and 5, and that Super+4 no longer switches workspace.
- [ ] 3.2 Implement `hypr/actions.lua`:
  - quit-app, which closes all windows of the focused class
  - force-kill
  - delete-to-line-start

  Verify that Cmd+Q with two browser windows and one terminal open closes both browser windows and leaves the terminal open.
- [ ] 3.3 Bind full screen, minimize and system keys:
  - Cmd+Ctrl+F full screen
  - Cmd+M to the scratchpad, Ctrl+Down to toggle it
  - Cmd+Tab and Cmd+Shift+Tab to cycle
  - Cmd+Space launcher
  - Cmd+Ctrl+Q lock
  - Cmd+Shift+3/4/5 captures, after confirming the capture commands' arguments with `--help`

  Verify each scenario in `specs/window-management-shortcuts/spec.md`.
- [ ] 3.4 Bind the Ctrl+Opt tiling layer: arrows, Shift+arrows, T/J/G/P/O/L, Equal and Minus, Space (Omarchy menu) and Slash (keybindings). Verify each one, and verify that `omarchy menu keybindings --print` lists the new bindings with their descriptions.
- [ ] 3.5 Check the released and kept bindings. Pressing Cmd+Shift+B must not launch a browser, and Super+Return must still open a terminal. Verify with `omarchy menu keybindings --print | grep -E '^SUPER \+ [A-Z] '` that only this module's bindings remain on SUPER+letter.

## 3b. Natural scrolling

- [ ] 3b.1 Add the `input` table to `keymap.lua` and apply it in `init.lua` (design D10). Verify that `hyprctl getoption input:natural_scroll` and `hyprctl getoption input:touchpad:natural_scroll` both report `true`, and that rolling the mouse wheel toward you in a browser reveals later content.
- [x] 3b.2 Verify the override. Set `natural_scroll = false` for the mouse in `~/.config/hypr/input.lua`, reload, and confirm `input:natural_scroll` reports `false` while shortcuts still work. Then revert the test edit.
- [x] 3b.3 Document natural scrolling and how to turn it off in `README.md`, and add the opt-out hint to the installer's closing message. Verify that the README snippet, pasted into `input.lua`, works as written.

## 4. Installer

- [x] 4.1 Implement `install.sh` preflight and bootstrap: Omarchy, anchor line, `git`/`hyprctl`/`lua`, then clone or pull and re-exec from the clone. Verify that it exits non-zero with a clear message in a shell where `OMARCHY_PATH` points to an empty dir, and that nothing under `~/.config` changes.
- [x] 4.2 Implement the backup, the symlink, and insertion of the marked pre and post blocks (design D2) with awk. Verify that two consecutive runs leave exactly one of each block (`grep -c '>>> omarchy-macos-shortcuts'` gives 2) and that the user's `hypr.bindings` require stays after our block.
- [x] 4.3 Implement the reload, `hyprctl configerrors` and rollback. Verify by planting a syntax error in `hypr/init.lua` on a test branch: the installer restores `hyprland.lua`, reloads, prints the error and exits 1.
- [x] 4.4 Implement `install.sh uninstall`: remove the blocks, reload, then remove the hook and symlink, and ask before removing the clone. Verify that Super+F toggles full screen again afterwards, that `hyprctl getoption input:natural_scroll` is back to its pre-install value, and that `diff` against the backup shows only the user's own later edits.
- [x] 4.5 Implement `--pc-keyboard` (design D9). Verify with `hyprctl getoption input:kb_options` that it shows Omarchy's options plus `altwin:swap_alt_win`, and that a default install leaves the value unchanged.
- [x] 4.6 Verify the safety requirements:
  - Move the clone away and run `hyprctl reload`: `hyprctl configerrors` is clean and Omarchy's defaults apply.
  - Run `omarchy refresh hyprland` then the installer, and the block is restored.
  - A user binding on Cmd+M in `bindings.lua` wins.
- [x] 4.7 Write the install, update, uninstall and `--pc-keyboard` sections of `README.md`, including the curl one-liner, a link to `install.sh`, and the inspect-first clone path. Verify that the documented commands run exactly as written on a clean `~/.local/share`.

## 5. Collision check

- [x] 5.1 Implement `check/collect.lua`: stub `hl`, record `o.bind` calls, and load Omarchy's binding files with `omarchy_preinstalled_bindings = false`. Verify that it prints SUPER+1 through SUPER+0 (the loop-generated bindings) and SUPER+F.
- [x] 5.2 Implement `bin/omarchy-macos-check`:
  - report collisions, which are claimed keys not in `displaces`
  - report stale `displaces` entries as info
  - report a missing block or broken symlink
  - report `kb_options` drift when `--pc-keyboard` is on
  - exit non-zero on problems

  Verify against the current Omarchy that it exits 0, and that a temporary extra `o.bind("CTRL + ALT + T", ...)` in a copied defaults dir (via `OMARCHY_PATH`) makes it name the key and exit 1.
- [ ] 5.3 Add `--notify` and `hooks/post-update.hook`, and have the installer copy the hook to `post-update.d/omarchy-macos-shortcuts.hook`. Verify that `omarchy-hook post-update` shows no notification when the system is clean and one notification when a collision is planted. Verify with checksums before and after that no file under `~/.config` changes.
- [x] 5.4 Document the check and the hook in `README.md`, including what to do when Omarchy adds a colliding binding. Verify that the README command runs.

## 6. Integration

- [ ] 6.1 Run end to end on this machine: uninstall any test install, run the published curl one-liner against the pushed `main`, walk through every spec scenario once, then uninstall. Record the results in the change.
- [ ] 6.2 Run `openspec validate add-macos-shortcuts --strict` and fix any reported problems.

## Workflow follow-up

- Archive the change with `/opsx:archive` once the integration run passes and the README is published.
