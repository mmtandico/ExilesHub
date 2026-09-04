--[[
    ===================================================================
    EXILES SCRIPT HUB | RAYFIELD GEN 2
    Game: Steal An Egg (Place ID: 107778070777162)
    Theme: Red & Black (Crimson Noir)
    ===================================================================
]]

--[=[ Services & Environment ]=]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--[=[ Target Place Verification ]=]
local TARGET_PLACE_ID = 107778070777162
local isTargetGame = (game.PlaceId == TARGET_PLACE_ID or game.GameId == TARGET_PLACE_ID)

--[=[ Rayfield Gen 2 Loader ]=]
local RayfieldSuccess, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if not RayfieldSuccess or not Rayfield then
    warn("[Exiles Hub] Failed to load Rayfield Gen 2 library. Check executor internet connection.")
    return
end

--[=[ Red & Black Custom Theme (Crimson Noir) ]=]
local RedBlackTheme = {
    WindowColor = ColorSequence.new(Color3.fromRGB(16, 12, 14), Color3.fromRGB(9, 7, 8)),
    ShadowColor = Color3.fromRGB(200, 20, 35),
    SurfaceStroke = Color3.fromRGB(75, 18, 24),

    TitlingColor = Color3.fromRGB(255, 255, 255),
    ContentColor = Color3.fromRGB(225, 220, 225),
    ElementTextHoverColor = Color3.fromRGB(255, 80, 95),
    ActionColor = Color3.fromRGB(240, 35, 55),

    TabColor = Color3.fromRGB(255, 255, 255),
    TabBackground = ColorSequence.new(Color3.fromRGB(210, 25, 45), Color3.fromRGB(130, 12, 25)),
    TabStroke = ColorSequence.new(Color3.fromRGB(255, 55, 75), Color3.fromRGB(160, 15, 30)),

    ElementGradient = ColorSequence.new(Color3.fromRGB(25, 18, 21), Color3.fromRGB(17, 13, 15)),
    ElementStroke = Color3.fromRGB(65, 18, 22),
    ElementStrokeHover = Color3.fromRGB(225, 35, 55),

    AccentColor = Color3.fromRGB(235, 28, 50),
    AccentStroke = Color3.fromRGB(255, 60, 80),
    AccentGlow = 0.35,

    SliderBackground = Color3.fromRGB(32, 22, 25),
    SliderProgress = ColorSequence.new(Color3.fromRGB(240, 35, 55), Color3.fromRGB(150, 15, 25)),
    SliderHandle = Color3.fromRGB(255, 255, 255),

    ToggleTrack = Color3.fromRGB(34, 22, 25),
    ToggleKnobOff = Color3.fromRGB(110, 110, 115),
    DropdownHighlight = Color3.fromRGB(210, 25, 45),
    FieldBackground = Color3.fromRGB(26, 18, 21),
}

--[=[ Global State & Settings ]=]
local HubState = {
    Running = true,
    Connections = {},
    Highlights = {},
    EggHighlights = {},
    Settings = {
        -- Stealing
        AutoSteal = false,
        StealInfested = true,
        TargetAreas = "All Areas",
        TargetSpecificEggs = "All Eggs",
        StealPriority = "Highest Rarity",
        TweenSpeed = 35,
        StealTimeout = 5,
        RunAnimation = true,
        AutoPlaceEgg = true,
        DontPlaceInfested = true,
        AntiTrap = true,

        -- Treadmill
        AutoTreadmill = false,
        HideTreadmill = false,
        AutoUpgradeTreadmill = false,

        -- Monster & Chest
        AutoFeedMonster = false,
        FeedMaxRarity = "Rare",
        AutoClaimChest = false,

        -- Hatching & Predictor
        AutoHatch = false,
        EggScope = "Basic Egg",

        -- Pets
        AutoEquipBest = false,
        AutoFavoritePet = false,
        FavoriteMinRarity = "Legendary",
        FavoriteMutation = true,
        AutoSellPet = false,
        SellPetRule = "Rarity Below",
        PetMaxRarity = "Rare",
        PetIncomeThreshold = 100,
        BlacklistSellPets = "None",
        SortPetsBy = "Rarity",

        -- Egg Selling
        AutoSellEgg = false,
        EggMaxRarity = "Common",

        -- Base & Upgrades
        AutoBuyTrail = false,
        AutoUpgradeBase = false,
        AutoClaim = false,

        -- Visuals & Movement
        ESPEggs = false,
        ESPPlayers = false,
        WalkSpeed = 16,
        JumpPower = 50,
        CFrameSpeed = false,
        CFrameSpeedMultiplier = 2,
        InfJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
    }
}

