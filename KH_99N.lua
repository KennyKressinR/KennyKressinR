--========================================================--
-- KS HUB - 99 Noches
-- Main.lua (adaptado a int:CreateTab + debug)
--========================================================--

-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

print("[KS HUB] Iniciando...")

-- UI principal (asumo que ya tienes 'int' inicializado antes de esto)
local success, err = pcall(function()
    -- Tabs
    main        = int:CreateTab("Main","main functions/script utilities","default",true)
    autofarmss  = int:CreateTab("Auto","auto farm utilities (OP)","op")
    itemtp      = int:CreateTab("Item TP/ESP","bring items to you","item")
    gametp      = int:CreateTab("Game TP","goto in-game locations","info")
    charactertp = int:CreateTab("Mob TP","bring mobs to you","npc")
    plr         = int:CreateTab("Player","modify your localplayer","player")
    vis         = int:CreateTab("Visuals","modify your visuals","visuals")
    misc        = int:CreateTab("Misc","miscellaneous","misc")
end)

if not success then
    warn("[KS HUB] Error creando tabs:", err)
    return
else
    print("[KS HUB] Tabs creados correctamente.")
end

--========================================================--
-- Cargar módulos
--========================================================--
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
