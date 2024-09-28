local port = 8055
local m = peripheral.wrap("back")
m.open(8055)

local name = peripheral.call("back", "getNameLocal")

while true do
  local _, _, _, _, msg = os.pullEvent("modem_message")

  if msg.t == "place" and msg.id == name then
    turtle.select(2)
    turtle.dig()
    turtle.select(1)
    turtle.place()
  elseif msg.t == "dig" and msg.id == name then
    turtle.select(1)
    turtle.dig()
    turtle.select(2)
    turtle.place()
  elseif msg.t == "update" then
    local f = fs.open("startup.lua", "w")
    f.write(msg.d)
    f.close()
    os.reboot()
  end
end