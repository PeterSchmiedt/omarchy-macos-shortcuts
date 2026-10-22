# Spec Delta

## Purpose

Warns the user when Omarchy updates or config resets interfere with the installed macOS shortcuts, so a broken or shadowed shortcut is reported instead of failing silently.

## ADDED Requirements

### Requirement: On-demand check
The project SHALL provide a check command. It SHALL list every key this module claims that Omarchy's current default bindings also use for a different action, and it SHALL exit non-zero when it finds any.

#### Scenario: No collisions
- **WHEN** Omarchy's defaults use none of the claimed keys and the user runs the check
- **THEN** it reports that no collisions were found and exits zero

#### Scenario: Omarchy adds a binding on a claimed key
- **WHEN** an Omarchy update adds a default binding on Ctrl+Opt+T and the user runs the check
- **THEN** the check names Ctrl+Opt+T, Omarchy's action for it, and this module's action, and exits non-zero

### Requirement: Detect a missing config block
The check SHALL report when the marked block is missing from `~/.config/hypr/hyprland.lua` or the module link is broken, and SHALL tell the user how to restore it.

#### Scenario: Block removed
- **WHEN** the marked block has been removed and the user runs the check
- **THEN** the check says the shortcuts are not loaded and shows the command that restores them

### Requirement: Runs after Omarchy updates
Installation SHALL register the check as an Omarchy post-update hook. After each `omarchy update`, any problem found SHALL appear as a desktop notification, and a clean result SHALL produce no notification.

#### Scenario: Update introduces a collision
- **WHEN** `omarchy update` finishes and the check finds a collision
- **THEN** the user receives a desktop notification that names the colliding keys

#### Scenario: Clean update
- **WHEN** `omarchy update` finishes and the check finds nothing
- **THEN** no notification is shown

### Requirement: Check never changes configuration
The check and its hook SHALL only read configuration. They SHALL NOT modify any file or binding.

#### Scenario: Read-only check
- **WHEN** the check runs and finds collisions
- **THEN** every file under `~/.config` is byte-for-byte unchanged afterwards
