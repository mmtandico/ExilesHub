--[[
    Exiles Hub Configuration & Game Registry
]]

local Config = {
    HubName = "EXILES SCRIPT HUB",
    Version = "2.1.0",
    DefaultTheme = "cobalt",
    TargetGames = {
        [107778070777162] = {
            Name = "Steal An Egg",
            Module = "steal_an_egg",
            Enabled = true,
        }
    }
}

function Config.GetGameInfo(placeId)
    return Config.TargetGames[placeId]
end

return Config
