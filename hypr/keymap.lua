-- macOS-style keymap for Omarchy. DATA ONLY: hypr/init.lua turns these tables
-- into Hyprland bindings, and bin/omarchy-macos-check reads them to detect
-- collisions with Omarchy's defaults.
--
-- Modifier names follow Hyprland: SUPER is the Mac Cmd key, ALT is Opt.
-- Digits, minus and equal use keycodes (code:10..21) because that's how
-- Omarchy binds them, so unbinding matches exactly.

local M = {}

-- Cmd+letter -> Ctrl+letter, Cmd+Shift+letter -> Ctrl+Shift+letter.
-- Letters missing here (Q, M) are reserved for window actions below.
M.forward_letters = {
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "N",
  "O", "P", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}

-- Terminals get Ctrl+Shift+letter for Cmd+letter, except these, which copy and
-- paste the same way Omarchy's universal clipboard does.
M.terminal_overrides = {
  C = { mods = "CTRL", key = "Insert" },
  V = { mods = "SHIFT", key = "Insert" },
}

-- Cmd+Equal / Cmd+Minus / Cmd+0 -> app zoom.
M.zoom = {
  { keys = "SUPER + code:21", description = "Zoom in", send = { mods = "CTRL", key = "equal" } },
  { keys = "SUPER + code:20", description = "Zoom out", send = { mods = "CTRL", key = "minus" } },
  { keys = "SUPER + code:19", description = "Reset zoom", send = { mods = "CTRL", key = "0" } },
}

-- Mac text navigation. `send` is used in normal windows, `terminal` in
-- terminals; a list of steps is sent in order.
M.text = {
  { keys = "SUPER + LEFT", description = "Line start", send = { mods = "", key = "Home" } },
  { keys = "SUPER + RIGHT", description = "Line end", send = { mods = "", key = "End" } },
  { keys = "SUPER + SHIFT + LEFT", description = "Select to line start", send = { mods = "SHIFT", key = "Home" } },
  { keys = "SUPER + SHIFT + RIGHT", description = "Select to line end", send = { mods = "SHIFT", key = "End" } },
  { keys = "SUPER + UP", description = "Document start", send = { mods = "CTRL", key = "Home" } },
  { keys = "SUPER + DOWN", description = "Document end", send = { mods = "CTRL", key = "End" } },
  { keys = "SUPER + SHIFT + UP", description = "Select to document start", send = { mods = "CTRL SHIFT", key = "Home" } },
  { keys = "SUPER + SHIFT + DOWN", description = "Select to document end", send = { mods = "CTRL SHIFT", key = "End" } },
  {
    keys = "ALT + LEFT",
    description = "Previous word",
    send = { mods = "CTRL", key = "Left" },
    terminal = { mods = "ALT", key = "b" },
  },
  {
    keys = "ALT + RIGHT",
    description = "Next word",
    send = { mods = "CTRL", key = "Right" },
    terminal = { mods = "ALT", key = "f" },
  },
  { keys = "ALT + SHIFT + LEFT", description = "Select previous word", send = { mods = "CTRL SHIFT", key = "Left" } },
  { keys = "ALT + SHIFT + RIGHT", description = "Select next word", send = { mods = "CTRL SHIFT", key = "Right" } },
  {
    keys = "ALT + BACKSPACE",
    description = "Delete previous word",
    send = { mods = "CTRL", key = "BackSpace" },
    terminal = { mods = "ALT", key = "BackSpace" },
  },
  {
    keys = "SUPER + BACKSPACE",
    description = "Delete to line start",
    send = { { mods = "SHIFT", key = "Home" }, { mods = "", key = "BackSpace" } },
    terminal = { mods = "CTRL", key = "u" },
  },
}

