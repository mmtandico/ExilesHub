--[[
    ===================================================================
    EXILES SCRIPT HUB | PETS & HATCHING MODULE
    ===================================================================
]]

local PetModule = {}

function PetModule.Init(HubState, Helpers)
    -- Auto Hatch loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoHatch then
                Helpers.FireRemoteByKeywords({"hatch", "buyegg", "open"}, { HubState.Settings.EggScope, 1 })
            end
            task.wait(0.4)
        end
    end)

    -- Auto Equip & Pet Maintenance loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoEquipBest then
                Helpers.FireRemoteByKeywords({"equipbest", "autoequip"})
            end
            if HubState.Settings.AutoSellPet then
                Helpers.FireRemoteByKeywords({"sellpet", "sellpets"})
            end
            task.wait(2.5)
        end
    end)
end

return PetModule
