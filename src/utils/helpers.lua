--[[
    ===================================================================
    EXILES SCRIPT HUB | UTILITY & EXECUTOR HELPERS
    ===================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Helpers = {}

function Helpers.GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Helpers.GetRootPart()
    local char = Helpers.GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
end

function Helpers.GetHumanoid()
    local char = Helpers.GetCharacter()
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
end

function Helpers.SafeFirePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.MaxActivationDistance = 99999
        prompt.RequiresLineOfSight = false
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

function Helpers.SafeFireTouch(part)
    if not part then return end
    local root = Helpers.GetRootPart()
    if not root then return end
    pcall(function()
        if firetouchinterest then
            firetouchinterest(root, part, 0)
            task.wait(0.05)
            firetouchinterest(root, part, 1)
        end
    end)
end

function Helpers.TweenTo(targetCFrame, speed)
    local root = Helpers.GetRootPart()
    local char = Helpers.GetCharacter()
    if not root or not char then return end

    -- Disable part collisions during tweening to prevent getting stuck in walls/traps
    local partsToRestore = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            p.CanCollide = false
            table.insert(partsToRestore, p)
        end
    end

    -- Zero velocities to prevent physics flings
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    local dist = (root.Position - targetCFrame.Position).Magnitude
    local time = math.clamp(dist / (speed or 35), 0.05, 12)
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()

    -- Zero velocity on arrival
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    -- Restore collisions safely
    task.defer(function()
        for _, p in ipairs(partsToRestore) do
            if p and p.Parent then
                p.CanCollide = true
            end
        end
    end)
end

-- Cached base for high-performance retrieval
Helpers.CachedBase = nil

function Helpers.GetPlayerBase()
    -- Return cached base if still valid in Workspace
    if Helpers.CachedBase and Helpers.CachedBase.Parent then
        return Helpers.CachedBase
    end

    local localName = LocalPlayer.Name:lower()
    local localUserId = tostring(LocalPlayer.UserId)
    local localDisplayName = LocalPlayer.DisplayName:lower()

    -- 1. Check dedicated base / plot / nest folders
    local searchContainers = {
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Nests"),
        Workspace:FindFirstChild("Tycoons"),
        Workspace:FindFirstChild("PlayerBases"),
        Workspace:FindFirstChild("Islands"),
        Workspace:FindFirstChild("Spawns"),
        Workspace,
    }

    for _, container in ipairs(searchContainers) do
        if container then
            for _, base in ipairs(container:GetChildren()) do
                local bName = base.Name:lower()
                -- Match by name
                if bName:find(localName) or bName:find(localUserId) or bName:find(localDisplayName) then
                    Helpers.CachedBase = base
                    return base
                end

                -- Match by Owner / Player attributes or Value objects
                local ownerVal = base:FindFirstChild("Owner") or base:FindFirstChild("Player") or base:FindFirstChild("UserId")
                if ownerVal then
                    local valStr = tostring(ownerVal.Value):lower()
                    if valStr:find(localName) or valStr:find(localUserId) then
                        Helpers.CachedBase = base
                        return base
                    end
                end

                local ownerAttr = base:GetAttribute("Owner") or base:GetAttribute("Player") or base:GetAttribute("UserId")
                if ownerAttr then
                    local attrStr = tostring(ownerAttr):lower()
                    if attrStr:find(localName) or attrStr:find(localUserId) then
                        Helpers.CachedBase = base
                        return base
                    end
                end

                -- Match by TextLabel signs inside the base
                for _, lbl in ipairs(base:GetDescendants()) do
                    if lbl:IsA("TextLabel") and lbl.Text ~= "" then
                        local txt = lbl.Text:lower()
                        if txt:find(localName) or txt:find(localDisplayName) then
                            Helpers.CachedBase = base
                            return base
                        end
                    end
                end
            end
        end
    end

    -- 2. Check for SpawnLocations assigned to player's team or name
    for _, spawn in ipairs(Workspace:GetDescendants()) do
        if spawn:IsA("SpawnLocation") then
            if spawn.Team and LocalPlayer.Team and spawn.Team == LocalPlayer.Team then
                Helpers.CachedBase = spawn
                return spawn
            end
            local sName = spawn.Name:lower()
            if sName:find(localName) or sName:find(localUserId) then
                Helpers.CachedBase = spawn
                return spawn
            end
        end
    end

    -- 3. Fallback: Return first spawn location or player's original position
    local defaultSpawn = Workspace:FindFirstChildOfClass("SpawnLocation")
    if defaultSpawn then
        Helpers.CachedBase = defaultSpawn
        return defaultSpawn
    end

    return nil
end

function Helpers.GetBaseDepositCFrame()
    local base = Helpers.GetPlayerBase()
    if not base then
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        return spawn and (spawn.CFrame + Vector3.new(0, 3, 0)) or CFrame.new(0, 5, 0)
    end

    -- Look for Nest, EggDeposit, Stand, Pad, or Main part within the base
    for _, part in ipairs(base:GetDescendants()) do
        if part:IsA("BasePart") then
            local pName = part.Name:lower()
            if pName:find("nest") or pName:find("deposit") or pName:find("eggstand") or pName:find("holder") or pName:find("pad") or pName:find("spawn") then
                return part.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end

    -- If base is a Model with PrimaryPart
    if base:IsA("Model") and base.PrimaryPart then
        return base.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
    elseif base:IsA("BasePart") then
        return base.CFrame + Vector3.new(0, 3, 0)
    end

    -- Fallback to base position
    local firstPart = base:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then
        return firstPart.CFrame + Vector3.new(0, 3, 0)
    end

    return CFrame.new(0, 5, 0)
end

function Helpers.FireRemoteByKeywords(keywords, args)
    local searchRoots = { ReplicatedStorage, Workspace }
    for _, root in ipairs(searchRoots) do
        for _, rem in ipairs(root:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local rName = rem.Name:lower()
                for _, kw in ipairs(keywords) do
                    if rName:find(kw) then
                        local ok = pcall(function()
                            if rem:IsA("RemoteFunction") then
                                if args then rem:InvokeServer(unpack(args)) else rem:InvokeServer() end
                            else
                                if args then rem:FireServer(unpack(args)) else rem:FireServer() end
                            end
                        end)
                        if ok then return true end
                    end
                end
            end
        end
    end
    return false
end

return Helpers
