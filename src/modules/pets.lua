--[[
    ===================================================================
    EXILES SCRIPT HUB | PETS & HATCHING MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")

local PetModule = {
    CachedEggStands = {},
}

local function FindEggStand(eggName)
    local low = eggName:lower()
    local searchContainers = {
        Workspace:FindFirstChild("Eggs"),
        Workspace:FindFirstChild("EggStands"),
        Workspace:FindFirstChild("Capsules"),
        Workspace,
    }

    for _, container in ipairs(searchContainers) do
        if container then
            for _, eggObj in ipairs(container:GetChildren()) do
                local oName = eggObj.Name:lower()
                if oName:find(low) or low:find(oName) then
                    return eggObj
                end
            end
        end
    end
    return nil
end

function PetModule.Init(HubState, Helpers)
    -- 1. Auto Hatch loop
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoHatch then
                pcall(function()
                    local eggScope = HubState.Settings.EggScope or "Basic Egg"

                    -- Fire remote
                    local remoteHit = Helpers.FireRemoteByKeywords(
                        {"hatch", "buyegg", "openegg", "hatchserver", "purchaseegg"},
                        { eggScope, 1 }
                    )

                    -- If physical egg stand in world, fire prompt/touch as fallback
                    local stand = PetModule.CachedEggStands[eggScope]
                    if not stand or not stand.Parent then
                        stand = FindEggStand(eggScope)
                        PetModule.CachedEggStands[eggScope] = stand
                    end

                    if stand then
                        for _, prompt in ipairs(stand:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                Helpers.SafeFirePrompt(prompt)
                                break
                            end
                        end
                    end
                end)
            end
            task.wait(0.4)
        end
    end)

    -- 2. Auto Equip & Pet Maintenance loop
    task.spawn(function()
        while HubState.Running do
            -- Auto Equip Best Pets
            if HubState.Settings.AutoEquipBest then
                pcall(function()
                    Helpers.FireRemoteByKeywords({"equipbest", "autoequip", "bestpets", "equipbestpets"})
                end)
            end

            -- Auto Favorite Pets
            if HubState.Settings.AutoFavoritePet then
                pcall(function()
                    local minRarity = HubState.Settings.FavoriteMinRarity or "Legendary"
                    local favMutation = HubState.Settings.FavoriteMutation
                    Helpers.FireRemoteByKeywords(
                        {"favorite", "lockpet", "favoritepet", "autofavorite"},
                        { minRarity, favMutation }
                    )
                end)
            end

            -- Auto Sell Pets
            if HubState.Settings.AutoSellPet then
                pcall(function()
                    local rule = HubState.Settings.SellPetRule or "Rarity Below"
                    local maxRarity = HubState.Settings.PetMaxRarity or "Rare"
                    local threshold = HubState.Settings.PetIncomeThreshold or 100
                    local blacklist = HubState.Settings.BlacklistSellPets or "Favorites Only"

                    Helpers.FireRemoteByKeywords(
                        {"sellpet", "sellpets", "autosellpets", "sellbypetrarity"},
                        { rule, maxRarity, threshold, blacklist }
                    )
                end)
            end

            task.wait(2.5)
        end
    end)
end

return PetModule
