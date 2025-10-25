----------------------------------------------------------
-- KS HUB – Parte 1: Núcleo, UI base, utilidades
----------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Estados globales
_G.noclipEnabled = false
_G.antiDelayEnabled = false
_G.espEnabled = false
_G.chamsEnabled = false
_G.fullBrightEnabled = false
_G.espItemsEnabled = false
_G.coordsEnabled = false
_G.auraCollectEnabled = false
_G.dragHubEnabled = false

-- GUI base
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 420)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 46)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KS HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 36, 0, 28)
CloseButton.Position = UDim2.new(1, -46, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 36, 0, 36)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -18)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)

-- Sonido click
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://6723721422"
toggleSound.Volume = 0.75
toggleSound.Parent = ToggleButton

----------------------------------------------------------
-- Funciones utilitarias
----------------------------------------------------------
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 32)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    button.MouseButton1Click:Connect(function()
        toggleSound:Play()
        if callback then pcall(callback) end
    end)
    return button
end

local function createToggleButton(parent, text, globalVarName, onFunc, offFunc)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
    button.Text = text.." [OFF]"
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    button.MouseButton1Click:Connect(function()
        toggleSound:Play()
        _G[globalVarName] = not _G[globalVarName]
        if _G[globalVarName] then
            button.Text = text.." [ON]"
            button.BackgroundColor3 = Color3.fromRGB(40, 120, 70)
            if onFunc then onFunc() end
        else
            button.Text = text.." [OFF]"
            button.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
            if offFunc then offFunc() end
        end
    end)
    return button
end

----------------------------------------------------------
-- KS HUB – Parte 2: Pestañas, Animaciones, Notificaciones
----------------------------------------------------------

-- Barra lateral de pestañas
local TabsBar = Instance.new("Frame")
TabsBar.Name = "TabsBar"
TabsBar.Size = UDim2.new(0, 120, 1, -40)
TabsBar.Position = UDim2.new(0, 0, 0, 40)
TabsBar.BackgroundColor3 = Color3.fromRGB(22, 32, 52)
TabsBar.BackgroundTransparency = 0.2
TabsBar.BorderSizePixel = 0
TabsBar.Parent = MainFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
tabsLayout.Parent = TabsBar

-- Contenedor de contenido de pestañas
local TabsContent = Instance.new("Frame")
TabsContent.Name = "TabsContent"
TabsContent.Size = UDim2.new(1, -130, 1, -50)
TabsContent.Position = UDim2.new(0, 130, 0, 45)
TabsContent.BackgroundTransparency = 1
TabsContent.Parent = MainFrame

-- Lista de pestañas
local tabsList = {"Main","Teleport","Waypoints","Visual","Ajustes"}
local Tabs = {}

-- Función para cambiar de pestaña
local function switchTab(tabName)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
    end
end

-- Crear pestañas y botones
for _, name in ipairs(tabsList) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -10, 0, 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    tabBtn.BackgroundTransparency = 0.1
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.new(1,1,1)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 14
    tabBtn.Parent = TabsBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = TabsContent

    Tabs[name] = page

    tabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- Activar pestaña inicial
switchTab("Main")

----------------------------------------------------------
-- Animaciones de abrir/cerrar HUB
----------------------------------------------------------
local function openHub()
    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 1
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)

    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.25
    }):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0.5, -210)
    }):Play()
end

local function closeHub()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 600, 0.5, -210),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        MainFrame.Visible = false
        MainFrame.Position = UDim2.new(0.5, -200, 0.5, -210)
    end)
end

----------------------------------------------------------
-- Conexiones de botones y tecla
----------------------------------------------------------
ToggleButton.MouseButton1Click:Connect(function()
    if not MainFrame.Visible then
        openHub()
    else
        closeHub()
    end
    toggleSound:Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    toggleSound:Play()
    closeHub()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if not MainFrame.Visible then
            openHub()
        else
            closeHub()
        end
        toggleSound:Play()
    end
end)

----------------------------------------------------------
-- Sistema de notificaciones flotantes
----------------------------------------------------------
local notifyFrame = Instance.new("Frame")
notifyFrame.Name = "NotifyFrame"
notifyFrame.Size = UDim2.new(0, 300, 0, 200)
notifyFrame.Position = UDim2.new(1, -310, 1, -210)
notifyFrame.BackgroundTransparency = 1
notifyFrame.Parent = ScreenGui

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Padding = UDim.new(0, 6)
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.Parent = notifyFrame

local function createNotification(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = text
    label.Parent = notifyFrame
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)

    task.delay(2, function()
        TweenService:Create(label, TweenInfo.new(0.4), {
            TextTransparency = 1,
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.5)
        label:Destroy()
    end)
end

----------------------------------------------------------
-- Función attachScrolling con padding y centrado
----------------------------------------------------------
local function attachScrolling(parentPage)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.Parent = parentPage

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = scroll

    return scroll
end

-- Adjuntar scroll a todas las pestañas
local MainScroll = attachScrolling(Tabs["Main"])
local TeleportScroll = attachScrolling(Tabs["Teleport"])
local WaypointsScroll = attachScrolling(Tabs["Waypoints"])
local VisualScroll = attachScrolling(Tabs["Visual"])
local AjustesScroll = attachScrolling(Tabs["Ajustes"])


----------------------------------------------------------
-- Parte 3: Botones dentro de cada pestaña
----------------------------------------------------------

----------------------------------------------------------
----------------------------------------------------------
-- Parte 4: MAIN (fusionada y optimizada)
----------------------------------------------------------
local MainScroll = Scrolls["Main"]

----------------------------------------------------------
-- 1. Auto Interact (fusionado)
-- Combina: Touch, ClickDetector, ProximityPrompt
-- Usa filtro por nombre y radio (configurable en Ajustes)
----------------------------------------------------------
local autoInteractConn
collectNameFilter = "coin"   -- valor inicial, editable en Ajustes
collectRadius = 50           -- valor inicial, editable en Ajustes

createButton(MainScroll, "Auto Interact (Touch/Click/Prompt)", function()
    if autoInteractConn then
        autoInteractConn:Disconnect()
        autoInteractConn = nil
        createNotification("Auto Interact OFF")
        return
    end

    autoInteractConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        if not hrp then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), collectNameFilter) then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < collectRadius then
                    -- Touch
                    local touch = obj:FindFirstChildOfClass("TouchTransmitter")
                    if touch then
                        firetouchinterest(hrp, obj, 0)
                        firetouchinterest(hrp, obj, 1)
                    end
                    -- Click
                    local click = obj:FindFirstChildOfClass("ClickDetector")
                    if click then fireclickdetector(click) end
                    -- Prompt
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and prompt.Enabled then
                        fireproximityprompt(prompt, math.huge)
                    end
                end
            end
        end
    end)

    createNotification("Auto Interact ON (Touch + Click + Prompt)")
end)