-- Window, workspace and system actions. `action` names a handler in
-- hypr/init.lua; `arg` is passed to it.
M.actions = {
  -- Workspaces, like macOS Spaces
  { keys = "CTRL + LEFT", description = "Previous workspace", action = "workspace", arg = "e-1" },
  { keys = "CTRL + RIGHT", description = "Next workspace", action = "workspace", arg = "e+1" },

  -- App and window lifecycle
  { keys = "SUPER + Q", description = "Quit app (all its windows)", action = "quit_app" },
  { keys = "SUPER + ALT + ESCAPE", description = "Force quit", action = "force_quit" },
  { keys = "SUPER + CTRL + F", description = "Full screen", action = "fullscreen" },
  { keys = "SUPER + M", description = "Minimize to scratchpad", action = "minimize" },
  { keys = "CTRL + DOWN", description = "Show scratchpad", action = "scratchpad" },
  { keys = "SUPER + TAB", description = "Next window", action = "cycle", arg = true },
  { keys = "SUPER + SHIFT + TAB", description = "Previous window", action = "cycle", arg = false },

  -- System
  { keys = "SUPER + SPACE", description = "App launcher", action = "exec", arg = "omarchy-menu toggle apps" },
  { keys = "SUPER + CTRL + Q", description = "Lock screen", action = "exec", arg = "omarchy-system-lock" },
  { keys = "SUPER + SHIFT + code:12", description = "Screenshot (full screen)", action = "exec", arg = "omarchy-capture-screenshot fullscreen" },
  { keys = "SUPER + SHIFT + code:13", description = "Screenshot (region)", action = "exec", arg = "omarchy-capture-screenshot region" },
  { keys = "SUPER + SHIFT + code:14", description = "Capture menu", action = "exec", arg = "omarchy-menu toggle capture" },

  -- Ctrl+Opt tiling layer (no macOS equivalent; Rectangle-style)
  { keys = "CTRL + ALT + LEFT", description = "Focus left window", action = "focus", arg = "l" },
  { keys = "CTRL + ALT + RIGHT", description = "Focus right window", action = "focus", arg = "r" },
  { keys = "CTRL + ALT + UP", description = "Focus window above", action = "focus", arg = "u" },
  { keys = "CTRL + ALT + DOWN", description = "Focus window below", action = "focus", arg = "d" },
  { keys = "CTRL + ALT + SHIFT + LEFT", description = "Swap window left", action = "swap", arg = "l" },
  { keys = "CTRL + ALT + SHIFT + RIGHT", description = "Swap window right", action = "swap", arg = "r" },
  { keys = "CTRL + ALT + SHIFT + UP", description = "Swap window up", action = "swap", arg = "u" },
  { keys = "CTRL + ALT + SHIFT + DOWN", description = "Swap window down", action = "swap", arg = "d" },
  { keys = "CTRL + ALT + T", description = "Toggle floating", action = "float" },
  { keys = "CTRL + ALT + J", description = "Toggle split", action = "split" },
  { keys = "CTRL + ALT + G", description = "Toggle grouping", action = "group" },
  { keys = "CTRL + ALT + P", description = "Pseudo-tile window", action = "pseudo" },
  { keys = "CTRL + ALT + O", description = "Pop window out", action = "exec", arg = "omarchy-hyprland-window-pop" },
  { keys = "CTRL + ALT + L", description = "Toggle workspace layout", action = "exec", arg = "omarchy-hyprland-workspace-layout-toggle" },
  { keys = "CTRL + ALT + F", description = "Tiled full screen", action = "exec", arg = "omarchy-hyprland-window-tiled-fullscreen-toggle" },
  { keys = "CTRL + ALT + code:20", description = "Expand window left", action = "resize", arg = -100 },
  { keys = "CTRL + ALT + code:21", description = "Shrink window left", action = "resize", arg = 100 },
  { keys = "CTRL + ALT + BACKSPACE", description = "Toggle window transparency", action = "exec", arg = "omarchy-hyprland-window-transparency-toggle" },
  { keys = "CTRL + ALT + SPACE", description = "Omarchy menu", action = "exec", arg = "omarchy-menu toggle" },
  { keys = "CTRL + ALT + SLASH", description = "Keybindings", action = "exec", arg = "omarchy-menu-keybindings" },
}

-- Ctrl+1..0 switch to workspace 1..10, Ctrl+Shift+1..0 move the window there.
M.workspace_count = 10

