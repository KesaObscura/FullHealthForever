local M, test, eq, ok = T.M, T.test, T.eq, T.ok

local LANGS = { "enUS", "deDE", "ruRU", "esES", "frFR", "ptBR", "koKR", "zhCN", "zhTW" }

-- every format specifier, also with flags; "%%" is a plain percent sign
local function placeholders(str)
  local out = {}
  for p in str:gsub("%%%%", ""):gmatch("%%[-+ #0]*%d*%.?%d*%a") do out[#out + 1] = p end
  return table.concat(out, " ")
end

local function strings()
  M.reset()
  local ns = {}
  assert(loadfile(M.ROOT .. "Locale.lua"))("FullHealthForever", ns)
  return ns.strings
end

test("9 languages, each with exactly the English keys and placeholders", function()
  local s = strings()
  local en = s.enUS
  for _, lang in ipairs(LANGS) do
    local t = s[lang]
    ok(t, "missing language " .. lang)
    for k, v in pairs(en) do
      ok(rawget(t, k), lang .. " misses " .. k)
      eq(placeholders(rawget(t, k)), placeholders(v), lang .. "." .. k .. " placeholders")
    end
    for k in pairs(t) do ok(en[k], lang .. " has extra key " .. k) end
  end
  for k in pairs(s) do
    local known = k == "esMX"
    for _, l in ipairs(LANGS) do known = known or l == k end
    ok(known, "unexpected language " .. k)
  end
  for k, v in pairs(s.esMX) do ok(en[k], "esMX has extra key " .. k) end
end)

test("every key used in the code exists, and every key is used", function()
  local en = strings().enUS
  local code = ""
  for _, f in ipairs({ "Core.lua", "HUD.lua", "Options.lua", "Engine.lua" }) do
    local h = assert(io.open(M.ROOT .. f)); code = code .. h:read("*a"); h:close()
  end
  for k in code:gmatch("L%.([%a_][%w_]*)") do ok(en[k], "missing key " .. k) end
  -- keys built at runtime: grp_<group>, tipGrp_<group>, role*, ht*, help* (in a list)
  for k in pairs(en) do
    local used = code:find("L%." .. k .. "[^%w_]") or code:find('"' .. k .. '"')
      or k:match("^grp_") or k:match("^tipGrp_")
    ok(used, "unused key " .. k)
  end
end)

test("the game language picks the table, esMX falls back to esES, unknown to English", function()
  local function loc(code)
    M.reset({ locale = code })
    local ns = {}
    assert(loadfile(M.ROOT .. "Locale.lua"))("FullHealthForever", ns)
    return ns
  end
  local ns = loc("ruRU")
  eq(ns.L.unknown, ns.strings.ruRU.unknown)
  ns = loc("esMX")
  eq(ns.L.unknown, ns.strings.esES.unknown)
  ns = loc("itIT")
  eq(ns.L.unknown, ns.strings.enUS.unknown)
end)

test("TOC: Notes in every language, version matches ns.VERSION", function()
  M.reset()
  local ns = M.load()
  local h = assert(io.open(M.ROOT .. "FullHealthForever.toc")); local toc = h:read("*a"); h:close()
  for line in toc:gmatch("[^\r\n]+") do
    if line:match("%.lua$") then ok(io.open(M.ROOT .. line), "TOC file exists: " .. line) end
  end
  ok(toc:find("## SavedVariables: FullHealthForeverDB"), "saved variables")
  for _, lang in ipairs(LANGS) do
    if lang ~= "enUS" then ok(toc:find("## Notes%-" .. lang .. ":"), "TOC misses Notes-" .. lang) end
  end
  ok(toc:find("## Notes%-esMX:"), "TOC misses Notes-esMX")
  eq(toc:match("## Version: (%S+)"), ns.VERSION, "TOC version")
end)