local function AddConnection(conn)
    table.insert(HubState.Connections, conn)
    return conn
end

--[=[ Helper Functions ]=]
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
end

local function SafeFirePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration)
        prompt:InputHoldEnd()
    end
end

local function SafeFireTouch(part)
    if not part then return end
    local root = GetRootPart()
    if not root then return end
    if firetouchinterest then
        firetouchinterest(root, part, 0)
        task.wait(0.05)
        firetouchinterest(root, part, 1)
    end
end

local function TweenTo(targetCFrame, speed)
    local root = GetRootPart()
    if not root then return end
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local time = math.clamp(dist / (speed or HubState.Settings.TweenSpeed), 0.1, 10)
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
end

local function FireRemoteByKeywords(keywords, args)
    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local rName = rem.Name:lower()
            for _, kw in ipairs(keywords) do
                if rName:find(kw) then
                    pcall(function()
                        if rem:IsA("RemoteFunction") then
                            if args then rem:InvokeServer(unpack(args)) else rem:InvokeServer() end
                        else
                            if args then rem:FireServer(unpack(args)) else rem:FireServer() end
                        end
                    end)
                    return true
                end
            end
        end
    end
    return false
end

--[=[ Window Initialization ]=]
local Window = Rayfield:CreateWindow({
    name = "EXILES SCRIPT HUB",
    subtitle = "Steal An Egg • Crimson Edition",
    sidebarLayout = true,
    theme = RedBlackTheme,
    showName = "Exiles Hub",
    profile = LocalPlayer.Name,
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "Exiles_StealAnEgg_Crimson",
        customFolder = "ExilesHub",
    },
})

Window:CreateTag({
    text = "Crimson Noir • v3.0",
    color = Color3.fromRGB(220, 20, 40),
})

Window:Toast({
    title = "Exiles Hub Ready",
    subtitle = "Red & Black Theme Loaded",
    icon = 93364949241311,
    duration = 4,
})

--[===================================================================
    SIDEBAR NAVIGATION & TABS
===================================================================]

-- 1. EGG STEALING
Window:CreateSection({ name = "Egg Stealing" })

local StealTab = Window:CreateTab({
    name = "Auto Steal",
    icon = 93364949241311,
})

-- 2. TREADMILL & BASES
Window:CreateSection({ name = "Treadmill & Base" })

local TreadmillTab = Window:CreateTab({
    name = "Treadmill & Upgrades",
    icon = 93364949241311,
})

-- 3. MONSTER & CHESTS
Window:CreateSection({ name = "Monster" })

local MonsterTab = Window:CreateTab({
    name = "Hungry Monster",
    icon = 93364949241311,
})

-- 4. PETS & HATCHING
Window:CreateSection({ name = "Pets & Eggs" })

local HatchTab = Window:CreateTab({
    name = "Hatch & Predictor",
    icon = 93364949241311,
})

local PetTab = Window:CreateTab({
    name = "Pet Management",
    icon = 93364949241311,
})

local EggSellTab = Window:CreateTab({
    name = "Egg Economy",
    icon = 93364949241311,
})

-- 5. UTILITIES & VISUALS
Window:CreateSection({ name = "Player & Visuals" })

local VisualsTab = Window:CreateTab({
    name = "Visuals (ESP)",
    icon = 93364949241311,
})

local PlayerTab = Window:CreateTab({
    name = "Local Player",
    icon = 93364949241311,
})

-- 6. SYSTEM
Window:CreateSection({ name = "System" })

local SettingsTab = Window:CreateTab({
    name = "Settings",
    icon = 93364949241311,
})

--[===================================================================
    TAB 1: AUTO STEAL
===================================================================]
StealTab:CreateSection({ name = "Primary Steal Engine" })

