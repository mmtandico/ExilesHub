--[[
    ===================================================================
    EXILES SCRIPT HUB | MASTER ENTRY POINT & LOADER
    Architecture: Modular MVC (Design separated from Logic)
    Game: Steal An Egg (Place ID: 107778070777162)
    ===================================================================
]]

-- Target Place Verification
local TARGET_PLACE_ID = 107778070777162
if game.PlaceId ~= TARGET_PLACE_ID and game.GameId ~= TARGET_PLACE_ID then
    warn("[Exiles Hub] Note: Current Place ID is " .. tostring(game.PlaceId) .. " (Target: " .. tostring(TARGET_PLACE_ID) .. ")")
end

-- Rayfield Gen 2 Loader
local Rayfield
local loadOk, loadErr = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if not loadOk or not Rayfield then
    warn("[Exiles Hub] Failed to load Rayfield Gen 2: " .. tostring(loadErr))
    return
end

-- Modular Require System (Supports both Local Files & Remote GitHub)
local GITHUB_SRC_URL = "https://raw.githubusercontent.com/mmtandico/ExilesHub/main/src/"

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
                if fn then return fn() else warn("[Exiles Hub] Local parse error in " .. p .. ": " .. tostring(err)) end
            end
        end
    end

    -- Fallback: Fetch directly from GitHub with cache-busting
    local url = GITHUB_SRC_URL .. modulePath .. "?v=" .. tostring(os.time())
    local content = game:HttpGet(url)
    local fn, err = loadstring(content)
    if not fn then
        error("[Exiles Hub] Failed to load module " .. modulePath .. ": " .. tostring(err))
    end
    return fn()
end

-- Load Core Dependencies
local HubState = Require("state.lua")
local Helpers  = Require("utils/helpers.lua")

-- Load Game Modules
local Modules = {
    Steal     = Require("modules/steal.lua"),
    Treadmill = Require("modules/treadmill.lua"),
    Monster   = Require("modules/monster.lua"),
    Pets      = Require("modules/pets.lua"),
    EggSell   = Require("modules/egg_sell.lua"),
    Visuals   = Require("modules/visuals.lua"),
    Player    = Require("modules/player.lua"),
}

-- Initialize Module Logic Loops
Modules.Steal.Init(HubState, Helpers)
Modules.Treadmill.Init(HubState, Helpers)
Modules.Monster.Init(HubState, Helpers)
Modules.Pets.Init(HubState, Helpers)
Modules.EggSell.Init(HubState, Helpers)
Modules.Player.Init(HubState, Helpers)

-- Build & Render UI Design
local UILayout = Require("ui/layout.lua")
local Window = UILayout.Build(Rayfield, HubState, Helpers, Modules)

print("[Exiles Hub] Successfully initialized modular architecture!")