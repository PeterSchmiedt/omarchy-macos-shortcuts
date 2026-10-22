# Spec Delta

## Purpose

Lets any Omarchy user install, update and remove the macOS shortcuts with a single command, without root access and without modifying Omarchy's packaged files.

## ADDED Requirements

### Requirement: One-line install
Running the published one-line command (`curl -fsSL <install-url> | bash`) on an Omarchy system SHALL install the shortcuts and make them active in the running Hyprland session without logging out.

#### Scenario: Fresh install
- **WHEN** a user who has never installed the shortcuts runs the one-line command
- **THEN** the command exits successfully and Cmd+A selects all in the focused app immediately afterwards

### Requirement: No privileged or packaged changes
Installation, update and uninstall SHALL NOT require sudo. They SHALL NOT write under `/usr`, `/etc` or any other path outside the user's home directory.

#### Scenario: Install without sudo
- **WHEN** the installer runs as a normal user
- **THEN** it never prompts for a password and no file outside the user's home directory changes

### Requirement: Preflight checks
Before changing anything, the installer SHALL verify that it is running on Omarchy with the Lua Hyprland configuration and that `git` and `hyprctl` are available. If any check fails, it SHALL exit with a clear message and change nothing.

#### Scenario: Not an Omarchy system
- **WHEN** the installer runs on a system without Omarchy
- **THEN** it exits non-zero, explains why, and leaves the system unchanged

### Requirement: Idempotent install and update
Running the installer again SHALL update the installed copy to the latest published version. It SHALL leave exactly one marked config block and SHALL restore the block if it is missing.

#### Scenario: Second run
- **WHEN** the installer runs twice in a row
- **THEN** `~/.config/hypr/hyprland.lua` contains exactly one marked block

#### Scenario: Block removed by refresh
- **WHEN** the user ran `omarchy refresh hyprland` after installing, and then runs the installer again
- **THEN** the marked block is restored and the shortcuts work again

### Requirement: User overrides win
The user's own `~/.config/hypr/bindings.lua` SHALL take precedence over this module. A key the user binds there SHALL keep the user's binding.

#### Scenario: User rebinds a claimed key
- **WHEN** the user's `bindings.lua` unbinds Cmd+M and binds it to their own command
- **THEN** pressing Cmd+M runs the user's command

### Requirement: Validation and rollback
After changing configuration, the installer SHALL reload Hyprland and check for config errors. If errors are reported, it SHALL restore the previous configuration, reload again, and exit non-zero with the errors shown.

#### Scenario: Config error rolls back
- **WHEN** the reload after install reports a config error
- **THEN** `~/.config/hypr/hyprland.lua` matches its pre-install content and the installer exits non-zero

#### Scenario: Broken update unloads the module
- **WHEN** an update brings a module version that fails to load, and the restored previous configuration still reports errors
- **THEN** the installer removes its marked blocks so Hyprland loads with Omarchy's defaults, says so, and exits non-zero

### Requirement: Clean uninstall
Uninstall SHALL remove everything the installer added: the marked blocks (including the PC-keyboard flag), the symlink and the hook. It SHALL reload Hyprland so Omarchy's default bindings are restored. It SHALL remove the marked block before removing the module, so the config never points at a missing module.

#### Scenario: Uninstall restores defaults
- **WHEN** the user runs uninstall
- **THEN** Super+F toggles full screen again and no marked block, symlink or hook from this project remains

### Requirement: Missing module does not break Hyprland
If the installed module is missing, the Hyprland configuration SHALL still load without errors and Omarchy's defaults SHALL apply. This covers the clone being deleted without running uninstall.

#### Scenario: Clone deleted
- **WHEN** the user deletes `~/.local/share/omarchy-macos-shortcuts` and reloads Hyprland
- **THEN** `hyprctl configerrors` reports no errors related to this module

### Requirement: Optional PC keyboard swap
With the `--pc-keyboard` flag, the installer SHALL swap the Alt and Win keys so the key next to the space bar acts as Cmd. Omarchy's existing keyboard options SHALL be kept. Without the flag, no keyboard option SHALL be changed.

#### Scenario: PC keyboard install
- **WHEN** the installer runs with `--pc-keyboard`
- **THEN** pressing physical Alt+A selects all, and Omarchy's compose key still works

#### Scenario: Default install
- **WHEN** the installer runs without the flag
- **THEN** the keyboard options are identical to before installation
