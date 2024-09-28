local utils = require(".utils")
local dye = require("items.dye")
local export = {}

local chests = require(".chests").glass
export.colors = utils.allColors
export.name = "Stained Glass"
export.requiresDye = true

function export.calculateAvailable(color, list, dyeList)
  local totals = utils.getCounts(chests, list)

  local dyeName = "minecraft:" .. color .. "_dye"
  totals[dyeName] = dye.calculateAvailable(color, dyeList)

  local count = utils.calculateAvailableInRecipe(totals, {
    [dyeName] = 1,
    ["minecraft:glass"] = 8,
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
  local function moveGlass(name, needed, to, slot)
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
        moved = moved + utils.getCraftingChest().pushItems(utils.localName, s, math.min(64, (needed / 8) - moved), utils.slotMap[5])
      end
    end

    for i = 1, 4 do
      moveGlass("minecraft:glass", math.min(math.ceil(needed / 8), 64), utils.localName, utils.slotMap[i])
    end

    for i = 1, 4 do
      moveGlass("minecraft:glass", math.min(math.ceil(needed / 8), 64), utils.localName, utils.slotMap[i + 5])
    end

    turtle.craft()
    for i = 1, 16 do
      local detail = turtle.getItemDetail(i)
      if detail and detail.name == "minecraft:" .. color .. "_stained_glass" then
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
  return "minecraft:" .. color .. "_stained_glass"
end

return export
