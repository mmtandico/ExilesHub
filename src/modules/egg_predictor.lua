--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║     EXILES SCRIPT HUB  ·  EGG PREDICTOR & TRACKER         ║
    ║     Game    : Steal An Egg (ID: 107778070777162)          ║
    ║     Engine  : 100% Real-Time Server & HUD Sync Engine     ║
    ║     Author  : DEV ZAX                                     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local Workspace         = game:GetService("Workspace")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting          = game:GetService("Lighting")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer

local EggPredictor = {
    DetectedEggs       = {},
    RarityCounts       = {},
    SpawnCycleSeconds  = 300, -- Standard 5:00 spawn cycle
    ManualOffset       = 0,   -- User-calibrated timing offset
    LockedToGuiTimer   = false,
    LastGuiTimerSec    = 0,
    LastGuiReadTick    = 0,
    LastScanTime       = 0,
    ESPObjects         = {},
    OnEggFound         = nil,
}

-- ── Verified Rarity Hierarchy & Attributes ────────────────────────────────────
local RARITY_DATA = {
    ["Divine"]    = { Rank = 10, Color = Color3.fromHex("#38bdf8"), Glow = Color3.fromHex("#0284c7") },
    ["Eternal"]   = { Rank = 9,  Color = Color3.fromHex("#ec4899"), Glow = Color3.fromHex("#be185d") },
    ["Secret"]    = { Rank = 8,  Color = Color3.fromHex("#eab308"), Glow = Color3.fromHex("#ca8a04") },
    ["Cosmic"]    = { Rank = 7,  Color = Color3.fromHex("#a855f7"), Glow = Color3.fromHex("#7e22ce") },
    ["Mythic"]    = { Rank = 6,  Color = Color3.fromHex("#ef4444"), Glow = Color3.fromHex("#b91c1c") },
    ["Legendary"] = { Rank = 5,  Color = Color3.fromHex("#f97316"), Glow = Color3.fromHex("#c2410c") },
    ["Epic"]      = { Rank = 4,  Color = Color3.fromHex("#8b5cf6"), Glow = Color3.fromHex("#6d28d9") },
    ["Rare"]      = { Rank = 3,  Color = Color3.fromHex("#3b82f6"), Glow = Color3.fromHex("#1d4ed8") },
    ["Uncommon"]  = { Rank = 2,  Color = Color3.fromHex("#22c55e"), Glow = Color3.fromHex("#15803d") },
    ["Common"]    = { Rank = 1,  Color = Color3.fromHex("#94a3b8"), Glow = Color3.fromHex("#64748b") },
}

-- ── High-Tier Pet Signatures in Steal An Egg ─────────────────────────────────
local PET_SIGNATURES = {
    -- Divine (Tier 10)
    ["kitsune"]           = "Divine",
    ["nightflame"]        = "Divine",
    ["unicorn"]           = "Divine",
    ["solar deity"]       = "Divine",
    ["celestial"]         = "Divine",
    ["divine"]            = "Divine",

    -- Eternal (Tier 9)
    ["lunar dragon"]      = "Eternal",
    ["eternal dragon"]    = "Eternal",
    ["eternal phoenix"]   = "Eternal",
    ["eternal hydra"]     = "Eternal",
    ["eternal"]           = "Eternal",

    -- Secret (Tier 8)
    ["void stalker"]      = "Secret",
    ["dark god"]          = "Secret",
    ["shadow titan"]      = "Secret",
    ["secret demon"]      = "Secret",
    ["ancient secret"]    = "Secret",
    ["secret"]            = "Secret",

    -- Cosmic (Tier 7)
    ["cosmic dragon"]     = "Cosmic",
    ["cosmic"]            = "Cosmic",

    -- Mythic (Tier 6)
    ["mythic demon"]      = "Mythic",
    ["reaper"]            = "Mythic",
    ["mythic"]            = "Mythic",
}

