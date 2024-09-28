local chest = "minecraft:chest_4774"
local name = peripheral.wrap("left").getNameLocal()
local modem = peripheral.wrap("left")
local turtles = { peripheral.find("turtle") }
local echest = "ender_storage_7176"

for i, v in pairs(turtles) do
  v.turnOn()
end

local args = { ... }

if args[1] == "update" then
  local f = fs.open("update.lua", "r")
  local data = f.readAll()
  f.close()

  modem.transmit(1000, 1000, {
    act = "update",
    data = data
  })

  return
elseif args[1] == "fp" then
  modem.transmit(1000, 1000, {
    act = "push",
  })

  return
end

while true do
  peripheral.call(echest, "pushItems", name, 1, nil, 1)
  if turtle.getItemDetail(1) then
    peripheral.call(chest, "pullItems", name, 1, nil, 1)
    modem.transmit(1000, 1000, {
      act = "pull"
    })
    sleep(0.4)
    modem.transmit(1000, 1000, {
      act = "place"
    })
    sleep(0.6)
    modem.transmit(1000, 1000, {
      act = "dig"
    })
    sleep(0.6)
    modem.transmit(1000, 1000, {
      act = "push"
    })
    sleep(0.4)
  else
    sleep(0.5)
  end
  peripheral.call(echest, "pullItems", name, 2, nil, 2)

  modem.transmit(1000, 1000, {
    act = "push"
  })
  peripheral.call(chest, "pushItems", name, 2, nil, 2)
end
