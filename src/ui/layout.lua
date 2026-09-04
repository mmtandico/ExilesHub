--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║     EXILES SCRIPT HUB  ·  VISUAL UI REDESIGN              ║
    ║     Library : Visual UI Library                           ║
    ║     Theme   : Nordic Dark / Dynamic Themes                ║
    ║     Author  : DEV ZAX                                     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local UILayout = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ── Toast Notification Helper ─────────────────────────────────────────────
local function Notify(Library, title, content, duration)
    pcall(function()
        if Library and type(Library.CreateNotification) == "function" then
            Library:CreateNotification(title or "Exiles Hub", content or "", duration or 3)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "Exiles Hub",
                Text = content or "",
                Duration = duration or 3,
            })
        end
    end)
end

-- ── Safe Element Wrappers for Dynamic Updates ─────────────────────────────
local function SafeCreateParagraph(section, title, text)
    local paraObj = section:CreateParagraph(title, text)
    return {
        Set = function(self, newTitle, newText)
            if not newText then
                newText = newTitle
                newTitle = title
            end
            if paraObj and type(paraObj.UpdateParagraph) == "function" then
                pcall(function()
                    paraObj:UpdateParagraph(newTitle, newText)
                end)
            end
        end,
        UpdateParagraph = function(self, newTitle, newText)
            if paraObj and type(paraObj.UpdateParagraph) == "function" then
                pcall(function()
                    paraObj:UpdateParagraph(newTitle, newText)
                end)
            end
        end
    }
end

local function SafeCreateButton(section, initialName, callback)
    local currentAction = callback or function() end
    local holderName = initialName .. "ButtonHolder"
    local btnName = initialName .. "Button"

    section:CreateButton(initialName, function()
        pcall(currentAction)
    end)

    return {
        Set = function(self, newText, newCallback)
            if newCallback then
                currentAction = newCallback
            end
            pcall(function()
                local holder = section:FindFirstChild(holderName)
                if holder then
                    local btn = holder:FindFirstChild(btnName)
                    if btn and btn:IsA("TextButton") then
                        btn.Text = newText
                    end
                end
            end)
        end
    }
end

