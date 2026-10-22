# Spec Delta

## Purpose

Makes scrolling on Omarchy move content in the same direction as on macOS, where content follows the fingers, for both mouse wheels and touchpads.

## ADDED Requirements

### Requirement: Natural scrolling for mouse wheels
While the module is installed, scrolling a mouse wheel SHALL scroll content in the macOS natural direction. Rolling the wheel toward the user SHALL move the content up, revealing what is further down.

#### Scenario: Wheel scroll in a browser
- **WHEN** a long web page is open and the user rolls the mouse wheel toward themselves
- **THEN** the page content moves up and later content comes into view, the same as the default macOS setting

### Requirement: Natural scrolling for touchpads
While the module is installed, a two-finger touchpad swipe SHALL scroll content in the same direction as the fingers move.

#### Scenario: Two-finger swipe up
- **WHEN** the user swipes two fingers upward on the touchpad over a long page
- **THEN** the content moves up with the fingers

### Requirement: User can opt out
A scroll direction the user sets in `~/.config/hypr/input.lua` SHALL take precedence over this module's setting.

#### Scenario: User prefers traditional scrolling
- **WHEN** the user sets `natural_scroll = false` for the mouse in their `input.lua` and reloads Hyprland
- **THEN** the mouse wheel scrolls in the traditional direction and the rest of the module keeps working

### Requirement: Uninstall restores the previous direction
After uninstall, the scroll direction SHALL return to whatever Omarchy's defaults and the user's own configuration specify.

#### Scenario: Uninstall
- **WHEN** the module is uninstalled on a system where neither Omarchy nor the user enabled natural scrolling
- **THEN** both the mouse wheel and the touchpad scroll in the traditional direction again
