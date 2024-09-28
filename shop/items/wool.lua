local utils = require(".utils")
local export = {}
local chests = require(".chests").wool
export.colors = utils.allColors
export.name = "Wool"

function export.calculateAvailable(color, list)
  local totals = utils.getCounts(chests, list)
  local count = totals["minecraft:" .. color .. "_wool"] or 0

  return count
end

function export.listChest()
  return utils.getCounts(chests)
end

function export.calculateCostPerStack(color)
  return 0
end

function export.craft(color, needed)
  local available = export.calculateAvailable(color)
  local name = "minecraft:" .. color .. "_wool"

  local function moveItem(name, needed, to, slot)
    for i, v in pairs(chests) do
      local list = utils.callChest(v, "list")
      local moved = 0
      for s, i in pairs(list) do
        if moved >= needed then break end
        if i.name == name then
          moved = moved + utils.callChest(v, "pushItems", to, s, math.min(64, needed - moved), slot)
        end
      end
      if moved >= needed then break end
    end

    return needed
  end

  if available < needed then
    return false
  end

  moveItem(name, needed, utils.getCraftingChestName())

  return true
end

function export.getName(color)
  return "minecraft:" .. color .. "_wool"
end

export.costs = costs

return export
