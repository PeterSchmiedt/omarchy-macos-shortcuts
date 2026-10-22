-- Canonical form of a Hyprland key string, so "SUPER + SHIFT + ALT + B" and
-- "SUPER + ALT + SHIFT + b" compare equal: modifiers upper-cased and sorted,
-- then the key upper-cased.
return function(keys)
  local mods, key = {}, nil
  for raw in keys:gmatch("[^+]+") do
    local upper = raw:match("^%s*(.-)%s*$"):upper()
    if upper == "SUPER" or upper == "SHIFT" or upper == "CTRL" or upper == "ALT" then
      table.insert(mods, upper)
    else
      key = upper
    end
  end
  table.sort(mods)
  table.insert(mods, key or "")
  return table.concat(mods, " + ")
end
