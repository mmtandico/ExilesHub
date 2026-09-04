--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║     EXILES SCRIPT HUB  ·  MASTER ENTRY POINT              ║
    ║     Architecture : Modular MVC                             ║
    ║     Library      : RedzLib (RedzHub UI)                    ║
    ║     Game         : Steal An Egg (ID: 107778070777162)      ║
    ║     Author       : DEV ZAX                                 ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- ── Target Place Verification ────────────────────────────────────────────
local TARGET_PLACE_ID = 107778070777162
if game.PlaceId ~= TARGET_PLACE_ID and game.GameId ~= TARGET_PLACE_ID then
    warn("[Exiles Hub] Note: Current Place ID is " .. tostring(game.PlaceId)
        .. " (Target: " .. tostring(TARGET_PLACE_ID) .. ")")
end

-- ── RedzLib UI Loader (Multi-Source Robust Loader) ─────────────────────────
local REDZ_URLS = {
    "https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui",
    "https://raw.githubusercontent.com/kingsoluctionsforce-droid/1010183818289192028382899283818283828918282719393828283838828182838/refs/heads/main/REDzHubui",
    "https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/src/ui/redzlib.lua"
}

local redzlib = nil
for _, url in ipairs(REDZ_URLS) do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and res and type(res.MakeWindow) == "function" then
        redzlib = res
        break
    end
end

-- Fallback to local file if available in executor filesystem
if not redzlib and typeof(readfile) == "function" and typeof(isfile) == "function" then
    for _, path in ipairs({ "src/ui/redzlib.lua", "Exiles/src/ui/redzlib.lua" }) do
        if isfile(path) then
            local fn = loadstring(readfile(path))
            if fn then
                local ok, res = pcall(fn)
                if ok and res and type(res.MakeWindow) == "function" then
                    redzlib = res
                    break
                end
            end
        end
    end
end

if not redzlib then
    warn("[Exiles Hub] Failed to load RedzLib.")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Exiles Hub Error",
            Text     = "Failed to load RedzLib. Check network connection.",
            Duration = 5,
        })
    end)
    return
end

-- ── Modular Require System (Local Files → GitHub Fallback) ───────────────
local GITHUB_SRC_URL = "https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/src/"

local function Require(modulePath)
    -- Check local filesystem first
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        local localPaths = {
            "src/" .. modulePath,
            "Exiles/src/" .. modulePath,
            modulePath
        }
        for _, p in ipairs(localPaths) do
            if isfile(p) then
                local content = readfile(p)
                local fn, err = loadstring(content)
                if fn then return fn() else
                    warn("[Exiles Hub] Local parse error in " .. p .. ": " .. tostring(err))
                end
            end
        end
    end

    -- Fallback: Fetch from GitHub
    local url = GITHUB_SRC_URL .. modulePath .. "?v=" .. tostring(os.time())
    local ok, content = pcall(function() return game:HttpGet(url) end)
    if not ok or not content or content == "" then
        error("[Exiles Hub] Network error fetching " .. modulePath .. ": " .. tostring(content))
    end
    local fn, err = loadstring(content)
    if not fn then
        error("[Exiles Hub] Failed to load module " .. modulePath .. ": " .. tostring(err))
    end
    return fn()
end

-- ── Load Core Dependencies ────────────────────────────────────────────────
local HubState = Require("state.lua")
local Helpers  = Require("utils/helpers.lua")

-- ── Load Game Modules ─────────────────────────────────────────────────────
local Modules = {
    Steal     = Require("modules/steal.lua"),
    Treadmill = Require("modules/treadmill.lua"),
    Monster   = Require("modules/monster.lua"),
    Pets      = Require("modules/pets.lua"),
    Predictor = Require("modules/egg_predictor.lua"),
    EggSell   = Require("modules/egg_sell.lua"),
    Visuals   = Require("modules/visuals.lua"),
    Player    = Require("modules/player.lua"),
}

-- ── Initialize Module Logic Loops ─────────────────────────────────────────
Modules.Steal.Init(HubState, Helpers)
Modules.Treadmill.Init(HubState, Helpers)
Modules.Monster.Init(HubState, Helpers)
Modules.Pets.Init(HubState, Helpers)
Modules.Predictor.Init(HubState, Helpers)
Modules.EggSell.Init(HubState, Helpers)
Modules.Player.Init(HubState, Helpers)
Modules.Visuals.Init(HubState, Helpers)

-- ── Build & Render UI ─────────────────────────────────────────────────────
local UILayout = Require("ui/layout.lua")
local Window = UILayout.Build(redzlib, HubState, Helpers, Modules)

print("[Exiles Hub] RedzLib modular hub initialized — DEV ZAX")