--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║     EXILES SCRIPT HUB  ·  MASTER ENTRY POINT              ║
    ║     Architecture : Modular MVC                             ║
    ║     Library      : WindUI (Footagesus)                     ║
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

-- ── WindUI Loader ─────────────────────────────────────────────────────────
local loadOk, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not loadOk or not WindUI then
    warn("[Exiles Hub] Failed to load WindUI: " .. tostring(WindUI))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Exiles Hub Error",
            Text     = "Failed to load WindUI. Check connection.",
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

-- ── Build & Render UI ─────────────────────────────────────────────────────
local UILayout = Require("ui/layout.lua")
local Window = UILayout.Build(WindUI, HubState, Helpers, Modules)

print("[Exiles Hub] WindUI modular hub initialized — DEV ZAX")