--[[
    ===================================================================
    EXILES SCRIPT HUB | UNIVERSAL LOADER
    Repository: https://github.com/mmtandico/ExilesHub
    ===================================================================
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/"

-- Supported Games Table
local SupportedGames = {
    [107778070777162] = {
        Name = "Steal An Egg",
        Script = "main.lua"
    }
}

local currentGame = SupportedGames[game.PlaceId] or SupportedGames[game.GameId]

-- Notification Function
local function ShowNotification(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
end

print([[
  ______      _ _           _    _       _     
 |  ____|    (_) |         | |  | |     | |    
 | |__  __  ___| | ___  ___| |__| |_   _| |__  
 |  __| \ \/ / | |/ _ \/ __|  __  | | | | '_ \ 
 | |____ >  <| | |  __/\__ \ |  | | |_| | |_) |
 |______/_/\_\_|_|\___||___/_|  |_|\__,_|_.__/ 
]])
print("[Exiles Loader] Initializing for " .. LocalPlayer.Name .. "...")

if currentGame then
    ShowNotification("Exiles Hub", "Identified game: " .. currentGame.Name .. "\nLoading script...")
    local url = GITHUB_RAW_BASE .. currentGame.Script .. "?v=" .. tostring(os.time())
    local success, err = pcall(function()
        local content = game:HttpGet(url)
        local fn, pErr = loadstring(content)
        if not fn then error("Parse: " .. tostring(pErr)) end
        fn()
    end)
    if not success then
        warn("[Exiles Loader] Failed: " .. tostring(err))
        ShowNotification("Exiles Hub Error", string.sub(tostring(err), 1, 90))
    end
else
    -- Fallback: Load main script
    ShowNotification("Exiles Hub", "Loading Universal Hub...")
    local url = GITHUB_RAW_BASE .. "main.lua?v=" .. tostring(os.time())
    local success, err = pcall(function()
        local content = game:HttpGet(url)
        local fn, pErr = loadstring(content)
        if not fn then error("Parse: " .. tostring(pErr)) end
        fn()
    end)
    if not success then
        warn("[Exiles Loader] Failed: " .. tostring(err))
        ShowNotification("Exiles Hub Error", string.sub(tostring(err), 1, 90))
    end
end
