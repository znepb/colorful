local utils = require(".utils")
local powder = require("items.concretePowder")
local export = {}
local config = require(".config")

export.colors = utils.allColors
export.name = "Concrete"
export.requiresDye = true

function export.calculateAvailable(color, list, list2)
  return powder.calculateAvailable(color, list, list2)
end

function export.listChest()
  return powder.listChest()
end

function export.calculateCostPerStack(color)
  return powder.calculateCostPerStack(color)
end

function export.getName(color)
  return "minecraft:" .. color .. "_concrete"
end

function export.craft(color, needed)
  powder.craft(color, needed)

  local powderName = "minecraft:" .. color .. "_concrete_powder"
  local moved = 0

  repeat
    local list = utils.getCraftingChest().list()

    for s, i in pairs(list) do
      if i.name == powderName then
        utils.getCraftingChest().pushItems(config.concreteCrafter, s, nil, 1)
      end
    end

    moved = moved + utils.getCraftingChest().pullItems(config.concreteCrafter, 2)

    sleep(1)
  until moved >= needed

  return true
end

return export