----------------------------------------------------------
-- 2. Quick Interact (manual, ejecuta el prompt más cercano)
----------------------------------------------------------
createButton(MainScroll, "Quick Interact (ProximityPrompt)", function()
    local hrp = getHRP()
    if not hrp then return end

    local closestPrompt, closestDist
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or nil
            if parentPart then
                local dist = (parentPart.Position - hrp.Position).Magnitude
                if not closestDist or dist < closestDist then
                    closestPrompt = obj
                    closestDist = dist
                end
            end
        end
    end

    if closestPrompt and closestDist < 20 then
        fireproximityprompt(closestPrompt, math.huge)
        createNotification("Quick Interact ejecutado en "..closestPrompt.Parent.Name)
    else
        createNotification("No hay prompt cercano (<20 studs)")
    end
end)

----------------------------------------------------------
-- 3. Noclip
----------------------------------------------------------
local noclipConn
createButton(MainScroll, "Noclip (toggle)", function()
    _G.noclipEnabled = not _G.noclipEnabled
    if _G.noclipEnabled and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        createNotification("Noclip ON")
    elseif noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
        createNotification("Noclip OFF")
    end
end)

----------------------------------------------------------
-- 4. Infinite Jump (opcional, mantenido aquí)
----------------------------------------------------------
local infiniteJumpConn
createButton(MainScroll, "Infinite Jump (toggle)", function()
    _G.infiniteJumpEnabled = not _G.infiniteJumpEnabled
    if _G.infiniteJumpEnabled and not infiniteJumpConn then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        createNotification("Infinite Jump ON")
    elseif infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
        createNotification("Infinite Jump OFF")
    end
end)

----------------------------------------------------------
-- TELEPORT
----------------------------------------------------------
createButton(TeleportScroll, "Ir al Spawn", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(Vector3.new(0, 5, 0))
        createNotification("Teletransportado al Spawn")
    end
end)


----------------------------------------------------------
-- Waypoints 
----------------------------------------------------------
local WaypointsScroll = Scrolls["Waypoints"]
local savedWaypoints = {}
local lastCreated = nil -- guardamos el último creado

