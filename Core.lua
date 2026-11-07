-- Full Health Forever - core: version, chat output, slash command.
-- 0.0.x is a test build: the only feature is the probe (Probe.lua), which finds out what
-- WoW Forever lets an addon know about health. The real addon is planned from its results.

local _, ns = ...
local L = ns.L

ns.VERSION = "0.0.4"

function ns.Print(fmt, ...)
  local ok, text = pcall(string.format, fmt, ...)
  if not ok then text = tostring(fmt) end
  print("|cff33dd55Full Health Forever|r " .. text)
end

local function Help()
  ns.Print(L.helpHead, ns.VERSION)
  if ns.Probe then
    ns.Print(L.helpProbe)
    ns.Print(L.helpWatch)
    ns.Print(L.helpStop)
    ns.Print(L.helpSend)
  end
end

SLASH_FULLHEALTHFOREVER1 = "/fhf"
SlashCmdList.FULLHEALTHFOREVER = function(msg)
  local cmd, rest = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
  if cmd == "" or cmd == "help" then return Help() end
  if cmd == "probe" and ns.Probe then
    local sub, arg = rest:match("^(%S*)%s*(.-)$")
    if sub == "" then return ns.Probe.Snapshot() end
    if sub == "watch" then return ns.Probe.Watch(tonumber(arg)) end
    if sub == "stop" then return ns.Probe.Stop() end
  end
  ns.Print(L.unknown)
end