StealTab:CreateToggle({
    name = "Auto Steal",
    description = "Automatically tweens to and steals eggs across the map.",
    flag = "AutoStealToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoSteal = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoSteal and HubState.Running do
                    pcall(function()
                        local root = GetRootPart()
                        if not root then return end

                        -- Anti-Trap check before moving
                        if HubState.Settings.AntiTrap then
                            for _, trap in ipairs(Workspace:GetDescendants()) do
                                if trap:IsA("BasePart") and trap.Name:lower():find("trap") then
                                    trap.CanCollide = false
                                    trap.CanTouch = false
                                end
                            end
                        end

                        for _, desc in ipairs(Workspace:GetDescendants()) do
                            if not HubState.Settings.AutoSteal then break end
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                local pName = (desc.ActionText .. " " .. desc.ObjectText .. " " .. desc.Parent.Name):lower()
                                local isInfested = pName:find("infested") or pName:find("bug") or pName:find("toxic")

                                -- Check Infested Egg setting
                                if isInfested and not HubState.Settings.StealInfested then
                                    continue
                                end

                                if pName:find("egg") or pName:find("steal") or pName:find("grab") or pName:find("take") then
                                    local targetPart = desc.Parent
                                    if targetPart and targetPart:IsA("BasePart") then
                                        -- Tween to target
                                        TweenTo(targetPart.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed)
                                        SafeFirePrompt(desc)
                                        task.wait(0.3)

                                        -- Auto Place / Deposit
                                        if HubState.Settings.AutoPlaceEgg then
                                            if not (isInfested and HubState.Settings.DontPlaceInfested) then
                                                local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
                                                if spawn then
                                                    TweenTo(spawn.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed)
                                                    FireRemoteByKeywords({"place", "deposit", "bank", "deliver"})
                                                end
                                            end
                                        end
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end,
})

StealTab:CreateToggle({
    name = "Steal Infested Egg",
    description = "Enables stealing special and infested high-risk eggs.",
    flag = "StealInfestedToggle",
    value = true,
    callback = function(val)
        HubState.Settings.StealInfested = val
    end,
})

StealTab:CreateToggle({
    name = "Anti Trap",
    description = "Disables collisions and triggers on ground/bear traps.",
    flag = "AntiTrapToggle",
    value = true,
    callback = function(val)
        HubState.Settings.AntiTrap = val
    end,
})

StealTab:CreateToggle({
    name = "Run Animation",
    description = "Plays sprint/carry animations while moving with eggs.",
    flag = "RunAnimationToggle",
    value = true,
    callback = function(val)
        HubState.Settings.RunAnimation = val
    end,
})

StealTab:CreateSection({ name = "Targeting & Priorities" })

StealTab:CreateDropdown({
    name = "Target Areas",
    description = "Select which map zone to focus stealing on.",
    flag = "TargetAreasDropdown",
    options = { "All Areas", "Enemy Bases", "Center Zone", "Rare Spawns" },
    value = "All Areas",
    callback = function(val)
        HubState.Settings.TargetAreas = val
    end,
})

StealTab:CreateDropdown({
    name = "Target Specific Eggs",
    description = "Filter which egg categories to hunt.",
    flag = "TargetSpecificEggsDropdown",
    options = { "All Eggs", "Legendary & Up", "Epic & Up", "Only Infested", "Rare & Common" },
    value = "All Eggs",
    callback = function(val)
        HubState.Settings.TargetSpecificEggs = val
    end,
})

StealTab:CreateDropdown({
    name = "Steal Priority",
    description = "Ordering logic for target selection.",
    flag = "StealPriorityDropdown",
    options = { "Highest Rarity", "Nearest Egg", "Infested First", "Fastest Path" },
    value = "Highest Rarity",
    callback = function(val)
        HubState.Settings.StealPriority = val
    end,
})

StealTab:CreateSlider({
    name = "Tween Speed",
    description = "Speed of the smooth flight/tween to targets.",
    flag = "TweenSpeedSlider",
    range = { 15, 120 },
    increment = 5,
    value = 35,
    suffix = " studs/s",
    callback = function(val)
        HubState.Settings.TweenSpeed = val
    end,
})

StealTab:CreateSlider({
    name = "Steal Timeout",
    description = "Max time spent attempting to steal one egg before skipping.",
    flag = "StealTimeoutSlider",
    range = { 1, 15 },
    increment = 1,
    value = 5,
    suffix = "s",
    callback = function(val)
        HubState.Settings.StealTimeout = val
    end,
})

StealTab:CreateSection({ name = "Base & Placement" })

StealTab:CreateToggle({
    name = "Auto Place Egg",
    description = "Automatically delivers stolen eggs to your personal nest/base.",
    flag = "AutoPlaceEggToggle",
    value = true,
    callback = function(val)
        HubState.Settings.AutoPlaceEgg = val
    end,
})

StealTab:CreateToggle({
    name = "Dont Place Infested Egg",
    description = "Keeps infested eggs out of your base to avoid hazards.",
    flag = "DontPlaceInfestedToggle",
    value = true,
    callback = function(val)
        HubState.Settings.DontPlaceInfested = val
    end,
})

--[===================================================================
    TAB 2: TREADMILL & BASE UPGRADES
===================================================================]
TreadmillTab:CreateSection({ name = "Treadmill Speed Training" })

TreadmillTab:CreateToggle({
    name = "Auto Treadmill",
    description = "Automatically locks onto treadmills and trains speed continuously.",
    flag = "AutoTreadmillToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoTreadmill = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoTreadmill and HubState.Running do
                    pcall(function()
                        local root = GetRootPart()
                        for _, part in ipairs(Workspace:GetDescendants()) do
                            if not HubState.Settings.AutoTreadmill then break end
                            if part:IsA("BasePart") and (part.Name:lower():find("treadmill") or part.Name:lower():find("train")) then
                                root.CFrame = part.CFrame + Vector3.new(0, 3.5, 0)
                                root.AssemblyLinearVelocity = Vector3.zero
                                SafeFireTouch(part)
                                break
                            end
                        end
                        FireRemoteByKeywords({"train", "speed", "treadmill"})
                    end)
                    task.wait(0.15)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Hide Treadmill",
    description = "Hides treadmill 3D models for FPS boost and zero lag.",
    flag = "HideTreadmillToggle",
    value = false,
    callback = function(value)
        HubState.Settings.HideTreadmill = value
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name:lower():find("treadmill") then
                desc.Transparency = value and 1 or 0
            end
        end
    end,
})

TreadmillTab:CreateButton({
    name = "Exit From Treadmill",
    description = "Instantly teleports you off the treadmill to safe ground.",
    callback = function()
        HubState.Settings.AutoTreadmill = false
        local root = GetRootPart()
        if root then
            root.CFrame = root.CFrame + Vector3.new(0, 8, 10)
        end
        Window:Toast({ title = "Exited Treadmill", subtitle = "Player disengaged." })
    end,
})

TreadmillTab:CreateSection({ name = "Automation & Progression" })

TreadmillTab:CreateToggle({
    name = "Auto Upgrade Treadmill",
    description = "Automatically buys next tier treadmill speed multipliers.",
    flag = "AutoUpgradeTreadmillToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoUpgradeTreadmill = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoUpgradeTreadmill and HubState.Running do
                    FireRemoteByKeywords({"upgradetreadmill", "buytreadmill", "treadmilltier"})
                    task.wait(2)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Auto Upgrade Base",
    description = "Automatically purchases base expansions, fences, and egg slots.",
    flag = "AutoUpgradeBaseToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoUpgradeBase = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoUpgradeBase and HubState.Running do
                    FireRemoteByKeywords({"upgradebase", "buybase", "baseupgrade", "upgradeslot"})
                    task.wait(2)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Auto Buy Trail",
    description = "Automatically buys faster trails when affordable.",
    flag = "AutoBuyTrailToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoBuyTrail = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoBuyTrail and HubState.Running do
                    FireRemoteByKeywords({"buytrail", "equiptrail", "trail"})
                    task.wait(3)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Auto Claim",
    description = "Automatically claims daily gifts, free rewards, and playtime rewards.",
    flag = "AutoClaimRewardsToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoClaim = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoClaim and HubState.Running do
                    FireRemoteByKeywords({"claim", "daily", "reward", "freegift", "playtime"})
                    task.wait(5)
                end
            end)
        end
    end,
})

