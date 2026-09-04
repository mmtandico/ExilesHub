--[[
    ===================================================================
    EXILES SCRIPT HUB | TREADMILL & BASE UPGRADES MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")

local TreadmillModule = {
    CachedTreadmill = nil,
}

local function FindBestTreadmill(Helpers)
    -- 1. Check if user's own base has a treadmill
    local myBase = Helpers.GetPlayerBase()
    if myBase then
        for _, part in ipairs(myBase:GetDescendants()) do
            if part:IsA("BasePart") then
                local pName = part.Name:lower()
                if pName:find("treadmill") or pName:find("train") or pName:find("speedpad") then
                    return part
                end
            end
        end
    end

    -- 2. Search common treadmill folders
    local searchContainers = {
        Workspace:FindFirstChild("Treadmills"),
        Workspace:FindFirstChild("Training"),
        Workspace:FindFirstChild("Gym"),
        Workspace,
    }

    local root = Helpers.GetRootPart()
    local rootPos = root and root.Position or Vector3.zero
    local bestPart = nil
    local bestDist = math.huge

    for _, container in ipairs(searchContainers) do
        if container then
            for _, desc in ipairs(container:GetChildren()) do
                if desc:IsA("BasePart") then
                    local dName = desc.Name:lower()
                    if dName:find("treadmill") or dName:find("train") then
                        local dist = (desc.Position - rootPos).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestPart = desc
                        end
                    end
                elseif desc:IsA("Model") then
                    local dName = desc.Name:lower()
                    if dName:find("treadmill") or dName:find("train") then
                        local p = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local dist = (p.Position - rootPos).Magnitude
                            if dist < bestDist then
                                bestDist = dist
                                bestPart = p
                            end
                        end
                    end
                end
            end
        end
        if bestPart then return bestPart end
    end

    return nil
end

function TreadmillModule.Init(HubState, Helpers)
    -- Auto Treadmill loop (optimized with caching)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoTreadmill then
                pcall(function()
                    local root = Helpers.GetRootPart()
                    if not root then return end

                    if not TreadmillModule.CachedTreadmill or not TreadmillModule.CachedTreadmill.Parent then
                        TreadmillModule.CachedTreadmill = FindBestTreadmill(Helpers)
                    end

                    local treadmill = TreadmillModule.CachedTreadmill
                    if treadmill and treadmill.Parent then
                        root.CFrame = treadmill.CFrame + Vector3.new(0, 3.2, 0)
                        root.AssemblyLinearVelocity = Vector3.zero
                        Helpers.SafeFireTouch(treadmill)

                        -- Check for training prompt on treadmill
                        for _, prompt in ipairs(treadmill:GetChildren()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                Helpers.SafeFirePrompt(prompt)
                            end
                        end
                    end

                    Helpers.FireRemoteByKeywords({"train", "speed", "treadmill", "run", "gain"})
                end)
                task.wait(0.25)
            else
                TreadmillModule.CachedTreadmill = nil
                task.wait(1)
            end
        end
    end)

    -- Auto Upgrades & Base Maintenance loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoUpgradeTreadmill then
                Helpers.FireRemoteByKeywords({"upgradetreadmill", "buytreadmill", "treadmillupgrade"})
                -- Also check base upgrade pads
                local myBase = Helpers.GetPlayerBase()
                if myBase then
                    for _, pad in ipairs(myBase:GetDescendants()) do
                        if pad:IsA("BasePart") and pad.Name:lower():find("treadmill") and pad.Name:lower():find("upgrade") then
                            Helpers.SafeFireTouch(pad)
                        end
                    end
                end
            end

            if HubState.Settings.AutoUpgradeBase then
                Helpers.FireRemoteByKeywords({"upgradebase", "buybase", "baseupgrade", "upgradenest", "buynest"})
                local myBase = Helpers.GetPlayerBase()
                if myBase then
                    for _, pad in ipairs(myBase:GetDescendants()) do
                        if pad:IsA("BasePart") and (pad.Name:lower():find("baseupgrade") or pad.Name:lower():find("buypad")) then
                            Helpers.SafeFireTouch(pad)
                        end
                    end
                end
            end

            if HubState.Settings.AutoBuyTrail then
                Helpers.FireRemoteByKeywords({"buytrail", "equiptrail", "trail"})
            end

            if HubState.Settings.AutoClaim then
                Helpers.FireRemoteByKeywords({"claim", "daily", "reward", "freegift", "claimdaily", "gift"})
            end

            task.wait(2.5)
        end
    end)
end

function TreadmillModule.SetHideTreadmill(hidden)
    pcall(function()
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name:lower():find("treadmill") then
                desc.Transparency = hidden and 1 or 0
            end
        end
    end)
end

function TreadmillModule.Exit(Helpers)
    local root = Helpers.GetRootPart()
    if root then
        root.CFrame = root.CFrame + Vector3.new(0, 10, 15)
        root.AssemblyLinearVelocity = Vector3.zero
    end
end

return TreadmillModule
