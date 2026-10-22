# Spec Delta

## Purpose

Gives macOS users the cursor-movement and deletion shortcuts they expect in text fields and editors, by translating Mac Cmd/Opt navigation keys into their Linux equivalents.

## ADDED Requirements

### Requirement: Line navigation with Cmd+arrows
Cmd+Left and Cmd+Right SHALL deliver Home and End. Cmd+Up and Cmd+Down SHALL deliver Ctrl+Home and Ctrl+End. Adding Shift SHALL deliver the same key with Shift held, so the movement extends the selection.

#### Scenario: Jump to line end
- **WHEN** the cursor is mid-line in a text field and the user presses Cmd+Right
- **THEN** the cursor moves to the end of the line

#### Scenario: Select to start of line
- **WHEN** the cursor is mid-line and the user presses Cmd+Shift+Left
- **THEN** the text from the line start to the cursor is selected

#### Scenario: Jump to document start
- **WHEN** an editor is focused and the user presses Cmd+Up
- **THEN** the editor receives Ctrl+Home

### Requirement: Word navigation with Opt+arrows
Opt+Left and Opt+Right SHALL deliver Ctrl+Left and Ctrl+Right. Opt+Shift+Left and Opt+Shift+Right SHALL deliver Ctrl+Shift+Left and Ctrl+Shift+Right.

#### Scenario: Jump one word
- **WHEN** the cursor is in a text field and the user presses Opt+Left
- **THEN** the cursor moves to the start of the previous word

#### Scenario: Select one word
- **WHEN** the user presses Opt+Shift+Right
- **THEN** the next word is added to the selection

### Requirement: Mac deletion shortcuts
Opt+Backspace SHALL deliver Ctrl+Backspace (delete previous word). Cmd+Backspace SHALL delete from the cursor to the start of the line.

#### Scenario: Delete previous word
- **WHEN** the cursor follows a word and the user presses Opt+Backspace
- **THEN** that word is deleted

#### Scenario: Delete to line start
- **WHEN** the cursor is mid-line and the user presses Cmd+Backspace
- **THEN** the text between the line start and the cursor is deleted

### Requirement: Navigation keys respect terminals
When a terminal window is focused, Cmd+Left/Right SHALL deliver Home/End and Opt+Left/Right SHALL deliver the terminal's word-jump keys (Alt+B and Alt+F), so shell line editing works.

#### Scenario: Shell word jump
- **WHEN** a terminal running a shell is focused and the user presses Opt+Left
- **THEN** the shell cursor moves back one word