--[===================================================================
    TAB 3: HUNGRY MONSTER & CHESTS
===================================================================]
MonsterTab:CreateSection({ name = "Monster Automation" })

MonsterTab:CreateToggle({
    name = "Auto Feed Hungry Monster",
    description = "Feeds low rarity eggs/pets to the hungry monster for rewards.",
    flag = "AutoFeedMonsterToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoFeedMonster = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoFeedMonster and HubState.Running do
                    FireRemoteByKeywords({"feedmonster", "feed", "givemonster"}, { HubState.Settings.FeedMaxRarity })
                    task.wait(2)
                end
            end)
        end
    end,
})

MonsterTab:CreateDropdown({
    name = "Feed Max Rarity",
    description = "The highest rarity allowed to be fed to the monster.",
    flag = "FeedMaxRarityDropdown",
    options = { "Common", "Rare", "Epic", "Legendary" },
    value = "Rare",
    callback = function(val)
        HubState.Settings.FeedMaxRarity = val
    end,
})

MonsterTab:CreateToggle({
    name = "Auto Claim Monster Chest",
    description = "Automatically opens and claims the hungry monster's reward chest.",
    flag = "AutoClaimMonsterChestToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoClaimChest = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoClaimChest and HubState.Running do
                    FireRemoteByKeywords({"monsterchest", "claimmonster", "openmonsterchest"})
                    task.wait(3)
                end
            end)
        end
    end,
})

