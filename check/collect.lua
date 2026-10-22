-- Evaluate Omarchy's default binding files outside Hyprland and print every
-- binding they define, so the collision check can compare them with our keymap.
--
-- Hyprland's live state already has our overlay applied, so it can't tell us
-- what Omarchy itself binds. Instead we stub the `hl` API, record o.bind calls,
-- and load the same files default/hypr/omarchy.lua loads. Loop-generated
-- bindings (workspaces 1-10) come out exactly as Hyprland would see them.
--
-- Usage: lua check/collect.lua <omarchy_path>
-- Output: one "<normalized keys>\t<description>" line per binding.

local omarchy_path = arg[1] or os.getenv("OMARCHY_PATH") or "/usr/share/omarchy"

local here = arg[0]:match("^(.*)/[^/]*$") or "."
package.path = omarchy_path .. "/?.lua;" .. here .. "/?.lua;" .. package.path

local normalize = require("normalize")

-- Any hl.* or hl.dsp.* lookup returns a callable placeholder.
local function stub()
  return setmetatable({}, {
    __index = function()
      return stub()
    end,
    __call = function()
      return stub()
    end,
  })
end

hl = stub()

-- Match the installed configuration: our pre block turns preinstalled
-- launcher bindings off.
omarchy_preinstalled_bindings = false

require("default.hypr.helpers")

function o.bind(keys, description)
  print(normalize(keys) .. "\t" .. tostring(description or ""))
end

function o.bind_toggle(keys, description)
  o.bind(keys, description)
end

-- Same files, same order, as default/hypr/omarchy.lua.
for _, module in ipairs({
  "default.hypr.bindings.media",
  "default.hypr.bindings.clipboard",
  "default.hypr.bindings.tiling",
  "default.hypr.bindings.utilities",
  "default.hypr.bindings.voxtype",
  "default.hypr.bindings.applications",
}) do
  if package.searchpath(module, package.path) then
    require(module)
  end
end
