# Spec Delta

## Purpose

Moves Omarchy's window, workspace and system actions onto the keys a macOS user expects for the same jobs, so the Cmd key is free for application shortcuts while every displaced action stays reachable.

## ADDED Requirements

### Requirement: Workspaces on Ctrl like macOS Spaces
Ctrl+Left and Ctrl+Right SHALL switch to the previous and next workspace. Ctrl+1 through Ctrl+9 and Ctrl+0 SHALL switch to workspaces 1-10. Ctrl+Shift+1 through Ctrl+Shift+9 and Ctrl+Shift+0 SHALL move the focused window to workspaces 1-10.

#### Scenario: Next workspace
- **WHEN** the user is on workspace 2 and presses Ctrl+Right
- **THEN** workspace 3 becomes active

#### Scenario: Jump to a workspace
- **WHEN** the user presses Ctrl+4
- **THEN** workspace 4 becomes active

#### Scenario: Send window to a workspace
- **WHEN** a window is focused and the user presses Ctrl+Shift+5
- **THEN** that window moves to workspace 5

### Requirement: Window and app lifecycle keys
Cmd+Q SHALL close every window that belongs to the focused window's application. Cmd+Opt+Escape SHALL force-kill the focused window's process. Cmd+Ctrl+F SHALL toggle full screen for the focused window.

#### Scenario: Quit an app with several windows
- **WHEN** two browser windows are open and one is focused and the user presses Cmd+Q
- **THEN** both browser windows close and windows of other applications stay open

#### Scenario: Full screen
- **WHEN** a window is focused and the user presses Cmd+Ctrl+F
- **THEN** the window toggles full screen

### Requirement: Minimize maps to the scratchpad
Cmd+M SHALL move the focused window to the scratchpad. Ctrl+Down SHALL show or hide the scratchpad.

#### Scenario: Minimize a window
- **WHEN** a window is focused and the user presses Cmd+M
- **THEN** the window leaves the current workspace and is placed on the scratchpad

#### Scenario: Bring minimized windows back
- **WHEN** the scratchpad holds a window and the user presses Ctrl+Down
- **THEN** the scratchpad is shown over the current workspace

### Requirement: Cmd+Tab cycles windows
Cmd+Tab SHALL focus the next window and raise it. Cmd+Shift+Tab SHALL focus the previous window and raise it. No visual picker is shown.

#### Scenario: Switch to another window
- **WHEN** two windows are open and the user presses Cmd+Tab
- **THEN** focus moves to the other window and it is shown on top

### Requirement: System shortcuts in macOS positions
Cmd+Space SHALL open the application launcher. Cmd+Ctrl+Q SHALL lock the screen. Cmd+Shift+3 SHALL capture the whole screen, Cmd+Shift+4 SHALL capture a selected region, and Cmd+Shift+5 SHALL open the capture menu.

#### Scenario: Launch an app
- **WHEN** the user presses Cmd+Space
- **THEN** the application launcher opens

#### Scenario: Region screenshot
- **WHEN** the user presses Cmd+Shift+4
- **THEN** a region selector appears and the selected area is captured

#### Scenario: Lock
- **WHEN** the user presses Cmd+Ctrl+Q
- **THEN** the screen locks

### Requirement: Tiling actions on the Ctrl+Opt layer
Actions with no macOS equivalent SHALL be reachable with Ctrl+Opt. Arrows SHALL move focus between windows, Shift+arrows SHALL swap the window, and T, J, G, P, O and L SHALL toggle floating, split, grouping, pseudo-tiling, pop-out and layout. Equal and Minus SHALL resize, Space SHALL open the Omarchy menu, and Slash SHALL show the keybindings list.

#### Scenario: Focus window to the left
- **WHEN** two tiled windows are side by side, the right one is focused, and the user presses Ctrl+Opt+Left
- **THEN** focus moves to the left window

#### Scenario: Toggle floating
- **WHEN** a tiled window is focused and the user presses Ctrl+Opt+T
- **THEN** the window becomes floating

#### Scenario: Find a shortcut
- **WHEN** the user presses Ctrl+Opt+Slash
- **THEN** the keybindings list opens and shows the Mac-style bindings

### Requirement: Displaced Omarchy bindings are released
Omarchy default bindings on keys this module claims for app shortcuts or text navigation SHALL be removed. That covers SUPER+letter, SUPER+SHIFT+letter, SUPER+arrows, SUPER+SHIFT+arrows and SUPER+digit. Omarchy's preinstalled application and web-app launcher bindings SHALL be turned off. Bindings on keys this module does not claim SHALL keep working.

#### Scenario: Old full-screen key no longer fires
- **WHEN** a browser is focused and the user presses Cmd+F
- **THEN** the window does not change to full screen

#### Scenario: Launchers are off
- **WHEN** the user presses Cmd+Shift+B
- **THEN** no new browser window is launched by Omarchy and the focused app receives Ctrl+Shift+B

#### Scenario: Unclaimed binding still works
- **WHEN** the user presses Super+Return
- **THEN** a terminal opens, as with Omarchy's default
