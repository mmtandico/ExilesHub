--[[
    ===================================================================
    EXILES SCRIPT HUB | VISUALS & ESP MODULE
    ===================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local VisualsModule = {
    EggHighlights = {},
    PlayerHighlights = {},
}

local function ApplyEggHighlight(part)
    if not part:IsA("BasePart") then return end
    local pName = part.Name:lower()
    if not pName:find("egg") then return end
    if part:FindFirstChild("Exiles_EggESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "Exiles_EggESP"
    h.Adornee = part
    local isInfested = pName:find("infested") or pName:find("toxic")
    h.FillColor = isInfested and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 30, 60)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.Parent = part
    table.insert(VisualsModule.EggHighlights, h)
end

local function ApplyPlayerHighlight(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    if char:FindFirstChild("Exiles_PlayerESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "Exiles_PlayerESP"
    h.Adornee = char
    h.FillColor = Color3.fromRGB(220, 25, 45)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.Parent = char
    table.insert(VisualsModule.PlayerHighlights, h)
end

function VisualsModule.Init(HubState, Helpers)
    -- Watch for newly spawned eggs
    Workspace.DescendantAdded:Connect(function(desc)
        if HubState.Settings.ESPEggs and desc:IsA("BasePart") and desc.Name:lower():find("egg") then
            ApplyEggHighlight(desc)
        end
    end)

    -- Watch for players respawning
    local function hookPlayer(p)
        if p == LocalPlayer then return end
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if HubState.Settings.ESPPlayers then
                ApplyPlayerHighlight(p)
            end
        end)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        hookPlayer(p)
    end
    Players.PlayerAdded:Connect(hookPlayer)

    -- Periodic validation loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.ESPEggs then
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("BasePart") and desc.Name:lower():find("egg") then
                        ApplyEggHighlight(desc)
                    end
                end
            end

            if HubState.Settings.ESPPlayers then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        ApplyPlayerHighlight(p)
                    end
                end
            end

            task.wait(2.5)
        end
    end)
end

function VisualsModule.SetEggESP(enabled, HubState)
    HubState.Settings.ESPEggs = enabled
    if enabled then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name:lower():find("egg") then
                ApplyEggHighlight(desc)
            end
        end
    else
        for _, h in ipairs(VisualsModule.EggHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        VisualsModule.EggHighlights = {}
        for _, h in ipairs(HubState.EggHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        HubState.EggHighlights = {}
    end
end

function VisualsModule.SetPlayerESP(enabled, HubState)
    HubState.Settings.ESPPlayers = enabled
    if enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                ApplyPlayerHighlight(p)
            end
        end
    else
        for _, h in ipairs(VisualsModule.PlayerHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        VisualsModule.PlayerHighlights = {}
        for _, h in ipairs(HubState.Highlights) do
            if h and h.Parent then h:Destroy() end
        end
        HubState.Highlights = {}
    end
end

return VisualsModule
