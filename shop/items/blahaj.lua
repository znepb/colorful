local utils = require(".utils")
local dye = require("items.dye")
local export = {}

local woolChests = require(".chests").wool
export.colors = utils.allColors
export.name = "Blahaj"
export.requiresDye = true

function export.calculateAvailable(color, list, dyeList)
  local totals = utils.getCounts(woolChests, list)

  local dyeName = "minecraft:pink_dye"
  totals[dyeName] = dye.calculateAvailable(color, dyeList)

  local count = utils.calculateAvailableInRecipe(totals, {
    [dyeName] = 1,
    ["minecraft:white_wool"] = 1,
    ["minecraft:" .. color .. "_wool"] = 4,
    count = 1
  })

  return count
end

function export.listChest()
  return utils.getCounts(woolChests)
end

function export.calculateCostPerStack(color)
  local dyeCost = dye.calculateCostPerStack(color)

  return dyeCost + 4
end

function export.craft(color, needed)
  local success = dye.craft("pink", math.ceil(needed))
  if not success then return false end

  repeat
    local list = utils.getCraftingChest().list()
    local moved = 0
    local crafted = 0

    for s, i in pairs(list) do
      if moved >= needed / 8 then break end
      if i.name == "minecraft:" .. color .. "_dye" then
        moved = moved + utils.getCraftingChest().pushItems(utils.localName, s, math.min(64, (needed / 8) - moved), utils.slotMap[5])
      end
    end

    for i = 1, 4 do
      moveGravelOrSand("minecraft:terracotta", math.min(math.ceil(needed / 8), 64), utils.localName, utils.slotMap[i])
    end

    for i = 1, 4 do
      moveGravelOrSand("minecraft:terracotta", math.min(math.ceil(needed / 8), 64), utils.localName, utils.slotMap[i + 5])
    end

    turtle.craft()
    for i = 1, 16 do
      local detail = turtle.getItemDetail(i)
      if detail and detail.name == "minecraft:" .. color .. "_terracotta" then
        crafted = crafted + detail.count
      end
      utils.getCraftingChest().pullItems(utils.localName, i)
    end

    needed = needed - crafted
    sleep(1)
  until needed <= 0

  return true
end

function export.getName(color)
  return "sc-goodies:shark_" .. color
end

return export
