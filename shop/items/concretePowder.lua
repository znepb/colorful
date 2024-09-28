local utils = require(".utils")
local dye = require("items.dye")
local export = {}

local chests = require(".chests").concretePowder
export.colors = utils.allColors
export.name = "Concrete Powder"
export.requiresDye = true

function export.calculateAvailable(color, list, dyeList)
  local totals = utils.getCounts(chests, list)

  local dyeName = "minecraft:" .. color .. "_dye"
  totals[dyeName] = dye.calculateAvailable(color, dyeList)

  local count = utils.calculateAvailableInRecipe(totals, {
    [dyeName] = 1,
    ["minecraft:sand"] = 4,
    ["minecraft:gravel"] = 4,
    count = 8
  })

  return count
end

function export.listChest()
  return utils.getCounts(chests)
end

function export.calculateCostPerStack(color)
  local dyeCost = dye.calculateCostPerStack(color)

  return dyeCost + 1
end

function export.craft(color, needed)
  local function moveGravelOrSand(name, needed, to, slot)
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
  end

  local success = dye.craft(color, math.ceil(needed / 8))
  if not success then return false end

  repeat
    local list = utils.getCraftingChest().list()
    local moved = 0
    local crafted = 0

    for s, i in pairs(list) do
      if moved >= needed / 8 then break end
      if i.name == "minecraft:" .. color .. "_dye" then
        moved = moved + utils.getCraftingChest().pushItems(utils.localName, s, math.min(64, (needed / 8) - moved), 1)
      end
    end

    for i = 1, 4 do
      moveGravelOrSand("minecraft:sand", math.min(math.ceil(needed / 8), 64), utils.localName, utils.slotMap[i + 1])
    end

    for i = 1, 4 do
      moveGravelOrSand("minecraft:gravel", math.min(math.ceil(needed / 8), 64), utils.localName, utils.slotMap[i + 5])
    end

    turtle.craft()
    for i = 1, 16 do
      local detail = turtle.getItemDetail(i)
      if detail and detail.name == "minecraft:" .. color .. "_concrete_powder" then
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
  return "minecraft:" .. color .. "_concrete_powder"
end

return export