-- Refrescar lista de waypoints
local function refreshWaypoints()
    for _, child in ipairs(WaypointsScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for name, pos in pairs(savedWaypoints) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundTransparency = 1
        frame.Parent = WaypointsScroll

        -- Botón TP
        local btnTP = createButton(frame, "TP: " .. name, function()
            teleportToCFrame(CFrame.new(pos))
            createNotification("Teletransportado a '"..name.."'")
        end)
        btnTP.Size = UDim2.new(0.65, -3, 1, 0)
        btnTP.Position = UDim2.new(0, 0, 0, 0)

        -- Botón DEL
        local btnDel = Instance.new("TextButton")
        btnDel.Size = UDim2.new(0.3, 0, 1, 0)
        btnDel.Position = UDim2.new(0.7, 0, 0, 0)
        btnDel.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        btnDel.Text = "DEL"
        btnDel.TextColor3 = Color3.new(1,1,1)
        btnDel.Font = Enum.Font.GothamBold
        btnDel.TextSize = 14
        btnDel.Parent = frame
        Instance.new("UICorner", btnDel).CornerRadius = UDim.new(0, 6)

        btnDel.MouseButton1Click:Connect(function()
            savedWaypoints[name] = nil
            if lastCreated == name then lastCreated = nil end
            refreshWaypoints()
            createNotification("Waypoint '"..name.."' eliminado")
        end)
    end
end

-- Caja de texto para nombre
local wpBox = Instance.new("TextBox")
wpBox.Size = UDim2.new(1, 0, 0, 30)
wpBox.PlaceholderText = "Nombre del Waypoint"
wpBox.Text = ""
wpBox.Font = Enum.Font.Gotham
wpBox.TextSize = 16
wpBox.TextColor3 = Color3.new(1, 1, 1)
wpBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
wpBox.BackgroundTransparency = 0.1
wpBox.BorderSizePixel = 0
wpBox.ClearTextOnFocus = false
wpBox.Parent = WaypointsScroll
Instance.new("UICorner", wpBox).CornerRadius = UDim.new(0, 6)

-- Botón Crear / Sobrescribir
createButton(WaypointsScroll, "Crear / Actualizar Waypoint", function()
    local hrp = getHRP()
    if hrp then
        local name = wpBox.Text ~= "" and wpBox.Text or ("WP"..tostring(#savedWaypoints+1))
        savedWaypoints[name] = hrp.Position
        lastCreated = name
        wpBox.Text = ""
        refreshWaypoints()
        createNotification("Waypoint '"..name.."' guardado/actualizado")
    end
end)

-- Botón Renombrar último creado
createButton(WaypointsScroll, "Renombrar último Waypoint", function()
    if lastCreated and savedWaypoints[lastCreated] then
        local newName = wpBox.Text
        if newName ~= "" then
            savedWaypoints[newName] = savedWaypoints[lastCreated]
            savedWaypoints[lastCreated] = nil
            lastCreated = newName
            wpBox.Text = ""
            refreshWaypoints()
            createNotification("Waypoint renombrado a '"..newName.."'")
        else
            createNotification("Escribe un nuevo nombre en la caja")
        end
    else
        createNotification("No hay waypoint reciente para renombrar")
    end
end)

-- Botón Borrar Todos
local clearAllBtn = Instance.new("TextButton")
clearAllBtn.Size = UDim2.new(1, 0, 0, 30)
clearAllBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
clearAllBtn.Text = "Borrar TODOS los Waypoints"
clearAllBtn.TextColor3 = Color3.new(1,1,1)
clearAllBtn.Font = Enum.Font.GothamBold
clearAllBtn.TextSize = 14
clearAllBtn.Parent = WaypointsScroll
Instance.new("UICorner", clearAllBtn).CornerRadius = UDim.new(0, 6)

clearAllBtn.MouseButton1Click:Connect(function()
    savedWaypoints = {}
    lastCreated = nil
    refreshWaypoints()
    createNotification("Todos los waypoints borrados")
end)

-- Inicializar lista
refreshWaypoints()

----------------------------------------------------------
-- VISUAL
----------------------------------------------------------
----------------------------------------------------------
-- Parte 7: Visual – ESP jugadores, ESP ítems, FullBright
----------------------------------------------------------
local VisualScroll = Scrolls["Visual"]

-- Estado visual
local espPlayersEnabled = false
local espItemsEnabled = false
local fullBrightEnabled = false

-- Config jugadores
local espPlayerColor = Color3.fromRGB(120, 200, 255)
local espPlayerMode = "Boxes" -- "Boxes" | "Tracers" | "Chams"
local espMaxDistance = 1000
local espFilterSameTeam = false
local espFilterAliveOnly = true

-- Config ítems
local espItemNameFilter = "coin"
local espItemColor = Color3.fromRGB(255, 220, 120)
local espItemRadius = 200

-- Colecciones
local playerEspDrawings = {}  -- {player = {box=Drawing, line=Drawing}}
local itemEspDrawings = {}    -- {[BasePart] = Drawing}
local chamsApplied = {}       -- {character = true}

----------------------------------------------------------
-- Helpers de Drawing (2D overlay). Requiere exploit con Drawings.
-- Si no hay Drawing disponible, la sección Boxes/Tracers no hará nada visible.
----------------------------------------------------------
local function newLine(color)
    local d = Drawing and Drawing.new("Line") or nil
    if d then
        d.Visible = true
        d.Color = color
        d.Thickness = 1.5
        d.Transparency = 1
    end
    return d
end

local function newRect(color)
    local d = Drawing and Drawing.new("Square") or nil
    if d then
        d.Visible = true
        d.Color = color
        d.Filled = false
        d.Thickness = 1.5
        d.Transparency = 1
        d.Size = Vector2.new(40, 60)
        d.Position = Vector2.new(0, 0)
    end
    return d
end

local function clearDrawings(map)
    for k, v in pairs(map) do
        if typeof(v) == "table" then
            for _, d in pairs(v) do
                if d and d.Remove then d:Remove() end
            end
        elseif v and v.Remove then
            v:Remove()
        end
        map[k] = nil
    end
end

----------------------------------------------------------
-- Proyección 3D → 2D
----------------------------------------------------------
local camera = workspace.CurrentCamera
local function worldToViewport(vec3)
    local v, onScreen = camera:WorldToViewportPoint(vec3)
    return Vector2.new(v.X, v.Y), onScreen, v.Z
end

----------------------------------------------------------
-- ESP jugadores: render loop
----------------------------------------------------------
local espPlayersConn
local function renderPlayersESP()
    clearDrawings(playerEspDrawings)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if espFilterSameTeam and plr.Team == LocalPlayer.Team then
                -- Saltar mismo equipo
            else
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local alive = hum and hum.Health > 0

                if char and hrp then
                    local dist = (hrp.Position - (getHRP() and getHRP().Position or hrp.Position)).Magnitude
                    if dist <= espMaxDistance and (not espFilterAliveOnly or alive) then
                        if espPlayerMode == "Boxes" or espPlayerMode == "Tracers" then
                            -- Calcula bounding box aproximada
                            local head = char:FindFirstChild("Head")
                            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                            local feetPos = hrp.Position - Vector3.new(0, 3, 0)
                            local topPos = head and head.Position + Vector3.new(0, 0.5, 0) or hrp.Position + Vector3.new(0, 2, 0)

                            local top2D, onTop, _ = worldToViewport(topPos)
                            local feet2D, onFeet, _ = worldToViewport(feetPos)

                            if onTop and onFeet then
                                playerEspDrawings[plr] = playerEspDrawings[plr] or {}
                                if espPlayerMode == "Boxes" then
                                    local box = playerEspDrawings[plr].box or newRect(espPlayerColor)
                                    playerEspDrawings[plr].box = box
                                    if box then
                                        local height = math.abs(top2D.Y - feet2D.Y)
                                        local width = height * 0.6
                                        local x = top2D.X - width/2
                                        local y = top2D.Y
                                        box.Color = espPlayerColor
                                        box.Size = Vector2.new(width, height)
                                        box.Position = Vector2.new(x, y)
                                        box.Visible = true
                                    end
                                elseif espPlayerMode == "Tracers" then
                                    local line = playerEspDrawings[plr].line or newLine(espPlayerColor)
                                    playerEspDrawings[plr].line = line
                                    if line then
                                        line.Color = espPlayerColor
                                        line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                                        line.To = top2D
                                        line.Visible = true
                                    end
                                end
                            end
                        elseif espPlayerMode == "Chams" then
                            if not chamsApplied[char] then
                                for _, part in ipairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.Material = Enum.Material.ForceField
                                        part.Color = espPlayerColor
                                        part.Transparency = 0.3
                                    end
                                end
                                chamsApplied[char] = true
                            else
                                for _, part in ipairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.Color = espPlayerColor -- permite recolor en tiempo real
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

----------------------------------------------------------
-- ESP ítems: render loop
----------------------------------------------------------
local espItemsConn
local function renderItemsESP()
    clearDrawings(itemEspDrawings)

    local hrp = getHRP()
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(espItemNameFilter)) then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist <= espItemRadius then
                local pos2D, onScreen = worldToViewport(obj.Position)
                if onScreen then
                    local rect = itemEspDrawings[obj] or newRect(espItemColor)
                    itemEspDrawings[obj] = rect
                    if rect then
                        rect.Color = espItemColor
                        rect.Size = Vector2.new(16, 16)
                        rect.Position = pos2D - Vector2.new(8, 8)
                        rect.Visible = true
                    end
                end
            end
        end
    end
end

----------------------------------------------------------
-- Ticker de render
----------------------------------------------------------
local function ensurePlayersLoop(state)
    if state and not espPlayersConn then
        espPlayersConn = RunService.RenderStepped:Connect(function()
            renderPlayersESP()
        end)
    elseif not state and espPlayersConn then
        espPlayersConn:Disconnect()
        espPlayersConn = nil
        clearDrawings(playerEspDrawings)
    end
end

local function ensureItemsLoop(state)
    if state and not espItemsConn then
        espItemsConn = RunService.RenderStepped:Connect(function()
            renderItemsESP()
        end)
    elseif not state and espItemsConn then
        espItemsConn:Disconnect()
        espItemsConn = nil
        clearDrawings(itemEspDrawings)
    end
end

----------------------------------------------------------
-- UI: sección ESP Jugadores
----------------------------------------------------------
createSectionLabel(VisualScroll, "ESP jugadores")

-- Toggle principal
createButton(VisualScroll, "Toggle ESP jugadores", function()
    espPlayersEnabled = not espPlayersEnabled
    ensurePlayersLoop(espPlayersEnabled)
    createNotification("ESP jugadores: " .. (espPlayersEnabled and "ON" or "OFF"))
end)

-- Modo: Boxes / Tracers / Chams
createButton(VisualScroll, "Modo: Boxes", function() espPlayerMode = "Boxes"; createNotification("Modo ESP: Boxes") end)
createButton(VisualScroll, "Modo: Tracers", function() espPlayerMode = "Tracers"; createNotification("Modo ESP: Tracers") end)
createButton(VisualScroll, "Modo: Chams", function() espPlayerMode = "Chams"; createNotification("Modo ESP: Chams") end)

-- Color rápido
createSectionLabel(VisualScroll, "Color rápido")
createButton(VisualScroll, "Azul", function() espPlayerColor = Color3.fromRGB(120, 200, 255) end)
createButton(VisualScroll, "Rojo", function() espPlayerColor = Color3.fromRGB(255, 120, 120) end)
createButton(VisualScroll, "Verde", function() espPlayerColor = Color3.fromRGB(140, 255, 140) end)
createButton(VisualScroll, "Amarillo", function() espPlayerColor = Color3.fromRGB(255, 230, 120) end)

-- Color personalizado RGB (input)
local rgbBox = Instance.new("TextBox")
rgbBox.Size = UDim2.new(1, 0, 0, 30)
rgbBox.PlaceholderText = "Color RGB (ej: 120,200,255)"
rgbBox.Text = ""
rgbBox.Font = Enum.Font.Gotham
rgbBox.TextSize = 14
rgbBox.TextColor3 = Color3.new(1,1,1)
rgbBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
rgbBox.BackgroundTransparency = 0.1
rgbBox.BorderSizePixel = 0
rgbBox.ClearTextOnFocus = false
rgbBox.Parent = VisualScroll
Instance.new("UICorner", rgbBox).CornerRadius = UDim.new(0, 6)

createButton(VisualScroll, "Aplicar color RGB", function()
    local r, g, b = rgbBox.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    if r and g and b then
        espPlayerColor = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
        createNotification("Color aplicado")
    else
        createNotification("Formato inválido. Usa: 120,200,255")
    end
end)

-- Filtros
createSectionLabel(VisualScroll, "Filtros")
createButton(VisualScroll, "Filtrar mismo equipo (toggle)", function()
    espFilterSameTeam = not espFilterSameTeam
    createNotification("Filtro mismo equipo: " .. (espFilterSameTeam and "ON" or "OFF"))
end)
createButton(VisualScroll, "Solo vivos (toggle)", function()
    espFilterAliveOnly = not espFilterAliveOnly
    createNotification("Solo vivos: " .. (espFilterAliveOnly and "ON" or "OFF"))
end)

local distBox = Instance.new("TextBox")
distBox.Size = UDim2.new(1, 0, 0, 30)
distBox.PlaceholderText = "Distancia máx ESP (ej: 1000)"
distBox.Text = tostring(espMaxDistance)
distBox.Font = Enum.Font.Gotham
distBox.TextSize = 14
distBox.TextColor3 = Color3.new(1,1,1)
distBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
distBox.BackgroundTransparency = 0.1
distBox.BorderSizePixel = 0
distBox.ClearTextOnFocus = false
distBox.Parent = VisualScroll
Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 6)

createButton(VisualScroll, "Aplicar distancia", function()
    local v = tonumber(distBox.Text)
    if v and v >= 100 then
        espMaxDistance = v
        createNotification("Distancia máx: " .. tostring(v))
    else
        createNotification("Valor inválido (mín: 100)")
    end
end)

----------------------------------------------------------
-- UI: sección ESP Ítems
----------------------------------------------------------
createSectionLabel(VisualScroll, "ESP ítems")

local itemNameBox = Instance.new("TextBox")
itemNameBox.Size = UDim2.new(1, 0, 0, 30)
itemNameBox.PlaceholderText = "Nombre ítem (ej: coin, gem)"
itemNameBox.Text = espItemNameFilter
itemNameBox.Font = Enum.Font.Gotham
itemNameBox.TextSize = 14
itemNameBox.TextColor3 = Color3.new(1,1,1)
itemNameBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
itemNameBox.BackgroundTransparency = 0.1
itemNameBox.BorderSizePixel = 0
itemNameBox.ClearTextOnFocus = false
itemNameBox.Parent = VisualScroll
Instance.new("UICorner", itemNameBox).CornerRadius = UDim.new(0, 6)

local itemRadiusBox = Instance.new("TextBox")
itemRadiusBox.Size = UDim2.new(1, 0, 0, 30)
itemRadiusBox.PlaceholderText = "Radio (ej: 200)"
itemRadiusBox.Text = tostring(espItemRadius)
itemRadiusBox.Font = Enum.Font.Gotham
itemRadiusBox.TextSize = 14
itemRadiusBox.TextColor3 = Color3.new(1,1,1)
itemRadiusBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
itemRadiusBox.BackgroundTransparency = 0.1
itemRadiusBox.BorderSizePixel = 0
itemRadiusBox.ClearTextOnFocus = false
itemRadiusBox.Parent = VisualScroll
Instance.new("UICorner", itemRadiusBox).CornerRadius = UDim.new(0, 6)

-- Color rápido para ítems
createButton(VisualScroll, "Color ítems: Dorado", function() espItemColor = Color3.fromRGB(255, 220, 120) end)
createButton(VisualScroll, "Color ítems: Rosa", function() espItemColor = Color3.fromRGB(255, 140, 220) end)
createButton(VisualScroll, "Color ítems: Cian", function() espItemColor = Color3.fromRGB(120, 255, 255) end)

-- Toggle y aplicar filtros
createButton(VisualScroll, "Toggle ESP ítems", function()
    espItemsEnabled = not espItemsEnabled
    ensureItemsLoop(espItemsEnabled)
    createNotification("ESP ítems: " .. (espItemsEnabled and "ON" or "OFF"))
end)

createButton(VisualScroll, "Aplicar filtros ítems", function()
    espItemNameFilter = itemNameBox.Text ~= "" and itemNameBox.Text or espItemNameFilter
    local r = tonumber(itemRadiusBox.Text)
    if r and r >= 25 then
        espItemRadius = r
    else
        createNotification("Radio inválido (mín: 25)")
        return
    end
    createNotification("Ítems: filtro '"..espItemNameFilter.."', radio "..tostring(espItemRadius))
end)

----------------------------------------------------------
-- FullBright + Reset visual
----------------------------------------------------------
createSectionLabel(VisualScroll, "FullBright y Reset")

createButton(VisualScroll, "FullBright (toggle)", function()
    fullBrightEnabled = not fullBrightEnabled
    if fullBrightEnabled then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Brightness = 4
        Lighting.FogEnd = 100000
        createNotification("FullBright ON")
    else
        -- Restaurar aproximado
        Lighting.Ambient = Color3.new(0.5,0.5,0.5)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1000
        createNotification("FullBright OFF")
    end
end)

createButton(VisualScroll, "Reset Visual", function()
    -- Apagar loops
    ensurePlayersLoop(false)
    ensureItemsLoop(false)
    espPlayersEnabled = false
    espItemsEnabled = false

    -- Limpiar dibujos y chams
    clearDrawings(playerEspDrawings)
    clearDrawings(itemEspDrawings)
    for char, _ in pairs(chamsApplied) do
        if char and char.Parent then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Intento de restauración básica (no siempre perfecto)
                    part.Material = Enum.Material.Plastic
                    part.Transparency = 0
                end
            end
        end
        chamsApplied[char] = nil
    end

    -- FullBright off
    if fullBrightEnabled then
        fullBrightEnabled = false
        Lighting.Ambient = Color3.new(0.5,0.5,0.5)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1000
    end

    createNotification("Visuales reseteados")
end)

----------------------------------------------------------
-- AJUSTES
----------------------------------------------------------
local setLabel = Instance.new("TextLabel")
setLabel.Size = UDim2.new(0.9, 0, 0, 28)
setLabel.BackgroundTransparency = 1
setLabel.Text = "Ajustes"
setLabel.TextColor3 = Color3.fromRGB(200,200,200)
setLabel.Font = Enum.Font.GothamBold
setLabel.TextSize = 16
setLabel.Parent = AjustesScroll

-- Slider de Opacidad
local opacityLabel = Instance.new("TextLabel")
opacityLabel.Size = UDim2.new(0.9, 0, 0, 24)
opacityLabel.BackgroundTransparency = 1
opacityLabel.Text = "Opacidad del HUB"
opacityLabel.TextColor3 = Color3.fromRGB(220,220,220)
opacityLabel.Font = Enum.Font.Gotham
opacityLabel.TextSize = 14
opacityLabel.Parent = AjustesScroll

local opacitySlider = Instance.new("Frame")
opacitySlider.Size = UDim2.new(0.9, 0, 0, 32)
opacitySlider.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
opacitySlider.Parent = AjustesScroll
Instance.new("UICorner", opacitySlider).CornerRadius = UDim.new(0, 8)

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0.8, 0, 0.3, 0)
sliderBar.Position = UDim2.new(0.1, 0, 0.35, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(100, 120, 180)
sliderBar.Parent = opacitySlider
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 4)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 12, 1.5, 0)
sliderKnob.Position = UDim2.new(0.25, -6, -0.25, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
sliderKnob.Parent = sliderBar
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local dragging = false
local minTransparency, maxTransparency = 0.2, 0.8
local function updateTransparency(xPos)
    local barAbsPos = sliderBar.AbsolutePosition.X
    local barAbsSize = sliderBar.AbsoluteSize.X
    local ratio = math.clamp((xPos - barAbsPos) / barAbsSize, 0, 1)
    sliderKnob.Position = UDim2.new(ratio, -6, -0.25, 0)
    local transparency = minTransparency + (maxTransparency - minTransparency) * ratio
    MainFrame.BackgroundTransparency = transparency
    TopBar.BackgroundTransparency = transparency
end

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

sliderKnob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateTransparency(input.Position.X)
    end
end)

