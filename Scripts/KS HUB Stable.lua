----------------------------------------------------------
-- Parte 1: Servicios, estados globales y utilidades
----------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Sonidos (IDs configurables)
local CLICK_SOUND_ID = "rbxassetid://6723721422"
local OPEN_CLOSE_SOUND_ID = "rbxassetid://9118823106"
local CLOSE_CLICK_SOUND_ID = "rbxassetid://9118823106"

-- Estados globales
_G.noclipEnabled = false
_G.antiDelayEnabled = false
_G.infiniteJumpEnabled = false
_G.espEnabled = false
_G.chamsEnabled = false
_G.fullBrightEnabled = false
_G.espItemsEnabled = false
_G.coordsEnabled = false
_G.auraCollectEnabled = false
_G.dragHubEnabled = true

-- Utilidades
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportToCFrame(cf)
    local hrp = getHRP()
    if hrp then hrp.CFrame = cf end
end

local function createNotification(msg)
    print("[KS HUB] " .. msg)
end

----------------------------------------------------------
-- Parte 2: ScreenGui, MainFrame, TopBar, Toggle flotante
----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 420)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 46)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
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
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 36, 0, 28)
CloseButton.Position = UDim2.new(1, -46, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
CloseButton.BackgroundTransparency = 0.1
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Sonidos
local openCloseSound = Instance.new("Sound")
openCloseSound.SoundId = OPEN_CLOSE_SOUND_ID
openCloseSound.Volume = 0.75
openCloseSound.Parent = MainFrame

local closeClickSound = Instance.new("Sound")
closeClickSound.SoundId = CLOSE_CLICK_SOUND_ID
closeClickSound.Volume = 0.75
closeClickSound.Parent = CloseButton

-- Toggle flotante ≡
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 42, 0, 42)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -21)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
ToggleButton.BackgroundTransparency = 0.15
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = OPEN_CLOSE_SOUND_ID
toggleSound.Volume = 0.75
toggleSound.Parent = ToggleButton

-- Animaciones
local function openHub()
    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 1
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.25,
        Position = UDim2.new(0.5, -210, 0.5, -160)
    }):Play()
end

local function closeHub()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 600, 0.5, -160),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        MainFrame.Visible = false
        MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    end)
end

-- Acciones
CloseButton.MouseButton1Click:Connect(function()
    closeClickSound:Play()
    closeHub()
end)

ToggleButton.MouseButton1Click:Connect(function()
    if not MainFrame.Visible then openHub() else closeHub() end
    toggleSound:Play()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if not MainFrame.Visible then openHub() else closeHub() end
        openCloseSound:Play()
    end
end)


----------------------------------------------------------
-- Parte 3: Sidebar vertical, páginas y helpers (mejorada)
----------------------------------------------------------
local TabsBar = Instance.new("Frame")
TabsBar.Name = "TabsBar"
TabsBar.Size = UDim2.new(0, 118, 1, -40)
TabsBar.Position = UDim2.new(0, 6, 0, 40)
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

local TabsContent = Instance.new("Frame")
TabsContent.Name = "TabsContent"
TabsContent.Size = UDim2.new(1, -130, 1, -50)
TabsContent.Position = UDim2.new(0, 130, 0, 45)
TabsContent.BackgroundTransparency = 1
TabsContent.Parent = MainFrame

----------------------------------------------------------
-- Helpers
----------------------------------------------------------
-- Botón genérico con callback
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    -- Hover feedback
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 70, 120)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    end)

    btn.MouseButton1Click:Connect(function()
        local s = Instance.new("Sound")
        s.SoundId = CLICK_SOUND_ID
        s.Volume = 0.7
        s.Parent = btn
        s:Play()
        callback()
        s:Destroy()
    end)
    return btn
end

-- Subtítulo dentro de pestañas
local function createSectionLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "» " .. text
    lbl.TextColor3 = Color3.fromRGB(180, 200, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Scroll automático para cada pestaña
local function attachScrolling(parentFrame)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 160, 220)
    scroll.BackgroundTransparency = 1
    scroll.Parent = parentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent = scroll

    return scroll
end

----------------------------------------------------------
-- Tabs dinámicos
----------------------------------------------------------
local tabsList = {"Main","Teleport","Waypoints","Visual","Ajustes"}
local Tabs = {}
local Scrolls = {}
local TabButtons = {}

-- Cambiar de pestaña
local function switchTab(tabName)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
        if TabButtons[name] then
            TabButtons[name].BackgroundColor3 = (name == tabName)
                and Color3.fromRGB(50, 90, 150)
                or Color3.fromRGB(30, 50, 80)
        end
    end
end

-- Crear pestañas
for _, name in ipairs(tabsList) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -10, 0, 30)
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

    Scrolls[name] = attachScrolling(page)
    TabButtons[name] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- Activar pestaña inicial
switchTab("Main")



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
-- Parte 5: Teleport a jugadores
----------------------------------------------------------
local TeleportScroll = Scrolls["Teleport"]

-- Refrescar lista de jugadores
local function refreshPlayers()
    -- Limpia botones previos
    for _, child in ipairs(TeleportScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Crea un botón por cada jugador
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createButton(TeleportScroll, "TP a " .. plr.Name, function()
                local targetChar = plr.Character or plr.CharacterAdded:Wait()
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    teleportToCFrame(targetHRP.CFrame)
                    createNotification("Teletransportado a " .. plr.Name)
                else
                    warn("[KS HUB] El jugador " .. plr.Name .. " no tiene HumanoidRootPart")
                end
            end)
        end
    end
end

-- Eventos para actualizar lista
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- Inicializar lista
refreshPlayers()



----------------------------------------------------------
-- Parte 6: Waypoints (actualizado)
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

)



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
-- Parte 8: Ajustes (opacidad con slider, drag, reset, etc.)
----------------------------------------------------------
local AjustesScroll = Scrolls["Ajustes"]

