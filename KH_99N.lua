--=============================================================
--  HUB PROFESIONAL "99 Nights"
--  Script unificado con depuración (prints en puntos clave)
--=============================================================

print("[99.lua] Script cargado correctamente")

--// Referencias de servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

--=============================================================
--  CREAR REMOTEEVENTS (Server side)
--=============================================================
print("[99.lua] Iniciando RemoteEvents...")

local function getOrCreateEvent(name)
    local ev = ReplicatedStorage:FindFirstChild(name)
    if not ev then
        print("[HubSetup] Creando RemoteEvent:", name)
        ev = Instance.new("RemoteEvent")
        ev.Name = name
        ev.Parent = ReplicatedStorage
    else
        print("[HubSetup] RemoteEvent ya existe:", name)
    end
    return ev
end

local HubActionEvent = getOrCreateEvent("HubAction")
local BringItemEvent = getOrCreateEvent("BringItemRequest")
local StartDragEvent = getOrCreateEvent("RequestStartDraggingItem")
local StopDragEvent = getOrCreateEvent("StopDraggingItem")

print("[99.lua] RemoteEvents listos")

--=============================================================
--  SERVER HANDLER (solo si es servidor)
--=============================================================
if RunService:IsServer() then
    print("[99.lua] Corriendo en SERVER, cargando handlers...")

    -- Saltar noche
    HubActionEvent.OnServerEvent:Connect(function(player, action)
        print("[Server] Acción recibida:", action, "de", player.Name)
        if action == "SkipNight" then
            if player.UserId == game.CreatorId then
                print("[Server] Saltando noche (ADMIN)")
                -- Aquí pones tu lógica para saltar noche
            else
                warn("[Server] Jugador NO autorizado a saltar noche:", player.Name)
            end
        elseif action == "TeleportToLobby" then
            print("[Server] Teleportando", player.Name, "al Lobby")
            local lobbySpawn = workspace:FindFirstChild("LobbySpawn")
            if lobbySpawn then
                player.Character:MoveTo(lobbySpawn.Position)
            else
                warn("[Server] No se encontró LobbySpawn")
            end
        end
    end)

    -- Dar item
    BringItemEvent.OnServerEvent:Connect(function(player, itemName)
        print("[Server] Petición de item:", itemName, "por", player.Name)
        local item = ServerStorage:FindFirstChild("Items") and ServerStorage.Items:FindFirstChild(itemName)
        if item then
            local clone = item:Clone()
            clone.Parent = player.Backpack
            print("[Server] Item entregado:", itemName)
        else
            warn("[Server] Item no encontrado en ServerStorage.Items:", itemName)
        end
    end)
end

--=============================================================
--  CLIENT HANDLER (solo si es cliente)
--=============================================================
if RunService:IsClient() then
    print("[99.lua] Corriendo en CLIENTE, creando HUD...")

    local LocalPlayer = Players.LocalPlayer
    print("[Client] Player detectado:", LocalPlayer.Name)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    print("[Client] PlayerGui listo")

    -- Crear GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HubGui"
    screenGui.Parent = PlayerGui
    print("[Client] ScreenGui creado")

    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = screenGui
    print("[Client] Frame principal creado")

    -- Layout
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 120, 0, 40)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.FillDirectionMaxCells = 2
    layout.Parent = frame

    -- Función crear botón
    local function createButton(txt, callback)
        local btn = Instance.new("TextButton")
        btn.Text = txt
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 18
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            print("[Client] Click en botón:", txt)
            callback()
        end)
    end

    -- Botones de ejemplo
    createButton("Skip Night", function()
        HubActionEvent:FireServer("SkipNight")
    end)

    createButton("Teleport Lobby", function()
        HubActionEvent:FireServer("TeleportToLobby")
    end)

    createButton("Give Log", function()
        BringItemEvent:FireServer("Log")
    end)

    createButton("Give Coal", function()
        BringItemEvent:FireServer("Coal")
    end)

    print("[Client] HUD debería estar visible ahora")

    -- Toggle con RightShift
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            frame.Visible = not frame.Visible
            print("[Client] Toggle HUD:", frame.Visible)
        end
    end)
end
