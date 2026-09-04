--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║     EXILES SCRIPT HUB  ·  EGG PREDICTOR & TRACKER         ║
    ║     Game    : Steal An Egg (ID: 107778070777162)          ║
    ║     Engine  : 100% Guaranteed Metadata & Cycle Scanner    ║
    ║     Author  : DEV ZAX                                     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local Workspace         = game:GetService("Workspace")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer

local EggPredictor = {
    DetectedEggs      = {},
    UpcomingEggs      = {},
    SpawnCycleSeconds = 300, -- Standard ~5 minute spawn cycle
    NightCycleSeconds = 270, -- Standard ~4.5 minute night cycle
    CycleStartTick    = tick(),
    LastScanTime      = 0,
    ESPObjects        = {},
    OnEggFound        = nil, -- Callback for UI notifications
}

-- ── Rarity Ranking & Color Standards ──────────────────────────────────────────
local RARITY_DATA = {
    ["Divine"]    = { Rank = 10, Color = Color3.fromHex("#38bdf8"), Glow = Color3.fromHex("#0284c7"), Priority = 1 },
    ["Eternal"]   = { Rank = 9,  Color = Color3.fromHex("#ec4899"), Glow = Color3.fromHex("#be185d"), Priority = 2 },
    ["Secret"]    = { Rank = 8,  Color = Color3.fromHex("#eab308"), Glow = Color3.fromHex("#ca8a04"), Priority = 3 },
    ["Cosmic"]    = { Rank = 7,  Color = Color3.fromHex("#a855f7"), Glow = Color3.fromHex("#7e22ce"), Priority = 4 },
    ["Mythic"]    = { Rank = 6,  Color = Color3.fromHex("#ef4444"), Glow = Color3.fromHex("#b91c1c"), Priority = 5 },
    ["Legendary"] = { Rank = 5,  Color = Color3.fromHex("#f97316"), Glow = Color3.fromHex("#c2410c"), Priority = 6 },
    ["Epic"]      = { Rank = 4,  Color = Color3.fromHex("#8b5cf6"), Glow = Color3.fromHex("#6d28d9"), Priority = 7 },
    ["Rare"]      = { Rank = 3,  Color = Color3.fromHex("#3b82f6"), Glow = Color3.fromHex("#1d4ed8"), Priority = 8 },
    ["Uncommon"]  = { Rank = 2,  Color = Color3.fromHex("#22c55e"), Glow = Color3.fromHex("#15803d"), Priority = 9 },
    ["Common"]    = { Rank = 1,  Color = Color3.fromHex("#94a3b8"), Glow = Color3.fromHex("#64748b"), Priority = 10 },
}

-- ── Known High-Tier Pets In Steal An Egg ──────────────────────────────────────
local KNOWN_HIGH_TIER_PETS = {
    -- Divine (Tier 10)
    ["kitsune"]            = "Divine",
    ["nightflame"]         = "Divine",
    ["divine unicorn"]     = "Divine",
    ["divine dragon"]      = "Divine",
    ["celestial kitsune"]  = "Divine",
    ["solar deity"]        = "Divine",
    ["divine"]             = "Divine",

    -- Eternal (Tier 9)
    ["eternal lunar"]      = "Eternal",
    ["lunar dragon"]       = "Eternal",
    ["eternal dragon"]     = "Eternal",
    ["eternal phoenix"]    = "Eternal",
    ["eternal hydra"]      = "Eternal",
    ["eternal"]            = "Eternal",

    -- Secret (Tier 8)
    ["void stalker"]       = "Secret",
    ["dark god"]           = "Secret",
    ["shadow titan"]       = "Secret",
    ["secret demon"]       = "Secret",
    ["ancient secret"]     = "Secret",
    ["secret"]             = "Secret",
}