-- Botón para cerrar HUB
createButton(AjustesScroll, "Cerrar HUB", function()
    closeHub()
    createNotification("HUB cerrado")
end)
----------------------------------------------------------
----------------------------------------------------------
-- KS HUB – Parte 4: Waypoints (versión final mejorada)
----------------------------------------------------------

-- Tabla de waypoints guardados
local savedWaypoints = {}

-- Función para refrescar la lista de waypoints en la UI
local function refreshWaypoints()
    -- Limpia la lista antes de regenerar
    for _, child in ipairs(WaypointsScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Genera un frame con botones TP y DEL por cada waypoint
    for name, pos in pairs(savedWaypoints) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundTransparency = 1
        frame.Parent = WaypointsScroll

        local btnTP = createButton(frame, "TP: " .. name, function()
            teleportToCFrame(CFrame.new(pos))
            createNotification("Teletransportado a '"..name.."'")
        end)
        btnTP.Size = UDim2.new(0.65, -3, 1, 0)
        btnTP.Position = UDim2.new(0, 0, 0, 0)

        local btnDel = Instance.new("TextButton")
        btnDel.Size = UDim2.new(0.3, 0, 1, 0)
        btnDel.Position = UDim2.new(0.7, 0, 0, 0)
        btnDel.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- rojo estilo cerrar
        btnDel.Text = "DEL"
        btnDel.TextColor3 = Color3.new(1,1,1)
        btnDel.Font = Enum.Font.GothamBold
        btnDel.TextSize = 14
        btnDel.Parent = frame
        Instance.new("UICorner", btnDel).CornerRadius = UDim.new(0, 6)

        btnDel.MouseButton1Click:Connect(function()
            savedWaypoints[name] = nil
            refreshWaypoints()
            createNotification("Waypoint '"..name.."' eliminado")
        end)
    end
end

-- Caja de texto para nombre de waypoint
local wpBox = Instance.new("TextBox")
wpBox.Size = UDim2.new(1, 0, 0, 30)
wpBox.PlaceholderText = "Nombre del Waypoint"
wpBox.Text = ""
wpBox.Font = Enum.Font.Gotham
wpBox.TextSize = 16
wpBox.TextColor3 = Color3.new(1, 1, 1)
wpBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
wpBox.BackgroundTransparency = 0.1
wpBox.BorderSizePixel = 0
wpBox.ClearTextOnFocus = false
wpBox.Parent = WaypointsScroll
Instance.new("UICorner", wpBox).CornerRadius = UDim.new(0, 6)

-- Botón para crear waypoint
createButton(WaypointsScroll, "Crear Waypoint", function()
    local hrp = getHRP()
    if hrp then
        local name = wpBox.Text ~= "" and wpBox.Text or ("WP"..tostring(#savedWaypoints+1))
        savedWaypoints[name] = hrp.Position
        wpBox.Text = ""
        refreshWaypoints()
        createNotification("Waypoint '"..name.."' creado")
    end
end)

-- Botón para borrar todos
local clearAllBtn = Instance.new("TextButton")
clearAllBtn.Size = UDim2.new(1, 0, 0, 30)
clearAllBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- rojo
clearAllBtn.Text = "Borrar TODOS los Waypoints"
clearAllBtn.TextColor3 = Color3.new(1,1,1)
clearAllBtn.Font = Enum.Font.GothamBold
clearAllBtn.TextSize = 14
clearAllBtn.Parent = WaypointsScroll
Instance.new("UICorner", clearAllBtn).CornerRadius = UDim.new(0, 6)

clearAllBtn.MouseButton1Click:Connect(function()
    savedWaypoints = {}
    refreshWaypoints()
    createNotification("Todos los waypoints borrados")
end)

-- Inicializar lista
refreshWaypoints()

print("[KS HUB] Parte 4 lista: Waypoints configurados")



----------------------------------------------------------
-- KS HUB – Parte 5: Visual
-- Incluye:
-- - ESP Jugadores (con nombre y color configurable)
-- - Selector de color ESP (Azul, Verde, Rojo, Blanco)
-- - ESP Items (máx. 50 más cercanos)
-- - Aura Collect universal (Touch, Click, Prompt) + notificaciones
-- - Mostrar Coordenadas
-- - Chams
-- - FullBright
-- - Desbloquear 3ra persona
-- - Desbloquear Zoom máximo
----------------------------------------------------------

----------------------------------------------------------
-- ESP Jugadores
----------------------------------------------------------
local espConnections = {}
local espColor = Color3.fromRGB(0, 170, 255) -- Azul por defecto

local function applyPlayerESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Highlight
    if not char:FindFirstChild("KSHUB_PlayerESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "KSHUB_PlayerESP"
        highlight.FillColor = espColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char
    else
        char.KSHUB_PlayerESP.FillColor = espColor
    end

    -- Nombre encima
    if not char:FindFirstChild("KSHUB_NameTag") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "KSHUB_NameTag"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char:FindFirstChild("Head") or hrp

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = plr.Name
        label.TextColor3 = espColor
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = billboard
    else
        char.KSHUB_NameTag.TextLabel.TextColor3 = espColor
    end
end

createToggleButton(VisualScroll, "ESP Jugadores", "espEnabled",
    function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then applyPlayerESP(plr) end
        end
        espConnections["Added"] = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(1)
                applyPlayerESP(plr)
            end)
        end)
        espConnections["CharAdded"] = {}
        for _, plr in pairs(Players:GetPlayers()) do
            espConnections["CharAdded"][plr] = plr.CharacterAdded:Connect(function()
                task.wait(1)
                applyPlayerESP(plr)
            end)
        end
        createNotification("ESP Jugadores ON")
    end,
    function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                if plr.Character:FindFirstChild("KSHUB_PlayerESP") then plr.Character.KSHUB_PlayerESP:Destroy() end
                if plr.Character:FindFirstChild("KSHUB_NameTag") then plr.Character.KSHUB_NameTag:Destroy() end
            end
        end
        for _, conn in pairs(espConnections) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect()
            elseif typeof(conn) == "table" then for _, c in pairs(conn) do c:Disconnect() end end
        end
        espConnections = {}
        createNotification("ESP Jugadores OFF")
    end
)

-- Selector de color
createButton(VisualScroll, "Color ESP Azul", function() espColor = Color3.fromRGB(0,170,255) end)
createButton(VisualScroll, "Color ESP Verde", function() espColor = Color3.fromRGB(0,255,0) end)
createButton(VisualScroll, "Color ESP Rojo", function() espColor = Color3.fromRGB(255,0,0) end)
createButton(VisualScroll, "Color ESP Blanco", function() espColor = Color3.fromRGB(255,255,255) end)

----------------------------------------------------------
-- ESP Items + Aura Collect
----------------------------------------------------------
local espItemConnection
local auraCollectConnection

local itemBox = Instance.new("TextBox")
itemBox.Size = UDim2.new(1, 0, 0, 30)
itemBox.PlaceholderText = "Nombre parcial del ítem (ej: Cookies)"
itemBox.Text = ""
itemBox.Font = Enum.Font.Gotham
itemBox.TextSize = 16
itemBox.TextColor3 = Color3.new(1, 1, 1)
itemBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemBox.BackgroundTransparency = 0.1
itemBox.BorderSizePixel = 0
itemBox.ClearTextOnFocus = false
itemBox.Parent = VisualScroll
Instance.new("UICorner", itemBox).CornerRadius = UDim.new(0, 6)

-- ESP Items
createToggleButton(VisualScroll, "ESP Items", "espItemsEnabled",
    function()
        local keyword = string.lower(itemBox.Text)
        if keyword == "" then warn("[KS HUB] Ingresa un nombre parcial") return end
        espItemConnection = RunService.RenderStepped:Connect(function()
            local hrp = getHRP()
            if not hrp then return end
            local candidates = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(string.lower(obj.Name), keyword) then
                    table.insert(candidates, obj)
                end
            end
            table.sort(candidates, function(a,b)
                return (a.Position-hrp.Position).Magnitude < (b.Position-hrp.Position).Magnitude
            end)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj:FindFirstChild("KSHUB_ItemESP") then obj.KSHUB_ItemESP:Destroy() end
            end
            for i=1, math.min(50,#candidates) do
                local obj = candidates[i]
                if not obj:FindFirstChild("KSHUB_ItemESP") then
                    local h = Instance.new("Highlight")
                    h.Name = "KSHUB_ItemESP"
                    h.FillColor = Color3.fromRGB(255,255,0)
                    h.OutlineColor = Color3.fromRGB(255,255,255)
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.Parent = obj
                end
            end
        end)
        createNotification("ESP Items ON (máx 50)")
    end,
    function()
        if espItemConnection then espItemConnection:Disconnect() espItemConnection=nil end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj:FindFirstChild("KSHUB_ItemESP") then obj.KSHUB_ItemESP:Destroy() end
        end
        createNotification("ESP Items OFF")
    end
)

-- Aura Collect universal
createToggleButton(VisualScroll, "Aura Collect", "auraCollectEnabled",
    function()
        local keyword = string.lower(itemBox.Text)
        if keyword == "" then warn("[KS HUB] Ingresa un nombre parcial") return end
        auraCollectConnection = RunService.Heartbeat:Connect(function()
            local hrp = getHRP()
            if not hrp then return end
            local collectedCount = 0
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(string.lower(obj.Name), keyword) then
                    local dist = (obj.Position-hrp.Position).Magnitude
                    if dist < 50 then
                        local touch = obj:FindFirstChildOfClass("TouchTransmitter")
                        if touch then firetouchinterest(hrp,obj,0) firetouchinterest(hrp,obj,1) collectedCount+=1 end
                        local click = obj:FindFirstChildOfClass("ClickDetector")
                        if click then fireclickdetector(click) collectedCount+=1 end
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt, math.huge) collectedCount+=1 end
                    end
                end
            end
            if collectedCount>0 then
                createNotification("+"..collectedCount.." "..itemBox.Text.." recogidos")
            end
        end)
        createNotification("Aura Collect ON")
    end,
    function()
        if auraCollectConnection then auraCollectConnection:Disconnect() auraCollectConnection=nil end
        createNotification("Aura Collect OFF")
    end
)

----------------------------------------------------------
-- Mostrar Coordenadas
----------------------------------------------------------
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(1, 0, 0, 24)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Font = Enum.Font.Gotham
coordsLabel.TextSize = 14
coordsLabel.Text = ""
coordsLabel.Visible = false
coordsLabel.Parent = VisualScroll

local coordsConnection
createToggleButton(VisualScroll, "Mostrar Coordenadas", "coordsEnabled",
    function()
        coordsLabel.Visible = true
        coordsConnection = RunService.RenderStepped:Connect(function()
            local hrp = getHRP()
            if hrp then
                local pos = hrp.Position
                coordsLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
            end
        end)
        createNotification("Coordenadas ON")
    end,
    function()
        coordsLabel.Visible = false
        coordsLabel.Text = ""
        if coordsConnection then coordsConnection:Disconnect() coordsConnection=nil end
        createNotification("Coordenadas OFF")
    end
)

----------------------------------------------------------
-- Chams (colorear personajes con Neon)
----------------------------------------------------------
local chamsConnection
createToggleButton(VisualScroll, "Chams", "chamsEnabled",
    function()
        chamsConnection = RunService.RenderStepped:Connect(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") and not part:FindFirstChild("KSHUB_Chams") then
                            local neon = Instance.new("BoxHandleAdornment")
                            neon.Name = "KSHUB_Chams"
                            neon.Size = part.Size + Vector3.new(0.1,0.1,0.1)
                            neon.Adornee = part
                            neon.AlwaysOnTop = true
                            neon.ZIndex = 5
                            neon.Color3 = Color3.fromRGB(0,255,255)
                            neon.Transparency = 0.5
                            neon.Parent = part
                        end
                    end
                end
            end
        end)
        createNotification("Chams ON")
    end,
    function()
        if chamsConnection then chamsConnection:Disconnect() chamsConnection=nil end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part:FindFirstChild("KSHUB_Chams") then
                        part.KSHUB_Chams:Destroy()
                    end
                end
            end
        end
        createNotification("Chams OFF")
    end
)

----------------------------------------------------------
-- FullBright
----------------------------------------------------------
local lightingBackup = {}
createToggleButton(VisualScroll, "FullBright", "fullBrightEnabled",
    function()
        lightingBackup.Ambient = Lighting.Ambient
        lightingBackup.Brightness = Lighting.Brightness
        lightingBackup.ClockTime = Lighting.ClockTime
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        createNotification("FullBright ON")
    end,
    function()
        if lightingBackup.Ambient then
            Lighting.Ambient = lightingBackup.Ambient
            Lighting.Brightness = lightingBackup.Brightness
            Lighting.ClockTime = lightingBackup.ClockTime
        end
        createNotification("FullBright OFF")
    end
)

----------------------------------------------------------
-- Desbloquear 3ra Persona
----------------------------------------------------------
createToggleButton(VisualScroll, "Desbloquear 3ra Persona", "thirdPersonUnlocked",
    function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        createNotification("3ra Persona desbloqueada")
    end,
    function()
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        createNotification("3ra Persona bloqueada")
    end
)

----------------------------------------------------------
-- Desbloquear Zoom Máximo
----------------------------------------------------------
local originalZoom = LocalPlayer.CameraMaxZoomDistance
createToggleButton(VisualScroll, "Desbloquear Zoom", "zoomUnlocked",
    function()
        originalZoom = LocalPlayer.CameraMaxZoomDistance
        LocalPlayer.CameraMaxZoomDistance = 1000
        createNotification("Zoom máximo desbloqueado")
    end,
    function()
        LocalPlayer.CameraMaxZoomDistance = originalZoom or 128
        createNotification("Zoom máximo restaurado")
    end
)

print("[KS HUB] Parte 5 lista: Visual configurado")


----------------------------------------------------------
-- KS HUB – Parte 6: Ajustes
-- Incluye:
-- - Reset Character
-- - Rejoin
-- - Toggle Anclar/Desanclar botón ≡
-- - Cerrar HUB completo
-- - Ajustar Opacidad Global
-- - Arrastrar HUB ON/OFF
-- - Selector de posición de notificaciones
----------------------------------------------------------

----------------------------------------------------------
-- Reset Character
----------------------------------------------------------
createButton(AjustesScroll, "Reset Character", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
        createNotification("Character reseteado")
    end
end)

----------------------------------------------------------
-- Rejoin
----------------------------------------------------------
createButton(AjustesScroll, "Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
    createNotification("Rejoin ejecutado")
end)

----------------------------------------------------------
-- Toggle Anclar/Desanclar Botón de abrir
----------------------------------------------------------
createButton(AjustesScroll, "Toggle Anclar Botón Abrir", function()
    anchored = not anchored
    if anchored then
        ToggleButton.Position = initialPosition
        createNotification("📌 Botón de abrir ANCLADO")
    else
        createNotification("📌 Botón de abrir DESANCLADO")
    end
end)

----------------------------------------------------------
-- Cerrar HUB por completo
----------------------------------------------------------
createButton(AjustesScroll, "Cerrar HUB", function()
    if noclipConnection then noclipConnection:Disconnect() end
    if antiDelayConnection then antiDelayConnection:Disconnect() end
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
    if espItemConnection then espItemConnection:Disconnect() end
    if auraCollectConnection then auraCollectConnection:Disconnect() end
    if coordsConnection then coordsConnection:Disconnect() end
    if chamsConnection then chamsConnection:Disconnect() end
    for _, conn in pairs(espConnections or {}) do
        if typeof(conn)=="RBXScriptConnection" then conn:Disconnect()
        elseif typeof(conn)=="table" then for _,c in pairs(conn) do c:Disconnect() end end
    end

    _G.noclipEnabled = false
    _G.antiDelayEnabled = false
    _G.infiniteJumpEnabled = false
    _G.espEnabled = false
    _G.chamsEnabled = false
    _G.fullBrightEnabled = false
    _G.espItemsEnabled = false
    _G.coordsEnabled = false
    _G.auraCollectEnabled = false
    _G.dragHubEnabled = false

    if ScreenGui then ScreenGui:Destroy() end
    print("[KS HUB] HUB cerrado completamente")
end)

----------------------------------------------------------
-- Ajustar Opacidad Global
----------------------------------------------------------
local opacityBox = Instance.new("TextBox")
opacityBox.Size = UDim2.new(1, 0, 0, 30)
opacityBox.PlaceholderText = "Opacidad (0 = invisible, 1 = sólido)"
opacityBox.Text = ""
opacityBox.Font = Enum.Font.Gotham
opacityBox.TextSize = 16
opacityBox.TextColor3 = Color3.new(1, 1, 1)
opacityBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
opacityBox.BackgroundTransparency = 0.1
opacityBox.BorderSizePixel = 0
opacityBox.ClearTextOnFocus = false
opacityBox.Parent = AjustesScroll
Instance.new("UICorner", opacityBox).CornerRadius = UDim.new(0, 6)

opacityBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(opacityBox.Text)
        if val and val >= 0 and val <= 1 then
            setGlobalOpacity(val)
            createNotification("Opacidad global: "..val)
        else
            warn("[KS HUB] Ingresa un valor entre 0 y 1")
        end
    end
end)

----------------------------------------------------------
-- Arrastrar HUB ON/OFF
----------------------------------------------------------
createToggleButton(AjustesScroll, "Arrastrar HUB", "dragHubEnabled", onDragHub, offDragHub)

----------------------------------------------------------
-- Selector de posición de notificaciones
----------------------------------------------------------
local notifyPosition = "BottomRight"

local function updateNotifyPosition()
    if notifyPosition == "BottomRight" then
        notifyFrame.Position = UDim2.new(1, -310, 1, -210)
        notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    elseif notifyPosition == "BottomLeft" then
        notifyFrame.Position = UDim2.new(0, 10, 1, -210)
        notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    elseif notifyPosition == "TopRight" then
        notifyFrame.Position = UDim2.new(1, -310, 0, 10)
        notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    elseif notifyPosition == "TopLeft" then
        notifyFrame.Position = UDim2.new(0, 10, 0, 10)
        notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    end
end

createButton(AjustesScroll, "Notificaciones: Abajo Derecha", function()
    notifyPosition = "BottomRight"
    updateNotifyPosition()
    createNotification("📍 Notificaciones en Abajo Derecha")
end)
createButton(AjustesScroll, "Notificaciones: Abajo Izquierda", function()
    notifyPosition = "BottomLeft"
    updateNotifyPosition()
    createNotification("📍 Notificaciones en Abajo Izquierda")
end)
createButton(AjustesScroll, "Notificaciones: Arriba Derecha", function()
    notifyPosition = "TopRight"
    updateNotifyPosition()
    createNotification("📍 Notificaciones en Arriba Derecha")
end)
createButton(AjustesScroll, "Notificaciones: Arriba Izquierda", function()
    notifyPosition = "TopLeft"
    updateNotifyPosition()
    createNotification("📍 Notificaciones en Arriba Izquierda")
end)

updateNotifyPosition()

print("[KS HUB] Parte 6 lista: Ajustes configurados")



----------------------------------------------------------
-- KS HUB – Parte 7: Extras de Gameplay
-- Incluye:
-- - Placeholders para futuras expansiones
-- - Ejemplos de utilidades adicionales
-- - Sistema modular para añadir más funciones sin romper lo existente
----------------------------------------------------------

----------------------------------------------------------
-- Placeholder: Auto Respawn
-- (ejemplo de cómo podrías implementar en el futuro)
----------------------------------------------------------
local autoRespawnConnection
createToggleButton(MainScroll, "Auto Respawn", "autoRespawnEnabled",
    function()
        autoRespawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            createNotification("Respawneaste automáticamente")
        end)
        createNotification("Auto Respawn ON")
    end,
    function()
        if autoRespawnConnection then autoRespawnConnection:Disconnect() autoRespawnConnection=nil end
        createNotification("Auto Respawn OFF")
    end
)

