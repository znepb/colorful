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
    local list = peripheral.call(c, "list")

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
    pulled = pulled + peripheral.call(chest, "pullItems", to, slot, count - pulled, toSlot)
    tries = tries + 1
  until pulled >= count or tries >= 32
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
    pulled = pulled + peripheral.call(chest, "pushItems", to, slot, count - pulled, toSlot)
    tries = tries + 1
  until pulled >= count or tries >= 32
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
  turtle.dropUp()

  local result, err = http.post(
    "https://colorful.znepb.me/api/colorful/pushEvent",
    textutils.serialiseJSON({
      event = {
        type = "cartridgeRefill",
      }
    }), {
      Authorization = "Bearer cwuUYHaXy0vGEfEa4mICvVnLeBr1gf04BDX71PCweVJWRjTmOM6PtdzyoGJUBK04",
      ["Content-Type"] = "application/json"
    }
  )
  result.close()
end

local lastDropUUID = ""

local function checkEntity(v)
  return v.x >= -0.5 and v.x <= 0.5 and v.z >= -0.5 and v.z <= 0.5 and v.y >= 0 and v.y <= 1 and v.id ~= lastDropUUID
end

local function setDropped()
  local entities = peripheral.wrap("left").sense()
  for i, v in pairs(entities) do
    if checkEntity(v) then
      lastDropUUID = v.id
    end
  end
end

while true do
  if getCountStored("minecraft:magenta_dye", true) <= 16 then
    print("should craft magenta")
    local needToCraft = math.min(math.ceil((64 - getCountStored("minecraft:magenta_dye")) / 4), 12)
    if getCountInStorage("minecraft:blue_dye") >= needToCraft
      and getCountInStorage("minecraft:red_dye") >= needToCraft * 2
      and getCountInStorage("minecraft:white_dye") >= needToCraft then
      pushItem("minecraft:blue_dye", needToCraft, localName, 1)
      pushItem("minecraft:red_dye", needToCraft, localName, 2)
      pushItem("minecraft:red_dye", needToCraft, localName, 3)
      pushItem("minecraft:white_dye", needToCraft, localName, 5)
      turtle.select(1)
      turtle.craft()
      peripheral.call(items, "pullItems", localName, 1)
      listCache = {}
    end
  elseif getCountStored("minecraft:cyan_dye", true) <= 16 then
    print("should craft cyan")
    local needToCraft = math.min(math.ceil((64 - getCountStored("minecraft:cyan_dye")) / 2), 24)
    if getCountInStorage("minecraft:blue_dye") >= needToCraft
      and getCountInStorage("minecraft:green_dye") >= needToCraft then
      pushItem("minecraft:blue_dye", needToCraft, localName, 1)
      pushItem("minecraft:green_dye", needToCraft, localName, 2)
      turtle.select(1)
      turtle.craft()
      peripheral.call(items, "pullItems", localName, 1)
      listCache = {}
    end
  end

  local entities = peripheral.wrap("left").sense()
  for i, v in pairs(entities) do
    if checkEntity(v) and canMakeCartridge() then
      turtle.select(1)
      turtle.suckUp()

      local data =  turtle.getItemDetail(1)
      if data and data.name == "sc-peripherals:empty_ink_cartridge" then
        createCartridge()
      else
        turtle.dropUp()
      end

      sleep(0.1)
      setDropped()
    end
  end

  sleep(0.5)
end