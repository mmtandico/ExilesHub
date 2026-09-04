--[[
    ===================================================================
    EXILES SCRIPT HUB | CENTRAL STATE & SETTINGS
    ===================================================================
]]

local HubState = {
    Running = true,
    TargetPlaceId = 107778070777162,
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

        -- Treadmill & Upgrades
        AutoTreadmill = false,
        HideTreadmill = false,
        AutoUpgradeTreadmill = false,
        AutoUpgradeBase = false,
        AutoBuyTrail = false,
        AutoClaim = false,

        -- Monster
        AutoFeedMonster = false,
        FeedMaxRarity = "Rare",
        AutoClaimChest = false,

        -- Hatching
        AutoHatch = false,
        EggScope = "Basic Egg",

        -- Egg Predictor & Tracker (100% Guaranteed Detection)
        PredictorEnabled   = true,
        NotifyDivine       = true,
        NotifyEternal      = true,
        NotifySecret       = true,
        AutoStealPredicted = false,
        PredictorESP       = true,
        PredictorFilter    = "Secret+",

        -- Pet Management
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

function HubState.AddConnection(conn)
    table.insert(HubState.Connections, conn)
    return conn
end

function HubState.Cleanup()
    HubState.Running = false
    for _, conn in ipairs(HubState.Connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    for _, h in ipairs(HubState.Highlights) do
        if h and h.Parent then h:Destroy() end
    end
    for _, h in ipairs(HubState.EggHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    table.clear(HubState.Connections)
    table.clear(HubState.Highlights)
    table.clear(HubState.EggHighlights)
end

return HubState
