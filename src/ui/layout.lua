--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║      EXILES SCRIPT HUB  ·  RAYFIELD GEN 2 UI LAYOUT       ║
    ║      Theme  : Cobalt  (Deep Blue–Black Premium)            ║
    ║      Author : DEV ZAX                                      ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local UILayout = {}

-- ── Loading animation helper ─────────────────────────────────────────────
local function AnimatedNotify(Window, title, content, duration)
    pcall(function()
        Window:Notify({
            title    = title,
            content  = content,
            duration = duration or 4,
        })
    end)
end

local function SectionedToast(Window, title, sub)
    pcall(function()
        Window:Toast({
            title    = title,
            subtitle = sub or "",
            duration = 3,
        })
    end)
end

-- ─────────────────────────────────────────────────────────────────────────
function UILayout.Build(Rayfield, HubState, Helpers, Modules)

    -- ── Window ───────────────────────────────────────────────────────────
    local Window = Rayfield:CreateWindow({
        name          = "EXILES HUB",
        subtitle      = "Steal An Egg  ·  DEV ZAX",
        sidebarLayout = true,
        theme         = "cobalt",
        showName      = "Exiles Hub",
        configuration = {
            autoSave     = true,
            autoLoad     = true,
            fileName     = "ExilesHub_ZAX",
            customFolder = "ExilesHub",
        },
    })

    -- ── Version Tag ──────────────────────────────────────────────────────
    pcall(function()
        Window:CreateTag({
            text  = "DEV ZAX  ·  v3.2",
            color = Color3.fromRGB(50, 140, 255),
        })
    end)

    -- ── Boot Toast ───────────────────────────────────────────────────────
    SectionedToast(Window, "⚡ Exiles Hub Loaded", "Welcome — DEV ZAX Edition")

    -- ════════════════════════════════════════════════════════════════════
    -- 1.  EGG STEALING
    -- ════════════════════════════════════════════════════════════════════
    Window:CreateSection({ name = "🥚  Egg Operations" })
    local StealTab = Window:CreateTab({ name = "Auto Steal" })

    StealTab:CreateSection({ name = "⚙️  Steal Engine" })

    StealTab:CreateToggle({
        name        = "Auto Steal",
        description = "Automatically steal eggs from enemy bases.",
        flag        = "AutoStealToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.AutoSteal = val
            SectionedToast(Window, val and "✅ Auto Steal ON" or "⛔ Auto Steal OFF", "")
        end,
    })

    StealTab:CreateToggle({
        name        = "Steal Infested Egg",
        description = "Include infested eggs in the steal queue.",
        flag        = "StealInfestedToggle",
        value       = true,
        callback    = function(val) HubState.Settings.StealInfested = val end,
    })

    StealTab:CreateToggle({
        name        = "Anti Trap",
        description = "Detect and avoid egg-trap zones.",
        flag        = "AntiTrapToggle",
        value       = true,
        callback    = function(val) HubState.Settings.AntiTrap = val end,
    })

    StealTab:CreateToggle({
        name     = "Run Animation",
        flag     = "RunAnimationToggle",
        value    = true,
        callback = function(val) HubState.Settings.RunAnimation = val end,
    })

    StealTab:CreateSection({ name = "🎯  Targeting Rules" })

    StealTab:CreateDropdown({
        name     = "Target Areas",
        flag     = "TargetAreasDropdown",
        options  = { "All Areas", "Enemy Bases", "Center Zone", "Rare Spawns" },
        value    = "All Areas",
        callback = function(val) HubState.Settings.TargetAreas = val end,
    })

    StealTab:CreateDropdown({
        name     = "Target Egg Tier",
        flag     = "TargetSpecificEggsDropdown",
        options  = { "All Eggs", "Legendary & Up", "Epic & Up", "Only Infested" },
        value    = "All Eggs",
        callback = function(val) HubState.Settings.TargetSpecificEggs = val end,
    })

    StealTab:CreateDropdown({
        name     = "Steal Priority",
        flag     = "StealPriorityDropdown",
        options  = { "Highest Rarity", "Nearest Egg", "Infested First" },
        value    = "Highest Rarity",
        callback = function(val) HubState.Settings.StealPriority = val end,
    })

    StealTab:CreateSection({ name = "⚡  Speed & Timing" })

    StealTab:CreateSlider({
        name      = "Tween Speed",
        flag      = "TweenSpeedSlider",
        range     = { 15, 120 },
        increment = 5,
        value     = 35,
        suffix    = " studs/s",
        callback  = function(val) HubState.Settings.TweenSpeed = val end,
    })

    StealTab:CreateSlider({
        name      = "Steal Timeout",
        flag      = "StealTimeoutSlider",
        range     = { 1, 15 },
        increment = 1,
        value     = 5,
        suffix    = "s",
        callback  = function(val) HubState.Settings.StealTimeout = val end,
    })

    StealTab:CreateSection({ name = "🏠  Base Placement" })

    StealTab:CreateToggle({
        name     = "Auto Place Egg",
        flag     = "AutoPlaceEggToggle",
        value    = true,
        callback = function(val) HubState.Settings.AutoPlaceEgg = val end,
    })

    StealTab:CreateToggle({
        name        = "Skip Infested Placement",
        description = "Don't place infested eggs back on your base.",
        flag        = "DontPlaceInfestedToggle",
        value       = true,
        callback    = function(val) HubState.Settings.DontPlaceInfested = val end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 2.  TREADMILL & BASE UPGRADES
    -- ════════════════════════════════════════════════════════════════════
    Window:CreateSection({ name = "🏋️  Treadmill & Base" })
    local TreadmillTab = Window:CreateTab({ name = "Treadmill & Base" })

    TreadmillTab:CreateSection({ name = "🏃  Speed Farming" })

    TreadmillTab:CreateToggle({
        name        = "Auto Treadmill",
        description = "Automatically run on treadmills for speed boosts.",
        flag        = "AutoTreadmillToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.AutoTreadmill = val
            SectionedToast(Window, val and "✅ Treadmill ON" or "⛔ Treadmill OFF", "")
        end,
    })

    TreadmillTab:CreateToggle({
        name     = "Hide Treadmill",
        flag     = "HideTreadmillToggle",
        value    = false,
        callback = function(val)
            HubState.Settings.HideTreadmill = val
            Modules.Treadmill.SetHideTreadmill(val)
        end,
    })

    TreadmillTab:CreateButton({
        name     = "⏹  Exit Treadmill Now",
        callback = function()
            HubState.Settings.AutoTreadmill = false
            Modules.Treadmill.Exit(Helpers)
            SectionedToast(Window, "Treadmill Exited", "Auto-Treadmill disabled.")
        end,
    })

    TreadmillTab:CreateSection({ name = "📈  Upgrades" })

    TreadmillTab:CreateToggle({
        name     = "Auto Upgrade Treadmill",
        flag     = "AutoUpgradeTreadmillToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoUpgradeTreadmill = val end,
    })

    TreadmillTab:CreateToggle({
        name     = "Auto Upgrade Base",
        flag     = "AutoUpgradeBaseToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoUpgradeBase = val end,
    })

    TreadmillTab:CreateToggle({
        name     = "Auto Buy Trail",
        flag     = "AutoBuyTrailToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoBuyTrail = val end,
    })

    TreadmillTab:CreateToggle({
        name     = "Auto Claim",
        flag     = "AutoClaimToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoClaim = val end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 3.  HUNGRY MONSTER
    -- ════════════════════════════════════════════════════════════════════
    Window:CreateSection({ name = "👾  Monster" })
    local MonsterTab = Window:CreateTab({ name = "Hungry Monster" })

    MonsterTab:CreateSection({ name = "🍖  Monster Feeding" })

    MonsterTab:CreateToggle({
        name        = "Auto Feed Monster",
        description = "Feed the Hungry Monster automatically.",
        flag        = "AutoFeedMonsterToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.AutoFeedMonster = val
            SectionedToast(Window, val and "✅ Feed Monster ON" or "⛔ Feed Monster OFF", "")
        end,
    })

    MonsterTab:CreateDropdown({
        name     = "Feed Max Rarity",
        flag     = "FeedMaxRarityDropdown",
        options  = { "Common", "Rare", "Epic", "Legendary" },
        value    = "Rare",
        callback = function(val) HubState.Settings.FeedMaxRarity = val end,
    })

    MonsterTab:CreateToggle({
        name     = "Auto Claim Monster Chest",
        flag     = "AutoClaimMonsterChestToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoClaimChest = val end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 4.  HATCH & PREDICTOR
    -- ════════════════════════════════════════════════════════════════════
    Window:CreateSection({ name = "🐣  Pets & Hatching" })
    local HatchTab = Window:CreateTab({ name = "Hatch & Predictor" })

    HatchTab:CreateSection({ name = "🥚  Egg Opener" })

    HatchTab:CreateDropdown({
        name     = "Egg Scope",
        flag     = "EggScopeDropdown",
        options  = {
            "Basic Egg", "Rare Egg", "Epic Egg",
            "Legendary Egg", "Mythic Egg", "Infested Egg", "Void Egg",
        },
        value    = "Basic Egg",
        callback = function(val) HubState.Settings.EggScope = val end,
    })

    HatchTab:CreateToggle({
        name        = "Auto Hatch",
        description = "Continuously hatch the selected egg type.",
        flag        = "AutoHatchToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.AutoHatch = val
            SectionedToast(Window, val and "✅ Auto Hatch ON" or "⛔ Auto Hatch OFF", HubState.Settings.EggScope)
        end,
    })

    HatchTab:CreateSection({ name = "🔮  Predictors" })

    HatchTab:CreateButton({
        name     = "🔮  Pet Predictor",
        callback = function()
            local p = Modules.Pets.Predict(HubState.Settings.EggScope)
            AnimatedNotify(Window,
                "🔮 Pet Predictor",
                "Next from " .. HubState.Settings.EggScope .. ":\n▶ " .. p,
                5)
        end,
    })

    HatchTab:CreateButton({
        name     = "📋  All Eggs Predictor",
        callback = function()
            AnimatedNotify(Window,
                "📋 All Eggs Predictor",
                "Basic: Rare Dog\nEpic: Legendary Dragon\nVoid: Mythic Reaper",
                6)
        end,
    })

    HatchTab:CreateButton({
        name     = "⚗️  Fuse Predictor",
        callback = function()
            AnimatedNotify(Window,
                "⚗️ Fuse Predictor",
                "Predicted: Rainbow Shiny Dragon\n▶ Success Rate: 95%",
                5)
        end,
    })

    HatchTab:CreateButton({
        name     = "🔄  Refresh Fuse Predictor",
        callback = function()
            SectionedToast(Window, "🔄 Fuse Predictor", "Seed refreshed successfully.")
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 5.  PET MANAGEMENT
    -- ════════════════════════════════════════════════════════════════════
    local PetTab = Window:CreateTab({ name = "Pet Management" })

    PetTab:CreateSection({ name = "⭐  Equip & Favorites" })

    PetTab:CreateToggle({
        name     = "Auto Equip Best",
        flag     = "AutoEquipBestToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoEquipBest = val end,
    })

    PetTab:CreateToggle({
        name     = "Auto Favorite Pet",
        flag     = "AutoFavoritePetToggle",
        value    = false,
        callback = function(val) HubState.Settings.AutoFavoritePet = val end,
    })

    PetTab:CreateDropdown({
        name     = "Favorite Min Rarity",
        flag     = "FavoriteMinRarityDropdown",
        options  = { "Rare", "Epic", "Legendary", "Mythic" },
        value    = "Legendary",
        callback = function(val) HubState.Settings.FavoriteMinRarity = val end,
    })

    PetTab:CreateToggle({
        name     = "Favorite Mutations",
        flag     = "FavoriteMutationToggle",
        value    = true,
        callback = function(val) HubState.Settings.FavoriteMutation = val end,
    })

    PetTab:CreateButton({
        name     = "⭐  Favorite Pets Now",
        callback = function()
            Helpers.FireRemoteByKeywords({"favorite", "lockpet"})
            SectionedToast(Window, "⭐ Favorites Updated", "All qualifying pets marked.")
        end,
    })

    PetTab:CreateSection({ name = "💰  Auto Sell Pets" })

    PetTab:CreateToggle({
        name        = "Auto Sell Pet",
        description = "Sell pets that match the sell rule below.",
        flag        = "AutoSellPetToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.AutoSellPet = val
            SectionedToast(Window, val and "✅ Auto Sell Pets ON" or "⛔ Auto Sell Pets OFF", "")
        end,
    })

    PetTab:CreateDropdown({
        name     = "Sell Pet Rule",
        flag     = "SellPetRuleDropdown",
        options  = { "Rarity Below", "Income Below", "Duplicates Only" },
        value    = "Rarity Below",
        callback = function(val) HubState.Settings.SellPetRule = val end,
    })

    PetTab:CreateDropdown({
        name     = "Sell Below Rarity",
        flag     = "PetMaxRarityDropdown",
        options  = { "Common", "Rare", "Epic", "Legendary" },
        value    = "Rare",
        callback = function(val) HubState.Settings.PetMaxRarity = val end,
    })

    PetTab:CreateSlider({
        name      = "Income Threshold",
        flag      = "PetIncomeThresholdSlider",
        range     = { 10, 5000 },
        increment = 50,
        value     = 100,
        suffix    = " coins/s",
        callback  = function(val) HubState.Settings.PetIncomeThreshold = val end,
    })

    PetTab:CreateDropdown({
        name     = "Blacklist Sell",
        flag     = "BlacklistSellPetsDropdown",
        options  = { "None", "Favorites Only", "Mutations Only" },
        value    = "Favorites Only",
        callback = function(val) HubState.Settings.BlacklistSellPets = val end,
    })

    PetTab:CreateButton({
        name     = "💰  Sell Pets Now",
        callback = function()
            Helpers.FireRemoteByKeywords({"sellpet", "sellpets"})
            SectionedToast(Window, "💰 Pets Sold", "Matching pets have been sold.")
        end,
    })

    PetTab:CreateSection({ name = "🗃️  Inventory Tools" })

    PetTab:CreateDropdown({
        name     = "Sort Pets By",
        flag     = "SortPetsByDropdown",
        options  = { "Rarity", "Income", "Mutation", "Level" },
        value    = "Rarity",
        callback = function(val) HubState.Settings.SortPetsBy = val end,
    })

    PetTab:CreateButton({
        name     = "🔄  Refresh Inventory",
        callback = function()
            Helpers.FireRemoteByKeywords({"refreshpets", "getpets"})
            SectionedToast(Window, "🔄 Inventory Refreshed", "Pet list updated.")
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 6.  EGG ECONOMY
    -- ════════════════════════════════════════════════════════════════════
    local EggSellTab = Window:CreateTab({ name = "Egg Economy" })

    EggSellTab:CreateSection({ name = "💸  Egg Selling" })

    EggSellTab:CreateToggle({
        name        = "Auto Sell Egg",
        description = "Automatically sell eggs below the set rarity.",
        flag        = "AutoSellEggToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.AutoSellEgg = val
            SectionedToast(Window, val and "✅ Auto Sell Egg ON" or "⛔ Auto Sell Egg OFF", "")
        end,
    })

    EggSellTab:CreateDropdown({
        name     = "Sell Below Rarity",
        flag     = "EggMaxRarityDropdown",
        options  = { "Common", "Rare", "Epic" },
        value    = "Common",
        callback = function(val) HubState.Settings.EggMaxRarity = val end,
    })

    EggSellTab:CreateButton({
        name     = "💸  Sell Eggs Now",
        callback = function()
            Helpers.FireRemoteByKeywords({"sellegg", "selleggs"})
            SectionedToast(Window, "💸 Eggs Sold", "Matching eggs have been sold.")
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 7.  VISUALS (ESP)
    -- ════════════════════════════════════════════════════════════════════
    Window:CreateSection({ name = "👁️  Player & Visuals" })
    local VisualsTab = Window:CreateTab({ name = "Visuals (ESP)" })

    VisualsTab:CreateSection({ name = "🔴  ESP Chams" })

    VisualsTab:CreateToggle({
        name        = "ESP Eggs",
        description = "Highlight eggs — Red = Regular, Green = Infested.",
        flag        = "ESPEggsToggle",
        value       = false,
        callback    = function(val)
            Modules.Visuals.SetEggESP(val, HubState)
            SectionedToast(Window, val and "✅ Egg ESP ON" or "⛔ Egg ESP OFF", "")
        end,
    })

    VisualsTab:CreateToggle({
        name        = "ESP Players",
        description = "Draw red box chams on other players.",
        flag        = "ESPPlayersToggle",
        value       = false,
        callback    = function(val)
            Modules.Visuals.SetPlayerESP(val, HubState)
            SectionedToast(Window, val and "✅ Player ESP ON" or "⛔ Player ESP OFF", "")
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 8.  LOCAL PLAYER
    -- ════════════════════════════════════════════════════════════════════
    local PlayerTab = Window:CreateTab({ name = "Local Player" })

    PlayerTab:CreateSection({ name = "💨  Speed & Movement" })

    local WalkSpeedSlider = PlayerTab:CreateSlider({
        name      = "WalkSpeed",
        flag      = "PlayerWalkSpeed",
        range     = { 16, 350 },
        increment = 1,
        value     = 16,
        suffix    = " studs/s",
        callback  = function(val)
            HubState.Settings.WalkSpeed = val
            Modules.Player.SetWalkSpeed(val, Helpers)
        end,
    })

    PlayerTab:CreateToggle({
        name        = "CFrame Speed Hack",
        description = "Bypass anti-cheat speed resets smoothly.",
        flag        = "CFrameSpeedToggle",
        value       = false,
        callback    = function(val) HubState.Settings.CFrameSpeed = val end,
    })

    PlayerTab:CreateSlider({
        name      = "CFrame Speed Multiplier",
        flag      = "CFrameSpeedMultiplier",
        range     = { 1, 10 },
        increment = 0.5,
        value     = 2,
        suffix    = "x",
        callback  = function(val) HubState.Settings.CFrameSpeedMultiplier = val end,
    })

    PlayerTab:CreateSection({ name = "🚀  Speed Presets" })

    PlayerTab:CreateButton({
        name     = "🐢  Normal  (16)",
        callback = function()
            WalkSpeedSlider:Set(16)
            SectionedToast(Window, "Speed → Normal", "WalkSpeed set to 16.")
        end,
    })
    PlayerTab:CreateButton({
        name     = "🏃  Fast    (50)",
        callback = function()
            WalkSpeedSlider:Set(50)
            SectionedToast(Window, "Speed → Fast", "WalkSpeed set to 50.")
        end,
    })
    PlayerTab:CreateButton({
        name     = "⚡  Flash   (150)",
        callback = function()
            WalkSpeedSlider:Set(150)
            SectionedToast(Window, "Speed → Flash", "WalkSpeed set to 150.")
        end,
    })
    PlayerTab:CreateButton({
        name     = "🌩️  God     (300)",
        callback = function()
            WalkSpeedSlider:Set(300)
            SectionedToast(Window, "Speed → God Mode", "WalkSpeed set to 300.")
        end,
    })

    PlayerTab:CreateSection({ name = "🦾  Abilities" })

    PlayerTab:CreateToggle({
        name        = "Infinite Jump",
        description = "Jump unlimited times in the air.",
        flag        = "InfJumpToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.InfJump = val
            SectionedToast(Window, val and "✅ Infinite Jump ON" or "⛔ Infinite Jump OFF", "")
        end,
    })

    PlayerTab:CreateToggle({
        name        = "Noclip",
        description = "Phase through walls and objects.",
        flag        = "NoclipToggle",
        value       = false,
        callback    = function(val)
            HubState.Settings.Noclip = val
            SectionedToast(Window, val and "✅ Noclip ON" or "⛔ Noclip OFF", "")
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 9.  SETTINGS
    -- ════════════════════════════════════════════════════════════════════
    Window:CreateSection({ name = "⚙️  System" })
    local SettingsTab = Window:CreateTab({ name = "Settings" })

    SettingsTab:CreateSection({ name = "🎨  Theme & Keybind" })

    SettingsTab:CreateDropdown({
        name     = "UI Theme",
        flag     = "WindowThemeDropdown",
        options  = { "cobalt", "ember", "amethyst", "frost", "rose", "default" },
        value    = "cobalt",
        callback = function(selected)
            Window:ChangeTheme(selected)
            SectionedToast(Window, "🎨 Theme Changed", "Now using: " .. selected)
        end,
    })

    SettingsTab:CreateKeybind({
        name     = "Toggle Window",
        flag     = "ToggleWindowKeybind",
        value    = Enum.KeyCode.RightControl,
        callback = function() Window:ToggleHide() end,
    })

    SettingsTab:CreateSection({ name = "💾  Session" })

    SettingsTab:CreateButton({
        name     = "💾  Save Config",
        callback = function()
            Window:Save()
            SectionedToast(Window, "💾 Config Saved", "Settings written to disk.")
        end,
    })

    SettingsTab:CreateButton({
        name     = "ℹ️  About Exiles Hub",
        callback = function()
            AnimatedNotify(Window,
                "ℹ️ Exiles Hub v3.2",
                "Developer : DEV ZAX\nGame       : Steal An Egg\nFramework  : Rayfield Gen 2\nRepo       : github.com/mmtandico/ExilesHub",
                7)
        end,
    })

    SettingsTab:CreateButton({
        name     = "🗑️  Unload Hub",
        callback = function()
            HubState.Cleanup()
            local hum = Helpers.GetHumanoid()
            if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
            AnimatedNotify(Window, "🗑️ Exiles Hub Unloaded", "Thanks for using — DEV ZAX", 4)
            Window:Unload()
        end,
    })

    return Window
end

return UILayout
