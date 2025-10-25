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
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
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
-- Parte 4: MAIN (refactorizado y mejorado)
----------------------------------------------------------
local MainScroll = Scrolls["Main"]

----------------------------------------------------------
-- 1. Farm (Auto Touch/Click) - antes AntiDelay
----------------------------------------------------------
local farmConn
createButton(MainScroll, "Farm (Auto Touch/Click)", function()
    if farmConn then
        farmConn:Disconnect()
        farmConn = nil
        createNotification("Farm OFF")
        return
    end

    farmConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        if not hrp then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                -- Detecta objetos con TouchTransmitter
                if obj:FindFirstChildOfClass("TouchTransmitter") then
                    firetouchinterest(hrp, obj, 0)
                    firetouchinterest(hrp, obj, 1)
                end
                -- Detecta objetos clickeables
                local click = obj:FindFirstChildOfClass("ClickDetector")
                if click then fireclickdetector(click) end
            end
        end
    end)

    createNotification("Farm ON (Touch + Click)")
end)

----------------------------------------------------------
-- 2. Quick Interact - nuevo
----------------------------------------------------------
createButton(MainScroll, "Quick Interact (ProximityPrompt)", function()
    local hrp = getHRP()
    if not hrp then return end

    local closestPrompt, closestDist
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local dist = (obj.Parent.Position - hrp.Position).Magnitude
            if not closestDist or dist < closestDist then
                closestPrompt = obj
                closestDist = dist
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
-- 4. Infinite Jump
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
-- 5. Mostrar Coordenadas
----------------------------------------------------------
createButton(MainScroll, "Mostrar Coordenadas (print)", function()
    local hrp = getHRP()
    if hrp then
        print(string.format("[KS HUB] Pos: (%.1f, %.1f, %.1f)", hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
        createNotification("Coordenadas en consola")
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

    ----------------------------------------------------------
-- Parte 7: Visual + Auto Collect (AntiDelay integrado)
----------------------------------------------------------
local VisualScroll = Scrolls["Visual"]

-- FullBright (toggle)
createButton(VisualScroll, "Full Bright (toggle)", function()
    _G.fullBrightEnabled = not _G.fullBrightEnabled
    if _G.fullBrightEnabled then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Brightness = 4
        createNotification("FullBright ON")
    else
        -- Restaurar valores por defecto (ajústalos según el juego)
        Lighting.Ambient = Color3.new(0.5,0.5,0.5)
        Lighting.Brightness = 2
        createNotification("FullBright OFF")
    end
end)

-- Auto Collect universal con AntiDelay Touch interno
local autoCollectConn
-- Configuración inicial (puede modificarse en Ajustes)
collectNameFilter = "coin"
collectRadius = 50

createButton(VisualScroll, "Auto Collect (toggle)", function()
    if autoCollectConn then
        autoCollectConn:Disconnect()
        autoCollectConn = nil
        createNotification("Auto Collect OFF")
        return
    end

    autoCollectConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        if not hrp then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), collectNameFilter) then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < collectRadius then
                    -- AntiDelay integrado: fuerza el touch sin cooldown
                    local touch = obj:FindFirstChildOfClass("TouchTransmitter")
                    if touch then
                        firetouchinterest(hrp, obj, 0)
                        firetouchinterest(hrp, obj, 1)
                    end
                    local click = obj:FindFirstChildOfClass("ClickDetector")
                    if click then fireclickdetector(click) end
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt, math.huge) end
                end
            end
        end
    end)

    createNotification("Auto Collect ON")
end)



    ----------------------------------------------------------
-- Parte 8: Ajustes (opacidad, drag y Auto Collect config)
----------------------------------------------------------
local AjustesScroll = Scrolls["Ajustes"]

-- Control de Opacidad Global (con mínimos)
local function setGlobalOpacity(alpha)
    -- alpha = 0 (transparente) → 1 (opaco)
    local function applyTransparency(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("TextLabel") then
            -- Fondo: mínimo 0.1
            local bgTrans = 1 - alpha
            if bgTrans < 0.1 then bgTrans = 0.1 end
            obj.BackgroundTransparency = bgTrans

            -- Texto: mínimo 0.2
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

-- Caja de texto para opacidad
local opacityBox = Instance.new("TextBox")
opacityBox.Size = UDim2.new(1, 0, 0, 30)
opacityBox.PlaceholderText = "Opacidad 0.0–1.0 (mín: fondos 0.1, texto 0.2)"
opacityBox.Text = "0.85"
opacityBox.Font = Enum.Font.Gotham
opacityBox.TextSize = 14
opacityBox.TextColor3 = Color3.new(1,1,1)
opacityBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
opacityBox.BackgroundTransparency = 0.1
opacityBox.BorderSizePixel = 0
opacityBox.ClearTextOnFocus = false
opacityBox.Parent = AjustesScroll
Instance.new("UICorner", opacityBox).CornerRadius = UDim.new(0, 6)

createButton(AjustesScroll, "Aplicar Opacidad", function()
    local v = tonumber(opacityBox.Text)
    if v then
        setGlobalOpacity(math.clamp(v, 0, 1))
        createNotification("Opacidad aplicada: "..tostring(v))
    else
        createNotification("Valor inválido")
    end
end)

-- Drag del HUB (arrastrar desde TopBar)
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and _G.dragHubEnabled then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Configuración de Auto Collect
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
    collectRadius = r
    createNotification("AutoCollect: filtro '"..nf.."', radio "..tostring(r))
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
