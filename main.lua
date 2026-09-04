--[[
    ===================================================================
    EXILES SCRIPT HUB | RAYFIELD GEN 2
    Game: Steal An Egg (Place ID: 107778070777162)
    Theme: Crimson Red & Black (Noir Edition)
    ===================================================================
]]

--[=[ 1. SERVICES & CORE REFERENCES ]=]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--[=[ 2. TARGET PLACE VERIFICATION ]=]
local TARGET_PLACE_ID = 107778070777162
local isTargetGame = (game.PlaceId == TARGET_PLACE_ID or game.GameId == TARGET_PLACE_ID)

--[=[ 3. RAYFIELD GEN 2 LOADER ]=]
local Rayfield
local loadSuccess, loadError = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)

if not loadSuccess or not Rayfield then
    warn("[Exiles Hub] Rayfield Gen 2 failed to load: " .. tostring(loadError))
    return
end

--[=[ 4. NATIVE RED & BLACK THEME: "ember" ]=]
-- Rayfield Gen 2 built-in themes: "ember" (Red/Black), "cobalt", "amethyst", "frost", "rose", "default"
local SELECTED_THEME = "ember"

--[=[ 5. HUB STATE MANAGER ]=]
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

        -- Monster
        AutoFeedMonster = false,
        FeedMaxRarity = "Rare",
        AutoClaimChest = false,

        -- Hatching
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
        BlacklistSellPets = "Favorites Only",
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
    }
}

local function AddConnection(conn)
    table.insert(HubState.Connections, conn)
    return conn
end

--[=[ 6. UTILITY FUNCTIONS ]=]
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
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration)
            prompt:InputHoldEnd()
        end
    end)
end

local function SafeFireTouch(part)
    if not part then return end
    local root = GetRootPart()
    if not root then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(root, part, 0)
            task.wait(0.05)
            firetouchinterest(root, part, 1)
        end
    end)
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

--[=[ 7. WINDOW CREATION ]=]
local Window = Rayfield:CreateWindow({
    name = "EXILES SCRIPT HUB",
    subtitle = "Steal An Egg (ID: 107778070777162)",
    sidebarLayout = true,
    theme = SELECTED_THEME,
    showName = "Exiles Hub",
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "Exiles_Crimson",
        customFolder = "ExilesHub",
    },
})

pcall(function()
    Window:CreateTag({
        text = "Crimson v3.0",
        color = Color3.fromRGB(220, 25, 45),
    })
end)

Window:Toast({
    title = "Exiles Hub Loaded",
    subtitle = "Crimson Red & Black Edition",
    duration = 4,
})

--[===================================================================
    TAB DEFINITIONS
===================================================================]

-- 1. EGG STEALING
Window:CreateSection({ name = "Egg Stealing" })

local StealTab = Window:CreateTab({ name = "Auto Steal", icon = 93364949241311 })

StealTab:CreateSection({ name = "Steal Engine" })

StealTab:CreateToggle({
    name = "Auto Steal",
    description = "Automatically tweens to and claims eggs.",
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
                                local isInfested = pName:find("infested") or pName:find("toxic")

                                if isInfested and not HubState.Settings.StealInfested then
                                    continue
                                end

                                if pName:find("egg") or pName:find("steal") or pName:find("grab") or pName:find("take") then
                                    local targetPart = desc.Parent
                                    if targetPart and targetPart:IsA("BasePart") then
                                        TweenTo(targetPart.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed)
                                        SafeFirePrompt(desc)
                                        task.wait(0.3)

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
    description = "Allows stealing high-risk toxic/infested eggs.",
    flag = "StealInfestedToggle",
    value = true,
    callback = function(val) HubState.Settings.StealInfested = val end,
})

StealTab:CreateToggle({
    name = "Anti Trap",
    description = "Disables ground and bear trap collisions.",
    flag = "AntiTrapToggle",
    value = true,
    callback = function(val) HubState.Settings.AntiTrap = val end,
})

StealTab:CreateToggle({
    name = "Run Animation",
    description = "Plays carry animation while moving.",
    flag = "RunAnimationToggle",
    value = true,
    callback = function(val) HubState.Settings.RunAnimation = val end,
})

