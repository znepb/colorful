local bigfont = require("bigfont")
local utils = require("utils")
local dyes = require("items.dye")
local config = require(".config")
local chests = require(".chests")

local state = {
  page = "Dyes"
}

local export = {}

local pages = {}

local amountAvailableCache = {}
local prices = {}
local buttonEvents = {}
local count = 1

local function getColor(name)
  if name == "light_gray" then return "lightGray" end
  if name == "light_blue" then return "lightBlue" end
  return name
end

local function clamp(n, min, max)
  return math.max(math.min(n, max), min)
end

local function makePage(package)
  table.insert(pages, {
    name = package.name,
    updateCache = function()
      local list = package.listChest()
      local list2

      if package.requiresDye == true then
        list2 = dyes.listChest()
      end

      for i, v in pairs(package.colors) do
        amountAvailableCache[package.getName(v)] = package.calculateAvailable(v, list, list2)
        prices[package.getName(v)] = package.calculateCostPerStack(v) / 64
      end
    end,
    f = function(m, w, h)
      m.setBackgroundColor(colors.white)
      m.setTextColor(colors.gray)
      local szY = 4 * math.ceil(#package.colors / 4)
      local szX = 8 * (#package.colors - (math.ceil(#package.colors / 4) - 1) * 4)
      local fW, fH = w - 19, h - 6
      bigfont.writeOn(m, 1, package.name,
        19 + ((w - 19) / 2 - (#package.name * 3 / 2)),
        (6 + fH / 2 - szY / 2) - 4
      )
      for i, v in pairs(package.colors) do
        local y = math.ceil(i / 4) - 1
        local x = (i - y * 4) - 1
        local rX = (x * 8) + (19 + fW / 2 - szX / 2)
        local rY = (y * 4) + (6 + fH / 2 - szY / 2)

        if colors[getColor(v)] < colors.gray then m.setTextColor(colors.gray) else m.setTextColor(colors.white) end

        for i = 0, 3 do
          m.setCursorPos(rX, rY + i)
          m.setBackgroundColor(colors[getColor(v)])
          if state.color == v then
            m.write(("\127"):rep(8))
          else
            m.write((" "):rep(8))
          end
        end

        local str = tostring(math.floor(amountAvailableCache[package.getName(v)] / 64)) .. "s"
        m.setCursorPos(rX + (4 - math.floor(#str / 2)), rY + 1)
        m.write(str)

        local cost = "\164" .. tostring(package.calculateCostPerStack(v))
        m.setCursorPos(rX + (4 - math.floor(#cost / 2)), rY + 2)
        m.write(cost)

        table.insert(buttonEvents, {
          sX = rX,
          sY = rY,
          eX = rX + 8,
          eY = rY + 4,
          f = function()
            state.color = v
            export.render()
          end
        })
      end

      m.setCursorPos(
        18 + ((w - 19) / 2 - (#("Prices and amounts are by stack") / 2)),
        (6 + fH / 2 + szY / 2) + 1
      )
      m.setTextColor(colors.gray)
      m.setBackgroundColor(colors.white)
      m.write("Prices and amounts are by stack")

      m.setTextColor(colors.white)
      m.setBackgroundColor(colors.green)

      local startX = 19 + ((w - 19) / 2 - 12)
      local buttonY = (6 + fH / 2 + szY / 2) + 2 + 1

      local function renderCount()
        if state.color and math.floor(amountAvailableCache[package.getName(state.color)] / 64) <= 0 then
          local s = "This item is currently unavailable."
          m.setCursorPos(
            19 + ((w - 19) / 2 - (#s / 2)),
            (6 + fH / 2 + szY / 2) + 3
          )
          m.setBackgroundColor(colors.white)
          m.setTextColor(colors.lightGray)
          m.write(s)
        else
          for i = 1, 3 do
            m.setCursorPos(
              19 + ((w - 19) / 2 - 12),
              (6 + fH / 2 + szY / 2) + 2 + i
            )

            if i == 2 then
              -- 7, 11, 7
              m.blit(" -  -  " .. (" %s stacks "):format(count > 9 and tostring(count) or " " .. tostring(count)) .. "  +  + ", ("0"):rep(25), "eee6667777777777777555ddd")

            else
              m.blit((" "):rep(25), (" "):rep(25), "eee6667777777777777555ddd")
            end
          end

          if state.color then
            m.setTextColor(colors.gray)
            m.setBackgroundColor(colors.white)
            local str = ("      Total Cost: \164%d      "):format(package.calculateCostPerStack(state.color) * count)
            local str2 = ("      /pay colorful.kst \164%d      "):format(package.calculateCostPerStack(state.color) * count)
            m.setCursorPos(
              19 + ((w - 19) / 2 - (#str / 2)),
              (6 + fH / 2 + szY / 2) + 7
            )
            m.write(str)

            m.setCursorPos(
              19 + ((w - 19) / 2 - (#str2 / 2)),
              (6 + fH / 2 + szY / 2) + 8
            )
            m.write(str2)
          else
            local str = "Please select a color"
            m.setCursorPos(
              19 + ((w - 19) / 2 - (#str / 2)),
              (6 + fH / 2 + szY / 2) + 7
            )
            m.setTextColor(colors.lightGray)
            m.setBackgroundColor(colors.white)
            m.write(str)
          end
        end
      end
      -- --

      if state.color and math.floor(amountAvailableCache[package.getName(state.color)] / 64) > 0 then
        table.insert(buttonEvents, {
          sX = startX - 1,
          sY = buttonY,
          eX = startX + 2,
          eY = buttonY + 3,
          f = function()
            count = math.min(clamp(count - 8, 1, math.floor(amountAvailableCache[package.getName(state.color)] / 64)), 32)
            renderCount()
          end
        })

        table.insert(buttonEvents, {
          sX = startX + 2,
          sY = buttonY,
          eX = startX + 5,
          eY = buttonY + 3,
          f = function()
            count = math.min(clamp(count - 1, 1, math.floor(amountAvailableCache[package.getName(state.color)] / 64)), 32)
            renderCount()
          end
        })

        table.insert(buttonEvents, {
          sX = startX + 18,
          sY = buttonY,
          eX = startX + 21,
          eY = buttonY + 3,
          f = function()
            count = math.min(clamp(count + 1, 1, math.floor(amountAvailableCache[package.getName(state.color)] / 64)), 64)
            renderCount()
          end
        })

        table.insert(buttonEvents, {
          sX = startX + 21,
          sY = buttonY,
          eX = startX + 24,
          eY = buttonY + 3,
          f = function()
            count = math.min(clamp(count + 8, 1, math.floor(amountAvailableCache[package.getName(state.color)] / 64)), 64)
            renderCount()
          end
        })
      end

      renderCount()
    end
  })
end

function export.render()
  buttonEvents = {}
  local m = peripheral.wrap(config.monitor)
  local w, h = m.getSize()
  m.setTextScale(0.5)
  m.setBackgroundColor(colors.white)
  m.clear()
  m.setTextColor(colors.white)
  m.setBackgroundColor(colors.gray)

  for i = 1, 6 do m.setCursorPos(1, i) m.clearLine() end

  local textColor = {colors.brown, colors.red, colors.orange, colors.yellow, colors.lime, colors.green, colors.cyan, colors.blue, colors.purple, colors.purple, colors.magenta, colors.pink}
  local str = "colorful.kst"
  for i = 1, #str do
    local color = textColor[i] or colors.white
    m.setTextColor(color)
    bigfont.writeOn(m, 1, ("colorful.kst"):sub(i, i), 33 + (i - 1) * 3, 2)
  end

  m.setCursorPos(w / 2 - #("For all your colorful block needs!") / 2 + 1, 5)
  m.setTextColor(colors.white)
  m.write("For all your colorful block needs!")

  if state.page == "cache" then
    m.setCursorPos(w / 2 - #("Refreshing item data, please wait...") / 2, h / 2 + 3)
    m.setBackgroundColor(colors.white)
    m.setTextColor(colors.gray)
    m.write("Refreshing item data, please wait...")
  elseif state.page == "crafting" then
    m.setBackgroundColor(colors.white)

    local msg = "Your items are being created! This hopefully won't take long."
    m.setCursorPos(w / 2 - #msg / 2, h / 2 + 2)
    m.setTextColor(colors.gray)
    m.write(msg)

    msg = "Do not teleport away or leave the area until your items are done crafting!"
    m.setCursorPos(w / 2 - #msg / 2, h / 2 + 3)
    m.setTextColor(colors.red)
    m.write(msg)

    msg = "If any problems occur, please contact znepb."
    m.setCursorPos(w / 2 - #msg / 2, h / 2 + 5)
    m.write(msg)
  else
    for i = 7, h do
      if pages[i - 6] then
        local v = pages[i - 6]
        if v.name == state.page then
          m.setBackgroundColor(colors.black)
        else
          m.setBackgroundColor(colors.gray)
          table.insert(buttonEvents, {
            sX = 1,
            sY = i,
            eX = 19,
            eY = i,
            f = function()
              state.page = v.name
              export.render()
            end
          })
        end

        m.setCursorPos(1, i)

        m.write(" " .. v.name .. (" "):rep(20):sub(#v.name, 17))
      else
        m.setBackgroundColor(colors.gray)
        m.setCursorPos(1, i)
        m.write((" "):rep(19))
      end
    end

    local item = utils.filter(pages, function(p) return p.name == state.page end)[1]
    if item then
      item.f(m, w, h)
    end
  end
end

function export.setState(newState)
  state = newState
  export.render()
end

function export.updateCache()
  local oldPage = state.page
  state.page = "cache"
  export.render()
  for i, v in pairs(pages) do
    print("Updating cache:", v.name)
    v.updateCache()
  end
  state.page = oldPage

  local updates = {
    dyes = {
      white = 0,
      black = 0,
      red = 0,
      yellow = 0,
      green = 0,
      blue = 0,
      brown = 0,
    },
    wool = {
      white = 0,
      orange = 0,
      magenta = 0,
      ["light_blue"] = 0,
      yellow = 0,
      lime = 0,
      pink = 0,
      gray = 0,
      ["light_gray"] = 0,
      cyan = 0,
      purple = 0,
      blue = 0,
      brown = 0,
      green = 0,
      red = 0,
      black = 0,
    },
    ingredients = {
      sand = 0,
      gravel = 0,
      glass = 0,
      terracotta = 0,
    },
  }

  local function getChests(chests, section)
    local counts = utils.getCounts(chests)

    for i, v in pairs(counts) do
      local name = i:gsub("minecraft:", ""):gsub("_wool$", ""):gsub("_dye$", "")
      updates[section][name] = v
    end
  end

  getChests(chests.terracotta, "ingredients")
  getChests(chests.concretePowder, "ingredients")
  getChests(chests.wool, "wool")
  getChests(chests.dye, "dyes")
  getChests(chests.glass, "ingredients")

  local result, err = http.post(config.updatesEndpoint .. "colorful/updateItems", textutils.serialiseJSON(updates), {
    Authorization = config.updatesAuthToken,
    ["Content-Type"] = "application/json"
  })
  result.close()

  export.render()
end

function export.event(e)
  if e[1] == "monitor_touch" and e[2] == config.monitor then
    local x, y = e[3], e[4]
    for i, v in pairs(buttonEvents) do
      if x >= v.sX and x <= v.eX and y >= v.sY and y <= v.eY then
        v.f()
      end
    end
  end
end

function export.getState()
  return state
end

function export.getCount()
  return count
end

function export.addPackage(p)
  makePage(p)
end

function export.getAmountsAvailable()
  return amountAvailableCache
end

function export.getPrices()
  return prices
end

return export