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
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration)
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
    if not root then return end
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local time = math.clamp(dist / (speed or 35), 0.1, 10)
    local tween = TweenService:Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
end

function Helpers.FireRemoteByKeywords(keywords, args)
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

return Helpers
