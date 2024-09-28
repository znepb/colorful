local chests = {
  "sc-goodies:diamond_barrel_3603",
  "sc-goodies:diamond_barrel_3604",
  "sc-goodies:diamond_barrel_3605",
  "sc-goodies:diamond_barrel_3606",
}

local items = "minecraft:barrel_1144"

local localName = peripheral.call("bottom", "getNameLocal")
local function findItem(name)
  local list = peripheral.call(items, "list")

  for i, v in pairs(list) do
    if v.name == name then
      return items, i
    end
  end

  for i, c in pairs(chests) do
    list = peripheral.call(c, "list")

    for i, v in pairs(list) do
      if v.name == name then
        return c, i
      end
    end
  end
end

local function getCountStored(name)
  local list = peripheral.call(items, "list")
  local stored = 0

  for i, v in pairs(list) do
    if v.name == name then
      stored = stored + v.count
    end
  end

  return stored
end

local function getCountInStorage(name)
  local stored = 0

  for i, c in pairs(chests) do
    local list = peripheral.call(c, "list")

    for i, v in pairs(list) do
      if v.name == name then
        stored = stored + v.count
      end
    end
  end

  return stored
end

local function pullItem(name, count, to, toSlot)
  local total = getCountStored(name) + getCountInStorage(name)
  if total < count then return end

  local pulled = 0
  local tries = 0
  repeat
    local chest, slot = findItem(name)
    if chest == nil then return end
    pulled = pulled + peripheral.call(chest, "pullItems", to, slot, count, toSlot)
    tries = tries + 1
  until pulled == count or tries >= 32
  return pulled
end

local function pushItem(name, count, to, toSlot)
  local total = getCountStored(name) + getCountInStorage(name)
  if total < count then  return end

  local pulled = 0
  local tries = 0
  repeat
    local chest, slot = findItem(name)
    if chest == nil then return end
    pulled = pulled + peripheral.call(chest, "pushItems", to, slot, count, toSlot)
    tries = tries + 1
  until pulled == count or tries >= 32
  return pulled
end

local function canMakeCartridge()
  if getCountStored("minecraft:magenta_dye") == 0 then return end
  if getCountStored("minecraft:cyan_dye") == 0 then return end
  if getCountInStorage("minecraft:yellow_dye") == 0 then return end
  if getCountInStorage("minecraft:black_dye") == 0 then return end
  return true
end

local function createCartridge()
  if not canMakeCartridge() then return end

  pushItem("minecraft:magenta_dye", 1, localName, 2)
  pushItem("minecraft:cyan_dye", 1, localName, 3)
  pushItem("minecraft:yellow_dye", 1, localName, 5)
  pushItem("minecraft:black_dye", 1, localName, 6)

  turtle.select(1)
  turtle.craft()

  local result, err = http.post(
    "",
    textutils.serialiseJSON({
      event = {
        type = "cartridgeRefill",
      }
    }), {
      Authorization = "",
      ["Content-Type"] = "application/json"
    }
  )
  result.close()
end

local enderstorage = "ender_storage_6483"

while true do
  if canMakeCartridge() then
    local list = peripheral.call(enderstorage, "list")

    for i, v in pairs(list) do
      if v.name == "sc-peripherals:empty_ink_cartridge" then
        print("Make Cartridge")
        peripheral.call(enderstorage, "pushItems", localName, i, nil, 1)
        createCartridge()
        peripheral.call(enderstorage, "pullItems", localName, 1, nil, i)
      end
    end
  end

  sleep(0.5)
end