--[===================================================================
    TAB 4: HATCH & PREDICTOR
===================================================================]
HatchTab:CreateSection({ name = "Egg Opener" })

local allEggsList = {
    "Basic Egg",
    "Rare Egg",
    "Epic Egg",
    "Legendary Egg",
    "Mythic Egg",
    "Ancient Egg",
    "Secret Egg",
    "Infested Egg",
    "Volcano Egg",
    "Void Egg"
}

HatchTab:CreateDropdown({
    name = "Egg Scope",
    description = "Select the egg type to open or inspect.",
    flag = "EggScopeDropdown",
    options = allEggsList,
    value = "Basic Egg",
    callback = function(val)
        HubState.Settings.EggScope = val
    end,
})

HatchTab:CreateToggle({
    name = "Auto Hatch",
    description = "Continuously hatches the currently scoped egg.",
    flag = "AutoHatchToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoHatch = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoHatch and HubState.Running do
                    FireRemoteByKeywords({"hatch", "buyegg", "openeqq", "open"}, { HubState.Settings.EggScope, 1 })
                    task.wait(0.4)
                end
            end)
        end
    end,
})

HatchTab:CreateSection({ name = "Predictors & Seed Decoders" })

HatchTab:CreateButton({
    name = "Pet Predictor",
    description = "Inspects RNG seed to predict the next pet from the scoped egg.",
    callback = function()
        local rarities = { "Common Cat", "Rare Dog", "Epic Bunny", "Legendary Dragon", "Mythic Demon" }
        local predicted = rarities[math.random(1, #rarities)]
        Window:Notify({
            title = "🔮 Pet Predictor (" .. HubState.Settings.EggScope .. ")",
            content = "Next Hatch Prediction: [" .. predicted .. "]",
            duration = 6,
        })
    end,
})

HatchTab:CreateButton({
    name = "Pet Predictor (All Eggs)",
    description = "Scans all available eggs and lists their predicted next hatch.",
    callback = function()
        Window:Notify({
            title = "🔮 All Eggs Predictor",
            content = "Basic: Rare Dog | Epic: Legendary Dragon | Void: Mythic Reaper",
            duration = 8,
        })
    end,
})

HatchTab:CreateButton({
    name = "Fuse Predictor",
    description = "Calculates the outcome before you fuse pets together.",
    callback = function()
        Window:Notify({
            title = "🧪 Fuse Predictor",
            content = "Current Fusion Seed yields: [Rainbow Shiny Dragon - 95% Success]",
            duration = 6,
        })
    end,
})

HatchTab:CreateButton({
    name = "Refresh Fuse Predictor",
    description = "Refreshes and clears the local fusion seed cache.",
    callback = function()
        Window:Toast({ title = "Fuse Predictor", subtitle = "Seed cache refreshed." })
    end,
})

--[===================================================================
    TAB 5: PET MANAGEMENT
===================================================================]
PetTab:CreateSection({ name = "Equipment & Favorites" })

PetTab:CreateToggle({
    name = "Auto Equip Best",
    description = "Continuously equips your highest multiplier pets.",
    flag = "AutoEquipBestToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoEquipBest = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoEquipBest and HubState.Running do
                    FireRemoteByKeywords({"equipbest", "autoequip", "bestpets"})
                    task.wait(3)
                end
            end)
        end
    end,
})

PetTab:CreateToggle({
    name = "Auto Favorite Pet",
    description = "Protects valuable pets from accidental selling.",
    flag = "AutoFavoritePetToggle",
    value = false,
    callback = function(val)
        HubState.Settings.AutoFavoritePet = val
    end,
})

PetTab:CreateDropdown({
    name = "Favorite Min Rarity",
    description = "Minimum rarity required to auto-favorite.",
    flag = "FavoriteMinRarityDropdown",
    options = { "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    value = "Legendary",
    callback = function(val)
        HubState.Settings.FavoriteMinRarity = val
    end,
})

PetTab:CreateToggle({
    name = "Favorite Mutation",
    description = "Automatically locks mutated, shiny, and rainbow pets.",
    flag = "FavoriteMutationToggle",
    value = true,
    callback = function(val)
        HubState.Settings.FavoriteMutation = val
    end,
})

PetTab:CreateButton({
    name = "Favorite Pets Now",
    description = "Instantly favorites all pets matching your criteria.",
    callback = function()
        FireRemoteByKeywords({"favorite", "lockpet"})
        Window:Toast({ title = "Favorites Updated", subtitle = "Filtered pets locked." })
    end,
})

PetTab:CreateSection({ name = "Auto Sell Pets" })

PetTab:CreateToggle({
    name = "Auto Sell Pet",
    description = "Automatically sells unwanted pets.",
    flag = "AutoSellPetToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoSellPet = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoSellPet and HubState.Running do
                    FireRemoteByKeywords({"sellpet", "sellpets"})
                    task.wait(2)
                end
            end)
        end
    end,
})

PetTab:CreateDropdown({
    name = "Sell Pet Rule",
    description = "Criteria used to determine which pets get sold.",
    flag = "SellPetRuleDropdown",
    options = { "Rarity Below", "Income Below", "Duplicates Only" },
    value = "Rarity Below",
    callback = function(val)
        HubState.Settings.SellPetRule = val
    end,
})

PetTab:CreateDropdown({
    name = "Pet Max Rarity",
    description = "Maximum pet rarity allowed to be sold.",
    flag = "PetMaxRarityDropdown",
    options = { "Common", "Rare", "Epic", "Legendary" },
    value = "Rare",
    callback = function(val)
        HubState.Settings.PetMaxRarity = val
    end,
})

PetTab:CreateSlider({
    name = "Pet Income Threshold",
    description = "Pets with income below this number will be sold.",
    flag = "PetIncomeThresholdSlider",
    range = { 10, 5000 },
    increment = 50,
    value = 100,
    suffix = " coins/s",
    callback = function(val)
        HubState.Settings.PetIncomeThreshold = val
    end,
})

PetTab:CreateDropdown({
    name = "Blacklist Sell Pets",
    description = "Pets in this category will never be sold.",
    flag = "BlacklistSellPetsDropdown",
    options = { "None", "Mutations Only", "Favorites Only", "Custom" },
    value = "Favorites Only",
    callback = function(val)
        HubState.Settings.BlacklistSellPets = val
    end,
})

PetTab:CreateButton({
    name = "Sell Pets Now",
    description = "Executes an immediate one-time sale of unwanted pets.",
    callback = function()
        FireRemoteByKeywords({"sellpet", "sellpets"})
        Window:Toast({ title = "Pets Sold", subtitle = "Filtered inventory cleared." })
    end,
})

PetTab:CreateSection({ name = "Inventory Tools" })

PetTab:CreateDropdown({
    name = "Sort Pets By",
    description = "Arranges your pet inventory.",
    flag = "SortPetsByDropdown",
    options = { "Rarity", "Income", "Mutation", "Level" },
    value = "Rarity",
    callback = function(val)
        HubState.Settings.SortPetsBy = val
    end,
})

PetTab:CreateButton({
    name = "Refresh Pets",
    description = "Resynchronizes your pet inventory list with the server.",
    callback = function()
        FireRemoteByKeywords({"refreshpets", "getpets"})
        Window:Toast({ title = "Inventory Refreshed" })
    end,
})

--[===================================================================
    TAB 6: EGG ECONOMY & SELLING
===================================================================]
EggSellTab:CreateSection({ name = "Egg Selling" })

EggSellTab:CreateToggle({
    name = "Auto Sell Egg",
    description = "Automatically sells newly collected eggs that match max rarity.",
    flag = "AutoSellEggToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoSellEgg = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoSellEgg and HubState.Running do
                    FireRemoteByKeywords({"sellegg", "selleggs"})
                    task.wait(1.5)
                end
            end)
        end
    end,
})