function UILayout.Build(Library, HubState, Helpers, Modules)
    -- ── Create Visual UI Window ───────────────────────────────────────────
    local Window = Library:CreateWindow(
        "Exiles Hub",                    -- HubName
        "Steal An Egg",                  -- GameName
        "Exiles Hub | DEV ZAX",          -- IntroText
        "rbxassetid://10709761530",      -- IntroIcon
        false,                           -- ImprovePerformance
        "ExilesHub_StealAnEgg",          -- ConfigFolder
        "Nordic Dark"                    -- Theme
    )

    Notify(Library, "⚡ Exiles Hub", "Visual UI Loaded — Welcome " .. (LocalPlayer.DisplayName or LocalPlayer.Name), 4)

    -- ════════════════════════════════════════════════════════════════════
    -- 1.  HOME & DASHBOARD TAB
    -- ════════════════════════════════════════════════════════════════════
    local HomeTab = Window:CreateTab("Home", true, "rbxassetid://10709761530")

    local HomeStatusSec = HomeTab:CreateSection("Welcome & Status")

    HomeStatusSec:CreateParagraph(
        "DEV ZAX  ·  Exiles Hub v3.5",
        "Hello " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " (@" .. LocalPlayer.Name .. ")\nGame: Steal An Egg (ID: 107778070777162)\nStatus: Operational & Undetected\nUI Engine: Visual UI Library"
    )

    HomeStatusSec:CreateParagraph(
        "Exiles Hub Community",
        "Join our Discord for updates, free scripts & community support!\nOfficial Invite: discord.gg/exileshub"
    )

    local HomeActionsSec = HomeTab:CreateSection("Quick Actions")

    HomeActionsSec:CreateButton("Copy Discord Link (.gg/exileshub)", function()
        pcall(function()
            setclipboard("https://discord.gg/exileshub")
            Notify(Library, "Discord Copied", "discord.gg/exileshub copied to clipboard!", 3)
        end)
    end)

    HomeActionsSec:CreateButton("Copy Profile Link", function()
        pcall(function()
            setclipboard("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile")
            Notify(Library, "Profile Copied", "Profile link copied to clipboard!", 3)
        end)
    end)

    HomeActionsSec:CreateButton("Rejoin Current Server", function()
        Notify(Library, "Rejoining", "Connecting back to server...", 2)
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    HomeActionsSec:CreateButton("Server Hop (Smallest)", function()
        pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local res = game:HttpGet(url)
            local data = HttpService:JSONDecode(res)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                        Notify(Library, "Server Hopping", "Connecting to new server...", 2)
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
            Notify(Library, "Server Hop", "No alternative server found.", 3)
        end)
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 2.  EGG PREDICTOR & SERVER TRACKER TAB
    -- ════════════════════════════════════════════════════════════════════
    local PredictorTab = Window:CreateTab("Egg Predictor", false, "rbxassetid://10709761530")

    local PredictorForecastSec = PredictorTab:CreateSection("Live Game & Night Cycle Forecast")

    local PredictorStatus = SafeCreateParagraph(
        PredictorForecastSec,
        "Cycle Forecast",
        "Spawn Cycle: 05:00\nIn-Game Clock: " .. string.format("%.2f", Lighting.ClockTime) .. ":00\nNight Cycle: Calculating..."
    )

    local PredictorStats = SafeCreateParagraph(
        PredictorForecastSec,
        "Detected Eggs Across Server",
        "Divine: 0  |  Eternal: 0  |  Secret: 0  |  Cosmic: 0"
    )

    local PredictorSyncSec = PredictorTab:CreateSection("Timer Sync & Calibration")

    PredictorSyncSec:CreateButton("🌙 Sync With In-Game Night Cycle", function()
        if Modules.Predictor and Modules.Predictor.SyncWithLighting then
            local s, rem = Modules.Predictor.SyncWithLighting()
            if s then
                Notify(Library, "🌙 Night Synced", "Forecast calibrated: " .. string.format("%02d:%02d", math.floor(rem/60), rem%60), 3)
            else
                Notify(Library, "Timer", "Sync completed.", 2)
            end
        end
    end)

    PredictorSyncSec:CreateButton("🔄 Reset Spawn Timer (05:00)", function()
        if Modules.Predictor and Modules.Predictor.SyncTimer then
            Modules.Predictor.SyncTimer(300)
            Notify(Library, "Timer Reset", "Spawn cycle reset to 05:00", 2)
        end
    end)

    PredictorSyncSec:CreateButton("⏩ +10s Fine Tune Offset", function()
        if Modules.Predictor and Modules.Predictor.AdjustManualOffset then
            Modules.Predictor.AdjustManualOffset(10)
            Notify(Library, "Timer Calibrated", "+10s applied to forecast", 2)
        end
    end)

    PredictorSyncSec:CreateButton("⏪ -10s Fine Tune Offset", function()
        if Modules.Predictor and Modules.Predictor.AdjustManualOffset then
            Modules.Predictor.AdjustManualOffset(-10)
            Notify(Library, "Timer Calibrated", "-10s applied to forecast", 2)
        end
    end)

    local PredictorCtrlSec = PredictorTab:CreateSection("Detection & Auto-Steal Controls")

    PredictorCtrlSec:CreateToggle("Predictor & Tracker Enabled", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.PredictorEnabled = v
        Notify(Library, "Predictor", v and "Detection Engine ON" or "Detection Engine OFF", 2)
    end)

    PredictorCtrlSec:CreateToggle("Auto-Steal On Detect", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoStealPredicted = v
        Notify(Library, "Auto-Steal Target", v and "Will claim rare eggs on spawn" or "Disabled", 2)
    end)

    PredictorCtrlSec:CreateToggle("Predictor ESP Beacons", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.PredictorESP = v
        if Modules.Predictor and Modules.Predictor.UpdateESP then
            Modules.Predictor.UpdateESP(v)
        end
    end)

    PredictorCtrlSec:CreateToggle("Notify Divine (Tier 10)", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.NotifyDivine = v
    end)

    PredictorCtrlSec:CreateToggle("Notify Eternal (Tier 9)", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.NotifyEternal = v
    end)

    PredictorCtrlSec:CreateToggle("Notify Secret (Tier 8)", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.NotifySecret = v
    end)

    local PredictorSlotsSec = PredictorTab:CreateSection("1-Click Instant Target Steal")

    local Slot1Btn = SafeCreateButton(PredictorSlotsSec, "Slot 1: Scanning for high-tier egg...", function() end)
    local Slot2Btn = SafeCreateButton(PredictorSlotsSec, "Slot 2: Scanning for high-tier egg...", function() end)

    -- Background loop to refresh Predictor status and slot buttons
    task.spawn(function()
        while HubState.Running do
            if Modules.Predictor and HubState.Settings.PredictorEnabled then
                pcall(function()
                    local clock = Lighting.ClockTime
                    local nightEta = Modules.Predictor.GetNextNightETA and Modules.Predictor.GetNextNightETA() or 0
                    local spawnEta = Modules.Predictor.GetSpawnCycleSecondsRemaining and Modules.Predictor.GetSpawnCycleSecondsRemaining() or 300

                    local mSpawn = math.floor(spawnEta / 60)
                    local sSpawn = spawnEta % 60
                    local mNight = math.floor(nightEta / 60)
                    local sNight = nightEta % 60

                    PredictorStatus:Set(
                        "Cycle Forecast",
                        string.format("Next Spawn: %02d:%02d\nIn-Game Clock: %05.2f:00\nNext Night (30x Speed): %02d:%02d",
                            mSpawn, sSpawn, clock, mNight, sNight)
                    )

                    local counts = Modules.Predictor.RarityCounts or {}
                    PredictorStats:Set(
                        "Detected Eggs Across Server",
                        string.format("Divine: %d  |  Eternal: %d  |  Secret: %d  |  Cosmic: %d",
                            counts.Divine or 0, counts.Eternal or 0, counts.Secret or 0, counts.Cosmic or 0)
                    )

                    local detected = Modules.Predictor.DetectedEggs or {}
                    if #detected >= 1 and detected[1] and detected[1].Part then
                        local e1 = detected[1]
                        Slot1Btn:Set(
                            string.format("⚡ Claim [%s] %s (%s)", e1.Rarity, e1.Name, e1.Area or "Map"),
                            function()
                                Notify(Library, "Target Steal", "Teleporting to " .. e1.Name, 2)
                                Modules.Predictor.StealTargetEgg(e1, Helpers, HubState)
                            end
                        )
                    else
                        Slot1Btn:Set("Slot 1: Waiting for high-tier egg spawn...", function() end)
                    end

                    if #detected >= 2 and detected[2] and detected[2].Part then
                        local e2 = detected[2]
                        Slot2Btn:Set(
                            string.format("⚡ Claim [%s] %s (%s)", e2.Rarity, e2.Name, e2.Area or "Map"),
                            function()
                                Notify(Library, "Target Steal", "Teleporting to " .. e2.Name, 2)
                                Modules.Predictor.StealTargetEgg(e2, Helpers, HubState)
                            end
                        )
                    else
                        Slot2Btn:Set("Slot 2: Waiting for high-tier egg spawn...", function() end)
                    end
                end)
            end
            task.wait(1.5)
        end
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 3.  AUTO STEAL TAB
    -- ════════════════════════════════════════════════════════════════════
    local StealTab = Window:CreateTab("Auto Steal", false, "rbxassetid://10709761530")

    local StealEngineSec = StealTab:CreateSection("Auto Steal Engine")

    StealEngineSec:CreateToggle("Auto Steal Eggs", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoSteal = v
        Notify(Library, "Auto Steal", v and "✅ Auto Steal Active" or "⛔ Auto Steal Stopped", 2)
    end)

    StealEngineSec:CreateToggle("Steal Infested Eggs", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.StealInfested = v
    end)

    StealEngineSec:CreateToggle("Anti-Trap (Bypass Traps)", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AntiTrap = v
    end)

    local StealBaseSec = StealTab:CreateSection("Base Deposit Settings")

    StealBaseSec:CreateToggle("Auto Place Egg On Base Nest", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoPlaceEgg = v
    end)

    StealBaseSec:CreateToggle("Skip Infested Egg Placement", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.DontPlaceInfested = v
    end)

    local StealRulesSec = StealTab:CreateSection("Targeting Rules")

    StealRulesSec:CreateDropdown(
        "Steal Priority",
        { "Highest Rarity", "Nearest Egg", "Infested First" },
        "Highest Rarity",
        0.2,
        function(v) HubState.Settings.StealPriority = v end
    )

    StealRulesSec:CreateDropdown(
        "Target Egg Tier",
        { "All Eggs", "Legendary & Up", "Epic & Up", "Only Infested" },
        "All Eggs",
        0.2,
        function(v) HubState.Settings.TargetSpecificEggs = v end
    )

    StealRulesSec:CreateDropdown(
        "Target Areas",
        { "All Areas", "Enemy Bases", "Center Zone", "Rare Spawns" },
        "All Areas",
        0.2,
        function(v) HubState.Settings.TargetAreas = v end
    )

    local StealSpeedSec = StealTab:CreateSection("Speed & Timing")

    StealSpeedSec:CreateSlider(
        "Tween Speed",
        15,
        120,
        35,
        Color3.fromRGB(0, 170, 255),
        function(v) HubState.Settings.TweenSpeed = v end
    )

    StealSpeedSec:CreateSlider(
        "Steal Timeout (Seconds)",
        1,
        15,
        5,
        Color3.fromRGB(0, 170, 255),
        function(v) HubState.Settings.StealTimeout = v end
    )

    -- ════════════════════════════════════════════════════════════════════
    -- 4.  TREADMILL & BASE TAB
    -- ════════════════════════════════════════════════════════════════════
    local TreadmillTab = Window:CreateTab("Treadmill & Base", false, "rbxassetid://10709761530")

    local TreadmillFarmSec = TreadmillTab:CreateSection("Speed Boost Farming")

    TreadmillFarmSec:CreateToggle("Auto Treadmill Farm", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoTreadmill = v
        Notify(Library, "Treadmill", v and "✅ Auto Treadmill Active" or "⛔ Stopped", 2)
    end)

    TreadmillFarmSec:CreateToggle("Hide Treadmill (Anti-Detection)", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.HideTreadmill = v
        Modules.Treadmill.SetHideTreadmill(v)
    end)

    TreadmillFarmSec:CreateButton("Exit Treadmill Now", function()
        HubState.Settings.AutoTreadmill = false
        Modules.Treadmill.Exit(Helpers)
        Notify(Library, "Treadmill", "Exited treadmill safe spot.", 2)
    end)

    local TreadmillUpgradesSec = TreadmillTab:CreateSection("Base Upgrades & Rewards")

    TreadmillUpgradesSec:CreateToggle("Auto Upgrade Treadmill", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoUpgradeTreadmill = v
    end)

    TreadmillUpgradesSec:CreateToggle("Auto Upgrade Base Nest", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoUpgradeBase = v
    end)

    TreadmillUpgradesSec:CreateToggle("Auto Buy Speed Trail", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoBuyTrail = v
    end)

    TreadmillUpgradesSec:CreateToggle("Auto Claim Daily & Free Gifts", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoClaim = v
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 5.  PETS & HATCHING TAB
    -- ════════════════════════════════════════════════════════════════════
    local PetsTab = Window:CreateTab("Pets & Hatching", false, "rbxassetid://10709761530")

    local PetsHatchSec = PetsTab:CreateSection("Egg Opener")

    PetsHatchSec:CreateDropdown(
        "Select Egg Type",
        { "Basic Egg", "Rare Egg", "Epic Egg", "Legendary Egg", "Mythic Egg", "Infested Egg", "Void Egg" },
        "Basic Egg",
        0.2,
        function(v) HubState.Settings.EggScope = v end
    )

    PetsHatchSec:CreateToggle("Auto Hatch Selected Egg", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoHatch = v
        Notify(Library, "Auto Hatch", v and ("✅ Hatching " .. HubState.Settings.EggScope) or "⛔ Stopped", 2)
    end)

    local PetsMgmtSec = PetsTab:CreateSection("Pet Management")

    PetsMgmtSec:CreateToggle("Auto Equip Best Pets", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoEquipBest = v
    end)

    PetsMgmtSec:CreateToggle("Auto Favorite Pet", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoFavoritePet = v
    end)

    PetsMgmtSec:CreateDropdown(
        "Favorite Min Rarity",
        { "Rare", "Epic", "Legendary", "Mythic" },
        "Legendary",
        0.2,
        function(v) HubState.Settings.FavoriteMinRarity = v end
    )

    PetsMgmtSec:CreateToggle("Favorite All Mutations", true, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.FavoriteMutation = v
    end)

    PetsMgmtSec:CreateButton("Favorite Pets Now", function()
        Helpers.FireRemoteByKeywords({"favorite", "lockpet"})
        Notify(Library, "Pets", "Marked qualifying pets as favorite.", 2)
    end)

    local PetsSellSec = PetsTab:CreateSection("Auto Sell Pets")

    PetsSellSec:CreateToggle("Auto Sell Pets", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoSellPet = v
    end)

    PetsSellSec:CreateDropdown(
        "Sell Pet Rule",
        { "Rarity Below", "Income Below", "Duplicates Only" },
        "Rarity Below",
        0.2,
        function(v) HubState.Settings.SellPetRule = v end
    )

    PetsSellSec:CreateDropdown(
        "Sell Below Rarity",
        { "Common", "Rare", "Epic", "Legendary" },
        "Rare",
        0.2,
        function(v) HubState.Settings.PetMaxRarity = v end
    )

    PetsSellSec:CreateSlider(
        "Income Threshold",
        10,
        5000,
        100,
        Color3.fromRGB(0, 170, 255),
        function(v) HubState.Settings.PetIncomeThreshold = v end
    )

    PetsSellSec:CreateDropdown(
        "Blacklist From Selling",
        { "None", "Favorites Only", "Mutations Only" },
        "Favorites Only",
        0.2,
        function(v) HubState.Settings.BlacklistSellPets = v end
    )

    PetsSellSec:CreateButton("Sell Matching Pets Now", function()
        Helpers.FireRemoteByKeywords({"sellpet", "sellpets"})
        Notify(Library, "Pets Sold", "Processed pet sale.", 2)
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 6.  MONSTER & ECONOMY TAB
    -- ════════════════════════════════════════════════════════════════════
    local EconomyTab = Window:CreateTab("Monster & Economy", false, "rbxassetid://10709761530")

    local MonsterSec = EconomyTab:CreateSection("Hungry Monster")

    MonsterSec:CreateToggle("Auto Feed Monster", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoFeedMonster = v
        Notify(Library, "Monster", v and "✅ Feeding Monster" or "⛔ Stopped", 2)
    end)

    MonsterSec:CreateDropdown(
        "Feed Max Rarity",
        { "Common", "Rare", "Epic", "Legendary" },
        "Rare",
        0.2,
        function(v) HubState.Settings.FeedMaxRarity = v end
    )

    MonsterSec:CreateToggle("Auto Claim Monster Chest", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoClaimChest = v
    end)

    local EggSellSec = EconomyTab:CreateSection("Egg Selling Merchant")

    EggSellSec:CreateToggle("Auto Sell Eggs", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.AutoSellEgg = v
    end)

    EggSellSec:CreateDropdown(
        "Sell Below Rarity",
        { "Common", "Rare", "Epic" },
        "Common",
        0.2,
        function(v) HubState.Settings.EggMaxRarity = v end
    )

    EggSellSec:CreateButton("Sell Eggs Now", function()
        Helpers.FireRemoteByKeywords({"sellegg", "selleggs"})
        Notify(Library, "Economy", "Sold qualifying eggs to merchant.", 2)
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 7.  LOCAL PLAYER TAB
    -- ════════════════════════════════════════════════════════════════════
    local PlayerTab = Window:CreateTab("Local Player", false, "rbxassetid://10709761530")

    local PlayerMoveSec = PlayerTab:CreateSection("Movement & Jump")

    PlayerMoveSec:CreateSlider(
        "WalkSpeed",
        16,
        350,
        16,
        Color3.fromRGB(0, 170, 255),
        function(v)
            HubState.Settings.WalkSpeed = v
            Modules.Player.SetWalkSpeed(v, Helpers)
        end
    )

    PlayerMoveSec:CreateSlider(
        "JumpPower",
        50,
        350,
        50,
        Color3.fromRGB(0, 170, 255),
        function(v)
            HubState.Settings.JumpPower = v
            Modules.Player.SetJumpPower(v, Helpers)
        end
    )

    local PlayerPresetsSec = PlayerTab:CreateSection("Speed Presets")

    PlayerPresetsSec:CreateButton("Default WalkSpeed (16)", function()
        HubState.Settings.WalkSpeed = 16
        Modules.Player.SetWalkSpeed(16, Helpers)
        Notify(Library, "Speed", "WalkSpeed set to 16", 2)
    end)

    PlayerPresetsSec:CreateButton("Fast Speed (50)", function()
        HubState.Settings.WalkSpeed = 50
        Modules.Player.SetWalkSpeed(50, Helpers)
        Notify(Library, "Speed", "WalkSpeed set to 50", 2)
    end)

    PlayerPresetsSec:CreateButton("Flash Speed (150)", function()
        HubState.Settings.WalkSpeed = 150
        Modules.Player.SetWalkSpeed(150, Helpers)
        Notify(Library, "Speed", "WalkSpeed set to 150", 2)
    end)

    PlayerPresetsSec:CreateButton("God Speed (300)", function()
        HubState.Settings.WalkSpeed = 300
        Modules.Player.SetWalkSpeed(300, Helpers)
        Notify(Library, "Speed", "WalkSpeed set to 300", 2)
    end)

    local PlayerBypassSec = PlayerTab:CreateSection("Anti-Cheat Bypass Movement")

    PlayerBypassSec:CreateToggle("CFrame Speed Hack", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.CFrameSpeed = v
    end)

    PlayerBypassSec:CreateSlider(
        "CFrame Multiplier",
        1,
        10,
        2,
        Color3.fromRGB(0, 170, 255),
        function(v) HubState.Settings.CFrameSpeedMultiplier = v end
    )

    local PlayerAbilitiesSec = PlayerTab:CreateSection("Player Abilities")

    PlayerAbilitiesSec:CreateToggle("Infinite Jump", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.InfJump = v
    end)

    PlayerAbilitiesSec:CreateToggle("Noclip (Walk Through Walls)", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        HubState.Settings.Noclip = v
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 8.  VISUALS (ESP) TAB
    -- ════════════════════════════════════════════════════════════════════
    local VisualsTab = Window:CreateTab("Visuals (ESP)", false, "rbxassetid://10709761530")

    local VisualsHighlightSec = VisualsTab:CreateSection("ESP Highlights")

    VisualsHighlightSec:CreateToggle("ESP Eggs", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        Modules.Visuals.SetEggESP(v, HubState)
        Notify(Library, "Visuals", v and "Egg ESP Enabled" or "Egg ESP Disabled", 2)
    end)

    VisualsHighlightSec:CreateToggle("ESP Players", false, Color3.fromRGB(0, 255, 120), 0.2, function(v)
        Modules.Visuals.SetPlayerESP(v, HubState)
        Notify(Library, "Visuals", v and "Player ESP Enabled" or "Player ESP Disabled", 2)
    end)

    local VisualsLegendSec = VisualsTab:CreateSection("ESP Color Legend")

    VisualsLegendSec:CreateParagraph(
        "Color Guide",
        "• Green: Infested / Toxic Eggs\n• Red: Regular Eggs\n• Yellow / Cyan: Secret / Divine Eggs"
    )

    -- ════════════════════════════════════════════════════════════════════
    -- 9.  SETTINGS TAB
    -- ════════════════════════════════════════════════════════════════════
    local SettingsTab = Window:CreateTab("Settings", false, "rbxassetid://10709761530")

    local SettingsThemeSec = SettingsTab:CreateSection("Theme & Aesthetics")

    SettingsThemeSec:CreateDropdown(
        "Select Theme",
        {
            "Nordic Dark", "Default", "Lighter", "Light", "Light+",
            "Discord", "Red And Black", "Nordic Light", "Purple",
            "Sentinel", "Synapse X", "Krnl", "Script-Ware", "Kiriot"
        },
        "Nordic Dark",
        0.2,
        function(v)
            pcall(function()
                if Library and type(Library.ChangeTheme) == "function" then
                    Library:ChangeTheme(v)
                    Notify(Library, "Theme Changed", "Theme set to " .. v, 2)
                end
            end)
        end
    )

    SettingsThemeSec:CreateSlider(
        "UI Transparency (%)",
        0,
        90,
        0,
        Color3.fromRGB(0, 170, 255),
        function(v)
            pcall(function()
                if Library and type(Library.SetTransparency) == "function" then
                    Library:SetTransparency(v / 100)
                end
            end)
        end
    )

    local SettingsControlsSec = SettingsTab:CreateSection("Keybinds & Controls")

    SettingsControlsSec:CreateKeybind(
        "Toggle UI Key",
        "RightControl",
        function()
            pcall(function()
                if Library and type(Library.ToggleUI) == "function" then
                    Library:ToggleUI()
                end
            end)
        end
    )

    SettingsControlsSec:CreateButton("Toggle UI Visibility (Show / Hide)", function()
        pcall(function()
            if Library and type(Library.ToggleUI) == "function" then
                Library:ToggleUI()
            end
        end)
    end)

    local SettingsInfoSec = SettingsTab:CreateSection("Script Information")

    SettingsInfoSec:CreateParagraph(
        "Exiles Script Hub",
        "Version: v3.5 (Visual UI)\nDeveloper: DEV ZAX\nDiscord: discord.gg/exileshub\nUI Engine: Visual UI Library"
    )

    SettingsInfoSec:CreateButton("Unload / Close Exiles Hub", function()
        Notify(Library, "Unloading", "Stopping automation loops...", 2)
        task.wait(0.3)
        HubState.Cleanup()
        pcall(function()
            if Library and type(Library.DestroyUI) == "function" then
                Library:DestroyUI()
            end
        end)
        pcall(function()
            local core = game:GetService("CoreGui"):FindFirstChild("Visual UI Library | .gg/puxxCphTnK")
            if core then core:Destroy() end
        end)
        pcall(function()
            local notif = game:GetService("CoreGui"):FindFirstChild("Visual UI Library | .gg/puxxCphTnK | Notifications")
            if notif then notif:Destroy() end
        end)
        Notify(Library, "Exiles Hub", "Script unloaded safely.", 3)
    end)

    return Window
end

return UILayout