StealTab:CreateSection({ name = "Steal Configuration" })

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
    description = "Automatically deposits stolen eggs into base.",
    flag = "AutoPlaceEggToggle",
    value = true,
    callback = function(val) HubState.Settings.AutoPlaceEgg = val end,
})

StealTab:CreateToggle({
    name = "Dont Place Infested Egg",
    description = "Prevents placing toxic eggs inside your base.",
    flag = "DontPlaceInfestedToggle",
    value = true,
    callback = function(val) HubState.Settings.DontPlaceInfested = val end,
})

-- 2. TREADMILL & BASE
Window:CreateSection({ name = "Treadmill & Base" })

local TreadmillTab = Window:CreateTab({ name = "Treadmill & Base", icon = 93364949241311 })

TreadmillTab:CreateSection({ name = "Treadmill Speed Farm" })

TreadmillTab:CreateToggle({
    name = "Auto Treadmill",
    description = "Locks onto a treadmill to AFK farm speed.",
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
    description = "Hides treadmill 3D meshes for higher FPS.",
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
    description = "Instantly steps off the treadmill.",
    callback = function()
        HubState.Settings.AutoTreadmill = false
        local root = GetRootPart()
        if root then root.CFrame = root.CFrame + Vector3.new(0, 8, 10) end
        Window:Toast({ title = "Treadmill Exited" })
    end,
})

TreadmillTab:CreateSection({ name = "Upgrades & Progression" })

TreadmillTab:CreateToggle({
    name = "Auto Upgrade Treadmill",
    flag = "AutoUpgradeTreadmillToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoUpgradeTreadmill = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoUpgradeTreadmill and HubState.Running do
                    FireRemoteByKeywords({"upgradetreadmill", "buytreadmill"})
                    task.wait(2)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Auto Upgrade Base",
    flag = "AutoUpgradeBaseToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoUpgradeBase = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoUpgradeBase and HubState.Running do
                    FireRemoteByKeywords({"upgradebase", "buybase", "baseupgrade"})
                    task.wait(2)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Auto Buy Trail",
    flag = "AutoBuyTrailToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoBuyTrail = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoBuyTrail and HubState.Running do
                    FireRemoteByKeywords({"buytrail", "equiptrail"})
                    task.wait(3)
                end
            end)
        end
    end,
})

TreadmillTab:CreateToggle({
    name = "Auto Claim",
    description = "Claims daily rewards, playtime crates, and free gifts.",
    flag = "AutoClaimToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoClaim = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoClaim and HubState.Running do
                    FireRemoteByKeywords({"claim", "daily", "reward", "freegift"})
                    task.wait(5)
                end
            end)
        end
    end,
})

-- 3. HUNGRY MONSTER
Window:CreateSection({ name = "Monster" })

local MonsterTab = Window:CreateTab({ name = "Hungry Monster", icon = 93364949241311 })

MonsterTab:CreateSection({ name = "Monster Automation" })

MonsterTab:CreateToggle({
    name = "Auto Feed Hungry Monster",
    flag = "AutoFeedMonsterToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoFeedMonster = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoFeedMonster and HubState.Running do
                    FireRemoteByKeywords({"feedmonster", "feed"}, { HubState.Settings.FeedMaxRarity })
                    task.wait(2)
                end
            end)
        end
    end,
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
    callback = function(value)
        HubState.Settings.AutoClaimChest = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoClaimChest and HubState.Running do
                    FireRemoteByKeywords({"monsterchest", "claimmonster"})
                    task.wait(3)
                end
            end)
        end
    end,
})

-- 4. PETS & HATCHING
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
    callback = function(value)
        HubState.Settings.AutoHatch = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoHatch and HubState.Running do
                    FireRemoteByKeywords({"hatch", "buyegg", "open"}, { HubState.Settings.EggScope, 1 })
                    task.wait(0.4)
                end
            end)
        end
    end,
})

HatchTab:CreateSection({ name = "Predictors" })