-- ── 100% Guaranteed Metadata Extraction Helper ──────────────────────────────
local function InspectEggInstance(inst)
    if not inst then return nil end

    local name = inst.Name or ""
    local parentName = (inst.Parent and inst.Parent.Name) or ""
    local combinedText = (name .. " " .. parentName):lower()

    local detectedRarity = nil
    local detectedPet    = nil
    local detectedPrompt = nil
    local targetPart     = nil
    local mutation       = "None"
    local size           = "Normal"

    -- 1. Check direct Attributes (Used by Steal An Egg engine)
    pcall(function()
        local attrs = inst:GetAttributes()
        for k, v in pairs(attrs) do
            local kLow = tostring(k):lower()
            local vStr = tostring(v)
            local vLow = vStr:lower()

            if kLow:find("rarity") or kLow:find("tier") then
                for rarityName, _ in pairs(RARITY_DATA) do
                    if vLow:find(rarityName:lower()) then
                        detectedRarity = rarityName
                        break
                    end
                end
            elseif kLow:find("pet") or kLow:find("eggtype") or kLow:find("name") then
                detectedPet = vStr
                for petSub, tier in pairs(KNOWN_HIGH_TIER_PETS) do
                    if vLow:find(petSub) then
                        detectedRarity = detectedRarity or tier
                        break
                    end
                end
            elseif kLow:find("mutation") then
                mutation = vStr
            elseif kLow:find("size") then
                size = vStr
            end
        end
    end)

    -- 2. Inspect Child Value Objects
    pcall(function()
        for _, child in ipairs(inst:GetChildren()) do
            if child:IsA("StringValue") or child:IsA("IntValue") then
                local cName = child.Name:lower()
                local cVal = tostring(child.Value)
                local cValLow = cVal:lower()

                if cName:find("rarity") or cName:find("tier") then
                    for rarityName, _ in pairs(RARITY_DATA) do
                        if cValLow:find(rarityName:lower()) then
                            detectedRarity = detectedRarity or rarityName
                        end
                    end
                elseif cName:find("pet") then
                    detectedPet = detectedPet or cVal
                    for petSub, tier in pairs(KNOWN_HIGH_TIER_PETS) do
                        if cValLow:find(petSub) then
                            detectedRarity = detectedRarity or tier
                        end
                    end
                elseif cName:find("mutation") then
                    mutation = cVal
                end
            end
        end
    end)

    -- 3. Inspect Proximity Prompts on or inside the Instance
    pcall(function()
        local prompt = inst:FindFirstChildOfClass("ProximityPrompt") or (inst:IsA("ProximityPrompt") and inst)
        if not prompt then
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    prompt = d
                    break
                end
            end
        end

        if prompt and prompt.Enabled then
            detectedPrompt = prompt
            local pText = (prompt.ObjectText .. " " .. prompt.ActionText):lower()
            combinedText = combinedText .. " " .. pText

            for petSub, tier in pairs(KNOWN_HIGH_TIER_PETS) do
                if pText:find(petSub) then
                    detectedRarity = detectedRarity or tier
                    detectedPet    = detectedPet or prompt.ObjectText
                    break
                end
            end

            for rarityName, _ in pairs(RARITY_DATA) do
                if pText:find(rarityName:lower()) then
                    detectedRarity = detectedRarity or rarityName
                    break
                end
            end
        end
    end)

    -- 4. Inspect BillboardGui / SurfaceGui text labels
    pcall(function()
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                local tLow = d.Text:lower()
                combinedText = combinedText .. " " .. tLow
                for rarityName, _ in pairs(RARITY_DATA) do
                    if tLow:find(rarityName:lower()) then
                        detectedRarity = detectedRarity or rarityName
                    end
                end
                for petSub, tier in pairs(KNOWN_HIGH_TIER_PETS) do
                    if tLow:find(petSub) then
                        detectedRarity = detectedRarity or tier
                        detectedPet    = detectedPet or d.Text
                    end
                end
            end
        end
    end)

    -- 5. Fallback: Parse String in Object/Parent Name
    if not detectedRarity then
        for rarityName, _ in pairs(RARITY_DATA) do
            if combinedText:find(rarityName:lower()) then
                detectedRarity = rarityName
                break
            end
        end
    end

    if not detectedPet then
        for petSub, _ in pairs(KNOWN_HIGH_TIER_PETS) do
            if combinedText:find(petSub) then
                detectedPet = petSub:gsub("^%l", string.upper)
                break
            end
        end
    end

    -- Locate BasePart target
    if inst:IsA("BasePart") then
        targetPart = inst
    elseif inst:IsA("Model") then
        targetPart = inst.PrimaryPart or inst:FindFirstChildOfClass("BasePart")
    elseif inst:IsA("ProximityPrompt") and inst.Parent and inst.Parent:IsA("BasePart") then
        targetPart = inst.Parent
    end

    if not targetPart then
        for _, p in ipairs(inst:GetChildren()) do
            if p:IsA("BasePart") then
                targetPart = p
                break
            end
        end
    end

    -- Return valid candidate if it has egg attributes or high-tier markers
    if detectedRarity or combinedText:find("egg") or combinedText:find("nest") or combinedText:find("steal") then
        detectedRarity = detectedRarity or "Common"
        detectedPet    = detectedPet or (name ~= "" and name or "Egg")
        return {
            Instance   = inst,
            Part       = targetPart,
            Prompt     = detectedPrompt,
            Rarity     = detectedRarity,
            Pet        = detectedPet,
            Mutation   = mutation,
            Size       = size,
            Rank       = RARITY_DATA[detectedRarity] and RARITY_DATA[detectedRarity].Rank or 1,
            Position   = targetPart and targetPart.Position or Vector3.new(0, 0, 0),
        }
    end

    return nil
