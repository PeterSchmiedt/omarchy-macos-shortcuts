-- omarchy-macos-shortcuts: macOS-style shortcuts on top of Omarchy's defaults.
--
-- Loaded from ~/.config/hypr/hyprland.lua right after require("default.hypr.omarchy")
-- and before the user's own hypr.bindings, so Omarchy's defaults are overridden
-- but the user's personal bindings still win. See hypr/keymap.lua for the map.

local keymap = require("hypr.macos.keymap")
local send = require("hypr.macos.send")
local actions = require("hypr.macos.actions")

local function description(text)
  return "Mac: " .. text
end

local function shell(script)
  return "bash -c " .. o.shell_quote(script)
end

-- Unbind every key we claim, plus the Omarchy defaults we displace without
-- rebinding (Super+1..0 and friends), once, before binding anything. Keys that
-- need two dispatchers (Cmd+Tab) are bound twice, so unbinding per bind would
-- undo the first one.
for _, keys in ipairs(keymap.claimed_keys()) do
  hl.unbind(keys)
end
for keys in pairs(keymap.displaces) do
  hl.unbind(keys)
end

-- Cmd+letter and Cmd+Shift+letter go to the app.
for _, letter in ipairs(keymap.forward_letters) do
  local terminal = keymap.terminal_overrides[letter] or { mods = "CTRL SHIFT", key = letter }

  o.bind(
    "SUPER + " .. letter,
    description("Cmd+" .. letter .. " -> Ctrl+" .. letter),
    send.forward({ mods = "CTRL", key = letter }, terminal),
    { repeating = true }
  )
  o.bind(
    "SUPER + SHIFT + " .. letter,
    description("Cmd+Shift+" .. letter .. " -> Ctrl+Shift+" .. letter),
    send.forward({ mods = "CTRL SHIFT", key = letter }),
    { repeating = true }
  )
end

for _, entry in ipairs(keymap.zoom) do
  o.bind(entry.keys, description(entry.description), send.forward(entry.send), { repeating = true })
end

for _, entry in ipairs(keymap.text) do
  o.bind(entry.keys, description(entry.description), send.forward(entry.send, entry.terminal), { repeating = true })
end

local handlers = {
  workspace = function(arg)
    return hl.dsp.focus({ workspace = arg })
  end,
  quit_app = function()
    return shell(actions.quit_app)
  end,
  force_quit = function()
    return shell(actions.force_quit)
  end,
  fullscreen = function()
    return hl.dsp.window.fullscreen({ mode = "fullscreen" })
  end,
  minimize = function()
    return hl.dsp.window.move({ workspace = "special:scratchpad", follow = false })
  end,
  scratchpad = function()
    return hl.dsp.workspace.toggle_special("scratchpad")
  end,
  exec = function(arg)
    return arg
  end,
  focus = function(arg)
    return hl.dsp.focus({ direction = arg })
  end,
  swap = function(arg)
    return hl.dsp.window.swap({ direction = arg })
  end,
  float = function()
    return hl.dsp.window.float({ action = "toggle" })
  end,
  split = function()
    return hl.dsp.layout("togglesplit")
  end,
  group = function()
    return hl.dsp.group.toggle()
  end,
  pseudo = function()
    return hl.dsp.window.pseudo()
  end,
  resize = function(arg)
    return hl.dsp.window.resize({ x = arg, y = 0, relative = true })
  end,
}

for _, entry in ipairs(keymap.actions) do
  if entry.action == "cycle" then
    -- Same pair Omarchy uses for ALT+TAB: focus the next window, then raise it.
    o.bind(entry.keys, description(entry.description), hl.dsp.window.cycle_next({ next = entry.arg }))
    o.bind(entry.keys, description("Raise window"), hl.dsp.window.bring_to_top())
  else
    o.bind(entry.keys, description(entry.description), handlers[entry.action](entry.arg))
  end
end

-- Ctrl+1..0 switch workspace, Ctrl+Shift+1..0 move the focused window there.
for workspace = 1, keymap.workspace_count do
  local code = "code:" .. tostring(workspace + 9)
  o.bind("CTRL + " .. code, description("Switch to workspace " .. workspace), hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind(
    "CTRL + SHIFT + " .. code,
    description("Move window to workspace " .. workspace),
    hl.dsp.window.move({ workspace = tostring(workspace) })
  )
end

-- Natural scrolling, and the optional Alt/Win swap for PC keyboards.
local input = {
  natural_scroll = keymap.input.natural_scroll,
  touchpad = keymap.input.touchpad,
}

if _G.macos_pc_keyboard == true then
  local options = hl.get_config("input.kb_options") or ""
  if not options:find(keymap.pc_keyboard_option, 1, true) then
    input.kb_options = options == "" and keymap.pc_keyboard_option or (options .. "," .. keymap.pc_keyboard_option)
  end
end

hl.config({ input = input })
