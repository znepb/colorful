local render = require("render")
local utils = require("utils")
local n = term.current()
local config = require("config")

local krist = require("ktwsl")("https://krist.dev", config.kristKey)
print("Krist Started")

local packages = {
  require("items.concrete"),
  require("items.concretePowder"),
  require("items.dye"),
  require("items.glass"),
  require("items.wool"),
  require("items.terracotta"),
  --require("items.blahaj"),
}

local function preformTransaction(to, from, value)
  local state = render.getState()
  local item = utils.filter(packages, function(v) return v.name == state.page end)[1]
  local count = render.getCount()

  if not item or not count or not state.color then
    krist.makeTransaction(from, value, from .. ";message=No active session! Please start a session before sending Krist.")
    return
  end

  local cost = item.calculateCostPerStack(state.color) * count

  if value < cost then
    krist.makeTransaction(from, value, from .. ";message=You underpaid for your purchase. Please pay the full amount of " .. cost .. " Krist.")
    return
  end

  utils.sendEvent("purchase", {
    Stacks = count,
    Item = state.page,
    Color = state.color,
    ["Purchased By"] = from,
    ["Transaction Value"] = cost
  })

  if value > cost then
    krist.makeTransaction(from, value - cost, from .. ";message=You overpaid for your purchase. Here is a refund.")
  end

  render.setState({page = "crafting"})

  item.craft(state.color, count * 64)
  local name = item.getName(state.color)

  local moved = 0

  local chest = config.shulkerChest
  local hasShulker = false

  if peripheral.call(chest, "list")[1] then
    peripheral.call(chest, "pushItems", utils.localName, 1, 1, 1)
    turtle.place()
    hasShulker = true
  end

  local function destroyShulker()
    turtle.dig()
    for i = 1, 16 do
      local detail = turtle.getItemDetail(i)
      if detail and detail.name:match("shulker_box") then
        turtle.select(i)
        turtle.drop()
      end
    end
  end

  local completed = false
  parallel.waitForAny(function()
    repeat
      local list = utils.getCraftingChest().list()

      for s, i in pairs(list) do
        if i.name == name then
          moved = moved + utils.getCraftingChest().pushItems(utils.localName, s, nil, 1)
          local success = turtle.drop()
          if not success then
            destroyShulker()
            turtle.select(1)
            turtle.drop()
          end
          if moved >= count * 64 then break end
        end
      end
    until moved >= count * 64
  end, function()
    local timer = 0
    local hasSentWarning = false
    while true do
      timer = timer + 1

      if hasSentWarning == false and timer >= (count * 1.5) + 5 then
        print("Possible stall!!!")
        utils.sendEvent("stall")
        hasSentWarning = true
      end

      sleep(1)
    end
  end)

  if hasShulker then
    destroyShulker()
  end

  utils.sendEvent("jobComplete", {
    ["Has Shulker"] = tostring(hasShulker),
  })

  render.updateCache()
  render.setState(state)
end

local function toName(name)
  name = name:gsub("_", " ")
  name = name:sub(1, 1):upper() .. name:sub(2)
  for set in name:gmatch("%s%a") do
    name = name:gsub(set, set:upper())
  end
  return name
end

local names = {
  {
    match = "minecraft:([%a_]+)_concrete$",
    name = "%s Concrete"
  },
  {
    match = "minecraft:([%a_]+)_concrete_powder$",
    name = "%s Concrete Powder"
  },
  {
    match = "minecraft:([%a_]+)_dye$",
    name = "%s Dye"
  },
  {
    match = "minecraft:([%a_]+)_terracotta$",
    name = "%s Terracotta"
  },
  {
    match = "minecraft:([%a_]+)_wool$",
    name = "%s Wool"
  },
  {
    match = "minecraft:([%a_]+)_stained_glass$",
    name = "%s Stained Glass"
  },
}

local function findDisplayName(name)
  for i, v in pairs(names) do
    if name:match(v.match) then
      local color = name:match(v.match)
      return v.name:format(toName(color))
    end
  end

  return name
end

local shouldBreak = false
for i, v in pairs(packages) do print("Loading:", v.name) render.addPackage(v) end

xpcall(function()
  parallel.waitForAny(function()
    render.updateCache()
    render.render()

    print("Starting!")
    utils.sendEvent("start")

    krist.subscribeAddress("colorful.kst")

    local lastMsg = 0

    while true do
      local e = {os.pullEvent()}
      if e[1] == "krist_transaction" then
        local to, from, value = e[2], e[3], e[4]
        if to == "colorful.kst" then
          preformTransaction(to, from, value)
        end
      elseif e[1] == "krist_stop" then
        error("Websocket failed! " .. e[2])
      end

      if os.epoch("utc") > lastMsg + config.shopSyncInterval * 1000 then
        lastMsg = os.epoch("utc")
        local modem = peripheral.wrap(config.shopSync)
        local items = {}

        local prices = render.getPrices()

        for i, v in pairs(render.getAmountsAvailable()) do
          table.insert(items, {
            prices = {
              {
                value = prices[i],
                currency = "KST",
                address = "colorful.kst"
              }
            },
            item = {
              name = i,
              displayName = findDisplayName(i)
            },
            stock = v,
            madeOnDemand = true,
            requiresInteraction = true
          })
        end

        print("Transmitting shopsync @ " .. tostring(os.epoch("utc")))
        modem.transmit(9773, 9773, {
          type = "ShopSync",
          info = {
            name = "colorful.kst",
            description = "Colorful blocks at cheap prices",
            owner = "znepb",
            computerID = os.getComputerID(),
            location = config.location,
          },
          items = items
        })
      end

      render.event(e)
    end
  end, krist.start)

  krist.stop()
end, function(err)
  utils.wsSend((":x: Shop Crashed \n```%s```"):format(err .. "\n\n" .. debug.traceback()))
  krist.stop()
  term.redirect(n)
  print("Stopped!", err)

  local m = peripheral.wrap("monitor_1022")
  m.setBackgroundColor(colors.red)
  m.setTextColor(colors.white)
  m.clear()
  m.setCursorPos(1, 1)
  term.redirect(m)
  local traceback = debug.traceback()

  print("An error has occured or the shop has been terminated. It has been reported. If this error persists, please contact znepb.\n\n", err)
  term.redirect(n)
end)