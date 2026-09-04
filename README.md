# Exiles Script Hub (Rayfield Gen 2)

A modular, high-performance Roblox Script Hub built on **Rayfield Gen 2** with dedicated support for **Steal An Egg** (`Place ID: 107778070777162`).

Official Documentation: [Sirius Rayfield Gen 2 Docs](https://docs.sirius.menu/rayfield-gen2)

---

## ⚡ Quick Start

### 1. Direct Execution in Executor
Copy and paste the entire contents of [`main.lua`](file:///c:/Users/Windows/OneDrive/Desktop/Exiles/main.lua) directly into your executor (Wave, Synapse Z, Delta, Codex, Fluxus, Arceus X, etc.) and hit **Execute**.

### 2. GitHub Loadstring (Recommended for Distribution)
If you host your repository on GitHub, players can load your script hub via a single line:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/<YOUR_USERNAME>/<REPO_NAME>/main/main.lua"))()
```

---

## 🎮 Game Profile: Steal An Egg

- **Place ID**: `107778070777162`
- **Game URL**: `https://www.roblox.com/games/107778070777162/Steal-An-Egg`

### Included Features:
- **Auto Farm**:
  - **Auto Steal Eggs**: Auto scans proximity prompts with smart distance activation and anti-rate-limit delay slider.
  - **Steal Delay Speed**: Configurable delay between steals (0.05s to 1.5s).
  - **Auto Treadmill Speed Train**: Automatically touches speed training zones and fires training remotes.
  - **Auto Sell / Deposit**: Automatically sells and deposits collected eggs when storage is full.
- **Eggs & Pets**:
  - **Egg Opener**: Select from Basic, Rare, Epic, Legendary, Mythic, Ancient, and Secret eggs.
  - **Auto Hatch Toggle**: Continuously opens selected egg.
  - **Instant 1x Hatch Button**: Opens a single egg on demand.
- **Local Player Utilities**:
  - **WalkSpeed & JumpPower**: Full slider control with character respawn persistence.
  - **Infinite Jump**: Jump mid-air infinitely.
  - **Noclip**: Walk through walls and objects cleanly without getting stuck.
  - **Fly Mode**: Free-cam directional flight using `WASD + Space + LeftShift` with a dedicated speed slider.
- **Teleports**:
  - Spawn / Base teleport.
  - Treadmill training zone teleport.
  - Dynamic Player Teleport with server player list dropdown and one-click refresh.
- **Visuals (ESP)**:
  - **Player ESP / Chams**: Roblox Highlight system showing all server players through walls.
  - **Egg Spawn ESP**: Golden chams showing all eggs and egg spawns on the map.
- **Rayfield Gen 2 System**:
  - **Sidebar Layout**: Modern rail navigation with custom icons and section headers.
  - **Built-in Theme Switcher**: Instant transition between `cobalt`, `ember`, `amethyst`, `frost`, `rose`, and `default`.
  - **Auto Save & Auto Load**: Remembers your toggles and slider settings across sessions in `Rayfield/Configurations/ExilesHub/`.
  - **Safe Unloader**: Cleanly destroys UI, stops all worker loops, removes ESP highlights, resets character speeds, and frees executor memory.

---

## 📚 Rayfield Gen 2 Quick Reference

### Library Load
```lua
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
```

### Window Creation
```lua
local Window = Rayfield:CreateWindow({
    name = "My Hub",
    subtitle = "Game Name",
    sidebarLayout = true, -- Modern left rail
    theme = "cobalt",     -- "default", "cobalt", "ember", "amethyst", "frost", "rose"
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "MyConfig",
        customFolder = "MyHubFolder",
    },
})
```

### Tabs & Elements
```lua
local Tab = Window:CreateTab({ name = "Main", icon = 93364949241311 })

-- Toggle
local Toggle = Tab:CreateToggle({
    name = "Auto Farm",
    flag = "AutoFarmFlag",
    value = false,
    callback = function(val) ... end,
})

-- Slider
local Slider = Tab:CreateSlider({
    name = "Speed",
    flag = "SpeedFlag",
    range = { 16, 200 },
    increment = 1,
    value = 16,
    suffix = " studs/s",
    callback = function(val) ... end,
})

-- Dropdown
local Dropdown = Tab:CreateDropdown({
    name = "Select Option",
    options = { "A", "B", "C" },
    value = "A",
    multiSelect = false,
    callback = function(choice) ... end,
})

-- Toasts & Notifications
Window:Toast({ title = "Saved", subtitle = "Profile 1" })
Window:Notify({ title = "Alert", content = "Message body", duration = 5 })
```

---

## 🛠 Adding More Games to the Hub
To support multiple games, you can check `game.PlaceId` or `game.GameId`:

```lua
if game.PlaceId == 107778070777162 then
    -- Load Steal An Egg features
elseif game.PlaceId == 123456789 then
    -- Load another game's tab
else
    -- Universal / Player tab only
end
```
