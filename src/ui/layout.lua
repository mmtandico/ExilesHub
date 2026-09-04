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
    -- 1.  EGG PREDICTOR & SERVER TRACKER (100% GUARANTEED DETECTION)
    -- ════════════════════════════════════════════════════════════════════
    local PredictorSection = Window:Section({ Title = "Egg Intelligence" })

    local PredictorTab = PredictorSection:Tab({
        Title     = "Egg Predictor",
        Icon      = "solar:magic-stick-3-bold-duotone",
        IconColor = Color3.fromHex("#c084fc"),
        IconShape = "Square",
        Border    = true,
    })

    -- ── Notification Alert Hook ───────────────────────────────────────────
    Modules.Predictor.OnEggFound = function(egg, dist)
        Notify(WindUI,
            "🚨 " .. egg.Rarity:upper() .. " EGG DETECTED!",
            string.format("%s (100%% Confirmed)\nDistance: %d studs · Tap to Steal", egg.Pet, dist),
            "solar:magic-stick-3-bold-duotone",
            6
        )
    end

    -- ── Live Cycle & Tracker Stats ────────────────────────────────────────
    PredictorTab:Section({ Title = "Global Spawn & Night Clock" })

    local cycleGroup1 = PredictorTab:Group()
    local NextSpawnBtn = cycleGroup1:Button({
        Title    = "Next Global Spawn",
        Desc     = "05:00 (Syncing...)",
        Icon     = "solar:clock-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    cycleGroup1:Space()
    local NightCycleBtn = cycleGroup1:Button({
        Title    = "Night Cycle (30x Hatch)",
        Desc     = "Detecting lighting...",
        Icon     = "solar:moon-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    local cycleGroup2 = PredictorTab:Group()
    local StatusScanBtn = cycleGroup2:Button({
        Title    = "Server Inventory",
        Desc     = "Scanning 100% of game...",
        Icon     = "solar:radar-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            local list = Modules.Predictor.ScanEntireGame()
            Notify(WindUI, "Full Scan Complete", string.format("Detected %d eggs across the server.", #list), "solar:radar-bold", 3)
        end,
    })
    cycleGroup2:Space()
    local RareCountBtn = cycleGroup2:Button({
        Title    = "High-Tier Targets",
        Desc     = "0 rare eggs",
        Icon     = "solar:shield-star-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    -- ── Timer Sync & Calibration Suite ───────────────────────────────────
    PredictorTab:Section({ Title = "Manual Timer Sync & Calibration" })

    -- Quick Presets (Row 1)
    local presetRow1 = PredictorTab:Group()
    presetRow1:Button({
        Title    = "Sync: 05:00",
        Desc     = "Tap when new eggs spawn",
        Icon     = "solar:restart-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.SetRemainingSeconds(300)
            Notify(WindUI, "Synced to 05:00", "Countdown locked to 5 minutes.", "solar:check-circle-bold", 2)
        end,
    })
    presetRow1:Space()
    presetRow1:Button({
        Title    = "Sync: 04:00",
        Desc     = "Set 4 minutes remaining",
        Icon     = "solar:clock-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.SetRemainingSeconds(240)
            Notify(WindUI, "Synced to 04:00", "Countdown locked to 4 minutes.", "solar:check-circle-bold", 2)
        end,
    })

    -- Quick Presets (Row 2)
    local presetRow2 = PredictorTab:Group()
    presetRow2:Button({
        Title    = "Sync: 03:00",
        Desc     = "Set 3 minutes remaining",
        Icon     = "solar:clock-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.SetRemainingSeconds(180)
            Notify(WindUI, "Synced to 03:00", "Countdown locked to 3 minutes.", "solar:check-circle-bold", 2)
        end,
    })
    presetRow2:Space()
    presetRow2:Button({
        Title    = "Sync: 02:00",
        Desc     = "Set 2 minutes remaining",
        Icon     = "solar:clock-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.SetRemainingSeconds(120)
            Notify(WindUI, "Synced to 02:00", "Countdown locked to 2 minutes.", "solar:check-circle-bold", 2)
        end,
    })

    -- Quick Presets (Row 3)
    local presetRow3 = PredictorTab:Group()
    presetRow3:Button({
        Title    = "Sync: 01:00",
        Desc     = "Set 1 minute remaining",
        Icon     = "solar:clock-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.SetRemainingSeconds(60)
            Notify(WindUI, "Synced to 01:00", "Countdown locked to 1 minute.", "solar:check-circle-bold", 2)
        end,
    })
    presetRow3:Space()
    presetRow3:Button({
        Title    = "Sync: 00:30 (Imminent)",
        Desc     = "Set 30 seconds remaining",
        Icon     = "solar:alarm-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.SetRemainingSeconds(30)
            Notify(WindUI, "Synced to 00:30", "Spawn imminent alert!", "solar:alarm-bold", 2)
        end,
    })

    -- Fine-Tune Offsets (+/- 30s)
    local adjustRow1 = PredictorTab:Group()
    adjustRow1:Button({
        Title    = "+30 Seconds",
        Desc     = "Add 30s to current countdown",
        Icon     = "solar:add-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.AdjustSeconds(30)
            Notify(WindUI, "Adjusted +30s", "Shifted countdown forward.", "solar:check-circle-bold", 1)
        end,
    })
    adjustRow1:Space()
    adjustRow1:Button({
        Title    = "-30 Seconds",
        Desc     = "Subtract 30s from countdown",
        Icon     = "solar:minus-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.AdjustSeconds(-30)
            Notify(WindUI, "Adjusted -30s", "Shifted countdown backward.", "solar:check-circle-bold", 1)
        end,
    })

    -- Fine-Tune Offsets (+/- 10s)
    local adjustRow2 = PredictorTab:Group()
    adjustRow2:Button({
        Title    = "+10 Seconds",
        Desc     = "Fine-tune +10s",
        Icon     = "solar:add-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.AdjustSeconds(10)
            Notify(WindUI, "Adjusted +10s", "Fine-tuned forward.", "solar:check-circle-bold", 1)
        end,
    })
    adjustRow2:Space()
    adjustRow2:Button({
        Title    = "-10 Seconds",
        Desc     = "Fine-tune -10s",
        Icon     = "solar:minus-circle-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function()
            Modules.Predictor.AdjustSeconds(-10)
            Notify(WindUI, "Adjusted -10s", "Fine-tuned backward.", "solar:check-circle-bold", 1)
        end,
    })

    -- Sync to Day/Night Cycle
    PredictorTab:Button({
        Title    = "Sync Countdown to Nightfall",
        Desc     = "Locks spawn timer to the in-game Day/Night cycle transition",
        Icon     = "solar:moon-bold",
        Color    = Color3.fromHex("#1e1e2e"),
        Callback = function()
            local cycleInfo = Modules.Predictor.GetUpcomingCycleInfo()
            if cycleInfo.NightSeconds and cycleInfo.NightSeconds > 0 then
                Modules.Predictor.SetRemainingSeconds(cycleInfo.NightSeconds)
                Notify(WindUI, "Synced to Nightfall", string.format("Locked to %s until night transition.", cycleInfo.NightFormatted), "solar:moon-bold", 3)
            end
        end,
    })

    -- Cycle Length Selector
    PredictorTab:Dropdown({
        Title    = "Cycle Duration",
        Flag     = "SpawnCycleLengthDropdown",
        Values   = { "5 Minutes (300s)", "4.5 Minutes (270s)", "4 Minutes (240s)", "3 Minutes (180s)" },
        Value    = "5 Minutes (300s)",
        Callback = function(val)
            local sec = 300
            if val:find("270") then sec = 270
            elseif val:find("240") then sec = 240
            elseif val:find("180") then sec = 180 end
            Modules.Predictor.SetCycleLength(sec)
            Notify(WindUI, "Cycle Interval Updated", "Cycle set to " .. tostring(sec) .. " seconds.", "solar:clock-circle-bold", 2)
        end,
    })

    -- ── Target Rarities & Automation ──────────────────────────────────────
    PredictorTab:Section({ Title = "Detection & Auto-Steal Filters" })

    PredictorTab:Toggle({
        Title    = "Active Predictor Scanner",
        Desc     = "Scans all workspaces, nests, spawners, and player bases for eggs.",
        Flag     = "PredictorEnabledToggle",
        Value    = true,
        Callback = function(val)
            HubState.Settings.PredictorEnabled = val
            Notify(WindUI, val and "✅ Predictor Active" or "⛔ Predictor Paused", "100% detection engine", "solar:radar-bold", 2)
        end,
    })

    PredictorTab:Toggle({
        Title    = "Track Divine Eggs (Tier 10)",
        Desc     = "100% detection for Kitsune, Nightflame, Divine Unicorn, etc.",
        Flag     = "NotifyDivineToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.NotifyDivine = val end,
    })

    PredictorTab:Toggle({
        Title    = "Track Eternal Eggs (Tier 9)",
        Desc     = "100% detection for Eternal Lunar Dragon, Eternal Phoenix, etc.",
        Flag     = "NotifyEternalToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.NotifyEternal = val end,
    })

    PredictorTab:Toggle({
        Title    = "Track Secret Eggs (Tier 8)",
        Desc     = "100% detection for Void Stalker, Dark God, Secret Demon, etc.",
        Flag     = "NotifySecretToggle",
        Value    = true,
        Callback = function(val) HubState.Settings.NotifySecret = val end,
    })

    PredictorTab:Toggle({
        Title    = "Auto-Steal On Detect",
        Desc     = "Automatically teleports & grabs any Secret, Eternal, or Divine egg the instant it spawns.",
        Flag     = "AutoStealPredictedToggle",
        Value    = false,
        Callback = function(val)
            HubState.Settings.AutoStealPredicted = val
            Notify(WindUI, val and "⚡ Auto-Steal Rare ON" or "⛔ Auto-Steal Rare OFF", "Instant priority grab", "solar:bolt-bold", 2)
        end,
    })

    PredictorTab:Toggle({
        Title    = "Predictor 3D ESP & Beacons",
        Desc     = "Highlights Secret (Yellow), Eternal (Pink), and Divine (Cyan) eggs with 3D tags.",
        Flag     = "PredictorESPToggle",
        Value    = true,
        Callback = function(val)
            HubState.Settings.PredictorESP = val
            Modules.Predictor.UpdateESP(val)
        end,
    })

    -- ── Live High-Tier Target Slots ───────────────────────────────────────
    PredictorTab:Section({ Title = "Live Detected High-Tier Eggs (1-Click Steal)" })

    local EggSlot1 = PredictorTab:Button({
        Title    = "Target 1: Scanning...",
        Desc     = "Waiting for high-tier egg detection",
        Icon     = "solar:egg-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    local EggSlot2 = PredictorTab:Button({
        Title    = "Target 2: Scanning...",
        Desc     = "Waiting for high-tier egg detection",
        Icon     = "solar:egg-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    local EggSlot3 = PredictorTab:Button({
        Title    = "Target 3: Scanning...",
        Desc     = "Waiting for high-tier egg detection",
        Icon     = "solar:egg-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    PredictorTab:Button({
        Title    = "Force Server Rescan",
        Desc     = "Immediately inspect all Workspace instances & proximity prompts",
        Icon     = "solar:refresh-circle-bold",
        Callback = function()
            local list = Modules.Predictor.ScanEntireGame()
            Notify(WindUI, "Rescan Finished", string.format("Found %d total eggs on the server.", #list), "solar:refresh-circle-bold", 3)
        end,
    })

    -- ── Upcoming Biome Forecasts ──────────────────────────────────────────
    PredictorTab:Section({ Title = "Upcoming Biome Spawn Forecast" })

    local forecastGroup = PredictorTab:Group()
    forecastGroup:Button({
        Title    = "Cherry Blossom (2.5B Spd)",
        Desc     = "Forecast: Divine Kitsune / Nightflame",
        Icon     = "solar:leaf-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })
    forecastGroup:Space()
    forecastGroup:Button({
        Title    = "Cosmic Biome (700M Spd)",
        Desc     = "Forecast: Eternal Dragon / Void Stalker",
        Icon     = "solar:planet-bold",
        Color    = Color3.fromHex("#18181b"),
        Callback = function() end,
    })

    -- ── Background Dynamic UI Updater for Predictor Tab ───────────────────
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local cycleInfo = Modules.Predictor.GetUpcomingCycleInfo()
                NextSpawnBtn:SetDesc(string.format("%s (%s)", cycleInfo.NextSpawnFormatted, cycleInfo.TimerSource or "Sync"))
                NightCycleBtn:SetDesc(cycleInfo.NightStatus)

                local detected = Modules.Predictor.DetectedEggs or {}
                local counts = Modules.Predictor.RarityCounts or {}

                local rareTotal = (counts.Divine or 0) + (counts.Eternal or 0) + (counts.Secret or 0)
                RareCountBtn:SetDesc(string.format("%d Divine, %d Eternal, %d Secret", counts.Divine or 0, counts.Eternal or 0, counts.Secret or 0))
                StatusScanBtn:SetDesc(string.format("Total: %d eggs tracked in server", #detected))

                -- Extract top high-tier eggs
                local highTierList = {}
                for _, egg in ipairs(detected) do
                    if egg.Rank >= 8 then
                        table.insert(highTierList, egg)
                    end
                end

                -- Update Target Slots
                local slots = { EggSlot1, EggSlot2, EggSlot3 }
                for i = 1, 3 do
                    local egg = highTierList[i]
                    local btn = slots[i]
                    if egg and btn then
                        local dist = 0
                        pcall(function()
                            local root = Helpers.GetRootPart()
                            if root and egg.Position then
                                dist = math.floor((egg.Position - root.Position).Magnitude)
                            end
                        end)
                        btn:SetTitle(string.format("[%s] %s", egg.Rarity:upper(), egg.Pet))
                        btn:SetDesc(string.format("Loc: %s · Dist: %d studs · Tap to Steal!", egg.Location or "Nest", dist))
                        btn.Callback = function()
                            Notify(WindUI, "Stealing " .. egg.Pet .. "...", "Teleporting to " .. (egg.Location or "target") .. "!", "solar:bolt-bold", 2)
                            Modules.Predictor.StealTargetEgg(egg, Helpers, HubState)
                        end
                    elseif btn then
                        btn:SetTitle(string.format("Target %d: No Rare Egg", i))
                        btn:SetDesc(i == 1 and (rareTotal == 0 and "No Secret/Eternal/Divine in server yet" or "Scanning...") or "Waiting for next spawn cycle")
                        btn.Callback = function() end
                    end
                end
            end)
        end
    end)

    -- ════════════════════════════════════════════════════════════════════
    -- 2.  EGG STEALING
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
    -- 5.  AUTO HATCH
    -- ════════════════════════════════════════════════════════════════════
    local PetsSection = Window:Section({ Title = "Pets & Hatching" })

    local HatchTab = PetsSection:Tab({
        Title     = "Auto Hatch",
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

    PlayerTab:Slider({
        Title    = "JumpPower",
        Flag     = "PlayerJumpPower",
        Step     = 5,
        Value    = { Min = 50, Max = 350, Default = 50 },
        Callback = function(val)
            HubState.Settings.JumpPower = val
            Modules.Player.SetJumpPower(val, Helpers)
        end,
    })

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
