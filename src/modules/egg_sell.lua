--[[
    ===================================================================
    EXILES SCRIPT HUB | EGG SELLING MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")

local EggSellModule = {
    CachedSellArea = nil,
}

local function FindSellArea()
    local searchContainers = {
        Workspace:FindFirstChild("Shops"),
        Workspace:FindFirstChild("Merchants"),
        Workspace:FindFirstChild("SellZones"),
        Workspace,
    }

    local keywords = {"sell", "merchant", "eggshop", "eggmerchant"}

    for _, container in ipairs(searchContainers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                local cName = child.Name:lower()
                for _, kw in ipairs(keywords) do
                    if cName:find(kw) then
                        return child
                    end
                end
            end
        end
    end
    return nil
end

function EggSellModule.Init(HubState, Helpers)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoSellEgg then
                pcall(function()
                    local maxRarity = HubState.Settings.EggMaxRarity or "Common"

                    -- Fire remotes with rarity filter
                    Helpers.FireRemoteByKeywords(
                        {"sellegg", "selleggs", "sellalleggs", "sellbyrarity", "merchantsell"},
                        { maxRarity }
                    )

                    -- Check for physical merchant/sell area in world
                    if not EggSellModule.CachedSellArea or not EggSellModule.CachedSellArea.Parent then
                        EggSellModule.CachedSellArea = FindSellArea()
                    end

                    local sellArea = EggSellModule.CachedSellArea
                    if sellArea then
                        -- Check for prompt
                        for _, prompt in ipairs(sellArea:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                local pText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                                if pText:find("sell") then
                                    Helpers.SafeFirePrompt(prompt)
                                    break
                                end
                            end
                        end
                        -- Check for touch pad
                        local pad = sellArea:IsA("BasePart") and sellArea or sellArea:FindFirstChildWhichIsA("BasePart", true)
                        if pad and pad.Name:lower():find("sell") then
                            Helpers.SafeFireTouch(pad)
                        end
                    end
                end)
            end
            task.wait(2)
        end
    end)
end

return EggSellModule