----------------------------------------------------------
-- Placeholder: Auto Farm básico
-- (ejemplo de estructura, sin lógica específica)
----------------------------------------------------------
createToggleButton(MainScroll, "Auto Farm (placeholder)", "autoFarmEnabled",
    function()
        -- Aquí podrías poner lógica de auto farm
        createNotification("Auto Farm ON (placeholder)")
    end,
    function()
        createNotification("Auto Farm OFF (placeholder)")
    end
)

----------------------------------------------------------
-- Placeholder: Mini Mapa
-- (estructura inicial para un minimapa en el futuro)
----------------------------------------------------------
local miniMapFrame = Instance.new("Frame")
miniMapFrame.Size = UDim2.new(0, 200, 0, 200)
miniMapFrame.Position = UDim2.new(1, -220, 0, 50)
miniMapFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
miniMapFrame.BackgroundTransparency = 0.2
miniMapFrame.Visible = false
miniMapFrame.Parent = ScreenGui
Instance.new("UICorner", miniMapFrame).CornerRadius = UDim.new(0, 8)

createToggleButton(MainScroll, "Mini Mapa (placeholder)", "miniMapEnabled",
    function()
        miniMapFrame.Visible = true
        createNotification("Mini Mapa ON (placeholder)")
    end,
    function()
        miniMapFrame.Visible = false
        createNotification("Mini Mapa OFF (placeholder)")
    end
)