-- Omarchy default bindings this keymap deliberately takes over, with where the
-- displaced action went. The collision check treats any OTHER Omarchy binding
-- on a key we claim as a collision.
M.displaces = {
  ["SUPER + C"] = "Cmd+C (copy)",
  ["SUPER + V"] = "Cmd+V (paste)",
  ["SUPER + X"] = "Cmd+X (cut)",
  ["SUPER + W"] = "Cmd+W sends Ctrl+W; Cmd+Q quits the app",
  ["SUPER + J"] = "Ctrl+Opt+J",
  ["SUPER + P"] = "Ctrl+Opt+P",
  ["SUPER + T"] = "Ctrl+Opt+T",
  ["SUPER + F"] = "Cmd+Ctrl+F",
  ["SUPER + O"] = "Ctrl+Opt+O",
  ["SUPER + L"] = "Ctrl+Opt+L",
  ["SUPER + S"] = "Ctrl+Down",
  ["SUPER + G"] = "Ctrl+Opt+G",
  ["SUPER + K"] = "Ctrl+Opt+/",
  ["SUPER + SPACE"] = "Ctrl+Opt+Space",
  ["SUPER + BACKSPACE"] = "Ctrl+Opt+Backspace",
  ["SUPER + TAB"] = "Ctrl+Right",
  ["SUPER + SHIFT + TAB"] = "Ctrl+Left",
  ["SUPER + LEFT"] = "Ctrl+Opt+Left",
  ["SUPER + RIGHT"] = "Ctrl+Opt+Right",
  ["SUPER + UP"] = "Ctrl+Opt+Up",
  ["SUPER + DOWN"] = "Ctrl+Opt+Down",
  ["SUPER + SHIFT + LEFT"] = "Ctrl+Opt+Shift+Left",
  ["SUPER + SHIFT + RIGHT"] = "Ctrl+Opt+Shift+Right",
  ["SUPER + SHIFT + UP"] = "Ctrl+Opt+Shift+Up",
  ["SUPER + SHIFT + DOWN"] = "Ctrl+Opt+Shift+Down",
  ["SUPER + code:20"] = "Ctrl+Opt+Minus",
  ["SUPER + code:21"] = "Ctrl+Opt+Equal",
  ["SUPER + CTRL + F"] = "Ctrl+Opt+F",
  ["SUPER + CTRL + Q"] = "Calculator key (XF86Calculator)",
  ["SUPER + SHIFT + B"] = "Cmd+Space launcher",
  ["SUPER + SHIFT + F"] = "Cmd+Space launcher",
  ["SUPER + SHIFT + N"] = "Cmd+Space launcher",
  ["SUPER + code:10"] = "Ctrl+1",
  ["SUPER + code:11"] = "Ctrl+2",
  ["SUPER + code:12"] = "Ctrl+3",
  ["SUPER + code:13"] = "Ctrl+4",
  ["SUPER + code:14"] = "Ctrl+5",
  ["SUPER + code:15"] = "Ctrl+6",
  ["SUPER + code:16"] = "Ctrl+7",
  ["SUPER + code:17"] = "Ctrl+8",
  ["SUPER + code:18"] = "Ctrl+9",
  ["SUPER + code:19"] = "Ctrl+0",
  ["SUPER + SHIFT + code:10"] = "Ctrl+Shift+1",
  ["SUPER + SHIFT + code:11"] = "Ctrl+Shift+2",
  ["SUPER + SHIFT + code:12"] = "Ctrl+Shift+3",
  ["SUPER + SHIFT + code:13"] = "Ctrl+Shift+4",
  ["SUPER + SHIFT + code:14"] = "Ctrl+Shift+5",
  ["SUPER + SHIFT + code:15"] = "Ctrl+Shift+6",
  ["SUPER + SHIFT + code:16"] = "Ctrl+Shift+7",
  ["SUPER + SHIFT + code:17"] = "Ctrl+Shift+8",
  ["SUPER + SHIFT + code:18"] = "Ctrl+Shift+9",
  ["SUPER + SHIFT + code:19"] = "Ctrl+Shift+0",
}

-- Natural (macOS-style) scrolling for mice and touchpads. The user's own
-- ~/.config/hypr/input.lua loads after this and can turn it back off.
M.input = {
  natural_scroll = true,
  touchpad = { natural_scroll = true },
}

-- Added to Omarchy's kb_options when installed with --pc-keyboard.
M.pc_keyboard_option = "altwin:swap_alt_win"

-- Every key this keymap binds, in the order init.lua binds them. Used by
-- init.lua (to unbind before binding) and by the collision check.
function M.claimed_keys()
  local keys = {}
  for _, letter in ipairs(M.forward_letters) do
    table.insert(keys, "SUPER + " .. letter)
    table.insert(keys, "SUPER + SHIFT + " .. letter)
  end
  for _, group in ipairs({ M.zoom, M.text, M.actions }) do
    for _, entry in ipairs(group) do
      table.insert(keys, entry.keys)
    end
  end
  for workspace = 1, M.workspace_count do
    local code = "code:" .. tostring(workspace + 9)
    table.insert(keys, "CTRL + " .. code)
    table.insert(keys, "CTRL + SHIFT + " .. code)
  end
  return keys
end

return M
