--[[
    ===================================================================
    EXILES SCRIPT HUB | HUNGRY MONSTER & CHEST MODULE
    ===================================================================
]]

local MonsterModule = {}

function MonsterModule.Init(HubState, Helpers)
    task.spawn(function()
        while HubState.Running do
            if HubState.Settings.AutoFeedMonster then
                Helpers.FireRemoteByKeywords({"feedmonster", "feed"}, { HubState.Settings.FeedMaxRarity })
            end
            if HubState.Settings.AutoClaimChest then
                Helpers.FireRemoteByKeywords({"monsterchest", "claimmonster"})
            end
            task.wait(2.5)
        end
    end)
end

return MonsterModule