----------------------------------------------------------
-- Placeholder: Auto Collect Coins
-- (ejemplo de cómo podrías extender Aura Collect a monedas)
----------------------------------------------------------
createToggleButton(MainScroll, "Auto Collect Coins (placeholder)", "autoCoinsEnabled",
    function()
        createNotification("Auto Collect Coins ON (placeholder)")
    end,
    function()
        createNotification("Auto Collect Coins OFF (placeholder)")
    end
)

print("[KS HUB] Parte 7 lista: Extras de Gameplay configurados")




----------------------------------------------------------
-- KS HUB – Parte 8: Depuración, Seguridad y Limpieza
-- Incluye:
-- - Manejo de errores global (pcall seguro)
-- - Limpieza de conexiones al cerrar HUB
-- - Reconexión de CharacterAdded y HumanoidRootPart
-- - Mensajes de estado en consola
----------------------------------------------------------

----------------------------------------------------------
-- Función segura para ejecutar callbacks
----------------------------------------------------------
local function safeCall(name, func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        warn("[KS HUB] Error en "..name..": "..tostring(err))
    end
end

----------------------------------------------------------
-- Limpieza de conexiones
----------------------------------------------------------
local allConnections = {}

local function trackConnection(conn)
    table.insert(allConnections, conn)
    return conn
end

local function disconnectAll()
    for _, conn in ipairs(allConnections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    allConnections = {}
end

----------------------------------------------------------
-- Reconexión de CharacterAdded
----------------------------------------------------------
trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    createNotification("Nuevo Character cargado")
    if _G.noclipEnabled then onNoclip() end
    if _G.antiDelayEnabled then onAntiDelay() end
    if _G.infiniteJumpEnabled then onInfiniteJump() end
end))

