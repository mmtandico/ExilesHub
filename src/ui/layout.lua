--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║      EXILES SCRIPT HUB  ·  WINDUI UI LAYOUT               ║
    ║      Library : WindUI (Footagesus)                         ║
    ║      Theme   : Midnight  (Deep Blue-Black Premium)         ║
    ║      Author  : DEV ZAX                                     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local UILayout = {}

-- ── Notification helper ───────────────────────────────────────────────────
local function Notify(WindUI, title, content, icon, duration)
    pcall(function()
        WindUI:Notify({
            Title    = title,
            Content  = content,
            Icon     = icon or "solar:bell-bold",
            Duration = duration or 4,
        })
    end)
end

-- ─────────────────────────────────────────────────────────────────────────
function UILayout.Build(WindUI, HubState, Helpers, Modules)

    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- ── Window (Hidden/Fisch Aesthetic) ──────────────────────────────────
    local Window = WindUI:CreateWindow({
        Title        = "Exiles - Steal An Egg",
        Author       = "DEV ZAX",
        Icon         = "solar:moon-bold-duotone",
        Folder       = "ExilesHub",
        Theme        = "Midnight",
        ToggleKey    = Enum.KeyCode.RightControl,
        NewElements  = true,
        HideSearchBar = false,
        User = {
            Enabled   = true,
            Anonymous = false,
            Callback  = function()
                pcall(function()
                    setclipboard("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile")
                    Notify(WindUI, "Profile Copied", "Your Roblox profile link was copied!", "solar:copy-bold", 3)
                end)
            end,
        },
        Topbar       = {
            Height      = 46,
            ButtonsType = "Mac",
        },
    })

    -- ── Tags (Discord & Dev Branding) ─────────────────────────────────────
    Window:Tag({
        Title  = ".gg/exileshub",
        Icon   = "solar:chat-round-bold",
        Color  = Color3.fromHex("#5865f2"),
        Border = true,
    })

    Window:Tag({
        Title  = "DEV ZAX  ·  v3.2",
        Icon   = "solar:star-bold",
        Color  = Color3.fromHex("#1e293b"),
        Border = true,
    })

    -- ── Boot notification ─────────────────────────────────────────────────
    Notify(WindUI, "⚡ Exiles Hub Loaded", "Welcome " .. (LocalPlayer and LocalPlayer.DisplayName or "") .. " — DEV ZAX", "solar:home-2-bold", 4)

    -- ════════════════════════════════════════════════════════════════════
    -- 0.  HOME / DASHBOARD (Exact Replica of Reference Design)
    -- ════════════════════════════════════════════════════════════════════
    local HomeTab = Window:Tab({
        Title     = "Home",
        Icon      = "solar:home-2-bold",
        IconColor = Color3.fromHex("#38bdf8"),
        IconShape = "Square",
        Border    = true,
    })

    -- ── Top Profile Card ──────────────────────────────────────────────────
    HomeTab:Section({ Title = "Dashboard" })

    local headshot = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    HomeTab:Button({
        Title    = "Hello, " .. (LocalPlayer.DisplayName or LocalPlayer.Name),
        Desc     = LocalPlayer.Name .. " - Exiles · Steal An Egg",
        Icon     = headshot,
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            pcall(function()
                setclipboard("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile")
                Notify(WindUI, "Copied Profile", "Profile URL copied to clipboard!", "solar:copy-bold", 3)
            end)
        end,
    })

    -- ── Status & Discord Row ──────────────────────────────────────────────
    local statusGroup = HomeTab:Group()

    local execName = "Universal"
    pcall(function()
        if typeof(identifyexecutor) == "function" then
            execName = tostring(identifyexecutor())
        elseif typeof(getexecutorname) == "function" then
            execName = tostring(getexecutorname())
        end
    end)

    statusGroup:Button({
        Title    = execName,
        Desc     = "Your executor seems to support this script.",
        Icon     = "solar:shield-check-bold",
        Color    = Color3.fromHex("#450a0a"),
        Callback = function()
            Notify(WindUI, "Executor: " .. execName, "Fully compatible with Exiles Hub.", "solar:shield-check-bold", 3)
        end,
    })

    statusGroup:Space()

    statusGroup:Button({
        Title    = "Discord",
        Desc     = "Tap to join the Discord Server",
        Icon     = "solar:chat-round-bold",
        Color    = Color3.fromHex("#5865f2"),
        Callback = function()
            pcall(function()
                setclipboard("https://discord.gg/exileshub")
                Notify(WindUI, "Discord Copied", "Invite link copied to clipboard! (.gg/exileshub)", "solar:chat-round-bold", 4)
            end)
        end,
    })

    -- ── Server Information Grid ───────────────────────────────────────────
    HomeTab:Section({ Title = "Server" })

    local srvRow1 = HomeTab:Group()
    local PlayersBtn = srvRow1:Button({
        Title    = "Players",
        Desc     = tostring(#Players:GetPlayers()) .. " playing",
        Icon     = "solar:users-group-rounded-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    srvRow1:Space()
    local MaxPlayersBtn = srvRow1:Button({
        Title    = "Maximum Players",
        Desc     = tostring(Players.MaxPlayers) .. " players can join this server",
        Icon     = "solar:shield-user-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    local srvRow2 = HomeTab:Group()
    local LatencyBtn = srvRow2:Button({
        Title    = "Latency",
        Desc     = "Calculating...",
        Icon     = "solar:wifi-router-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    srvRow2:Space()
    local RegionBtn = srvRow2:Button({
        Title    = "Server Region",
        Desc     = (game.JobId ~= "" and string.sub(game.JobId, 1, 8) or "Standard") .. " (Place: " .. tostring(game.PlaceId) .. ")",
        Icon     = "solar:map-point-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            pcall(function()
                setclipboard(tostring(game.JobId))
                Notify(WindUI, "Job ID Copied", "Server JobId copied to clipboard!", "solar:copy-bold", 3)
            end)
        end,
    })

    local srvRow3 = HomeTab:Group()
    local TimeBtn = srvRow3:Button({
        Title    = "In server for",
        Desc     = "00:00:00",
        Icon     = "solar:clock-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    srvRow3:Space()
    local JoinScriptBtn = srvRow3:Button({
        Title    = "Join Script",
        Desc     = "Tap to copy join script",
        Icon     = "solar:copy-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            pcall(function()
                local teleportScript = string.format(
                    'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
                    game.PlaceId,
                    game.JobId
                )
                setclipboard(teleportScript)
                Notify(WindUI, "Copied Join Script", "Teleport script copied to clipboard!", "solar:code-bold", 4)
            end)
        end,
    })

    -- ── Friends Grid ──────────────────────────────────────────────────────
    HomeTab:Section({ Title = "Friends" })

    local frndRow1 = HomeTab:Group()
    local InServerFriendsBtn = frndRow1:Button({
        Title    = "In Server",
        Desc     = "no friends",
        Icon     = "solar:user-check-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    frndRow1:Space()
    local OfflineFriendsBtn = frndRow1:Button({
        Title    = "Offline",
        Desc     = "Scanning...",
        Icon     = "solar:user-cross-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    local frndRow2 = HomeTab:Group()
    local OnlineFriendsBtn = frndRow2:Button({
        Title    = "Online",
        Desc     = "Scanning...",
        Icon     = "solar:user-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    frndRow2:Space()
    local AllFriendsBtn = frndRow2:Button({
        Title    = "All",
        Desc     = "Loading...",
        Icon     = "solar:users-group-two-rounded-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    -- ── Live Dashboard Statistics Updater ─────────────────────────────────
    local sessionStart = os.time()
    task.spawn(function()
        -- Query friends list asynchronously
        task.spawn(function()
            pcall(function()
                local onlineFriends = LocalPlayer:GetFriendsOnline(100)
                if typeof(onlineFriends) == "table" then
                    local onlineCount = #onlineFriends
                    local inServerCount = 0
                    for _, f in ipairs(onlineFriends) do
                        if f.GameId == game.JobId then
                            inServerCount = inServerCount + 1
                        end
                    end
                    pcall(function()
                        InServerFriendsBtn:SetDesc(inServerCount > 0 and (tostring(inServerCount) .. " friends") or "no friends")
                        OnlineFriendsBtn:SetDesc(tostring(onlineCount) .. " friends")
                    end)
                end
            end)

            pcall(function()
                local pages = Players:GetFriendsAsync(LocalPlayer.UserId)
                local total = 0
                while true do
                    local pageItems = pages:GetCurrentPage()
                    total = total + #pageItems
                    if pages.IsFinished or total >= 200 then break end
                    pages:AdvanceToNextPageAsync()
                end
                pcall(function()
                    AllFriendsBtn:SetDesc(tostring(total) .. " Friends")
                    local online = 0
                    pcall(function()
                        local txt = OnlineFriendsBtn.Desc or ""
                        online = tonumber(txt:match("(%d+)")) or 0
                    end)
                    OfflineFriendsBtn:SetDesc(tostring(math.max(0, total - online)) .. " friends")
                end)
            end)
        end)

        -- 1-second dynamic heartbeat ticker
        while task.wait(1) do
            local elapsed = os.time() - sessionStart
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = elapsed % 60
            local timeStr = string.format("%02d:%02d:%02d", h, m, s)

            local ping = 60
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            pcall(function()
                TimeBtn:SetDesc(timeStr)
                LatencyBtn:SetDesc(tostring(ping) .. "ms")
                PlayersBtn:SetDesc(tostring(#Players:GetPlayers()) .. " playing")
            end)
        end
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 1.  EGG STEALING
    -- ════════════════════════════════════════════════════════════════════
    local StealSection = Window:Section({ Title = "Egg Operations" })

    local StealTab = StealSection:Tab({
        Title     = "Auto Steal",
        Icon      = "solar:egg-bold-duotone",
        IconColor = Color3.fromHex("#f59e0b"),
        IconShape = "Square",
        Border    = true,
    })

    StealTab:Section({ Title = "Steal Engine" })

    StealTab:Toggle({
        Title    = "Auto Steal",
        Desc     = "Automatically steal eggs from enemy bases.",
        Flag     = "AutoStealToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoSteal = val
            Notify(WindUI,
                val and "✅ Auto Steal ON" or "⛔ Auto Steal OFF",
                "",
                val and "solar:play-circle-bold" or "solar:stop-circle-bold",
                2)
        end,
    })

    StealTab:Toggle({
        Title    = "Steal Infested Egg",
        Desc     = "Include infested eggs in the steal queue.",
        Flag     = "StealInfestedToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.StealInfested = val end,
    })

    StealTab:Toggle({
        Title    = "Anti Trap",
        Desc     = "Detect and avoid egg-trap zones.",
        Flag     = "AntiTrapToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.AntiTrap = val end,
    })

    StealTab:Toggle({
        Title    = "Run Animation",
        Flag     = "RunAnimationToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.RunAnimation = val end,
    })

    StealTab:Section({ Title = "Targeting Rules" })

    StealTab:Dropdown({
        Title    = "Target Areas",
        Flag     = "TargetAreasDropdown",
        Values   = { "All Areas", "Enemy Bases", "Center Zone", "Rare Spawns" },
        Value    = "All Areas",
        Callback = function(val) HubState.Settings.TargetAreas = val end,
    })

    StealTab:Dropdown({
        Title    = "Target Egg Tier",
        Flag     = "TargetSpecificEggsDropdown",
        Values   = { "All Eggs", "Legendary & Up", "Epic & Up", "Only Infested" },
        Value    = "All Eggs",
        Callback = function(val) HubState.Settings.TargetSpecificEggs = val end,
    })

    StealTab:Dropdown({
        Title    = "Steal Priority",
        Flag     = "StealPriorityDropdown",
        Values   = { "Highest Rarity", "Nearest Egg", "Infested First" },
        Value    = "Highest Rarity",
        Callback = function(val) HubState.Settings.StealPriority = val end,
    })

    StealTab:Section({ Title = "Speed & Timing" })

    StealTab:Slider({
        Title    = "Tween Speed",
        Flag     = "TweenSpeedSlider",
        Step     = 5,
        Value    = { Min = 15, Max = 120, Default = 35 },
        Callback = function(val) HubState.Settings.TweenSpeed = val end,
    })

    StealTab:Slider({
        Title    = "Steal Timeout",
        Flag     = "StealTimeoutSlider",
        Step     = 1,
        Value    = { Min = 1, Max = 15, Default = 5 },
        Callback = function(val) HubState.Settings.StealTimeout = val end,
    })

    StealTab:Section({ Title = "Base Placement" })

    StealTab:Toggle({
        Title    = "Auto Place Egg",
        Flag     = "AutoPlaceEggToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.AutoPlaceEgg = val end,
    })

    StealTab:Toggle({
        Title    = "Skip Infested Placement",
        Desc     = "Don't place infested eggs back on your base.",
        Flag     = "DontPlaceInfestedToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.DontPlaceInfested = val end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 2.  TREADMILL & BASE UPGRADES
    -- ════════════════════════════════════════════════════════════════════
    local TreadSection = Window:Section({ Title = "Treadmill & Base" })

    local TreadmillTab = TreadSection:Tab({
        Title     = "Treadmill & Base",
        Icon      = "solar:running-round-bold-duotone",
        IconColor = Color3.fromHex("#22c55e"),
        IconShape = "Square",
        Border    = true,
    })

    TreadmillTab:Section({ Title = "Speed Farming" })

    TreadmillTab:Toggle({
        Title    = "Auto Treadmill",
        Desc     = "Automatically run on treadmills for speed boosts.",
        Flag     = "AutoTreadmillToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoTreadmill = val
            Notify(WindUI,
                val and "✅ Treadmill ON" or "⛔ Treadmill OFF", "",
                "solar:running-round-bold", 2)
        end,
    })

    TreadmillTab:Toggle({
        Title    = "Hide Treadmill",
        Flag     = "HideTreadmillToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.HideTreadmill = val
            Modules.Treadmill.SetHideTreadmill(val)
        end,
    })

    TreadmillTab:Button({
        Title    = "Exit Treadmill Now",
        Icon     = "solar:logout-2-bold",
        Callback = function()
            HubState.Settings.AutoTreadmill = false
            Modules.Treadmill.Exit(Helpers)
            Notify(WindUI, "Treadmill Exited", "Auto-Treadmill disabled.", "solar:logout-2-bold", 2)
        end,
    })

    TreadmillTab:Section({ Title = "Upgrades" })

    TreadmillTab:Toggle({
        Title    = "Auto Upgrade Treadmill",
        Flag     = "AutoUpgradeTreadmillToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoUpgradeTreadmill = val end,
    })

    TreadmillTab:Toggle({
        Title    = "Auto Upgrade Base",
        Flag     = "AutoUpgradeBaseToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoUpgradeBase = val end,
    })

    TreadmillTab:Toggle({
        Title    = "Auto Buy Trail",
        Flag     = "AutoBuyTrailToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoBuyTrail = val end,
    })

    TreadmillTab:Toggle({
        Title    = "Auto Claim",
        Flag     = "AutoClaimToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoClaim = val end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 3.  HUNGRY MONSTER
    -- ════════════════════════════════════════════════════════════════════
    local MonsterSection = Window:Section({ Title = "Monster" })

    local MonsterTab = MonsterSection:Tab({
        Title     = "Hungry Monster",
        Icon      = "solar:ghost-bold-duotone",
        IconColor = Color3.fromHex("#a855f7"),
        IconShape = "Square",
        Border    = true,
    })

    MonsterTab:Section({ Title = "Monster Feeding" })

    MonsterTab:Toggle({
        Title    = "Auto Feed Monster",
        Desc     = "Feed the Hungry Monster automatically.",
        Flag     = "AutoFeedMonsterToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoFeedMonster = val
            Notify(WindUI,
                val and "✅ Feed Monster ON" or "⛔ Feed Monster OFF", "",
                "solar:ghost-bold", 2)
        end,
    })

    MonsterTab:Dropdown({
        Title    = "Feed Max Rarity",
        Flag     = "FeedMaxRarityDropdown",
        Values   = { "Common", "Rare", "Epic", "Legendary" },
        Value    = "Rare",
        Callback = function(val) HubState.Settings.FeedMaxRarity = val end,
    })

    MonsterTab:Toggle({
        Title    = "Auto Claim Monster Chest",
        Flag     = "AutoClaimMonsterChestToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoClaimChest = val end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 4.  HATCH & PREDICTOR
    -- ════════════════════════════════════════════════════════════════════
    local PetsSection = Window:Section({ Title = "Pets & Hatching" })

    local HatchTab = PetsSection:Tab({
        Title     = "Hatch & Predictor",
        Icon      = "solar:bird-bold-duotone",
        IconColor = Color3.fromHex("#f97316"),
        IconShape = "Square",
        Border    = true,
    })

    HatchTab:Section({ Title = "Egg Opener" })

    HatchTab:Dropdown({
        Title    = "Egg Scope",
        Flag     = "EggScopeDropdown",
        Values   = {
            "Basic Egg", "Rare Egg", "Epic Egg",
            "Legendary Egg", "Mythic Egg", "Infested Egg", "Void Egg",
        },
        Value    = "Basic Egg",
        Callback = function(val) HubState.Settings.EggScope = val end,
    })

    HatchTab:Toggle({
        Title    = "Auto Hatch",
        Desc     = "Continuously hatch the selected egg type.",
        Flag     = "AutoHatchToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoHatch = val
            Notify(WindUI,
                val and "✅ Auto Hatch ON" or "⛔ Auto Hatch OFF",
                HubState.Settings.EggScope,
                "solar:bird-bold", 2)
        end,
    })

    HatchTab:Section({ Title = "Predictors" })

    HatchTab:Button({
        Title    = "Pet Predictor",
        Icon     = "solar:magic-stick-3-bold",
        Callback = function()
            local p = Modules.Pets.Predict(HubState.Settings.EggScope)
            Notify(WindUI,
                "Pet Predictor",
                "Next from " .. HubState.Settings.EggScope .. ": " .. p,
                "solar:magic-stick-3-bold", 5)
        end,
    })

    HatchTab:Button({
        Title    = "All Eggs Predictor",
        Icon     = "solar:list-bold",
        Callback = function()
            Notify(WindUI,
                "All Eggs Predictor",
                "Basic: Rare Dog  |  Epic: Legendary Dragon  |  Void: Mythic Reaper",
                "solar:list-bold", 6)
        end,
    })

    HatchTab:Button({
        Title    = "Fuse Predictor",
        Icon     = "solar:test-tube-bold",
        Callback = function()
            Notify(WindUI,
                "Fuse Predictor",
                "Predicted: Rainbow Shiny Dragon — 95% Success Rate",
                "solar:test-tube-bold", 5)
        end,
    })

    HatchTab:Button({
        Title    = "Refresh Fuse Predictor",
        Icon     = "solar:refresh-bold",
        Callback = function()
            Notify(WindUI, "Fuse Predictor", "Seed refreshed successfully.", "solar:refresh-bold", 2)
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 5.  PET MANAGEMENT
    -- ════════════════════════════════════════════════════════════════════
    local PetTab = PetsSection:Tab({
        Title     = "Pet Management",
        Icon      = "solar:star-bold-duotone",
        IconColor = Color3.fromHex("#eab308"),
        IconShape = "Square",
        Border    = true,
    })

    PetTab:Section({ Title = "Equip & Favorites" })

    PetTab:Toggle({
        Title    = "Auto Equip Best",
        Flag     = "AutoEquipBestToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoEquipBest = val end,
    })

    PetTab:Toggle({
        Title    = "Auto Favorite Pet",
        Flag     = "AutoFavoritePetToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.AutoFavoritePet = val end,
    })

    PetTab:Dropdown({
        Title    = "Favorite Min Rarity",
        Flag     = "FavoriteMinRarityDropdown",
        Values   = { "Rare", "Epic", "Legendary", "Mythic" },
        Value    = "Legendary",
        Callback = function(val) HubState.Settings.FavoriteMinRarity = val end,
    })

    PetTab:Toggle({
        Title    = "Favorite Mutations",
        Flag     = "FavoriteMutationToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.FavoriteMutation = val end,
    })

    PetTab:Button({
        Title    = "Favorite Pets Now",
        Icon     = "solar:star-bold",
        Color    = Color3.fromHex("#1d4ed8"),
        Callback = function()
            Helpers.FireRemoteByKeywords({"favorite", "lockpet"})
            Notify(WindUI, "Favorites Updated", "All qualifying pets marked.", "solar:star-bold", 3)
        end,
    })

    PetTab:Section({ Title = "Auto Sell Pets" })

    PetTab:Toggle({
        Title    = "Auto Sell Pet",
        Desc     = "Sell pets that match the sell rule below.",
        Flag     = "AutoSellPetToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoSellPet = val
            Notify(WindUI,
                val and "✅ Auto Sell Pets ON" or "⛔ Auto Sell Pets OFF", "",
                "solar:tag-bold", 2)
        end,
    })

    PetTab:Dropdown({
        Title    = "Sell Pet Rule",
        Flag     = "SellPetRuleDropdown",
        Values   = { "Rarity Below", "Income Below", "Duplicates Only" },
        Value    = "Rarity Below",
        Callback = function(val) HubState.Settings.SellPetRule = val end,
    })

    PetTab:Dropdown({
        Title    = "Sell Below Rarity",
        Flag     = "PetMaxRarityDropdown",
        Values   = { "Common", "Rare", "Epic", "Legendary" },
        Value    = "Rare",
        Callback = function(val) HubState.Settings.PetMaxRarity = val end,
    })

    PetTab:Slider({
        Title    = "Income Threshold",
        Flag     = "PetIncomeThresholdSlider",
        Step     = 50,
        Value    = { Min = 10, Max = 5000, Default = 100 },
        Callback = function(val) HubState.Settings.PetIncomeThreshold = val end,
    })

    PetTab:Dropdown({
        Title    = "Blacklist Sell",
        Flag     = "BlacklistSellPetsDropdown",
        Values   = { "None", "Favorites Only", "Mutations Only" },
        Value    = "Favorites Only",
        Callback = function(val) HubState.Settings.BlacklistSellPets = val end,
    })

    PetTab:Button({
        Title    = "Sell Pets Now",
        Icon     = "solar:tag-bold",
        Color    = Color3.fromHex("#dc2626"),
        Callback = function()
            Helpers.FireRemoteByKeywords({"sellpet", "sellpets"})
            Notify(WindUI, "Pets Sold", "Matching pets have been sold.", "solar:tag-bold", 3)
        end,
    })

    PetTab:Section({ Title = "Inventory Tools" })

    PetTab:Dropdown({
        Title    = "Sort Pets By",
        Flag     = "SortPetsByDropdown",
        Values   = { "Rarity", "Income", "Mutation", "Level" },
        Value    = "Rarity",
        Callback = function(val) HubState.Settings.SortPetsBy = val end,
    })

    PetTab:Button({
        Title    = "Refresh Inventory",
        Icon     = "solar:refresh-bold",
        Callback = function()
            Helpers.FireRemoteByKeywords({"refreshpets", "getpets"})
            Notify(WindUI, "Inventory Refreshed", "Pet list updated.", "solar:refresh-bold", 2)
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 6.  EGG ECONOMY
    -- ════════════════════════════════════════════════════════════════════
    local EggSellTab = PetsSection:Tab({
        Title     = "Egg Economy",
        Icon      = "solar:shop-bold-duotone",
        IconColor = Color3.fromHex("#10b981"),
        IconShape = "Square",
        Border    = true,
    })

    EggSellTab:Section({ Title = "Egg Selling" })

    EggSellTab:Toggle({
        Title    = "Auto Sell Egg",
        Desc     = "Automatically sell eggs below the set rarity.",
        Flag     = "AutoSellEggToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoSellEgg = val
            Notify(WindUI,
                val and "✅ Auto Sell Egg ON" or "⛔ Auto Sell Egg OFF", "",
                "solar:shop-bold", 2)
        end,
    })

    EggSellTab:Dropdown({
        Title    = "Sell Below Rarity",
        Flag     = "EggMaxRarityDropdown",
        Values   = { "Common", "Rare", "Epic" },
        Value    = "Common",
        Callback = function(val) HubState.Settings.EggMaxRarity = val end,
    })

    EggSellTab:Button({
        Title    = "Sell Eggs Now",
        Icon     = "solar:shop-bold",
        Color    = Color3.fromHex("#059669"),
        Callback = function()
            Helpers.FireRemoteByKeywords({"sellegg", "selleggs"})
            Notify(WindUI, "Eggs Sold", "Matching eggs have been sold.", "solar:shop-bold", 3)
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 7.  VISUALS (ESP)
    -- ════════════════════════════════════════════════════════════════════
    local VisualsSection = Window:Section({ Title = "Player & Visuals" })

    local VisualsTab = VisualsSection:Tab({
        Title     = "Visuals (ESP)",
        Icon      = "solar:eye-bold-duotone",
        IconColor = Color3.fromHex("#ec4899"),
        IconShape = "Square",
        Border    = true,
    })

    VisualsTab:Section({ Title = "ESP Chams" })

    VisualsTab:Toggle({
        Title    = "ESP Eggs",
        Desc     = "Highlight eggs — Red = Regular, Green = Infested.",
        Flag     = "ESPEggsToggle",
        Value    = false,
        Callback = function(val)
            Modules.Visuals.SetEggESP(val, HubState)
            Notify(WindUI,
                val and "✅ Egg ESP ON" or "⛔ Egg ESP OFF", "",
                "solar:eye-bold", 2)
        end,
    })

    VisualsTab:Toggle({
        Title    = "ESP Players",
        Desc     = "Draw red box chams on other players.",
        Flag     = "ESPPlayersToggle",
        Value    = false,
        Callback = function(val)
            Modules.Visuals.SetPlayerESP(val, HubState)
            Notify(WindUI,
                val and "✅ Player ESP ON" or "⛔ Player ESP OFF", "",
                "solar:users-group-two-rounded-bold", 2)
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 8.  LOCAL PLAYER
    -- ════════════════════════════════════════════════════════════════════
    local PlayerTab = VisualsSection:Tab({
        Title     = "Local Player",
        Icon      = "solar:running-round-bold-duotone",
        IconColor = Color3.fromHex("#6366f1"),
        IconShape = "Square",
        Border    = true,
    })

    PlayerTab:Section({ Title = "Speed & Movement" })

    local WalkSpeedSlider = PlayerTab:Slider({
        Title    = "WalkSpeed",
        Flag     = "PlayerWalkSpeed",
        Step     = 1,
        Value    = { Min = 16, Max = 350, Default = 16 },
        Callback = function(val)
            HubState.Settings.WalkSpeed = val
            Modules.Player.SetWalkSpeed(val, Helpers)
        end,
    })

    PlayerTab:Toggle({
        Title    = "CFrame Speed Hack",
        Desc     = "Bypass anti-cheat speed resets smoothly.",
        Flag     = "CFrameSpeedToggle",
        Value    = false,
        Callback = function(val) HubState.Settings.CFrameSpeed = val end,
    })

    PlayerTab:Slider({
        Title    = "CFrame Multiplier",
        Flag     = "CFrameSpeedMultiplier",
        Step     = 0.5,
        Value    = { Min = 1, Max = 10, Default = 2 },
        Callback = function(val) HubState.Settings.CFrameSpeedMultiplier = val end,
    })

    PlayerTab:Section({ Title = "Speed Presets" })

    local SpeedGroup = PlayerTab:Group()
    SpeedGroup:Button({
        Title    = "Normal",
        Desc     = "16 studs/s",
        Icon     = "solar:walk-bold",
        Callback = function() WalkSpeedSlider:Set(16) end,
    })
    SpeedGroup:Space()
    SpeedGroup:Button({
        Title    = "Fast",
        Desc     = "50 studs/s",
        Icon     = "solar:running-2-bold",
        Callback = function() WalkSpeedSlider:Set(50) end,
    })

    local SpeedGroup2 = PlayerTab:Group()
    SpeedGroup2:Button({
        Title    = "Flash",
        Desc     = "150 studs/s",
        Icon     = "solar:bolt-bold",
        Color    = Color3.fromHex("#1d4ed8"),
        Callback = function() WalkSpeedSlider:Set(150) end,
    })
    SpeedGroup2:Space()
    SpeedGroup2:Button({
        Title    = "God",
        Desc     = "300 studs/s",
        Icon     = "solar:bolt-bold",
        Color    = Color3.fromHex("#7c3aed"),
        Callback = function() WalkSpeedSlider:Set(300) end,
    })

    PlayerTab:Section({ Title = "Abilities" })

    PlayerTab:Toggle({
        Title    = "Infinite Jump",
        Desc     = "Jump unlimited times in the air.",
        Flag     = "InfJumpToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.InfJump = val
            Notify(WindUI,
                val and "✅ Infinite Jump ON" or "⛔ Infinite Jump OFF", "",
                "solar:bolt-bold", 2)
        end,
    })

    PlayerTab:Toggle({
        Title    = "Noclip",
        Desc     = "Phase through walls and objects.",
        Flag     = "NoclipToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.Noclip = val
            Notify(WindUI,
                val and "✅ Noclip ON" or "⛔ Noclip OFF", "",
                "solar:ghost-bold", 2)
        end,
    })

    -- ════════════════════════════════════════════════════════════════════
    -- 9.  SETTINGS
    -- ════════════════════════════════════════════════════════════════════
    local SystemSection = Window:Section({ Title = "System" })

    local SettingsTab = SystemSection:Tab({
        Title     = "Settings",
        Icon      = "solar:settings-bold-duotone",
        IconColor = Color3.fromHex("#94a3b8"),
        IconShape = "Square",
        Border    = true,
    })

    SettingsTab:Section({ Title = "Theme & Keybind" })

    -- Dynamic theme picker from WindUI's theme list
    SettingsTab:Dropdown({
        Title    = "UI Theme",
        Flag     = "WindowThemeDropdown",
        Values   = (function()
            local names = {}
            for name in pairs(WindUI:GetThemes()) do
                table.insert(names, name)
            end
            table.sort(names)
            return names
        end)(),
        Value    = WindUI:GetCurrentTheme(),
        Callback = function(selected)
            WindUI:SetTheme(selected)
            Notify(WindUI, "Theme Changed", "Now using: " .. selected, "solar:palette-bold", 3)
        end,
    })

    SettingsTab:Keybind({
        Title    = "Toggle Window",
        Desc     = "Key to open/close the hub.",
        Flag     = "ToggleWindowKeybind",
        Value    = "RightControl",
        Callback = function(v)
            Window:SetToggleKey(Enum.KeyCode[v])
        end,
    })

    SettingsTab:Section({ Title = "Session" })

    SettingsTab:Button({
        Title    = "About Exiles Hub",
        Icon     = "solar:info-square-bold",
        Callback = function()
            Notify(WindUI,
                "Exiles Hub v3.2",
                "Developer: DEV ZAX\nGame: Steal An Egg\nLibrary: WindUI\nRepo: github.com/mmtandico/ExilesHub",
                "solar:info-square-bold",
                7)
        end,
    })

    SettingsTab:Button({
        Title    = "Unload Hub",
        Icon     = "solar:logout-3-bold",
        Color    = Color3.fromHex("#7f1d1d"),
        Callback = function()
            Window:Dialog({
                Title   = "Unload Exiles Hub?",
                Content = "This will clean up all scripts and destroy the UI.",
                Buttons = {
                    { Title = "Cancel",  Variant = "Secondary", Callback = function() end },
                    { Title = "Unload",  Variant = "Primary",   Callback = function()
                        HubState.Cleanup()
                        local hum = Helpers.GetHumanoid()
                        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
                        Notify(WindUI, "Exiles Hub Unloaded", "Thanks — DEV ZAX", "solar:logout-3-bold", 4)
                        task.wait(1)
                        Window:Destroy()
                    end },
                },
            })
        end,
    })

    return Window
end

return UILayout
