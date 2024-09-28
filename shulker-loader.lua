local speaker = peripheral.find("speaker")
local chest = "minecraft:barrel_1143"
local name = peripheral.call("bottom", "getNameLocal")
local canRetrieve = false

local function render()
  local m = peripheral.wrap("front")

  if canRetrieve then
    m.setTextScale(0.5)
    m.setBackgroundColor(colors.white)
    m.clear()
    m.setCursorPos(3, 4)
    m.setTextColor(colors.gray)
    m.write("Right-click")
    m.setCursorPos(3, 5)
    m.write("to retrieve")
    m.setCursorPos(3, 6)
    m.write("shulker box")
  else
    m.setTextScale(0.5)
    m.setBackgroundColor(colors.black)
    m.clear()
  end
end

local debounce = false

parallel.waitForAll(function()
  while true do
    local list = peripheral.call(chest, "list")
    if debounce then sleep(5) end
    if #list == 0 then
      canRetrieve = false
      turtle.suckUp()
      if turtle.getItemCount(1) > 0 then
        local data = turtle.getItemDetail(1)
        if data.name:match("shulker_box") then
          speaker.playSound("minecraft:entity.item.pickup", 1, 1)
          canRetrieve = true
          peripheral.call(chest, "pullItems", name, 1)
        else
          speaker.playSound("minecraft:entity.villager.no", 1, 1)
          turtle.dropUp()
          sleep(5)
        end
      end
    else
      canRetrieve = true
    end
    render()
    sleep(1)
  end
end, function()
  while true do
    local _, side = os.pullEvent("monitor_touch")
    if side == "front" then
      print("Retrieve")
      peripheral.call(chest, "pushItems", name, 1, 1, 1)
      turtle.dropUp()
      speaker.playSound("minecraft:entity.item.pickup", 1, 1)
      debounce = true
      canRetrieve = false
      render()
      sleep(3)
      debounce = false
    end
  end
end)
