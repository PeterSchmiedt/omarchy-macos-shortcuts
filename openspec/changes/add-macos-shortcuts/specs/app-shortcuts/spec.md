# Spec Delta

## Purpose

Lets a macOS user press Cmd-based app shortcuts on Omarchy and have the focused application perform the same action it would perform for the equivalent Linux Ctrl shortcut.

## ADDED Requirements

### Requirement: Cmd+letter reaches the app as Ctrl+letter
When a non-terminal window is focused, pressing Cmd+<letter> SHALL deliver Ctrl+<letter> to that window, for every letter A-Z except letters this module assigns to a window-management action.

#### Scenario: Select all in a browser
- **WHEN** a browser window is focused and the user presses Cmd+A
- **THEN** the browser receives Ctrl+A and selects all content

#### Scenario: Find in an editor
- **WHEN** a text editor is focused and the user presses Cmd+F
- **THEN** the editor receives Ctrl+F and opens its find bar, and the window does not go full screen

#### Scenario: Reserved letter is not forwarded
- **WHEN** any window is focused and the user presses Cmd+M
- **THEN** the window-management action for Cmd+M runs and the window receives no Ctrl+M

### Requirement: Cmd+Shift+letter reaches the app as Ctrl+Shift+letter
When a non-terminal window is focused, pressing Cmd+Shift+<letter> SHALL deliver Ctrl+Shift+<letter> to that window, for every letter A-Z except letters this module assigns to a window-management action.

#### Scenario: Reopen closed tab
- **WHEN** a browser is focused and the user presses Cmd+Shift+T
- **THEN** the browser receives Ctrl+Shift+T and reopens the last closed tab

#### Scenario: Redo
- **WHEN** a text editor is focused and the user presses Cmd+Shift+Z
- **THEN** the editor receives Ctrl+Shift+Z

### Requirement: Terminals receive terminal-safe shortcuts
When a terminal window is focused, Cmd+<letter> SHALL deliver Ctrl+Shift+<letter>, except Cmd+C and Cmd+V, which SHALL copy and paste the same way Omarchy's universal clipboard shortcuts do in terminals, and Cmd+W, which is covered below. The physical Ctrl key SHALL keep its normal terminal meaning.

#### Scenario: Copy in a terminal does not interrupt
- **WHEN** a terminal is focused, text is selected, and the user presses Cmd+C
- **THEN** the selection is copied to the clipboard and no interrupt signal is sent to the running program

#### Scenario: New terminal tab
- **WHEN** a terminal is focused and the user presses Cmd+T
- **THEN** the terminal receives Ctrl+Shift+T

#### Scenario: Ctrl+C still interrupts
- **WHEN** a terminal is focused and the user presses the physical Ctrl+C
- **THEN** the terminal receives Ctrl+C unchanged

### Requirement: Cmd+W closes terminal windows
In a terminal without tabs, Cmd+W SHALL close the focused terminal window. In a terminal with tabs, Cmd+W SHALL deliver Ctrl+Shift+W, so the current tab closes and the last tab closes the window. Holding Cmd+W SHALL NOT repeat.

#### Scenario: Close a terminal without tabs
- **WHEN** a foot or Alacritty window is focused and the user presses Cmd+W
- **THEN** that terminal window closes and other windows stay open

#### Scenario: Close a tab in a tabbed terminal
- **WHEN** a kitty or Ghostty window with two tabs is focused and the user presses Cmd+W
- **THEN** the terminal receives Ctrl+Shift+W, the current tab closes, and the window stays open

### Requirement: Zoom keys reach the app
Cmd+Equal, Cmd+Minus and Cmd+0 SHALL deliver Ctrl+Equal, Ctrl+Minus and Ctrl+0 to the focused window, so app zoom works as on macOS.

#### Scenario: Zoom in a browser
- **WHEN** a browser is focused and the user presses Cmd+Equal
- **THEN** the page zooms in and no window is resized

### Requirement: Held shortcuts repeat
Holding Cmd+<letter> or Cmd+Shift+<letter> SHALL repeat the forwarded shortcut at the keyboard's repeat rate and SHALL stop repeating when the key is released, leaving no modifier or key stuck down.

#### Scenario: Repeated undo
- **WHEN** an editor is focused and the user holds Cmd+Z for two seconds
- **THEN** the editor receives repeated Ctrl+Z presses for that duration and none after the key is released

#### Scenario: No stuck modifier
- **WHEN** the user releases Cmd after any forwarded shortcut
- **THEN** the next plain letter typed appears as plain text with no modifier applied
