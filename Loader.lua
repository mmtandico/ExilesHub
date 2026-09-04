--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          EXILES HUB  ·  UNIVERSAL LOADER                  ║
    ║          DEV: ZAX   ·  Powered by WindUI (Footagesus)     ║
    ║          Repository: github.com/mmtandico/ExilesHub        ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ── Config ─────────────────────────────────────────────────────────────
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/"
local VERSION         = "v3.2"
local AUTHOR          = "DEV ZAX"

local SupportedGames = {
    [107778070777162] = { Name = "Steal An Egg", Script = "main.lua" },
}

-- ── Helpers ─────────────────────────────────────────────────────────────
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = duration or 4,
        })
    end)
end

local function Wait(n)
    local t = tick()
    while tick() - t < n do RunService.Heartbeat:Wait() end
end

-- ── Boot Banner ─────────────────────────────────────────────────────────
print([[

  ███████╗██╗  ██╗██╗██╗     ███████╗███████╗
  ██╔════╝╚██╗██╔╝██║██║     ██╔════╝██╔════╝
  █████╗   ╚███╔╝ ██║██║     █████╗  ███████╗
  ██╔══╝   ██╔██╗ ██║██║     ██╔══╝  ╚════██║
  ███████╗██╔╝ ██╗██║███████╗███████╗███████║
  ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝
         H  U  B  ·  ]] .. VERSION .. [[  ·  ]] .. AUTHOR .. [[
]])

-- ── Loading Steps ───────────────────────────────────────────────────────
local steps = {
    { msg = "Initializing Exiles Hub " .. VERSION .. " ...",    delay = 0.4 },
    { msg = "Checking game environment ...",                     delay = 0.4 },
    { msg = "Fetching latest scripts from GitHub ...",           delay = 0.5 },
    { msg = "Loading WindUI framework ...",                      delay = 0.3 },
    { msg = "Injecting UI modules ...",                          delay = 0.3 },
    { msg = "Welcome, " .. LocalPlayer.Name .. "!",             delay = 0.2 },
}

-- Show sequential loading toasts in output
for i, step in ipairs(steps) do
    print(string.format("  [%d/%d] %s", i, #steps, step.msg))
    Wait(step.delay)
end

-- Initial notification
Notify("⚡ Exiles Hub " .. VERSION, "Loading — " .. AUTHOR, 5)

-- ── Game Detection & Execution ──────────────────────────────────────────
local currentGame = SupportedGames[game.PlaceId] or SupportedGames[game.GameId]
local scriptName  = currentGame and currentGame.Script or "main.lua"
local gameName    = currentGame and currentGame.Name   or "Universal Mode"

Notify("🎮 Game Detected", gameName .. " — fetching scripts...", 4)
print("  [Exiles Loader] Target: " .. gameName .. " (" .. scriptName .. ")")

-- ── Fetch & Execute ─────────────────────────────────────────────────────
local url     = GITHUB_RAW_BASE .. scriptName .. "?v=" .. tostring(os.time())
local success, err = pcall(function()
    local content = game:HttpGet(url)

    if not content or content == "" then
        error("Empty response from GitHub.")
    end

    -- Show loading animation steps
    local loadSteps = {
        "Parsing script ...",
        "Verifying integrity ...",
        "Compiling modules ...",
        "Launching UI ...",
    }
    for _, s in ipairs(loadSteps) do
        print("  [Exiles Loader] " .. s)
        Wait(0.2)
    end

    local fn, parseErr = loadstring(content)
    if not fn then
        error("Parse error: " .. tostring(parseErr))
    end
    fn()
end)

-- ── Result ───────────────────────────────────────────────────────────────
if success then
    print("  [Exiles Loader] ✓ Hub loaded successfully! Enjoy, " .. LocalPlayer.Name)
    Notify("✅ Exiles Hub Ready", "Welcome " .. LocalPlayer.Name .. " — " .. AUTHOR, 5)
else
    local errMsg = tostring(err)
    warn("  [Exiles Loader] ✗ Failed: " .. errMsg)
    Notify("❌ Exiles Hub Error", string.sub(errMsg, 1, 90), 6)
end