----------------------------------------------------------
-- Sección: Apariencia
----------------------------------------------------------
createSectionLabel(AjustesScroll, "Apariencia")

-- Slider de Opacidad
local opacityFrame = Instance.new("Frame")
opacityFrame.Size = UDim2.new(1, 0, 0, 40)
opacityFrame.BackgroundTransparency = 1
opacityFrame.Parent = AjustesScroll

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, -20, 0, 6)
sliderBar.Position = UDim2.new(0, 10, 0.5, -3)
sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = opacityFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.85, 0, 1, 0) -- valor inicial 0.85
sliderFill.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 14, 0, 14)
sliderBtn.Position = UDim2.new(0.85, -7, 0.5, -7)
sliderBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
sliderBtn.Text = ""
sliderBtn.Parent = sliderBar
Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

local opacityValue = 0.85

-- Función para aplicar opacidad global
local function setGlobalOpacity(alpha)
    alpha = math.clamp(alpha, 0.1, 1) -- mínimo 0.1
    opacityValue = alpha
    local function applyTransparency(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("TextLabel") then
            local bgTrans = 1 - alpha
            if bgTrans < 0.1 then bgTrans = 0.1 end
            obj.BackgroundTransparency = bgTrans
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local txtTrans = 1 - alpha
                if txtTrans < 0.2 then txtTrans = 0.2 end
                obj.TextTransparency = txtTrans
            end
        end
        for _, child in ipairs(obj:GetChildren()) do
            applyTransparency(child)
        end
    end
    applyTransparency(MainFrame)
    applyTransparency(ToggleButton)
end

-- Drag del slider
local draggingSlider = false
sliderBtn.MouseButton1Down:Connect(function()
    draggingSlider = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0.1, 1)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        sliderBtn.Position = UDim2.new(relX, -7, 0.5, -7)
        setGlobalOpacity(relX)
    end
end)

----------------------------------------------------------
-- Sección: Comportamiento
----------------------------------------------------------
createSectionLabel(AjustesScroll, "Comportamiento")

-- Toggle Drag HUB
createButton(AjustesScroll, "Toggle Drag HUB", function()
    _G.dragHubEnabled = not _G.dragHubEnabled
    createNotification("Drag HUB: " .. (_G.dragHubEnabled and "ON" or "OFF"))
end)

----------------------------------------------------------
-- Sección: Auto Collect
----------------------------------------------------------
createSectionLabel(AjustesScroll, "Auto Collect")

local nameFilterBox = Instance.new("TextBox")
nameFilterBox.Size = UDim2.new(1, 0, 0, 30)
nameFilterBox.PlaceholderText = "Filtro nombre (ej: coin, gem, star)"
nameFilterBox.Text = "coin"
nameFilterBox.Font = Enum.Font.Gotham
nameFilterBox.TextSize = 14
nameFilterBox.TextColor3 = Color3.new(1,1,1)
nameFilterBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
nameFilterBox.BackgroundTransparency = 0.1
nameFilterBox.BorderSizePixel = 0
nameFilterBox.ClearTextOnFocus = false
nameFilterBox.Parent = AjustesScroll
Instance.new("UICorner", nameFilterBox).CornerRadius = UDim.new(0, 6)

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.PlaceholderText = "Radio de recogida (ej: 50)"
radiusBox.Text = "50"
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 14
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusBox.BackgroundTransparency = 0.1
radiusBox.BorderSizePixel = 0
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = AjustesScroll
Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 6)

createButton(AjustesScroll, "Aplicar Auto Collect", function()
    local nf = nameFilterBox.Text ~= "" and string.lower(nameFilterBox.Text) or "coin"
    local r = tonumber(radiusBox.Text) or 50
    collectNameFilter = nf
    collectRadius = math.max(10, r) -- mínimo 10 studs
    createNotification("AutoCollect: filtro '"..nf.."', radio "..tostring(collectRadius))
end)

----------------------------------------------------------
-- Sección: Reset
----------------------------------------------------------
createSectionLabel(AjustesScroll, "Reset")

createButton(AjustesScroll, "Restaurar Configuración", function()
    -- Reset a valores por defecto
    setGlobalOpacity(0.85)
    sliderFill.Size = UDim2.new(0.85, 0, 1, 0)
    sliderBtn.Position = UDim2.new(0.85, -7, 0.5, -7)
    _G.dragHubEnabled = true
    collectNameFilter = "coin"
    collectRadius = 50
    nameFilterBox.Text = "coin"
    radiusBox.Text = "50"
    createNotification("Configuración restaurada a valores por defecto")
end)
    ----------------------------------------------------------
-- Parte 9: QoL, limpieza y arranque inicial
----------------------------------------------------------

-- Al iniciar, abrimos el HUB y dejamos la pestaña Main activa
openHub()
switchTab("Main")

-- Reset de estados al respawnear (opcional)
LocalPlayer.CharacterAdded:Connect(function()
    -- Aquí puedes resetear flags si lo deseas
    _G.noclipEnabled = false
    _G.antiDelayEnabled = false
    _G.infiniteJumpEnabled = false
    _G.espEnabled = false
    _G.chamsEnabled = false
    _G.fullBrightEnabled = false
    _G.espItemsEnabled = false
    _G.coordsEnabled = false
    _G.auraCollectEnabled = false
    createNotification("Personaje respawneado, estados reseteados")
end)

-- Mensaje de confirmación en consola
print("[KS HUB] Inicializado correctamente: UI compacta, sidebar vertical, animaciones, sonidos y módulos listos.")
