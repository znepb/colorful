local export = {}
local config = require(".config")

export.allColors = {"white", "orange", "magenta", "light_blue", "yellow", "lime", "pink", "gray", "light_gray", "cyan", "purple", "blue", "brown", "green", "red", "black"}

function export.callChest(id, ...)
  return peripheral.call("sc-goodies:diamond_barrel_" .. tostring(id), ...)
end

function export.getCounts(chests, list)
  if list then return list end
  local items = {}

  for i, v in pairs(chests) do
    for _, item in pairs(export.callChest(v, "list")) do
      if items[item.name] == nil then items[item.name] = 0 end
      items[item.name] = items[item.name] + item.count
    end
  end

  return items
end

function export.calculateAvailableInRecipe(availableList, recipe)
  local items = {}
  local output
  local available = math.huge
  local mostNeeded = 0

  for i, v in pairs(recipe) do
    if i == "count" then
      output = v
    else
      items[#items + 1] = {
        name = i,
        count = v
      }
      mostNeeded = math.max(v, mostNeeded)
    end
  end

  for i, v in pairs(items) do
    local amountAvailable = availableList[v.name] or 0
    available = math.min(math.floor(amountAvailable / v.count), available)
  end

  return available * output
end

function export.filter(tbl, f)
  local items = {}

  for i, v in pairs(tbl) do
    if f(v) then
      table.insert(items, v)
    end
  end

  return items
end

function export.roundHalf(n)
  if math.floor(n) == n then
    return n
  elseif n - math.floor(n) < 0.5 then
    return math.floor(n) + 0.5
  end

  return math.ceil(n)
end

function export.getCraftingChest()
  return peripheral.wrap(export.getCraftingChestName())
end

function export.getCraftingChestName()
  return "sc-goodies:diamond_barrel_3619"
end


function export.wsSend(message)
  http.post("https://discord.com/api/webhooks/1070493867515842560/x7aYU9Zl1RPMQiPi7wX2yTMf6yPNA_CB2CkF0XSpPVk6T3TNamzp7xBYC_PPcZyKra_-", textutils.serialiseJSON({
    username = "colorful.kst",
    content = message
  }), { ["content-type"] = "application/json" })
end

function export.sendEvent(event, data)
  local result, err = http.post(
    config.updatesEndpoint .. "colorful/pushEvent",
    textutils.serialiseJSON({
      event = {
        type = event,
        data = data
      }
    }), {
      Authorization = config.updatesAuthToken,
      ["Content-Type"] = "application/json"
    }
  )
  result.close()
end

export.localName = peripheral.call("back", "getNameLocal")
export.slotMap = { 1, 2, 3, 5, 6, 7, 9, 10, 11 }

return export