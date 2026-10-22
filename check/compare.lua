-- Compare Omarchy's default bindings (from collect.lua, on stdin) with the keys
-- our keymap claims.
--
-- Usage: lua check/collect.lua <omarchy_path> | lua check/compare.lua <repo_dir>
-- Output lines:
--   COLLISION\t<keys>\t<omarchy description>  Omarchy binds a key we claim and
--                                            keymap.displaces doesn't expect it
--   STALE\t<keys>\t<where it went>            keymap.displaces lists a key that
--                                            Omarchy no longer binds
-- Exits 1 when there is at least one collision.

local repo = arg[1] or "."
package.path = repo .. "/check/?.lua;" .. package.path

local normalize = require("normalize")
local keymap = dofile(repo .. "/hypr/keymap.lua")

local claimed = {}
for _, keys in ipairs(keymap.claimed_keys()) do
  claimed[normalize(keys)] = keys
end

local displaced = {}
for keys, destination in pairs(keymap.displaces) do
  displaced[normalize(keys)] = destination
end

local defaults = {}
for line in io.lines() do
  local keys, description = line:match("^(.-)\t(.*)$")
  if keys then
    defaults[keys] = defaults[keys] or description
  end
end

local collisions = 0
local sorted = {}
for keys in pairs(defaults) do
  table.insert(sorted, keys)
end
table.sort(sorted)

for _, keys in ipairs(sorted) do
  if claimed[keys] and not displaced[keys] then
    print("COLLISION\t" .. keys .. "\t" .. defaults[keys])
    collisions = collisions + 1
  end
end

local stale = {}
for keys in pairs(displaced) do
  if not defaults[keys] then
    table.insert(stale, keys)
  end
end
table.sort(stale)
for _, keys in ipairs(stale) do
  print("STALE\t" .. keys .. "\t" .. displaced[keys])
end

os.exit(collisions == 0 and 0 or 1)