----------------------------------------------------------
-- Seguridad: prevenir múltiples ScreenGui duplicados
----------------------------------------------------------
for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name == "KSHubGui" and gui ~= ScreenGui then
        gui:Destroy()
        warn("[KS HUB] ScreenGui duplicado eliminado")
    end
end

----------------------------------------------------------
-- Seguridad: prevenir múltiples conexiones de ESP
----------------------------------------------------------
local function clearESPArtifacts()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and (obj.Name=="KSHUB_PlayerESP" or obj.Name=="KSHUB_ItemESP") then
            obj:Destroy()
        end
        if obj:IsA("BillboardGui") and obj.Name=="KSHUB_NameTag" then
            obj:Destroy()
        end
        if obj:IsA("BoxHandleAdornment") and obj.Name=="KSHUB_Chams" then
            obj:Destroy()
        end
    end
end

----------------------------------------------------------
-- Seguridad: limpiar al cerrar HUB
----------------------------------------------------------
local function fullCleanup()
    disconnectAll()
    clearESPArtifacts()
    if ScreenGui then ScreenGui:Destroy() end
    print("[KS HUB] Limpieza completa ejecutada")
end

-- Puedes llamar a fullCleanup() desde Ajustes -> Cerrar HUB
-- ya está integrado en Parte 6

