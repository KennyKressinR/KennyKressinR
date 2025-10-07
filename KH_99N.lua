--========================================================--
-- KS HUB - 99 Noches
-- Main.lua (versión final con debug)
--========================================================--

print("[KS HUB] Iniciando...")

-- === SERVICES ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- === UI LIBRARY ===
local success, lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/iiivyne/robloxlua/refs/heads/main/lib.lua"))()
end)

if not success or not lib then
    warn("[KS HUB] Error cargando librería UI:", lib)
    return
else
    print("[KS HUB] Librería UI cargada correctamente.")
end

-- === INTERFACE ===
local int
local ok, err = pcall(function()
    int = lib:CreateInterface(
        "99 Nights in the Forest",
        "script made by lohjc",
        "https://discord.gg/ZNTHTWx7KE",
        "bottom left",
        "royal"
    )
end)

if not ok or not int then
    warn("[KS HUB] Error creando interfaz:", err)
    return
else
    print("[KS HUB] Interfaz creada correctamente.")
end

-- === TABS ===
local main, autofarmss, itemtp, gametp, charactertp, plr, vis, misc
local ok2, err2 = pcall(function()
    main        = int:CreateTab("Main","main functions/script utilities","default",true)
    autofarmss  = int:CreateTab("Auto","auto farm utilities (OP)","op")
    itemtp      = int:CreateTab("Item TP/ESP","bring items to you","item")
    gametp      = int:CreateTab("Game TP","goto in-game locations","info")
    charactertp = int:CreateTab("Mob TP","bring mobs to you","npc")
    plr         = int:CreateTab("Player","modify your localplayer","player")
    vis         = int:CreateTab("Visuals","modify your visuals","visuals")
    misc        = int:CreateTab("Misc","miscellaneous","misc")
end)

if not ok2 then
    warn("[KS HUB] Error creando tabs:", err2)
    return
else
    print("[KS HUB] Tabs creados correctamente.")
end

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