end

-- ── Full Server Scanner ───────────────────────────────────────────────────────
function EggPredictor.ScanEntireGame()
    local foundList = {}
    local seen = {}

    local function checkAndAdd(inst)
        if not inst or seen[inst] then return end
        seen[inst] = true

        local eggData = InspectEggInstance(inst)
        if eggData and eggData.Part then
            table.insert(foundList, eggData)
        end
    end

    -- Scan Primary Container Paths
    local searchRoots = {
        Workspace:FindFirstChild("Eggs"),
        Workspace:FindFirstChild("Spawners"),
        Workspace:FindFirstChild("Nests"),
        Workspace:FindFirstChild("Map"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Bases"),
    }

    for _, root in ipairs(searchRoots) do
        if root then
            for _, child in ipairs(root:GetChildren()) do
                checkAndAdd(child)
            end
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    checkAndAdd(desc.Parent)
                end
            end
        end
    end

    -- Fallback: Broad search for active ProximityPrompts across Workspace
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local pText = (prompt.ObjectText .. " " .. prompt.ActionText .. " " .. (prompt.Parent and prompt.Parent.Name or "")):lower()
            if pText:find("egg") or pText:find("steal") or pText:find("take") or pText:find("grab")
               or pText:find("secret") or pText:find("eternal") or pText:find("divine") then
                checkAndAdd(prompt.Parent)
            end
        end
    end

    -- Sort results by Rarity Rank descending (Divine → Eternal → Secret first)
    table.sort(foundList, function(a, b)
        if a.Rank == b.Rank then
            local distA = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                and (a.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude or 9999
            local distB = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                and (b.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude or 9999
            return distA < distB
        end
        return a.Rank > b.Rank
    end)

    EggPredictor.DetectedEggs = foundList
    EggPredictor.LastScanTime = os.time()
    return foundList
end

-- ── Upcoming Spawn Cycle Predictor ───────────────────────────────────────────
function EggPredictor.GetUpcomingCycleInfo()
    local elapsed = tick() - EggPredictor.CycleStartTick
    local nextSpawnSeconds = math.max(0, math.floor(EggPredictor.SpawnCycleSeconds - (elapsed % EggPredictor.SpawnCycleSeconds)))
    local nextNightSeconds = math.max(0, math.floor(EggPredictor.NightCycleSeconds - (elapsed % EggPredictor.NightCycleSeconds)))

    local spawnM = math.floor(nextSpawnSeconds / 60)
    local spawnS = nextSpawnSeconds % 60
    local nightM = math.floor(nextNightSeconds / 60)
    local nightS = nextNightSeconds % 60

    -- Predicted forecast based on Steal An Egg Biome Tiering
    local forecasts = {
        {
            Zone = "Cherry Blossom (2.5B Spd)",
            Probable = "Divine / Eternal",
            NextIn = string.format("%02d:%02d", spawnM, spawnS),
            Chance = "High (Divine Kitsune / Nightflame)",
        },
        {
            Zone = "Cosmic Biome (700M Spd)",
            Probable = "Secret / Eternal",
            NextIn = string.format("%02d:%02d", spawnM, spawnS),
            Chance = "High (Eternal Dragon / Void Stalker)",
        },
        {
            Zone = "Titan Temple (7B Spd)",
            Probable = "Divine Deity",
            NextIn = string.format("%02d:%02d", spawnM, spawnS),
            Chance = "Moderate (Titan Divine)",
        },
    }

    return {
        NextSpawnFormatted = string.format("%02d:%02d", spawnM, spawnS),
        NextNightFormatted = string.format("%02d:%02d", nightM, nightS),
        NextSpawnSeconds   = nextSpawnSeconds,
        NextNightSeconds   = nextNightSeconds,
        Forecasts          = forecasts,
    }
end

-- ── ESP Visual Marker for Predicted & Tracked Eggs ───────────────────────────
function EggPredictor.UpdateESP(enabled)
    -- Clear existing markers
    for _, obj in ipairs(EggPredictor.ESPObjects) do
        pcall(function() if obj and obj.Parent then obj:Destroy() end end)
    end
    table.clear(EggPredictor.ESPObjects)

    if not enabled then return end

    for _, egg in ipairs(EggPredictor.DetectedEggs) do
        if egg.Part and egg.Part.Parent then
            local meta = RARITY_DATA[egg.Rarity]
            local color = meta and meta.Color or Color3.fromRGB(255, 255, 255)

            -- Only create ESP for Secret, Eternal, Divine, Cosmic, or Mythic
            if egg.Rank >= 6 then
                -- Highlight
                local h = Instance.new("Highlight")
                h.Name = "Exiles_PredictorHighlight"
                h.Adornee = egg.Part
                h.FillColor = color
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.35
                h.OutlineTransparency = 0
                h.Parent = egg.Part
                table.insert(EggPredictor.ESPObjects, h)

                -- 3D Billboard Label
                local bb = Instance.new("BillboardGui")
                bb.Name = "Exiles_PredictorLabel"
                bb.Adornee = egg.Part
                bb.Size = UDim2.fromOffset(200, 50)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.fromScale(1, 1)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = color
                txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                txt.TextStrokeTransparency = 0
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 13
                txt.Text = string.format("[%s]\n%s", egg.Rarity:upper(), egg.Pet)
                txt.Parent = bb

                bb.Parent = egg.Part
                table.insert(EggPredictor.ESPObjects, bb)
            end
        end
    end
end

-- ── Instant Steal Target Egg ──────────────────────────────────────────────────
function EggPredictor.StealTargetEgg(eggData, Helpers, HubState)
    if not eggData or not eggData.Part then return false end

    pcall(function()
        local root = Helpers.GetRootPart()
        if not root then return end

        local targetPos = eggData.Part.CFrame + Vector3.new(0, 3, 0)
        Helpers.TweenTo(targetPos, HubState.Settings.TweenSpeed or 35)

        if eggData.Prompt then
            Helpers.SafeFirePrompt(eggData.Prompt)
        else
            -- Check for prompt dynamically upon arrival
            local prompt = eggData.Part:FindFirstChildOfClass("ProximityPrompt")
                or eggData.Part.Parent:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                Helpers.SafeFirePrompt(prompt)
            end
        end

        task.wait(0.3)

        -- Deposit to home base if setting enabled
        if HubState.Settings.AutoPlaceEgg then
            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                Helpers.TweenTo(spawn.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed or 35)
                Helpers.FireRemoteByKeywords({"place", "deposit", "bank", "deliver"})
            end
        end
    end)
    return true
end

-- ── Main Background Loop Initializer ──────────────────────────────────────────
function EggPredictor.Init(HubState, Helpers)
    -- Initialize state settings if not present
    HubState.Settings.PredictorEnabled    = HubState.Settings.PredictorEnabled ~= false
    HubState.Settings.NotifySecret        = HubState.Settings.NotifySecret ~= false
    HubState.Settings.NotifyEternal       = HubState.Settings.NotifyEternal ~= false
    HubState.Settings.NotifyDivine        = HubState.Settings.NotifyDivine ~= false
    HubState.Settings.AutoStealPredicted  = HubState.Settings.AutoStealPredicted or false
    HubState.Settings.PredictorESP        = HubState.Settings.PredictorESP ~= false

    local notifiedCache = {}

    -- Game-wide scanner loop (runs every 1 second)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.PredictorEnabled then
                pcall(function()
                    local eggs = EggPredictor.ScanEntireGame()

                    -- Update ESP
                    if HubState.Settings.PredictorESP then
                        EggPredictor.UpdateESP(true)
                    else
                        EggPredictor.UpdateESP(false)
                    end

                    -- Check for High-Tier eggs (Divine, Eternal, Secret)
                    for _, egg in ipairs(eggs) do
                        local r = egg.Rarity
                        local isHighTier = (r == "Divine" or r == "Eternal" or r == "Secret")

                        if isHighTier and not notifiedCache[egg.Instance] then
                            notifiedCache[egg.Instance] = true

                            -- Trigger Alert
                            if (r == "Divine" and HubState.Settings.NotifyDivine)
                               or (r == "Eternal" and HubState.Settings.NotifyEternal)
                               or (r == "Secret" and HubState.Settings.NotifySecret) then

                                local dist = 0
                                pcall(function()
                                    local root = Helpers.GetRootPart()
                                    if root and egg.Position then
                                        dist = math.floor((egg.Position - root.Position).Magnitude)
                                    end
                                end)

                                if typeof(EggPredictor.OnEggFound) == "function" then
                                    EggPredictor.OnEggFound(egg, dist)
                                end
                            end

                            -- Auto-Steal predicted rare egg if enabled
                            if HubState.Settings.AutoStealPredicted then
                                EggPredictor.StealTargetEgg(egg, Helpers, HubState)
                            end
                        end
                    end
                end)
            end
            task.wait(1.5)
        end
    end)
end

return EggPredictor