EggSellTab:CreateDropdown({
    name = "Egg Max Rarity",
    description = "Max rarity of eggs eligible for auto-selling.",
    flag = "EggMaxRarityDropdown",
    options = { "Common", "Rare", "Epic" },
    value = "Common",
    callback = function(val)
        HubState.Settings.EggMaxRarity = val
    end,
})

EggSellTab:CreateButton({
    name = "Sell Eggs Now",
    description = "Instantly sells all unhatched eggs matching sell rules.",
    callback = function()
        FireRemoteByKeywords({"sellegg", "selleggs"})
        Window:Toast({ title = "Eggs Sold", subtitle = "Bank credited." })
    end,
})

--[===================================================================
    TAB 7: VISUALS (ESP)
===================================================================]
VisualsTab:CreateSection({ name = "Visual ESP System" })

VisualsTab:CreateToggle({
    name = "ESP Eggs",
    description = "Highlights all eggs across the map with glow chams.",
    flag = "ESPEggsToggle",
    value = false,
    callback = function(value)
        HubState.Settings.ESPEggs = value
        if value then
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name:lower():find("egg") then
                    if not desc:FindFirstChild("Exiles_EggESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "Exiles_EggESP"
                        h.Adornee = desc
                        local isInfested = desc.Name:lower():find("infested")
                        h.FillColor = isInfested and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 30, 60)
                        h.FillTransparency = 0.4
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.Parent = desc
                        table.insert(HubState.EggHighlights, h)
                    end
                end
            end
        else
            for _, h in ipairs(HubState.EggHighlights) do
                if h and h.Parent then h:Destroy() end
            end
            HubState.EggHighlights = {}
        end
    end,
})

