--[[
    ===================================================================
    EXILES SCRIPT HUB | TREADMILL & BASE UPGRADES MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")

local TreadmillModule = {}

function TreadmillModule.Init(HubState, Helpers)
    -- Auto Treadmill loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoTreadmill then
                pcall(function()
                    local root = Helpers.GetRootPart()
                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if not HubState.Settings.AutoTreadmill then break end
                        if part:IsA("BasePart") and (part.Name:lower():find("treadmill") or part.Name:lower():find("train")) then
                            root.CFrame = part.CFrame + Vector3.new(0, 3.5, 0)
                            root.AssemblyLinearVelocity = Vector3.zero
                            Helpers.SafeFireTouch(part)
                            break
                        end
                    end
                    Helpers.FireRemoteByKeywords({"train", "speed", "treadmill"})
                end)
            end
            task.wait(0.15)
        end
    end)

    -- Auto Upgrades loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoUpgradeTreadmill then
                Helpers.FireRemoteByKeywords({"upgradetreadmill", "buytreadmill"})
            end
            if HubState.Settings.AutoUpgradeBase then
                Helpers.FireRemoteByKeywords({"upgradebase", "buybase", "baseupgrade"})
            end
            if HubState.Settings.AutoBuyTrail then
                Helpers.FireRemoteByKeywords({"buytrail", "equiptrail"})
            end
            if HubState.Settings.AutoClaim then
                Helpers.FireRemoteByKeywords({"claim", "daily", "reward", "freegift"})
            end
            task.wait(3)
        end
    end)
end

function TreadmillModule.SetHideTreadmill(hidden)
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name:lower():find("treadmill") then
            desc.Transparency = hidden and 1 or 0
        end
    end
end

function TreadmillModule.Exit(Helpers)
    local root = Helpers.GetRootPart()
    if root then
        root.CFrame = root.CFrame + Vector3.new(0, 8, 10)
    end
end

return TreadmillModule
