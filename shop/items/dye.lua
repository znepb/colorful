local utils = require(".utils")
local export = {}

local chests = require(".chests").dye
export.colors = utils.allColors
export.name = "Dyes"

local costs = {
  ["minecraft:white_dye"] = 0,
  ["minecraft:black_dye"] = 0.5 / 64,
  ["minecraft:blue_dye"] = 0,
  ["minecraft:red_dye"] = 0,
  ["minecraft:yellow_dye"] = 0,
  ["minecraft:green_dye"] = 0,
  ["minecraft:brown_dye"] = 0,
}

local recipes = {
  ["orange"] = {
    ["minecraft:red_dye"] = 1,
    ["minecraft:yellow_dye"] = 1,
    count = 2
  },
  ["magenta"] = {
    ["minecraft:white_dye"] = 1,
    ["minecraft:blue_dye"] = 1,
    ["minecraft:red_dye"] = 2,
    count = 4
  },
  ["light_blue"] = {
    ["minecraft:blue_dye"] = 1,
    ["minecraft:white_dye"] = 1,
    count = 2
  },
  ["lime"] = {
    ["minecraft:green_dye"] = 1,
    ["minecraft:white_dye"] = 1,
    count = 2
  },
  ["pink"] = {
    ["minecraft:red_dye"] = 1,
    ["minecraft:white_dye"] = 1,
    count = 2
  },
  ["gray"] = {
    ["minecraft:black_dye"] = 1,
    ["minecraft:white_dye"] = 1,
    count = 2
  },
  ["light_gray"] = {
    ["minecraft:black_dye"] = 1,
    ["minecraft:white_dye"] = 2,
    count = 3
  },
  ["cyan"] = {
    ["minecraft:blue_dye"] = 1,
    ["minecraft:green_dye"] = 1,
    count = 2
  },
  ["purple"] = {
    ["minecraft:blue_dye"] = 1,
    ["minecraft:red_dye"] = 1,
    count = 2
  }
}

function export.calculateAvailable(color, list)
  local totals = utils.getCounts(chests, list)

  local count = totals["minecraft:" .. color .. "_dye"] or 0

  if recipes[color] then
    count = count + utils.calculateAvailableInRecipe(totals, recipes[color])
  end

  return count
end

function export.listChest()
  return utils.getCounts(chests)
end

function export.calculateCostPerStack(color)
  local requiredItems = {}

  if recipes[color] then
    requiredItems = recipes[color]
  else
    requiredItems = { ["minecraft:" .. color .. "_dye"] = 1, count = 1 }
  end

  local count = requiredItems.count
  local cost = 0

  for i, v in pairs(requiredItems) do
    if i ~= "count" then
      cost = cost + (v / count) * costs[i]
    end
  end

  return math.ceil(cost * 64)
end

function export.craft(color, needed)
  local available = export.calculateAvailable(color)
  local name = "minecraft:" .. color .. "_dye"

  local function moveUncraftableDye(name, needed, to, slot)
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

  if available < needed then
    return false
  end

  if not recipes[color] then
    moveUncraftableDye(name, needed, utils.getCraftingChestName())
    return true
  end

  local recipe = recipes[color]
  local count = recipe.count
  local slots = {}

  for i, v in pairs(recipe) do
    if i ~= "count" then
      for a = 1, v do
        table.insert(slots, i)
      end
    end
  end

  print("Recipe items:", textutils.serialise(slots), "Count:", count)

  repeat
    local crafted = 0
    for i, v in pairs(slots) do
      moveUncraftableDye(v, math.min(math.ceil(needed / count), 64), utils.localName, utils.slotMap[i])
    end
    turtle.craft()
    for i = 1, 16 do
      local detail = turtle.getItemDetail(i)
      if detail and detail.name == "minecraft:" .. color .. "_dye" then
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
  return "minecraft:" .. color .. "_dye"
end

export.costs = costs

return export