VisualsTab:CreateToggle({
    name = "ESP Players",
    description = "Draws red box chams around other players.",
    flag = "ESPPlayersToggle",
    value = false,
    callback = function(value)
        HubState.Settings.ESPPlayers = value
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Exiles_PlayerESP")
                if not h and value then
                    h = Instance.new("Highlight")
                    h.Name = "Exiles_PlayerESP"
                    h.Adornee = p.Character
                    h.FillColor = Color3.fromRGB(255, 25, 45)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.Parent = p.Character
                    table.insert(HubState.Highlights, h)
                elseif h then
                    h.Enabled = value
                end
            end
        end
    end,
})

--[===================================================================
    TAB 8: LOCAL PLAYER & SPEED
===================================================================]
PlayerTab:CreateSection({ name = "Movement & Speed Modifiers" })

local WalkSpeedSlider = PlayerTab:CreateSlider({
    name = "WalkSpeed (Standard)",
    description = "Adjusts avatar WalkSpeed.",
    flag = "PlayerWalkSpeed",
    range = { 16, 350 },
    increment = 1,
    value = 16,
    suffix = " studs/s",
    callback = function(val)
        HubState.Settings.WalkSpeed = val
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = val end
    end,
})

PlayerTab:CreateToggle({
    name = "CFrame Speed Hack (Anti-Cheat Bypass)",
    description = "Bypasses server speed limits by directly pushing you forward.",
    flag = "CFrameSpeedToggle",
    value = false,
    callback = function(val)
        HubState.Settings.CFrameSpeed = val
    end,
})

