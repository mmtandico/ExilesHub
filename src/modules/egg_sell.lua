--[[
    ===================================================================
    EXILES SCRIPT HUB | EGG SELLING MODULE
    ===================================================================
]]

local EggSellModule = {}

function EggSellModule.Init(HubState, Helpers)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoSellEgg then
                Helpers.FireRemoteByKeywords({"sellegg", "selleggs"})
            end
            task.wait(2)
        end
    end)
end

return EggSellModule