----------------------------------------------------------
-- Mensajes de estado
----------------------------------------------------------
print("[KS HUB] Parte 8 lista: Depuración y seguridad configuradas")




----------------------------------------------------------
-- KS HUB – Parte 9: Inicialización Final y Wrap-Up
-- Incluye:
-- - Mensaje de bienvenida
-- - Confirmación de carga de todas las partes
-- - Recordatorio de expansiones futuras
-- - Estado inicial de toggles
----------------------------------------------------------

----------------------------------------------------------
-- Mensaje de bienvenida
----------------------------------------------------------
createNotification("⚡ KS HUB cargado con éxito")
print("========================================")
print("      KS HUB – Script Completo Listo     ")
print("========================================")
print("Todas las 9 partes han sido inicializadas correctamente.")
print("Puedes navegar entre pestañas: Main, Teleport, Waypoints, Visual, Ajustes.")
print("Funciones activas: ESP, Aura Collect, Chams, FullBright, Zoom, etc.")
print("========================================")

----------------------------------------------------------
-- Estado inicial de toggles
----------------------------------------------------------
_G.noclipEnabled = false
_G.antiDelayEnabled = false
_G.infiniteJumpEnabled = false
_G.espEnabled = false
_G.chamsEnabled = false
_G.fullBrightEnabled = false
_G.espItemsEnabled = false
_G.coordsEnabled = false
_G.auraCollectEnabled = false
_G.dragHubEnabled = false

----------------------------------------------------------
-- Recordatorio de expansiones futuras
----------------------------------------------------------
-- Parte 7 dejó placeholders para:
-- - Auto Respawn
-- - Auto Farm
-- - Mini Mapa
-- - Auto Collect Coins
-- Puedes implementar la lógica específica de cada juego
-- sin necesidad de modificar la estructura base del HUB.

----------------------------------------------------------
-- Wrap-Up
----------------------------------------------------------
print("[KS HUB] Wrap-Up completo. El HUB está listo para usarse.")
print("[KS HUB] Usa el botón ≡ para abrir/cerrar el HUB.")
print("[KS HUB] Ajusta opacidad, arrastre y posición de notificaciones en Ajustes.")
print("[KS HUB] ¡Disfruta de tu experiencia con KS HUB!")
