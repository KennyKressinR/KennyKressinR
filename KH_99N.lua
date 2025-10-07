--========================================================--
-- KS HUB - 99 Noches
-- Main.lua (estructura final modular y limpia)
--========================================================--

--// Librería de UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("KS HUB - 99 Noches", "DarkTheme")

--========================================================--
-- BLOQUE: Referencias Globales
--========================================================--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--========================================================--
-- BLOQUE: Listas de Ítems Globales
--========================================================--
_G.ItemNamesESP = {
    ["Revolver"] = true, ["Oil Barrel"] = true, ["Chainsaw"] = true, ["Giant Sack"] = true,
    ["Bunny Foot"] = true, ["MedKit"] = true, ["Alien Chest"] = true, ["Berry"] = true,
    ["Bolt"] = true, ["Broken Fan"] = true, ["Carrot"] = true, ["Coal"] = true,
    ["Coin Stack"] = true, ["Hologram Emitter"] = true, ["Item Chest"] = true,
    ["Laser Fence Blueprint"] = true, ["Log"] = true, ["Old Flashlight"] = true,
    ["Old Radio"] = true, ["Sheet Metal"] = true, ["Bandage"] = true, ["Rifle"] = true
}

_G.PossibleItems = {
    "Alien Chest","Alpha Wolf Pelt","Anvil Front","Anvil Back","Apple","Bandage","Bear Corpse",
    "Bear Pelt","Berry","Biofuel","Bolt","Broken Fan","Bunny Foot","Carrot","Coal","Coin Stack",
    "Cooked Morsel","Cooked Steak","Chainsaw","Cultist","Cultist Gem","Flower","Fuel Canister",
    "Hologram Emitter","Item Chest","Laser Fence Blueprint","Leather Body","Iron Body","Thorn Body",
    "Log","MedKit","Morsel","Old Flashlight","Old Radio","Good Sack","Good Axe","Raygun","Giant Sack",
    "Strong Axe","Oil Barrel","Old Car Engine","Rifle","Rifle Ammo","Revolver","Revolver Ammo",
    "Sapling","Sheet Metal","Steak","Wolf Pelt","Gem of the Forest Fragment","Tyre","Washing Machine",
    "Broken Microwave"
}

--========================================================--
-- BLOQUE: Cargar Módulos
--========================================================--
local Modules = {}
local function LoadModule(name)
    local success, module = pcall(function()
        return require(script.Modules[name])
    end)
    if success and module then
        Modules[name] = module
    else
        warn("No se pudo cargar el módulo: " .. name)
    end
end

--========================================================--
-- BLOQUE: Tabs principales
--========================================================--
local Tab_Main     = Window:NewTab("Main")
local Tab_Teleport = Window:NewTab("Teleports")
local Tab_Items    = Window:NewTab("Items")
local Tab_Mobs     = Window:NewTab("Mobs")
local Tab_Player   = Window:NewTab("Player")
local Tab_Visuals  = Window:NewTab("Visuals")
local Tab_AutoFarm = Window:NewTab("AutoFarm")
local Tab_Strong   = Window:NewTab("Stronghold")
local Tab_Extras   = Window:NewTab("Extras")

--========================================================--
-- BLOQUE: Inicialización de Módulos
--========================================================--
LoadModule("ItemESP")     if Modules.ItemESP then Modules.ItemESP.Init(Tab_Items) end
LoadModule("ItemTP")      if Modules.ItemTP then Modules.ItemTP.Init(Tab_Items) end
LoadModule("Teleports")   if Modules.Teleports then Modules.Teleports.Init(Tab_Teleport) end
LoadModule("Player")      if Modules.Player then Modules.Player.Init(Tab_Player) end
LoadModule("Visuals")     if Modules.Visuals then Modules.Visuals.Init(Tab_Visuals) end
LoadModule("AutoFarm")    if Modules.AutoFarm then Modules.AutoFarm.Init(Tab_AutoFarm) end
LoadModule("Stronghold")  if Modules.Stronghold then Modules.Stronghold.Init(Tab_Strong) end
LoadModule("Extras")      if Modules.Extras then Modules.Extras.Init(Tab_Extras) end

--========================================================--
-- BLOQUE: Inicialización Final
--========================================================--
print("[KS HUB] Cargado correctamente. Todos los módulos inicializados.")