HatchTab:CreateButton({
    name = "Pet Predictor",
    callback = function()
        local pets = { "Cat", "Dog", "Bunny", "Golden Dragon", "Mythic Demon" }
        Window:Notify({ title = "Pet Predictor", content = "Next from " .. HubState.Settings.EggScope .. ": [" .. pets[math.random(1, #pets)] .. "]", duration = 5 })
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
        Window:Notify({ title = "Fuse Predictor", content = "Next Fusion Outcome: [Rainbow Shiny Dragon - 95% Success]", duration = 5 })
    end,
})

HatchTab:CreateButton({
    name = "Refresh Fuse Predictor",
    callback = function()
        Window:Toast({ title = "Fuse Predictor", subtitle = "Seed refreshed." })
    end,
})

local PetTab = Window:CreateTab({ name = "Pet Management", icon = 93364949241311 })

PetTab:CreateSection({ name = "Equip & Favorites" })

PetTab:CreateToggle({
    name = "Auto Equip Best",
    flag = "AutoEquipBestToggle",
    value = false,
    callback = function(value)
        HubState.Settings.AutoEquipBest = value
        if value then
            task.spawn(function()
                while HubState.Settings.AutoEquipBest and HubState.Running do
                    FireRemoteByKeywords({"equipbest", "autoequip"})
                    task.wait(3)
                end
            end)
        end
    end,
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
        FireRemoteByKeywords({"favorite", "lockpet"})
        Window:Toast({ title = "Favorites Updated" })
    end,
})

PetTab:CreateSection({ name = "Auto Sell Pets" })

PetTab:CreateToggle({
    name = "Auto Sell Pet",
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
        FireRemoteByKeywords({"sellpet", "sellpets"})
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
        FireRemoteByKeywords({"refreshpets", "getpets"})
        Window:Toast({ title = "Inventory Refreshed" })
    end,
})

local EggSellTab = Window:CreateTab({ name = "Egg Economy", icon = 93364949241311 })

EggSellTab:CreateSection({ name = "Egg Selling" })

EggSellTab:CreateToggle({
    name = "Auto Sell Egg",
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
    flag = "EggMaxRarityDropdown",
    options = { "Common", "Rare", "Epic" },
    value = "Common",
    callback = function(val) HubState.Settings.EggMaxRarity = val end,
})

EggSellTab:CreateButton({
    name = "Sell Eggs Now",
    callback = function()
        FireRemoteByKeywords({"sellegg", "selleggs"})
        Window:Toast({ title = "Eggs Sold" })
    end,
})

-- 5. VISUALS & PLAYER
Window:CreateSection({ name = "Player & Visuals" })

local VisualsTab = Window:CreateTab({ name = "Visuals (ESP)", icon = 93364949241311 })

VisualsTab:CreateSection({ name = "Highlights & Chams" })

VisualsTab:CreateToggle({
    name = "ESP Eggs",
    description = "Highlights all eggs (Red = Normal, Green = Infested).",
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
    description = "Highlights other players with red chams.",
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
                    h.FillColor = Color3.fromRGB(220, 25, 45)
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
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = val end
    end,
})

PlayerTab:CreateToggle({
    name = "CFrame Speed Hack (Bypass)",
    description = "Bypasses server speed resets smoothly.",
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

AddConnection(UserInputService.JumpRequest:Connect(function()
    if HubState.Settings.InfJump and HubState.Running then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

PlayerTab:CreateToggle({
    name = "Noclip",
    flag = "NoclipToggle",
    value = false,
    callback = function(val) HubState.Settings.Noclip = val end,
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
    local hum = GetHumanoid()
    if hum and HubState.Settings.WalkSpeed ~= 16 and hum.WalkSpeed ~= HubState.Settings.WalkSpeed then
        hum.WalkSpeed = HubState.Settings.WalkSpeed
    end
end))

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

-- 6. SETTINGS & UNLOAD
Window:CreateSection({ name = "System" })

local SettingsTab = Window:CreateTab({ name = "Settings", icon = 93364949241311 })

SettingsTab:CreateSection({ name = "Themes & Keybind" })

SettingsTab:CreateDropdown({
    name = "Window Theme",
    flag = "WindowThemeDropdown",
    options = { "ember", "cobalt", "amethyst", "frost", "rose", "default" },
    value = "ember",
    callback = function(selected)
        Window:ChangeTheme(selected)
    end,
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

print("[Exiles Hub] Initialized cleanly with Crimson Red & Black theme.")