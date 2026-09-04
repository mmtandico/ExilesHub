--[[
    ===================================================================
    EXILES SCRIPT HUB | PLAYER MOVEMENT & SPEED MODULE
    ===================================================================
]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PlayerModule = {}

function PlayerModule.Init(HubState, Helpers)
    -- Infinite Jump
    HubState.AddConnection(UserInputService.JumpRequest:Connect(function()
        if HubState.Settings.InfJump and HubState.Running then
            local hum = Helpers.GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end))

    -- Noclip & WalkSpeed maintenance
    HubState.AddConnection(RunService.Stepped:Connect(function()
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

        local hum = Helpers.GetHumanoid()
        if hum and HubState.Settings.WalkSpeed ~= 16 and hum.WalkSpeed ~= HubState.Settings.WalkSpeed then
            hum.WalkSpeed = HubState.Settings.WalkSpeed
        end
    end))

    -- CFrame Speed Engine (Anti-Cheat Bypass)
    HubState.AddConnection(RunService.RenderStepped:Connect(function(deltaTime)
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
end

function PlayerModule.SetWalkSpeed(speed, Helpers)
    local hum = Helpers.GetHumanoid()
    if hum then hum.WalkSpeed = speed end
end

return PlayerModule
