-- Send a synthetic key chord to the focused surface.
--
-- Same approach as Omarchy's default/hypr/bindings/clipboard.lua (its helpers
-- are local, so they're re-implemented here): explicit mods, so the physically
-- held SUPER doesn't merge into the injected chord, and a separate down and up
-- event, because Hyprland's send_shortcut can leave keys stuck or repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099

local M = {}

local KEY_UP_DELAY_MS = 50
local STEP_DELAY_MS = 60

local function press(chord)
  hl.dispatch(hl.dsp.send_key_state({ mods = chord.mods, key = chord.key, state = "down" }))

  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = chord.mods, key = chord.key, state = "up" }))
  end, { timeout = KEY_UP_DELAY_MS, type = "oneshot" })
end

-- A chord is { mods, key }; a sequence is a list of chords sent in order.
local function send(chords)
  if chords.key then
    press(chords)
    return
  end

  for index, chord in ipairs(chords) do
    if index == 1 then
      press(chord)
    else
      hl.timer(function()
        press(chord)
      end, { timeout = STEP_DELAY_MS * (index - 1), type = "oneshot" })
    end
  end
end

-- Lean on Omarchy's terminal tag from default/hypr/apps/terminals.lua, so a
-- terminal means the same thing here as in Omarchy. Dynamic tags end in "*".
function M.active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

-- Returns a bind callback that sends `default` normally and `terminal` (when
-- given) while a terminal is focused.
function M.forward(default, terminal)
  return function()
    if terminal and M.active_window_is_terminal() then
      send(terminal)
    else
      send(default)
    end
  end
end

return M
