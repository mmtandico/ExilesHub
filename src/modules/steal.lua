--[[
    ===================================================================
    EXILES SCRIPT HUB | EGG STEALING MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")
local Players   = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local StealModule = {}

-- Rarity scoring for prioritization
local RARITY_SCORES = {
    ["divine"]    = 1000,
    ["eternal"]   = 900,
    ["secret"]    = 800,
    ["cosmic"]    = 700,
    ["mythic"]    = 600,
    ["legendary"] = 500,
    ["epic"]      = 400,
    ["rare"]      = 300,
    ["uncommon"]  = 200,
    ["common"]    = 100,
}

local function GetEggScore(name)
    local low = name:lower()
    for rarity, score in pairs(RARITY_SCORES) do
        if low:find(rarity) then
            return score
        end
    end
    return 50 -- default score
end

local function IsCarryingEgg(char)
    if not char then return false end
    -- Check character tools / welded models
    for _, child in ipairs(char:GetChildren()) do
        local cName = child.Name:lower()
        if (child:IsA("Tool") or child:IsA("Model") or child:IsA("BasePart")) and (cName:find("egg") or cName:find("carry") or cName:find("held")) then
            return true
        end
    end
    -- Check attributes
    if char:GetAttribute("HoldingEgg") or char:GetAttribute("CarryingEgg") or char:GetAttribute("HasEgg") then
        return true
    end
    if LocalPlayer:GetAttribute("HoldingEgg") or LocalPlayer:GetAttribute("CarryingEgg") or LocalPlayer:GetAttribute("HasEgg") then
        return true
    end
    return false
end

local function DepositEgg(Helpers, HubState, isInfested)
    if isInfested and HubState.Settings.DontPlaceInfested then
        return
    end

    local depositCFrame = Helpers.GetBaseDepositCFrame()
    Helpers.TweenTo(depositCFrame, HubState.Settings.TweenSpeed)
    task.wait(0.2)

    -- Check for deposit ProximityPrompt in own base
    local base = Helpers.GetPlayerBase()
    if base then
        for _, prompt in ipairs(base:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local pText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                if pText:find("place") or pText:find("deposit") or pText:find("drop") or pText:find("put") or pText:find("egg") then
                    Helpers.SafeFirePrompt(prompt)
                    break
                end
            end
        end
    end

    Helpers.FireRemoteByKeywords({"place", "deposit", "bank", "deliver", "dropegg", "nest"})
    task.wait(0.3)
end

function StealModule.Init(HubState, Helpers)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoSteal then
                pcall(function()
                    local char = Helpers.GetCharacter()
                    local root = Helpers.GetRootPart()
                    if not root or not char then return end

                    -- If already holding an egg, deposit it first!
                    if IsCarryingEgg(char) then
                        if HubState.Settings.AutoPlaceEgg then
                            DepositEgg(Helpers, HubState, false)
                        end
                        return
                    end

                    -- Anti-Trap check (lightweight disable around player)
                    if HubState.Settings.AntiTrap then
                        for _, trap in ipairs(Workspace:GetChildren()) do
                            if trap:IsA("BasePart") and trap.Name:lower():find("trap") then
                                trap.CanCollide = false
                                trap.CanTouch = false
                            end
                        end
                        local trapsFolder = Workspace:FindFirstChild("Traps")
                        if trapsFolder then
                            for _, trap in ipairs(trapsFolder:GetDescendants()) do
                                if trap:IsA("BasePart") then
                                    trap.CanCollide = false
                                    trap.CanTouch = false
                                end
                            end
                        end
                    end

                    local myBase = Helpers.GetPlayerBase()
                    local candidates = {}

                    -- Scan for stealable eggs via ProximityPrompts
                    for _, prompt in ipairs(Workspace:GetDescendants()) do
                        if not HubState.Settings.AutoSteal then break end
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local promptText = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Parent.Name):lower()
                            local isInfested = promptText:find("infested") or promptText:find("toxic")

                            if isInfested and not HubState.Settings.StealInfested then
                                continue
                            end

                            if promptText:find("egg") or promptText:find("steal") or promptText:find("grab") or promptText:find("take") then
                                local targetPart = prompt.Parent
                                if targetPart and targetPart:IsA("BasePart") then
                                    -- Ignore eggs inside our own base
                                    if myBase and targetPart:IsDescendantOf(myBase) then
                                        continue
                                    end

                                    -- Apply Target Egg Tier filter
                                    local tierFilter = HubState.Settings.TargetSpecificEggs or "All Eggs"
                                    local eggScore = GetEggScore(promptText)

                                    if tierFilter == "Only Infested" and not isInfested then
                                        continue
                                    elseif tierFilter == "Legendary & Up" and eggScore < 500 then
                                        continue
                                    elseif tierFilter == "Epic & Up" and eggScore < 400 then
                                        continue
                                    end

                                    local dist = (root.Position - targetPart.Position).Magnitude
                                    table.insert(candidates, {
                                        Prompt = prompt,
                                        Part = targetPart,
                                        Name = promptText,
                                        IsInfested = isInfested,
                                        Score = eggScore,
                                        Distance = dist,
                                    })
                                end
                            end
                        end
                    end

                    if #candidates == 0 then return end

                    -- Sort candidates based on StealPriority setting
                    local priority = HubState.Settings.StealPriority or "Highest Rarity"
                    if priority == "Nearest Egg" then
                        table.sort(candidates, function(a, b) return a.Distance < b.Distance end)
                    elseif priority == "Infested First" then
                        table.sort(candidates, function(a, b)
                            if a.IsInfested and not b.IsInfested then return true end
                            if not a.IsInfested and b.IsInfested then return false end
                            return a.Score > b.Score
                        end)
                    else -- "Highest Rarity"
                        table.sort(candidates, function(a, b) return a.Score > b.Score end)
                    end

                    -- Steal the top candidate
                    local target = candidates[1]
                    if target and target.Part and target.Prompt and target.Prompt.Parent then
                        -- Tween to the egg
                        Helpers.TweenTo(target.Part.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed)
                        
                        -- Fire the prompt with timeout protection
                        local timeout = HubState.Settings.StealTimeout or 5
                        local startTime = tick()
                        Helpers.SafeFirePrompt(target.Prompt)

                        while tick() - startTime < timeout and HubState.Settings.AutoSteal do
                            if IsCarryingEgg(Helpers.GetCharacter()) then
                                break
                            end
                            task.wait(0.2)
                        end

                        task.wait(0.2)

                        -- Deposit if holding egg and AutoPlaceEgg is on
                        if HubState.Settings.AutoPlaceEgg and (IsCarryingEgg(Helpers.GetCharacter()) or target.Prompt.Parent == nil) then
                            DepositEgg(Helpers, HubState, target.IsInfested)
                        end
                    end
                end)
            end
            task.wait(0.8)
        end
    end)
end

return StealModule
