--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║      EXILES SCRIPT HUB  ·  REDZ UI REDESIGN               ║
    ║      Library : RedzLib (RedzHub UI)                       ║
    ║      Theme   : Darker / Obsidian Custom                   ║
    ║      Author  : DEV ZAX                                     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local UILayout = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ── Toast Notification Helper ─────────────────────────────────────────────
local function Notify(title, content, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Exiles Hub",
            Text = content or "",
            Duration = duration or 3,
        })
    end)
end

function UILayout.Build(redzlib, HubState, Helpers, Modules)
    -- ── Create Window ─────────────────────────────────────────────────────
    local Window = redzlib:MakeWindow({
        Title = "Exiles Hub · Steal An Egg",
        SubTitle = "DEV ZAX",
        SaveFolder = "ExilesHub_StealAnEgg"
    })

    -- ── Add Minimize Floating Button ──────────────────────────────────────
    pcall(function()
        Window:AddMinimizeButton({
            Button = {
                Image = redzlib:GetIcon("egg") or "rbxassetid://10709761530",
                BackgroundTransparency = 0
            },
            Corner = {
                CornerRadius = UDim.new(35, 1)
            },
        })
    end)

    Notify("⚡ Exiles Hub", "Redz UI Loaded — Welcome " .. (LocalPlayer.DisplayName or LocalPlayer.Name), 4)

    -- ════════════════════════════════════════════════════════════════════
    -- 1.  HOME & DASHBOARD TAB
    -- ════════════════════════════════════════════════════════════════════
    local HomeTab = Window:MakeTab({
        Name = "Home",
        Icon = "home"
    })

    HomeTab:AddSection("Welcome to Exiles Hub")

    HomeTab:AddParagraph({
        "DEV ZAX  ·  Exiles Hub v3.5",
        "Hello " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " (@" .. LocalPlayer.Name .. ")\nGame: Steal An Egg (ID: 107778070777162)\nStatus: Operational & Undetected"
    })

    HomeTab:AddDiscordInvite({
        Name = "Exiles Hub Community",
        Description = "Join our Discord for updates, free scripts & community support!",
        Logo = "rbxassetid://10709761530",
        Invite = "https://discord.gg/exileshub"
    })

    HomeTab:AddSection("Quick Actions")

    HomeTab:AddButton({
        Name = "Copy Discord Link (.gg/exileshub)",
        Callback = function()
            pcall(function()
                setclipboard("https://discord.gg/exileshub")
                Notify("Discord Copied", "discord.gg/exileshub copied to clipboard!", 3)
            end)
        end
    })

    HomeTab:AddButton({
        Name = "Copy Profile Link",
        Callback = function()
            pcall(function()
                setclipboard("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile")
                Notify("Profile Copied", "Profile link copied to clipboard!", 3)
            end)
        end
    })

    HomeTab:AddButton({
        Name = "Rejoin Current Server",
        Callback = function()
            Notify("Rejoining", "Connecting back to server...", 2)
            task.wait(0.5)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    })

    HomeTab:AddButton({
        Name = "Server Hop (Smallest)",
        Callback = function()
            pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local res = game:HttpGet(url)
                local data = HttpService:JSONDecode(res)
                if data and data.data then
                    for _, s in ipairs(data.data) do
                        if s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                            Notify("Server Hopping", "Connecting to new server...", 2)
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                            return
                        end
                    end
                end
                Notify("Server Hop", "No alternative server found.", 3)
            end)
        end
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 2.  EGG PREDICTOR & SERVER TRACKER TAB
    -- ════════════════════════════════════════════════════════════════════
    local PredictorTab = Window:MakeTab({
        Name = "Egg Predictor",
        Icon = "activity"
    })

    PredictorTab:AddSection("Live Game & Night Cycle Forecast")

    local PredictorStatus = PredictorTab:AddParagraph({
        "Cycle Forecast",
        "Spawn Cycle: 05:00\nIn-Game Clock: " .. string.format("%.2f", Lighting.ClockTime) .. ":00\nNight Cycle: Calculating..."
    })

    local PredictorStats = PredictorTab:AddParagraph({
        "Detected Eggs",
        "Divine: 0  |  Eternal: 0  |  Secret: 0  |  Total: 0"
    })

    PredictorTab:AddSection("Timer Sync & Calibration")

    PredictorTab:AddButton({
        Name = "🌙 Sync With In-Game Night Cycle",
        Callback = function()
            if Modules.Predictor and Modules.Predictor.SyncWithLighting then
                local s, rem = Modules.Predictor.SyncWithLighting()
                if s then
                    Notify("🌙 Night Synced", "Forecast calibrated: " .. string.format("%02d:%02d", math.floor(rem/60), rem%60), 3)
                else
                    Notify("Timer", "Sync completed.", 2)
                end
            end
        end
    })

    PredictorTab:AddButton({
        Name = "🔄 Reset Spawn Timer (05:00)",
        Callback = function()
            if Modules.Predictor and Modules.Predictor.SyncTimer then
                Modules.Predictor.SyncTimer(300)
                Notify("Timer Reset", "Spawn cycle reset to 05:00", 2)
            end
        end
    })

    PredictorTab:AddButton({
        Name = "⏩ +10s Fine Tune Offset",
        Callback = function()
            if Modules.Predictor and Modules.Predictor.AdjustManualOffset then
                Modules.Predictor.AdjustManualOffset(10)
                Notify("Timer Calibrated", "+10s applied to forecast", 2)
            end
        end
    })

    PredictorTab:AddButton({
        Name = "⏪ -10s Fine Tune Offset",
        Callback = function()
            if Modules.Predictor and Modules.Predictor.AdjustManualOffset then
                Modules.Predictor.AdjustManualOffset(-10)
                Notify("Timer Calibrated", "-10s applied to forecast", 2)
            end
        end
    })

    PredictorTab:AddSection("Detection & Auto-Steal Controls")

    PredictorTab:AddToggle({
        Name = "Predictor & Tracker Enabled",
        Default = true,
        Callback = function(v)
            HubState.Settings.PredictorEnabled = v
            Notify("Predictor", v and "Detection Engine ON" or "Detection Engine OFF", 2)
        end
    })

    PredictorTab:AddToggle({
        Name = "Auto-Steal On Detect",
        Default = false,
        Callback = function(v)
            HubState.Settings.AutoStealPredicted = v
            Notify("Auto-Steal Target", v and "Will claim rare eggs on spawn" or "Disabled", 2)
        end
    })

    PredictorTab:AddToggle({
        Name = "Predictor ESP Beacons",
        Default = true,
        Callback = function(v)
            HubState.Settings.PredictorESP = v
            if Modules.Predictor and Modules.Predictor.UpdateESP then
                Modules.Predictor.UpdateESP(v)
            end
        end
    })

    PredictorTab:AddToggle({
        Name = "Notify Divine (Tier 10)",
        Default = true,
        Callback = function(v) HubState.Settings.NotifyDivine = v end
    })

    PredictorTab:AddToggle({
        Name = "Notify Eternal (Tier 9)",
        Default = true,
        Callback = function(v) HubState.Settings.NotifyEternal = v end
    })

    PredictorTab:AddToggle({
        Name = "Notify Secret (Tier 8)",
        Default = true,
        Callback = function(v) HubState.Settings.NotifySecret = v end
    })

    PredictorTab:AddSection("1-Click Instant Target Steal")

    local Slot1Btn = PredictorTab:AddButton({
        Name = "Slot 1: Scanning for high-tier egg...",
        Callback = function() end
    })

    local Slot2Btn = PredictorTab:AddButton({
        Name = "Slot 2: Scanning for high-tier egg...",
        Callback = function() end
    })

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
                                Notify("Target Steal", "Teleporting to " .. e1.Name, 2)
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
                                Notify("Target Steal", "Teleporting to " .. e2.Name, 2)
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
    local StealTab = Window:MakeTab({
        Name = "Auto Steal",
        Icon = "swords"
    })

    StealTab:AddSection("Auto Steal Engine")

    StealTab:AddToggle({
        Name = "Auto Steal Eggs",
        Default = false,
        Callback = function(v)
            HubState.Settings.AutoSteal = v
            Notify("Auto Steal", v and "✅ Auto Steal Active" or "⛔ Auto Steal Stopped", 2)
        end
    })

    StealTab:AddToggle({
        Name = "Steal Infested Eggs",
        Default = true,
        Callback = function(v) HubState.Settings.StealInfested = v end
    })

    StealTab:AddToggle({
        Name = "Anti-Trap (Bypass Traps)",
        Default = true,
        Callback = function(v) HubState.Settings.AntiTrap = v end
    })

    StealTab:AddSection("Base Deposit Settings")

    StealTab:AddToggle({
        Name = "Auto Place Egg On Base Nest",
        Default = true,
        Callback = function(v) HubState.Settings.AutoPlaceEgg = v end
    })

    StealTab:AddToggle({
        Name = "Skip Infested Egg Placement",
        Default = true,
        Callback = function(v) HubState.Settings.DontPlaceInfested = v end
    })

    StealTab:AddSection("Targeting Rules")

    StealTab:AddDropdown({
        Name = "Steal Priority",
        Options = { "Highest Rarity", "Nearest Egg", "Infested First" },
        Default = "Highest Rarity",
        Callback = function(v) HubState.Settings.StealPriority = v end
    })

    StealTab:AddDropdown({
        Name = "Target Egg Tier",
        Options = { "All Eggs", "Legendary & Up", "Epic & Up", "Only Infested" },
        Default = "All Eggs",
        Callback = function(v) HubState.Settings.TargetSpecificEggs = v end
    })

    StealTab:AddDropdown({
        Name = "Target Areas",
        Options = { "All Areas", "Enemy Bases", "Center Zone", "Rare Spawns" },
        Default = "All Areas",
        Callback = function(v) HubState.Settings.TargetAreas = v end
    })

    StealTab:AddSection("Speed & Timing")

    StealTab:AddSlider({
        Name = "Tween Speed",
        Min = 15,
        Max = 120,
        Increase = 5,
        Default = 35,
        Callback = function(v) HubState.Settings.TweenSpeed = v end
    })

    StealTab:AddSlider({
        Name = "Steal Timeout (Seconds)",
        Min = 1,
        Max = 15,
        Increase = 1,
        Default = 5,
        Callback = function(v) HubState.Settings.StealTimeout = v end
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 4.  TREADMILL & BASE TAB
    -- ════════════════════════════════════════════════════════════════════
    local TreadmillTab = Window:MakeTab({
        Name = "Treadmill & Base",
        Icon = "gauge"
    })

    TreadmillTab:AddSection("Speed Boost Farming")

    TreadmillTab:AddToggle({
        Name = "Auto Treadmill Farm",
        Default = false,
        Callback = function(v)
            HubState.Settings.AutoTreadmill = v
            Notify("Treadmill", v and "✅ Auto Treadmill Active" or "⛔ Stopped", 2)
        end
    })

    TreadmillTab:AddToggle({
        Name = "Hide Treadmill (Anti-Detection)",
        Default = false,
        Callback = function(v)
            HubState.Settings.HideTreadmill = v
            Modules.Treadmill.SetHideTreadmill(v)
        end
    })

    TreadmillTab:AddButton({
        Name = "Exit Treadmill Now",
        Callback = function()
            HubState.Settings.AutoTreadmill = false
            Modules.Treadmill.Exit(Helpers)
            Notify("Treadmill", "Exited treadmill safe spot.", 2)
        end
    })

    TreadmillTab:AddSection("Base Upgrades & Rewards")

    TreadmillTab:AddToggle({
        Name = "Auto Upgrade Treadmill",
        Default = false,
        Callback = function(v) HubState.Settings.AutoUpgradeTreadmill = v end
    })

    TreadmillTab:AddToggle({
        Name = "Auto Upgrade Base Nest",
        Default = false,
        Callback = function(v) HubState.Settings.AutoUpgradeBase = v end
    })

    TreadmillTab:AddToggle({
        Name = "Auto Buy Speed Trail",
        Default = false,
        Callback = function(v) HubState.Settings.AutoBuyTrail = v end
    })

    TreadmillTab:AddToggle({
        Name = "Auto Claim Daily & Free Gifts",
        Default = false,
        Callback = function(v) HubState.Settings.AutoClaim = v end
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 5.  PETS & HATCHING TAB
    -- ════════════════════════════════════════════════════════════════════
    local PetsTab = Window:MakeTab({
        Name = "Pets & Hatching",
        Icon = "star"
    })

    PetsTab:AddSection("Egg Opener")

    PetsTab:AddDropdown({
        Name = "Select Egg Type",
        Options = {
            "Basic Egg", "Rare Egg", "Epic Egg",
            "Legendary Egg", "Mythic Egg", "Infested Egg", "Void Egg"
        },
        Default = "Basic Egg",
        Callback = function(v) HubState.Settings.EggScope = v end
    })

    PetsTab:AddToggle({
        Name = "Auto Hatch Selected Egg",
        Default = false,
        Callback = function(v)
            HubState.Settings.AutoHatch = v
            Notify("Auto Hatch", v and ("✅ Hatching " .. HubState.Settings.EggScope) or "⛔ Stopped", 2)
        end
    })

    PetsTab:AddSection("Pet Management")

    PetsTab:AddToggle({
        Name = "Auto Equip Best Pets",
        Default = false,
        Callback = function(v) HubState.Settings.AutoEquipBest = v end
    })

    PetsTab:AddToggle({
        Name = "Auto Favorite Pet",
        Default = false,
        Callback = function(v) HubState.Settings.AutoFavoritePet = v end
    })

    PetsTab:AddDropdown({
        Name = "Favorite Min Rarity",
        Options = { "Rare", "Epic", "Legendary", "Mythic" },
        Default = "Legendary",
        Callback = function(v) HubState.Settings.FavoriteMinRarity = v end
    })

    PetsTab:AddToggle({
        Name = "Favorite All Mutations",
        Default = true,
        Callback = function(v) HubState.Settings.FavoriteMutation = v end
    })

    PetsTab:AddButton({
        Name = "Favorite Pets Now",
        Callback = function()
            Helpers.FireRemoteByKeywords({"favorite", "lockpet"})
            Notify("Pets", "Marked qualifying pets as favorite.", 2)
        end
    })

    PetsTab:AddSection("Auto Sell Pets")

    PetsTab:AddToggle({
        Name = "Auto Sell Pets",
        Default = false,
        Callback = function(v) HubState.Settings.AutoSellPet = v end
    })

    PetsTab:AddDropdown({
        Name = "Sell Pet Rule",
        Options = { "Rarity Below", "Income Below", "Duplicates Only" },
        Default = "Rarity Below",
        Callback = function(v) HubState.Settings.SellPetRule = v end
    })

    PetsTab:AddDropdown({
        Name = "Sell Below Rarity",
        Options = { "Common", "Rare", "Epic", "Legendary" },
        Default = "Rare",
        Callback = function(v) HubState.Settings.PetMaxRarity = v end
    })

    PetsTab:AddSlider({
        Name = "Income Threshold",
        Min = 10,
        Max = 5000,
        Increase = 50,
        Default = 100,
        Callback = function(v) HubState.Settings.PetIncomeThreshold = v end
    })

    PetsTab:AddDropdown({
        Name = "Blacklist From Selling",
        Options = { "None", "Favorites Only", "Mutations Only" },
        Default = "Favorites Only",
        Callback = function(v) HubState.Settings.BlacklistSellPets = v end
    })

    PetsTab:AddButton({
        Name = "Sell Matching Pets Now",
        Callback = function()
            Helpers.FireRemoteByKeywords({"sellpet", "sellpets"})
            Notify("Pets Sold", "Processed pet sale.", 2)
        end
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 6.  MONSTER & ECONOMY TAB
    -- ════════════════════════════════════════════════════════════════════
    local EconomyTab = Window:MakeTab({
        Name = "Monster & Economy",
        Icon = "ghost"
    })

    EconomyTab:AddSection("Hungry Monster")

    EconomyTab:AddToggle({
        Name = "Auto Feed Monster",
        Default = false,
        Callback = function(v)
            HubState.Settings.AutoFeedMonster = v
            Notify("Monster", v and "✅ Feeding Monster" or "⛔ Stopped", 2)
        end
    })

    EconomyTab:AddDropdown({
        Name = "Feed Max Rarity",
        Options = { "Common", "Rare", "Epic", "Legendary" },
        Default = "Rare",
        Callback = function(v) HubState.Settings.FeedMaxRarity = v end
    })

    EconomyTab:AddToggle({
        Name = "Auto Claim Monster Chest",
        Default = false,
        Callback = function(v) HubState.Settings.AutoClaimChest = v end
    })

    EconomyTab:AddSection("Egg Selling Merchant")

    EconomyTab:AddToggle({
        Name = "Auto Sell Eggs",
        Default = false,
        Callback = function(v) HubState.Settings.AutoSellEgg = v end
    })

    EconomyTab:AddDropdown({
        Name = "Sell Below Rarity",
        Options = { "Common", "Rare", "Epic" },
        Default = "Common",
        Callback = function(v) HubState.Settings.EggMaxRarity = v end
    })

    EconomyTab:AddButton({
        Name = "Sell Eggs Now",
        Callback = function()
            Helpers.FireRemoteByKeywords({"sellegg", "selleggs"})
            Notify("Economy", "Sold qualifying eggs to merchant.", 2)
        end
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 7.  LOCAL PLAYER TAB
    -- ════════════════════════════════════════════════════════════════════
    local PlayerTab = Window:MakeTab({
        Name = "Local Player",
        Icon = "user"
    })

    PlayerTab:AddSection("Movement & Jump")

    PlayerTab:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 350,
        Increase = 1,
        Default = 16,
        Callback = function(v)
            HubState.Settings.WalkSpeed = v
            Modules.Player.SetWalkSpeed(v, Helpers)
        end
    })

    PlayerTab:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 350,
        Increase = 5,
        Default = 50,
        Callback = function(v)
            HubState.Settings.JumpPower = v
            Modules.Player.SetJumpPower(v, Helpers)
        end
    })

    PlayerTab:AddSection("Speed Presets")

    PlayerTab:AddButton({
        Name = "Default WalkSpeed (16)",
        Callback = function()
            HubState.Settings.WalkSpeed = 16
            Modules.Player.SetWalkSpeed(16, Helpers)
            Notify("Speed", "WalkSpeed set to 16", 2)
        end
    })

    PlayerTab:AddButton({
        Name = "Fast Speed (50)",
        Callback = function()
            HubState.Settings.WalkSpeed = 50
            Modules.Player.SetWalkSpeed(50, Helpers)
            Notify("Speed", "WalkSpeed set to 50", 2)
        end
    })

    PlayerTab:AddButton({
        Name = "Flash Speed (150)",
        Callback = function()
            HubState.Settings.WalkSpeed = 150
            Modules.Player.SetWalkSpeed(150, Helpers)
            Notify("Speed", "WalkSpeed set to 150", 2)
        end
    })

    PlayerTab:AddButton({
        Name = "God Speed (300)",
        Callback = function()
            HubState.Settings.WalkSpeed = 300
            Modules.Player.SetWalkSpeed(300, Helpers)
            Notify("Speed", "WalkSpeed set to 300", 2)
        end
    })

    PlayerTab:AddSection("Anti-Cheat Bypass Movement")

    PlayerTab:AddToggle({
        Name = "CFrame Speed Hack",
        Default = false,
        Callback = function(v) HubState.Settings.CFrameSpeed = v end
    })

    PlayerTab:AddSlider({
        Name = "CFrame Multiplier",
        Min = 1,
        Max = 10,
        Increase = 1,
        Default = 2,
        Callback = function(v) HubState.Settings.CFrameSpeedMultiplier = v end
    })

    PlayerTab:AddSection("Player Abilities")

    PlayerTab:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(v) HubState.Settings.InfJump = v end
    })

    PlayerTab:AddToggle({
        Name = "Noclip (Walk Through Walls)",
        Default = false,
        Callback = function(v) HubState.Settings.Noclip = v end
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 8.  VISUALS (ESP) TAB
    -- ════════════════════════════════════════════════════════════════════
    local VisualsTab = Window:MakeTab({
        Name = "Visuals (ESP)",
        Icon = "eye"
    })

    VisualsTab:AddSection("ESP Highlights")

    VisualsTab:AddToggle({
        Name = "ESP Eggs",
        Default = false,
        Callback = function(v)
            Modules.Visuals.SetEggESP(v, HubState)
            Notify("Visuals", v and "Egg ESP Enabled" or "Egg ESP Disabled", 2)
        end
    })

    VisualsTab:AddToggle({
        Name = "ESP Players",
        Default = false,
        Callback = function(v)
            Modules.Visuals.SetPlayerESP(v, HubState)
            Notify("Visuals", v and "Player ESP Enabled" or "Player ESP Disabled", 2)
        end
    })

    VisualsTab:AddSection("ESP Color Legend")

    VisualsTab:AddParagraph({
        "Color Guide",
        "• Green: Infested / Toxic Eggs\n• Red: Regular Eggs\n• Yellow / Cyan: Secret / Divine Eggs"
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 9.  SETTINGS TAB
    -- ════════════════════════════════════════════════════════════════════
    local SettingsTab = Window:MakeTab({
        Name = "Settings",
        Icon = "settings"
    })

    SettingsTab:AddSection("Theme & Style")

    SettingsTab:AddDropdown({
        Name = "Select Theme",
        Options = { "Darker", "Dark", "Purple" },
        Default = "Darker",
        Callback = function(v)
            pcall(function()
                redzlib:SetTheme(v)
                Notify("Theme", "Switched theme to " .. v, 2)
            end)
        end
    })

    SettingsTab:AddSection("Script Information")

    SettingsTab:AddParagraph({
        "Exiles Script Hub",
        "Version: v3.5 (Redz UI)\nDeveloper: DEV ZAX\nDiscord: discord.gg/exileshub"
    })

    SettingsTab:AddButton({
        Name = "Unload / Close Exiles Hub",
        Callback = function()
            Window:Dialog({
                Title = "Unload Hub",
                Text = "Are you sure you want to stop all automation and unload the UI?",
                Options = {
                    { "Confirm", function()
                        HubState.Cleanup()
                        pcall(function()
                            local core = game:GetService("CoreGui"):FindFirstChild("redz Library V5")
                            if core then core:Destroy() end
                        end)
                        Notify("Exiles Hub", "Script unloaded safely.", 3)
                    end },
                    { "Cancel", function() end }
                }
            })
        end
    })

    return Window
end

return UILayout
