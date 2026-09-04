# Exiles Script Hub (Visual UI Library)

A modular, high-performance Roblox Script Hub built on **Visual UI Library** with dedicated support for **Steal An Egg** (`Place ID: 107778070777162`).

Official Source: [Visual UI Library GitHub](https://raw.githubusercontent.com/VisualRoblox/Roblox/main/UI-Libraries/Visual%20UI%20Library/Source.lua)

---

## ⚡ Quick Start (Official Loadstring)

Copy and execute this single line in any Roblox executor (Delta, Codex, Fluxus, Arceus X, Wave, Solara, etc.):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/Loader.lua"))()
```

Or load directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/mmtandico/ExilesHub/refs/heads/main/main.lua"))()
```

---

## 🎮 Game Profile: Steal An Egg

- **Place ID**: `107778070777162`
- **Game URL**: `https://www.roblox.com/games/107778070777162/Steal-An-Egg`

### Included Features:
- **Egg Predictor & Night Cycle Forecast**:
  - Live spawn countdown and in-game day/night cycle prediction (30x night speed calculation).
  - Server-wide egg counters (Divine, Eternal, Secret, Cosmic).
  - 1-Click Instant Target Steal slots for rare eggs.
  - Automatic time synchronization with Lighting.
- **Auto Steal**:
  - Auto scans, prioritizes, and collects eggs.
  - Infested egg handling & bypass traps anti-trap module.
  - Auto base nest placement & tween speed control.
- **Treadmill & Base**:
  - Auto treadmill speed farming.
  - Anti-detection treadmill hiding.
  - Base and nest upgrades.
- **Pets & Hatching**:
  - Auto hatch all egg types (Basic to Void).
  - Auto equip best pets and auto favorite.
  - Advanced auto sell with rules, rarity filters, and thresholds.
- **Monster & Economy**:
  - Auto feed hungry monster and claim chest.
  - Auto sell eggs to merchant.
- **Local Player Utilities**:
  - WalkSpeed & JumpPower sliders with quick presets.
  - CFrame speed hack (anti-cheat bypass).
  - Infinite Jump and Noclip.
- **Visuals (ESP)**:
  - Highlight ESP for eggs and players with color differentiation.
- **Visual UI Library Features**:
  - 14 built-in sleek themes (Nordic Dark, Discord, Purple, Sentinel, Synapse X, Krnl, etc.).
  - UI Transparency slider.
  - Customizable Keybind (`RightControl` default) and on-screen toggle button.
  - Safe clean unloader.

---

## 📚 Visual UI Library Quick Reference

### Library Load
```lua
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/VisualRoblox/Roblox/main/UI-Libraries/Visual%20UI%20Library/Source.lua'))()
```

### Window Creation
```lua
local Window = Library:CreateWindow(
    "Exiles Hub",               -- Hub Name
    "Steal An Egg",             -- Game Name
    "Exiles Hub | DEV ZAX",     -- Intro Text
    "rbxassetid://10709761530", -- Intro Icon
    false,                      -- ImprovePerformance
    "ExilesHub",                -- Config Folder
    "Nordic Dark"               -- Theme
)
```

### Tabs, Sections & Elements
```lua
local Tab = Window:CreateTab("Main", true, "rbxassetid://10709761530")
local Section = Tab:CreateSection("Auto Farming")

-- Toggle
Section:CreateToggle("Auto Steal", false, Color3.fromRGB(0, 255, 120), 0.2, function(val)
    print("Auto Steal:", val)
end)

-- Slider
Section:CreateSlider("Tween Speed", 15, 120, 35, Color3.fromRGB(0, 170, 255), function(val)
    print("Speed:", val)
end)

-- Dropdown
Section:CreateDropdown("Target Tier", { "All Eggs", "Legendary & Up" }, "All Eggs", 0.2, function(selected)
    print("Selected:", selected)
end)

-- Button
Section:CreateButton("Claim Rewards", function()
    print("Rewards claimed!")
end)
```
