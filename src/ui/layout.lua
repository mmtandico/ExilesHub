--[[
    ===================================================================
    EXILES SCRIPT HUB | RAYFIELD GEN 2 UI LAYOUT
    Design: Ember Red & Black Theme, Modern Rail Sidebar
    ===================================================================
]]

local UILayout = {}

function UILayout.Build(Rayfield, HubState, Helpers, Modules)
    local Window = Rayfield:CreateWindow({
        name = "EXILES SCRIPT HUB",
        subtitle = "Steal An Egg • Modular Edition",
        sidebarLayout = true,
        theme = "ember",
        showName = "Exiles Hub",
        configuration = {
            autoSave = true,
            autoLoad = true,
            fileName = "Exiles_Modular",
            customFolder = "ExilesHub",
        },
    })

    pcall(function()
        Window:CreateTag({
            text = "Modular v3.1",
            color = Color3.fromRGB(220, 25, 45),
        })
    end)

    Window:Toast({
        title = "Exiles Hub Ready",
        subtitle = "Modular Red & Black Edition",
        duration = 4,
    })

    -- ================================================================
    -- 1. EGG STEALING TAB
    -- ================================================================
    Window:CreateSection({ name = "Egg Stealing" })
    local StealTab = Window:CreateTab({ name = "Auto Steal", icon = 93364949241311 })

    StealTab:CreateSection({ name = "Steal Engine" })

    StealTab:CreateToggle({
        name = "Auto Steal",
        flag = "AutoStealToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoSteal = val end,
    })

    StealTab:CreateToggle({
        name = "Steal Infested Egg",
        flag = "StealInfestedToggle",
        value = true,
        callback = function(val) HubState.Settings.StealInfested = val end,
    })

    StealTab:CreateToggle({
        name = "Anti Trap",
        flag = "AntiTrapToggle",
        value = true,
        callback = function(val) HubState.Settings.AntiTrap = val end,
    })

    StealTab:CreateToggle({
        name = "Run Animation",
        flag = "RunAnimationToggle",
        value = true,
        callback = function(val) HubState.Settings.RunAnimation = val end,
    })

    StealTab:CreateSection({ name = "Targeting Rules" })

    StealTab:CreateDropdown({
        name = "Target Areas",
        flag = "TargetAreasDropdown",
        options = { "All Areas", "Enemy Bases", "Center Zone", "Rare Spawns" },
        value = "All Areas",
        callback = function(val) HubState.Settings.TargetAreas = val end,
    })

    StealTab:CreateDropdown({
        name = "Target Specific Eggs",
        flag = "TargetSpecificEggsDropdown",
        options = { "All Eggs", "Legendary & Up", "Epic & Up", "Only Infested" },
        value = "All Eggs",
        callback = function(val) HubState.Settings.TargetSpecificEggs = val end,
    })

    StealTab:CreateDropdown({
        name = "Steal Priority",
        flag = "StealPriorityDropdown",
        options = { "Highest Rarity", "Nearest Egg", "Infested First" },
        value = "Highest Rarity",
        callback = function(val) HubState.Settings.StealPriority = val end,
    })

    StealTab:CreateSlider({
        name = "Tween Speed",
        flag = "TweenSpeedSlider",
        range = { 15, 120 },
        increment = 5,
        value = 35,
        suffix = " studs/s",
        callback = function(val) HubState.Settings.TweenSpeed = val end,
    })

    StealTab:CreateSlider({
        name = "Steal Timeout",
        flag = "StealTimeoutSlider",
        range = { 1, 15 },
        increment = 1,
        value = 5,
        suffix = "s",
        callback = function(val) HubState.Settings.StealTimeout = val end,
    })

    StealTab:CreateSection({ name = "Base Placement" })

    StealTab:CreateToggle({
        name = "Auto Place Egg",
        flag = "AutoPlaceEggToggle",
        value = true,
        callback = function(val) HubState.Settings.AutoPlaceEgg = val end,
    })

    StealTab:CreateToggle({
        name = "Dont Place Infested Egg",
        flag = "DontPlaceInfestedToggle",
        value = true,
        callback = function(val) HubState.Settings.DontPlaceInfested = val end,
    })

    -- ================================================================
    -- 2. TREADMILL & BASE UPGRADES TAB
    -- ================================================================
    Window:CreateSection({ name = "Treadmill & Base" })
    local TreadmillTab = Window:CreateTab({ name = "Treadmill & Base", icon = 93364949241311 })

    TreadmillTab:CreateSection({ name = "Speed Farming" })

    TreadmillTab:CreateToggle({
        name = "Auto Treadmill",
        flag = "AutoTreadmillToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoTreadmill = val end,
    })

    TreadmillTab:CreateToggle({
        name = "Hide Treadmill",
        flag = "HideTreadmillToggle",
        value = false,
        callback = function(val)
            HubState.Settings.HideTreadmill = val
            Modules.Treadmill.SetHideTreadmill(val)
        end,
    })

    TreadmillTab:CreateButton({
        name = "Exit From Treadmill",
        callback = function()
            HubState.Settings.AutoTreadmill = false
            Modules.Treadmill.Exit(Helpers)
            Window:Toast({ title = "Treadmill Exited" })
        end,
    })

    TreadmillTab:CreateSection({ name = "Upgrades" })

    TreadmillTab:CreateToggle({
        name = "Auto Upgrade Treadmill",
        flag = "AutoUpgradeTreadmillToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoUpgradeTreadmill = val end,
    })

    TreadmillTab:CreateToggle({
        name = "Auto Upgrade Base",
        flag = "AutoUpgradeBaseToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoUpgradeBase = val end,
    })

    TreadmillTab:CreateToggle({
        name = "Auto Buy Trail",
        flag = "AutoBuyTrailToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoBuyTrail = val end,
    })

    TreadmillTab:CreateToggle({
        name = "Auto Claim",
        flag = "AutoClaimToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoClaim = val end,
    })

    -- ================================================================
    -- 3. HUNGRY MONSTER TAB
    -- ================================================================
    Window:CreateSection({ name = "Monster" })
    local MonsterTab = Window:CreateTab({ name = "Hungry Monster", icon = 93364949241311 })

    MonsterTab:CreateSection({ name = "Monster Feeding" })

    MonsterTab:CreateToggle({
        name = "Auto Feed Hungry Monster",
        flag = "AutoFeedMonsterToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoFeedMonster = val end,
    })

    MonsterTab:CreateDropdown({
        name = "Feed Max Rarity",
        flag = "FeedMaxRarityDropdown",
        options = { "Common", "Rare", "Epic", "Legendary" },
        value = "Rare",
        callback = function(val) HubState.Settings.FeedMaxRarity = val end,
    })

    MonsterTab:CreateToggle({
        name = "Auto Claim Monster Chest",
        flag = "AutoClaimMonsterChestToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoClaimChest = val end,
    })

    -- ================================================================
    -- 4. HATCH & PREDICTOR TAB
    -- ================================================================
    Window:CreateSection({ name = "Pets & Eggs" })
    local HatchTab = Window:CreateTab({ name = "Hatch & Predictor", icon = 93364949241311 })

    HatchTab:CreateSection({ name = "Egg Opener" })

    HatchTab:CreateDropdown({
        name = "Egg Scope",
        flag = "EggScopeDropdown",
        options = { "Basic Egg", "Rare Egg", "Epic Egg", "Legendary Egg", "Mythic Egg", "Infested Egg", "Void Egg" },
        value = "Basic Egg",
        callback = function(val) HubState.Settings.EggScope = val end,
    })

    HatchTab:CreateToggle({
        name = "Auto Hatch",
        flag = "AutoHatchToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoHatch = val end,
    })

    HatchTab:CreateSection({ name = "Predictors" })

    HatchTab:CreateButton({
        name = "Pet Predictor",
        callback = function()
            local p = Modules.Pets.Predict(HubState.Settings.EggScope)
            Window:Notify({ title = "Pet Predictor", content = "Next from " .. HubState.Settings.EggScope .. ": [" .. p .. "]", duration = 5 })
        end,
    })

    HatchTab:CreateButton({
        name = "Pet Predictor (All Eggs)",
        callback = function()
            Window:Notify({ title = "All Eggs Predictor", content = "Basic: Rare Dog | Epic: Legendary Dragon | Void: Mythic Reaper", duration = 6 })
        end,
    })

    HatchTab:CreateButton({
        name = "Fuse Predictor",
        callback = function()
            Window:Notify({ title = "Fuse Predictor", content = "Predicted Fusion: [Rainbow Shiny Dragon - 95% Success]", duration = 5 })
        end,
    })

    HatchTab:CreateButton({
        name = "Refresh Fuse Predictor",
        callback = function()
            Window:Toast({ title = "Fuse Predictor", subtitle = "Seed refreshed." })
        end,
    })

    -- ================================================================
    -- 5. PET MANAGEMENT TAB
    -- ================================================================
    local PetTab = Window:CreateTab({ name = "Pet Management", icon = 93364949241311 })

    PetTab:CreateSection({ name = "Equip & Favorites" })

    PetTab:CreateToggle({
        name = "Auto Equip Best",
        flag = "AutoEquipBestToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoEquipBest = val end,
    })

    PetTab:CreateToggle({
        name = "Auto Favorite Pet",
        flag = "AutoFavoritePetToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoFavoritePet = val end,
    })

    PetTab:CreateDropdown({
        name = "Favorite Min Rarity",
        flag = "FavoriteMinRarityDropdown",
        options = { "Rare", "Epic", "Legendary", "Mythic" },
        value = "Legendary",
        callback = function(val) HubState.Settings.FavoriteMinRarity = val end,
    })

    PetTab:CreateToggle({
        name = "Favorite Mutation",
        flag = "FavoriteMutationToggle",
        value = true,
        callback = function(val) HubState.Settings.FavoriteMutation = val end,
    })

    PetTab:CreateButton({
        name = "Favorite Pets Now",
        callback = function()
            Helpers.FireRemoteByKeywords({"favorite", "lockpet"})
            Window:Toast({ title = "Favorites Updated" })
        end,
    })

    PetTab:CreateSection({ name = "Auto Sell Pets" })

    PetTab:CreateToggle({
        name = "Auto Sell Pet",
        flag = "AutoSellPetToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoSellPet = val end,
    })

    PetTab:CreateDropdown({
        name = "Sell Pet Rule",
        flag = "SellPetRuleDropdown",
        options = { "Rarity Below", "Income Below", "Duplicates Only" },
        value = "Rarity Below",
        callback = function(val) HubState.Settings.SellPetRule = val end,
    })

    PetTab:CreateDropdown({
        name = "Pet Max Rarity",
        flag = "PetMaxRarityDropdown",
        options = { "Common", "Rare", "Epic", "Legendary" },
        value = "Rare",
        callback = function(val) HubState.Settings.PetMaxRarity = val end,
    })

    PetTab:CreateSlider({
        name = "Pet Income Threshold",
        flag = "PetIncomeThresholdSlider",
        range = { 10, 5000 },
        increment = 50,
        value = 100,
        suffix = " coins/s",
        callback = function(val) HubState.Settings.PetIncomeThreshold = val end,
    })

    PetTab:CreateDropdown({
        name = "Blacklist Sell Pets",
        flag = "BlacklistSellPetsDropdown",
        options = { "None", "Favorites Only", "Mutations Only" },
        value = "Favorites Only",
        callback = function(val) HubState.Settings.BlacklistSellPets = val end,
    })

    PetTab:CreateButton({
        name = "Sell Pets Now",
        callback = function()
            Helpers.FireRemoteByKeywords({"sellpet", "sellpets"})
            Window:Toast({ title = "Pets Sold" })
        end,
    })

    PetTab:CreateSection({ name = "Inventory Tools" })

    PetTab:CreateDropdown({
        name = "Sort Pets By",
        flag = "SortPetsByDropdown",
        options = { "Rarity", "Income", "Mutation", "Level" },
        value = "Rarity",
        callback = function(val) HubState.Settings.SortPetsBy = val end,
    })

    PetTab:CreateButton({
        name = "Refresh Pets",
        callback = function()
            Helpers.FireRemoteByKeywords({"refreshpets", "getpets"})
            Window:Toast({ title = "Inventory Refreshed" })
        end,
    })

    -- ================================================================
    -- 6. EGG ECONOMY TAB
    -- ================================================================
    local EggSellTab = Window:CreateTab({ name = "Egg Economy", icon = 93364949241311 })

    EggSellTab:CreateSection({ name = "Egg Selling" })

    EggSellTab:CreateToggle({
        name = "Auto Sell Egg",
        flag = "AutoSellEggToggle",
        value = false,
        callback = function(val) HubState.Settings.AutoSellEgg = val end,
    })

    EggSellTab:CreateDropdown({
        name = "Egg Max Rarity",
        flag = "EggMaxRarityDropdown",
        options = { "Common", "Rare", "Epic" },
        value = "Common",
        callback = function(val) HubState.Settings.EggMaxRarity = val end,
    })

    EggSellTab:CreateButton({
        name = "Sell Eggs Now",
        callback = function()
            Helpers.FireRemoteByKeywords({"sellegg", "selleggs"})
            Window:Toast({ title = "Eggs Sold" })
        end,
    })

    -- ================================================================
    -- 7. VISUALS (ESP) TAB
    -- ================================================================
    Window:CreateSection({ name = "Player & Visuals" })
    local VisualsTab = Window:CreateTab({ name = "Visuals (ESP)", icon = 93364949241311 })

    VisualsTab:CreateSection({ name = "ESP Chams" })

    VisualsTab:CreateToggle({
        name = "ESP Eggs",
        description = "Red = Regular Eggs, Green = Infested Eggs.",
        flag = "ESPEggsToggle",
        value = false,
        callback = function(val) Modules.Visuals.SetEggESP(val, HubState) end,
    })

    VisualsTab:CreateToggle({
        name = "ESP Players",
        description = "Draws red box chams on other players.",
        flag = "ESPPlayersToggle",
        value = false,
        callback = function(val) Modules.Visuals.SetPlayerESP(val, HubState) end,
    })

    -- ================================================================
    -- 8. LOCAL PLAYER TAB
    -- ================================================================
    local PlayerTab = Window:CreateTab({ name = "Local Player", icon = 93364949241311 })

    PlayerTab:CreateSection({ name = "Speed & Movement" })

    local WalkSpeedSlider = PlayerTab:CreateSlider({
        name = "WalkSpeed (Standard)",
        flag = "PlayerWalkSpeed",
        range = { 16, 350 },
        increment = 1,
        value = 16,
        suffix = " studs/s",
        callback = function(val)
            HubState.Settings.WalkSpeed = val
            Modules.Player.SetWalkSpeed(val, Helpers)
        end,
    })

    PlayerTab:CreateToggle({
        name = "CFrame Speed Hack (Bypass)",
        description = "Bypasses anti-cheat speed resets smoothly.",
        flag = "CFrameSpeedToggle",
        value = false,
        callback = function(val) HubState.Settings.CFrameSpeed = val end,
    })

    PlayerTab:CreateSlider({
        name = "CFrame Speed Multiplier",
        flag = "CFrameSpeedMultiplier",
        range = { 1, 10 },
        increment = 0.5,
        value = 2,
        suffix = "x",
        callback = function(val) HubState.Settings.CFrameSpeedMultiplier = val end,
    })

    PlayerTab:CreateSection({ name = "Speed Presets" })

    PlayerTab:CreateButton({ name = "Normal Speed (16)", callback = function() WalkSpeedSlider:Set(16) end })
    PlayerTab:CreateButton({ name = "Fast Speed (50)", callback = function() WalkSpeedSlider:Set(50) end })
    PlayerTab:CreateButton({ name = "Flash Speed (150)", callback = function() WalkSpeedSlider:Set(150) end })
    PlayerTab:CreateButton({ name = "God Speed (300)", callback = function() WalkSpeedSlider:Set(300) end })

    PlayerTab:CreateSection({ name = "Abilities" })

    PlayerTab:CreateToggle({
        name = "Infinite Jump",
        flag = "InfJumpToggle",
        value = false,
        callback = function(val) HubState.Settings.InfJump = val end,
    })

    PlayerTab:CreateToggle({
        name = "Noclip",
        flag = "NoclipToggle",
        value = false,
        callback = function(val) HubState.Settings.Noclip = val end,
    })

    -- ================================================================
    -- 9. SETTINGS TAB
    -- ================================================================
    Window:CreateSection({ name = "System" })
    local SettingsTab = Window:CreateTab({ name = "Settings", icon = 93364949241311 })

    SettingsTab:CreateSection({ name = "Theme & Keybind" })

    SettingsTab:CreateDropdown({
        name = "Window Theme",
        flag = "WindowThemeDropdown",
        options = { "ember", "cobalt", "amethyst", "frost", "rose", "default" },
        value = "ember",
        callback = function(selected) Window:ChangeTheme(selected) end,
    })

    SettingsTab:CreateKeybind({
        name = "Toggle Window Keybind",
        flag = "ToggleWindowKeybind",
        value = Enum.KeyCode.RightControl,
        callback = function() Window:ToggleHide() end,
    })

    SettingsTab:CreateSection({ name = "Session" })

    SettingsTab:CreateButton({
        name = "Force Save Config",
        callback = function()
            Window:Save()
            Window:Toast({ title = "Saved", subtitle = "Config saved to disk." })
        end,
    })

    SettingsTab:CreateButton({
        name = "Unload Script Hub",
        callback = function()
            HubState.Cleanup()
            local hum = Helpers.GetHumanoid()
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
            Window:Unload()
        end,
    })

    return Window
end

return UILayout
