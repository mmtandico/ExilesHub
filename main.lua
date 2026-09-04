--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║     EXILES SCRIPT HUB  ·  MASTER ENTRY POINT              ║
    ║     Architecture : Modular MVC                             ║
    ║     Library      : Visual UI Library                      ║
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

-- ── Clean up Any Previous UI Instances (Redz, Visual, etc.) ───────────────
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local PlayerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
    local targets = {
        "redz Library V5",
        "redz library V5",
        "Visual UI Library | .gg/puxxCphTnK",
        "Visual UI Library | .gg/puxxCphTnK | Notifications"
    }
    for _, name in ipairs(targets) do
        if CoreGui then
            local g = CoreGui:FindFirstChild(name)
            if g then g:Destroy() end
        end
        if PlayerGui then
            local g = PlayerGui:FindFirstChild(name)
            if g then g:Destroy() end
        end
    end
end)

-- ── Visual UI Library Loader (Multi-Source Robust Loader) ──────────────────
local VISUAL_URLS = {
    "https://raw.githubusercontent.com/VisualRoblox/Roblox/main/UI-Libraries/Visual%20UI%20Library/Source.lua",
    "https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/src/ui/visuallib.lua"
}

local Library = nil
for _, url in ipairs(VISUAL_URLS) do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and res and type(res.CreateWindow) == "function" then
        Library = res
        break
    end
end

-- Fallback to local file if available in executor filesystem
if not Library and typeof(readfile) == "function" and typeof(isfile) == "function" then
    for _, path in ipairs({ "src/ui/visuallib.lua", "Exiles/src/ui/visuallib.lua" }) do
        if isfile(path) then
            local fn = loadstring(readfile(path))
            if fn then
                local ok, res = pcall(fn)
                if ok and res and type(res.CreateWindow) == "function" then
                    Library = res
                    break
                end
            end
        end
    end
end

if not Library then
    warn("[Exiles Hub] Failed to load Visual UI Library.")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Exiles Hub Error",
            Text     = "Failed to load Visual UI Library. Check network connection.",
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
local Window = UILayout.Build(Library, HubState, Helpers, Modules)

print("[Exiles Hub] Visual UI modular hub initialized — DEV ZAX")