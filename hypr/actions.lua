-- Window actions that have no single Hyprland dispatcher.

local M = {}

-- Close every window of the focused window's app, like macOS Quit. Windows
-- are closed (not killed) so apps can still ask about unsaved work.
M.quit_app = [[
class=$(hyprctl activewindow -j | jq -r '.class // empty')
[ -n "$class" ] || exit 0
hyprctl clients -j | jq -r --arg class "$class" '.[] | select(.class == $class) | .address' |
  while read -r addr; do
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null
  done
]]

-- Kill the focused window's process, like macOS Force Quit.
M.force_quit = [[
pid=$(hyprctl activewindow -j | jq -r '.pid // empty')
[ -n "$pid" ] && [ "$pid" -gt 0 ] && kill -9 "$pid"
]]

return M
