--[[
    ===================================================================
    EXILES SCRIPT HUB | EGG STEALING MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")

local StealModule = {}

function StealModule.Init(HubState, Helpers)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoSteal then
                pcall(function()
                    local root = Helpers.GetRootPart()
                    if not root then return end

                    -- Anti-Trap check
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
                                    Helpers.TweenTo(targetPart.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed)
                                    Helpers.SafeFirePrompt(desc)
                                    task.wait(0.3)

                                    if HubState.Settings.AutoPlaceEgg then
                                        if not (isInfested and HubState.Settings.DontPlaceInfested) then
                                            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
                                            if spawn then
                                                Helpers.TweenTo(spawn.CFrame + Vector3.new(0, 3, 0), HubState.Settings.TweenSpeed)
                                                Helpers.FireRemoteByKeywords({"place", "deposit", "bank", "deliver"})
                                            end
                                        end
                                    end
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        end
    end)
end

return StealModule