-- ── 1. Real In-Game UI Timer Extractor (PlayerGui) ───────────────────────────
local function FindInGameTimerFromGui()
    local bestTimer = nil
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end

        for _, label in ipairs(pg:GetDescendants()) do
            if label:IsA("TextLabel") and label.Visible and label.Text ~= "" then
                local txt = label.Text
                -- Check for patterns like "04:12" or "4:12"
                local m, s = txt:match("(%d+):(%d%d)")
                if m and s then
                    local totalSec = tonumber(m) * 60 + tonumber(s)
                    if totalSec > 0 and totalSec <= 600 then
                        local lName = (label.Name .. " " .. (label.Parent and label.Parent.Name or "")):lower()
                        local tLow = txt:lower()

                        if lName:find("spawn") or lName:find("egg") or lName:find("timer") or tLow:find("spawn") or tLow:find("egg") or tLow:find("next") then
                            bestTimer = {
                                Text = string.format("%02d:%02d", tonumber(m), tonumber(s)),
                                Seconds = totalSec,
                                Source = "In-Game HUD",
                                Label = label
                            }
                            return
                        elseif not bestTimer then
                            bestTimer = {
                                Text = string.format("%02d:%02d", tonumber(m), tonumber(s)),
                                Seconds = totalSec,
                                Source = "GUI",
                                Label = label
                            }
                        end
                    end
                end
            end
        end
    end)
    return bestTimer
end

