--[[
    ===================================================================
    EXILES SCRIPT HUB | VISUALS & ESP MODULE
    ===================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local VisualsModule = {}

function VisualsModule.SetEggESP(enabled, HubState)
    HubState.Settings.ESPEggs = enabled
    if enabled then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name:lower():find("egg") then
                if not desc:FindFirstChild("Exiles_EggESP") then
                    local h = Instance.new("Highlight")
                    h.Name = "Exiles_EggESP"
                    h.Adornee = desc
                    local isInfested = desc.Name:lower():find("infested")
                    h.FillColor = isInfested and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 30, 60)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.Parent = desc
                    table.insert(HubState.EggHighlights, h)
                end
            end
        end
    else
        for _, h in ipairs(HubState.EggHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        HubState.EggHighlights = {}
    end
end

function VisualsModule.SetPlayerESP(enabled, HubState)
    HubState.Settings.ESPPlayers = enabled
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("Exiles_PlayerESP")
            if not h and enabled then
                h = Instance.new("Highlight")
                h.Name = "Exiles_PlayerESP"
                h.Adornee = p.Character
                h.FillColor = Color3.fromRGB(220, 25, 45)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = p.Character
                table.insert(HubState.Highlights, h)
            elseif h then
                h.Enabled = enabled
            end
        end
    end
end

return VisualsModule
