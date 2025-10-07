--========================================================--
-- KS HUB - 99 Noches
-- Main.lua (versión Orion UI)
--========================================================--

print("[KS HUB] Iniciando...")

-- === SERVICES ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- === ORION UI ===
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not success or not OrionLib then
    warn("[KS HUB] Error cargando Orion UI:", OrionLib)
    return
else
    print("[KS HUB] Orion UI cargada correctamente.")
end

-- Crear ventana principal
local Window = OrionLib:MakeWindow({
    Name = "KS HUB - 99 Noches",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "KSHub"
})

-- === TABS ===
local main        = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local autofarmss  = Window:MakeTab({Name = "Auto", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local itemtp      = Window:MakeTab({Name = "Item TP/ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local gametp      = Window:MakeTab({Name = "Game TP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local charactertp = Window:MakeTab({Name = "Mob TP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local plr         = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local vis         = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local misc        = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

print("[KS HUB] Tabs creados correctamente.")

-- === LOAD MODULES ===
local function LoadModule(name, tab)
    local ok, module = pcall(function()
        return require(script.Modules[name])
    end)
    if ok and module then
        print("[KS HUB] Módulo cargado:", name)
        if module.Init then
            local ok2, err2 = pcall(function()
                module.Init(tab)
            end)
            if ok2 then
                print("[KS HUB] Módulo inicializado:", name)
            else
                warn("[KS HUB] Error inicializando módulo:", name, err2)
            end
        end
    else
        warn("[KS HUB] Error cargando módulo:", name, module)
    end
end

-- Inicializar cada módulo en su tab
LoadModule("ItemTP", itemtp)
LoadModule("ItemESP", vis)
LoadModule("Teleports", gametp)
LoadModule("Player", plr)
LoadModule("Visuals", vis)
LoadModule("AutoFarm", autofarmss)
LoadModule("Stronghold", gametp)
LoadModule("Extras", misc)

print("[KS HUB] Inicialización completa.")

-- Iniciar Orion
OrionLib:Init()