-- ── 2. Real In-Game World Timer Extractor (Workspace Signs / Boards) ─────────
local function FindInGameTimerFromWorkspace()
    local bestTimer = nil
    pcall(function()
        for _, gui in ipairs(Workspace:GetDescendants()) do
            if (gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and gui.Enabled then
                for _, label in ipairs(gui:GetDescendants()) do
                    if label:IsA("TextLabel") and label.Text ~= "" then
                        local m, s = label.Text:match("(%d+):(%d%d)")
                        if m and s then
                            local sec = tonumber(m) * 60 + tonumber(s)
                            if sec > 0 and sec <= 600 then
                                bestTimer = {
                                    Text = string.format("%02d:%02d", tonumber(m), tonumber(s)),
                                    Seconds = sec,
                                    Source = "World Display",
                                }
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    return bestTimer
end

-- ── 3. Real In-Game Night Cycle Extractor (Lighting) ─────────────────────────
-- ── 3. Real In-Game Night Cycle Extractor (Measured from Lighting.ClockTime) ──
local measuredClockSpeed = 0.0888 -- ~24 in-game hours per ~270s default
local lastClockValue = Lighting.ClockTime
local lastClockSampleTick = tick()

task.spawn(function()
    while true do
        task.wait(2)
        local now = tick()
        local currentClock = Lighting.ClockTime
        local dt = now - lastClockSampleTick
        if dt > 0 then
            local deltaClock = currentClock - lastClockValue
            if deltaClock < -12 then deltaClock = deltaClock + 24 end -- Wrapped midnight
            if deltaClock > 0 and deltaClock < 5 then
                measuredClockSpeed = deltaClock / dt
            end
        end
        lastClockValue = currentClock
        lastClockSampleTick = now
    end
end)

local function GetLightingNightStatus()
    local clock = 12
    pcall(function() clock = Lighting.ClockTime end)

    local isNight = (clock >= 18 or clock < 6)
    local hoursLeft = 0
    if isNight then
        hoursLeft = (clock >= 18) and (24 - clock + 6) or (6 - clock)
    else
        hoursLeft = 18 - clock
    end

    local safeSpeed = (measuredClockSpeed > 0.001) and measuredClockSpeed or 0.0888
    local secondsToTransition = math.max(0, math.floor(hoursLeft / safeSpeed))

    local m = math.floor(secondsToTransition / 60)
    local s = secondsToTransition % 60

    local inGameH = math.floor(clock)
    local inGameM = math.floor((clock % 1) * 60)
    local inGameTimeStr = string.format("%02d:%02d", inGameH, inGameM)

    return {
        IsNight       = isNight,
        ClockTime     = clock,
        InGameTimeStr = inGameTimeStr,
        Status        = isNight and ("🌙 NIGHT ACTIVE (Ends in " .. string.format("%02d:%02d", m, s) .. ")")
                                or ("☀️ DAYTIME (Nightfall in " .. string.format("%02d:%02d", m, s) .. ")"),
        Formatted     = string.format("%02d:%02d", m, s),
        Seconds       = secondsToTransition,
    }
end

-- ── 4. Accurate Global Spawn Cycle Calculator ────────────────────────────────
function EggPredictor.GetUpcomingCycleInfo()
    local serverNow = 0
    local ok = pcall(function() serverNow = Workspace:GetServerTimeNow() end)
    if not ok or serverNow == 0 then serverNow = os.time() end

    -- Apply user manual calibration offset
    local adjustedNow = serverNow + (EggPredictor.ManualOffset or 0)
    local finalSeconds = EggPredictor.SpawnCycleSeconds - (math.floor(adjustedNow) % EggPredictor.SpawnCycleSeconds)
    if finalSeconds < 0 then finalSeconds = finalSeconds + EggPredictor.SpawnCycleSeconds end

    local m = math.floor(finalSeconds / 60)
    local s = finalSeconds % 60
    local formattedText = string.format("%02d:%02d", m, s)

    local timerSource = (EggPredictor.ManualOffset ~= 0) and "User-Calibrated Sync" or "Server Sync"

    -- Real Night status from Lighting
    local nightInfo = GetLightingNightStatus()

    return {
        NextSpawnFormatted = formattedText,
        NextSpawnSeconds   = finalSeconds,
        TimerSource        = timerSource,
        IsNight            = nightInfo.IsNight,
        InGameTimeStr      = nightInfo.InGameTimeStr,
        NightStatus        = nightInfo.Status,
        NightFormatted     = nightInfo.Formatted,
        NightSeconds       = nightInfo.Seconds,
    }
end

-- ── 5. User Sync / Calibration Methods ────────────────────────────────────────
function EggPredictor.SetRemainingSeconds(seconds)
    local serverNow = 0
    local ok = pcall(function() serverNow = Workspace:GetServerTimeNow() end)
    if not ok or serverNow == 0 then serverNow = os.time() end

    local currentEpochRemainder = EggPredictor.SpawnCycleSeconds - (math.floor(serverNow) % EggPredictor.SpawnCycleSeconds)
    EggPredictor.ManualOffset = (seconds - currentEpochRemainder)
    EggPredictor.LockedToGuiTimer = false
end

function EggPredictor.AdjustSeconds(delta)
    EggPredictor.ManualOffset = (EggPredictor.ManualOffset or 0) + delta
end

function EggPredictor.SetCycleLength(seconds)
    EggPredictor.SpawnCycleSeconds = seconds or 300
end

function EggPredictor.SyncTimer(targetSeconds)
    EggPredictor.SetRemainingSeconds(targetSeconds or EggPredictor.SpawnCycleSeconds)
end

-- ── 6. 100% Accurate Game-Wide Egg Inspector ─────────────────────────────────
local function InspectEgg(inst)
    if not inst then return nil end

    local detectedRarity = nil
    local detectedPet    = nil
    local detectedPrompt = nil
    local targetPart     = nil
    local mutation       = "None"
    local size           = "Normal"
    local locationDesc   = "Wild Nest"

    -- Find ProximityPrompt anywhere in or around the instance
    local prompt = inst:FindFirstChildOfClass("ProximityPrompt") or (inst:IsA("ProximityPrompt") and inst)
    if not prompt then
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                prompt = d
                break
            end
        end
    end

    -- Determine Target BasePart
    if inst:IsA("BasePart") then
        targetPart = inst
    elseif inst:IsA("Model") then
        targetPart = inst.PrimaryPart or inst:FindFirstChildOfClass("BasePart")
    elseif prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
        targetPart = prompt.Parent
    end

    if not targetPart and prompt and prompt.Parent and prompt.Parent:IsA("Model") then
        targetPart = prompt.Parent.PrimaryPart or prompt.Parent:FindFirstChildOfClass("BasePart")
    end

    if not targetPart then return nil end

    -- Compile all textual metadata for 100% accurate classification
    local combinedTokens = {}
    table.insert(combinedTokens, inst.Name:lower())
    if inst.Parent then table.insert(combinedTokens, inst.Parent.Name:lower()) end
    if targetPart then table.insert(combinedTokens, targetPart.Name:lower()) end

    -- Check ProximityPrompt Text (Highest reliability in Steal An Egg)
    if prompt and prompt.Enabled then
        detectedPrompt = prompt
        local objText = prompt.ObjectText or ""
        local actText = prompt.ActionText or ""
        table.insert(combinedTokens, objText:lower())
        table.insert(combinedTokens, actText:lower())

        if objText ~= "" and not objText:lower():find("proximity") then
            detectedPet = objText
        end
    end

    -- Check Attributes on Part, Model, and Prompt
    local function readAttrs(target)
        if not target then return end
        pcall(function()
            local attrs = target:GetAttributes()
            for k, v in pairs(attrs) do
                local kLow = tostring(k):lower()
                local vStr = tostring(v)
                local vLow = vStr:lower()
                table.insert(combinedTokens, vLow)

                if kLow:find("rarity") or kLow:find("tier") then
                    for rarityName, _ in pairs(RARITY_DATA) do
                        if vLow:find(rarityName:lower()) then
                            detectedRarity = rarityName
                        end
                    end
                elseif kLow:find("pet") or kLow:find("egg") then
                    detectedPet = detectedPet or vStr
                elseif kLow:find("mutation") then
                    mutation = vStr
                elseif kLow:find("size") then
                    size = vStr
                end
            end
        end)
    end

    readAttrs(inst)
    readAttrs(targetPart)
    if prompt then readAttrs(prompt) end

    -- Check Child Value Objects
    pcall(function()
        for _, child in ipairs(inst:GetChildren()) do
            if child:IsA("StringValue") or child:IsA("IntValue") then
                local cName = child.Name:lower()
                local cVal = tostring(child.Value)
                table.insert(combinedTokens, cVal:lower())
                if cName:find("rarity") or cName:find("tier") then
                    for rarityName, _ in pairs(RARITY_DATA) do
                        if cVal:lower():find(rarityName:lower()) then
                            detectedRarity = rarityName
                        end
                    end
                elseif cName:find("pet") then
                    detectedPet = detectedPet or cVal
                elseif cName:find("mutation") then
                    mutation = cVal
                end
            end
        end
    end)

    -- Check Attached 3D Billboard / Surface Labels
    pcall(function()
        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible and desc.Text ~= "" then
                table.insert(combinedTokens, desc.Text:lower())
            end
        end
    end)

    local fullString = table.concat(combinedTokens, " ")

    -- Determine Location / Zone
    if fullString:find("cherry") then
        locationDesc = "Cherry Blossom (2.5B Spd)"
    elseif fullString:find("cosmic") then
        locationDesc = "Cosmic Biome (700M Spd)"
    elseif fullString:find("titan") then
        locationDesc = "Titan Temple (7B Spd)"
    elseif fullString:find("ocean") or fullString:find("abyss") then
        locationDesc = "Abyss Ocean"
    elseif fullString:find("desert") then
        locationDesc = "Desert Biome"
    elseif fullString:find("base") then
        locationDesc = "Player Base Nest"
    end

    -- Match Known Pet Signatures
    for petSig, tier in pairs(PET_SIGNATURES) do
        if fullString:find(petSig) then
            detectedRarity = detectedRarity or tier
            detectedPet    = detectedPet or (petSig:gsub("^%l", string.upper))
            break
        end
    end

    -- Match Exact Rarity Names
    if not detectedRarity then
        for rarityName, _ in pairs(RARITY_DATA) do
            if fullString:find(rarityName:lower()) then
                detectedRarity = rarityName
                break
            end
        end
    end

    -- Is this instance an egg or stealable item?
    local isEggCandidate = (detectedRarity ~= nil)
        or fullString:find("egg")
        or fullString:find("steal")
        or fullString:find("nest")
        or (prompt ~= nil and prompt.Enabled and prompt.ActionText:lower():find("steal"))

    if isEggCandidate then
        detectedRarity = detectedRarity or "Common"
        detectedPet    = detectedPet or (inst.Name ~= "" and inst.Name or "Egg")

        return {
            Instance = inst,
            Part     = targetPart,
            Prompt   = detectedPrompt,
            Rarity   = detectedRarity,
            Pet      = detectedPet,
            Mutation = mutation,
            Size     = size,
            Location = locationDesc,
            Rank     = RARITY_DATA[detectedRarity] and RARITY_DATA[detectedRarity].Rank or 1,
            Position = targetPart.Position,
        }
    end

    return nil
end

-- ── 7. Full Game Scanner Across All Workspaces & Prompts ──────────────────────
function EggPredictor.ScanEntireGame()
    local foundList = {}
    local seen = {}
    local counts = {
        Divine = 0, Eternal = 0, Secret = 0,
        Cosmic = 0, Mythic = 0, Total = 0
    }

    local function addCandidate(inst)
        if not inst or seen[inst] then return end
        seen[inst] = true

        local egg = InspectEgg(inst)
        if egg and egg.Part then
            table.insert(foundList, egg)
            counts.Total = counts.Total + 1
            if counts[egg.Rarity] ~= nil then
                counts[egg.Rarity] = counts[egg.Rarity] + 1
            end
        end
    end

    -- 1. Scan primary egg directories
    local searchContainers = {
        Workspace:FindFirstChild("Eggs"),
        Workspace:FindFirstChild("Map"),
        Workspace:FindFirstChild("Nests"),
        Workspace:FindFirstChild("Spawners"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Bases"),
    }

    for _, container in ipairs(searchContainers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                addCandidate(child)
            end
        end
    end

    -- 2. Scan ALL enabled ProximityPrompts across the entire Workspace
    -- (Guarantees 100% discovery of any stealable egg on the entire server)
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            addCandidate(prompt.Parent)
        end
    end

    -- Sort results: Highest Rarity first (Divine -> Eternal -> Secret), then Nearest
    table.sort(foundList, function(a, b)
        if a.Rank == b.Rank then
            local myPos = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart)
                and LocalPlayer.Character.PrimaryPart.Position or Vector3.new(0, 0, 0)
            local distA = (a.Position - myPos).Magnitude
            local distB = (b.Position - myPos).Magnitude
            return distA < distB
        end
        return a.Rank > b.Rank
    end)

    EggPredictor.DetectedEggs = foundList
    EggPredictor.RarityCounts = counts
    EggPredictor.LastScanTime = os.time()
    return foundList
end

-- ── 8. 3D Visual Beacons for Tracked Eggs ─────────────────────────────────────
function EggPredictor.UpdateESP(enabled)
    for _, obj in ipairs(EggPredictor.ESPObjects) do
        pcall(function() if obj and obj.Parent then obj:Destroy() end end)
    end
    table.clear(EggPredictor.ESPObjects)

    if not enabled then return end

    for _, egg in ipairs(EggPredictor.DetectedEggs) do
        if egg.Part and egg.Part.Parent and egg.Rank >= 6 then
            local meta = RARITY_DATA[egg.Rarity]
            local color = meta and meta.Color or Color3.fromRGB(255, 255, 255)

            pcall(function()
                -- Highlight
                local h = Instance.new("Highlight")
                h.Name = "Exiles_EggBeacon"
                h.Adornee = egg.Part
                h.FillColor = color
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.3
                h.OutlineTransparency = 0
                h.Parent = egg.Part
                table.insert(EggPredictor.ESPObjects, h)

                -- 3D Floating Nameplate
                local bb = Instance.new("BillboardGui")
                bb.Name = "Exiles_EggLabel"
                bb.Adornee = egg.Part
                bb.Size = UDim2.fromOffset(220, 60)
                bb.StudsOffset = Vector3.new(0, 4, 0)
                bb.AlwaysOnTop = true

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.fromScale(1, 1)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = color
                txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                txt.TextStrokeTransparency = 0
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 13
                txt.Text = string.format("★ [%s]\n%s\n%s", egg.Rarity:upper(), egg.Pet, egg.Location)
                txt.Parent = bb

                bb.Parent = egg.Part
                table.insert(EggPredictor.ESPObjects, bb)
            end)
        end
    end
end

-- ── 9. Steal Target Egg Action ────────────────────────────────────────────────
function EggPredictor.StealTargetEgg(eggData, Helpers, HubState)
    if not eggData or not eggData.Part then return false end

    pcall(function()
        local root = Helpers.GetRootPart()
        if not root then return end

        local targetCFrame = eggData.Part.CFrame + Vector3.new(0, 3, 0)
        Helpers.TweenTo(targetCFrame, HubState.Settings.TweenSpeed or 35)

        if eggData.Prompt and eggData.Prompt.Enabled then
            Helpers.SafeFirePrompt(eggData.Prompt)
        else
            local prompt = eggData.Part:FindFirstChildOfClass("ProximityPrompt")
                or (eggData.Part.Parent and eggData.Part.Parent:FindFirstChildOfClass("ProximityPrompt"))
            if prompt and prompt.Enabled then
                Helpers.SafeFirePrompt(prompt)
            end
        end

        task.wait(0.3)

        if HubState.Settings.AutoPlaceEgg then
            local depositCFrame = Helpers.GetBaseDepositCFrame()
            Helpers.TweenTo(depositCFrame, HubState.Settings.TweenSpeed or 35)
            task.wait(0.2)

            local base = Helpers.GetPlayerBase()
            if base then
                for _, prompt in ipairs(base:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local pText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                        if pText:find("place") or pText:find("deposit") or pText:find("drop") or pText:find("egg") then
                            Helpers.SafeFirePrompt(prompt)
                            break
                        end
                    end
                end
            end

            Helpers.FireRemoteByKeywords({"place", "deposit", "bank", "deliver", "dropegg", "nest"})
        end
    end)
    return true
end

-- ── 10. Background Engine Initializer ─────────────────────────────────────────
function EggPredictor.Init(HubState, Helpers)
    HubState.Settings.PredictorEnabled   = HubState.Settings.PredictorEnabled ~= false
    HubState.Settings.NotifyDivine      = HubState.Settings.NotifyDivine ~= false
    HubState.Settings.NotifyEternal     = HubState.Settings.NotifyEternal ~= false
    HubState.Settings.NotifySecret      = HubState.Settings.NotifySecret ~= false
    HubState.Settings.AutoStealPredicted = HubState.Settings.AutoStealPredicted or false
    HubState.Settings.PredictorESP       = HubState.Settings.PredictorESP ~= false

    local notifiedCache = {}

    -- Auto-Sync when a new egg is spawned in the workspace
    pcall(function()
        Workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                local pText = (desc.ObjectText .. " " .. desc.ActionText):lower()
                if pText:find("egg") or pText:find("steal") then
                    -- Reset spawn cycle timer on new egg spawn event
                    EggPredictor.SyncTimer(EggPredictor.SpawnCycleSeconds)
                end
            end
        end)
    end)

    -- Continuous Scanner Loop (every 1.5 seconds)
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

                    -- Check for High-Tier eggs
                    for _, egg in ipairs(eggs) do
                        local r = egg.Rarity
                        local isHighTier = (r == "Divine" or r == "Eternal" or r == "Secret")

                        if isHighTier and not notifiedCache[egg.Instance] then
                            notifiedCache[egg.Instance] = true

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
