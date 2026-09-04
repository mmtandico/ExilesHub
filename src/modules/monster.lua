--[[
    ===================================================================
    EXILES SCRIPT HUB | HUNGRY MONSTER & CHEST MODULE
    ===================================================================
]]

local Workspace = game:GetService("Workspace")

local MonsterModule = {
    CachedMonster = nil,
    CachedChest = nil,
}

local function FindMonsterObject(keywords)
    for _, desc in ipairs(Workspace:GetChildren()) do
        local dName = desc.Name:lower()
        for _, kw in ipairs(keywords) do
            if dName:find(kw) then
                return desc
            end
        end
    end
    -- Check common subfolders
    local monsterFolder = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("World")
    if monsterFolder then
        for _, desc in ipairs(monsterFolder:GetDescendants()) do
            local dName = desc.Name:lower()
            for _, kw in ipairs(keywords) do
                if dName:find(kw) then
                    return desc
                end
            end
        end
    end
    return nil
end

function MonsterModule.Init(HubState, Helpers)
    task.spawn(function()
        while HubState.Running do
            -- 1. Auto Feed Monster
            if HubState.Settings.AutoFeedMonster then
                pcall(function()
                    -- Fire remotes with rarity filter
                    local maxRarity = HubState.Settings.FeedMaxRarity or "Rare"
                    local remoteHit = Helpers.FireRemoteByKeywords({"feedmonster", "feed", "hungrymonster"}, { maxRarity })

                    -- If physical monster exists in world, check for prompt
                    if not MonsterModule.CachedMonster or not MonsterModule.CachedMonster.Parent then
                        MonsterModule.CachedMonster = FindMonsterObject({"hungry", "monster", "feed"})
                    end

                    local monster = MonsterModule.CachedMonster
                    if monster then
                        for _, prompt in ipairs(monster:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                local pText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                                if pText:find("feed") or pText:find("give") or pText:find("monster") then
                                    Helpers.SafeFirePrompt(prompt)
                                end
                            end
                        end
                    end
                end)
            end

            -- 2. Auto Claim Monster Chest
            if HubState.Settings.AutoClaimChest then
                pcall(function()
                    Helpers.FireRemoteByKeywords({"monsterchest", "claimmonster", "openchest", "chest"})

                    if not MonsterModule.CachedChest or not MonsterModule.CachedChest.Parent then
                        MonsterModule.CachedChest = FindMonsterObject({"monsterchest", "chest", "rewardchest"})
                    end

                    local chest = MonsterModule.CachedChest
                    if chest then
                        for _, prompt in ipairs(chest:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                local pText = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
                                if pText:find("claim") or pText:find("open") or pText:find("chest") then
                                    Helpers.SafeFirePrompt(prompt)
                                end
                            end
                        end
                        -- Check for touch part
                        local touchPart = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart", true)
                        if touchPart then
                            Helpers.SafeFireTouch(touchPart)
                        end
                    end
                end)
            end

            task.wait(2.5)
        end
    end)
end

return MonsterModule