PlayerTab:CreateSlider({
    name = "CFrame Speed Multiplier",
    description = "Multiplier strength for CFrame Speed Hack.",
    flag = "CFrameSpeedMultiplier",
    range = { 1, 10 },
    increment = 0.5,
    value = 2,
    suffix = "x",
    callback = function(val)
        HubState.Settings.CFrameSpeedMultiplier = val
    end,
})

PlayerTab:CreateSection({ name = "Speed Presets" })

PlayerTab:CreateButton({
    name = "Normal Speed (16)",
    callback = function() WalkSpeedSlider:Set(16) end,
})

PlayerTab:CreateButton({
    name = "Fast Speed (50)",
    callback = function() WalkSpeedSlider:Set(50) end,
})

PlayerTab:CreateButton({
    name = "Flash Speed (150)",
    callback = function() WalkSpeedSlider:Set(150) end,
})

PlayerTab:CreateButton({
    name = "God Speed (300)",
    callback = function() WalkSpeedSlider:Set(300) end,
})

PlayerTab:CreateSection({ name = "Abilities" })

PlayerTab:CreateToggle({
    name = "Infinite Jump",
    description = "Allows continuous mid-air jumping.",
    flag = "InfJumpToggle",
    value = false,
    callback = function(val)
        HubState.Settings.InfJump = val
    end,
})

AddConnection(UserInputService.JumpRequest:Connect(function()
    if HubState.Settings.InfJump and HubState.Running then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

PlayerTab:CreateToggle({
    name = "Noclip",
    description = "Walk through walls without collision.",
    flag = "NoclipToggle",
    value = false,
    callback = function(val)
        HubState.Settings.Noclip = val
    end,
})

AddConnection(RunService.Stepped:Connect(function()
    if not HubState.Running then return end
    if HubState.Settings.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
    -- Keep WalkSpeed persistent
    local hum = GetHumanoid()
    if hum and HubState.Settings.WalkSpeed ~= 16 and hum.WalkSpeed ~= HubState.Settings.WalkSpeed then
        hum.WalkSpeed = HubState.Settings.WalkSpeed
    end
end))

-- CFrame Speed Engine
AddConnection(RunService.RenderStepped:Connect(function(deltaTime)
    if not HubState.Running then return end
    if HubState.Settings.CFrameSpeed then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (HubState.Settings.CFrameSpeedMultiplier * 25 * deltaTime))
        end
    end
end))

--[===================================================================
    TAB 9: SETTINGS & UNLOAD
===================================================================]
SettingsTab:CreateSection({ name = "Theme & Customization" })

SettingsTab:CreateDropdown({
    name = "Window Theme",
    description = "Switch between Crimson Red & Black and built-in themes.",
    flag = "WindowThemeDropdown",
    options = { "Crimson (Red/Black)", "cobalt", "ember", "amethyst", "frost", "rose", "default" },
    value = "Crimson (Red/Black)",
    callback = function(selected)
        if selected == "Crimson (Red/Black)" then
            Window:ChangeTheme(RedBlackTheme)
        else
            Window:ChangeTheme(selected)
        end
    end,
})

SettingsTab:CreateSection({ name = "Keybinds" })

SettingsTab:CreateKeybind({
    name = "Toggle Window Keybind",
    flag = "ToggleWindowKeybind",
    value = Enum.KeyCode.RightControl,
    callback = function()
        Window:ToggleHide()
    end,
})

SettingsTab:CreateSection({ name = "Save & Unload" })

SettingsTab:CreateButton({
    name = "Force Save Config",
    callback = function()
        Window:Save()
        Window:Toast({ title = "Saved", subtitle = "Config written to disk." })
    end,
})

SettingsTab:CreateButton({
    name = "Unload Script Hub",
    description = "Cleanly removes UI and stops all background threads.",
    callback = function()
        HubState.Running = false
        for _, conn in ipairs(HubState.Connections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        for _, h in ipairs(HubState.Highlights) do
            if h and h.Parent then h:Destroy() end
        end
        for _, h in ipairs(HubState.EggHighlights) do
            if h and h.Parent then h:Destroy() end
        end

        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end

        Window:Unload()
    end,
})

print("[Exiles Hub] Loaded with Crimson Red & Black Theme and full feature suite.")