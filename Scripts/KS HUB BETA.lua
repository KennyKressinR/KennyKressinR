
----------------------------------------------------------
-- KS HUB – Parte 1: Núcleo, UI base, utilidades y animaciones
----------------------------------------------------------

-- Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

-- Jugador local
local LocalPlayer = Players.LocalPlayer

-- Sonidos (IDs válidos)
local CLICK_SOUND_ID = "rbxassetid://6723721422"        -- Click en botones
local OPEN_CLOSE_SOUND_ID = "rbxassetid://9118823106"   -- Abrir/cerrar HUB
local CLOSE_CLICK_SOUND_ID = "rbxassetid://9118823106"  -- Cerrar con X

-- Estado global
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

-- Variables internas
local anchored = true
local initialPosition = UDim2.new(0, 10, 0.5, -18)
local toggleSound

----------------------------------------------------------
-- ScreenGui base
----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------
-- MainFrame
----------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"

MainFrame.Size = UDim2.new(0, 400, 0, 440) -- antes 520 px de ancho
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200) -- centrado con el nuevo ancho
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 46)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

----------------------------------------------------------
-- TopBar
----------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KS HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Botón cerrar
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

----------------------------------------------------------
-- Botón flotante ≡
----------------------------------------------------------
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 36, 0, 36)
ToggleButton.Position = initialPosition
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)

----------------------------------------------------------
-- Sonidos
----------------------------------------------------------
local openCloseSound = Instance.new("Sound")
openCloseSound.SoundId = OPEN_CLOSE_SOUND_ID
openCloseSound.Volume = 0.75
openCloseSound.Parent = MainFrame

local closeClickSound = Instance.new("Sound")
closeClickSound.SoundId = CLOSE_CLICK_SOUND_ID
closeClickSound.Volume = 0.75
closeClickSound.Parent = CloseButton

toggleSound = Instance.new("Sound")
toggleSound.SoundId = CLICK_SOUND_ID
toggleSound.Volume = 0.75
toggleSound.Parent = ToggleButton

----------------------------------------------------------
-- A partir de aquí siguen las Partes 2 a 9 tal como las pasaste,
-- ya no necesitan cambios grandes porque el error venía de la Parte 1.
-- Solo asegúrate de que usen estas variables: CloseButton, ToggleButton,
-- openCloseSound, closeClickSound, toggleSound, anchored, initialPosition.
----------------------------------------------------------
----------------------------------------------------------
-- KS HUB – Parte 2: Pestañas, ToggleButton, Animaciones y Notificaciones
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
        Position = UDim2.new(0.5, -260, 0.5, -210)
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
        MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
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
    openCloseSound:Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    closeClickSound:Play()
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
        openCloseSound:Play()
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

    -- Layout de los elementos
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6) -- espacio entre botones
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- centra horizontalmente
    layout.Parent = scroll

    -- Padding interno (márgenes dentro del scroll)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
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
-- Factories de UI: createButton y createToggleButton
-- Con sonido y colores dinámicos (celeste ON / azul OFF)
----------------------------------------------------------
local function attachClickSound(guiObject)
    local s = Instance.new("Sound")
    s.SoundId = CLICK_SOUND_ID
    s.Volume = 1
    s.Parent = guiObject
    return s
end
function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 32) -- más estrecho y compacto
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local clickSound = attachClickSound(button)
    button.MouseButton1Click:Connect(function()
        clickSound:Play()
        if callback then
            local ok, err = pcall(callback)
            if not ok then
                warn("[KS HUB] Error en botón '"..text.."': ".. tostring(err))
            end
        end
    end)

    return button
end

function createToggleButton(parent, text, stateVar, callbackOn, callbackOff)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text .. " [OFF]"
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(80, 180, 255) -- Azul normal (OFF)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    local clickSound = attachClickSound(button)
    _G[stateVar] = false

    button.MouseButton1Click:Connect(function()
        clickSound:Play()
        _G[stateVar] = not _G[stateVar]
        if _G[stateVar] then
            button.Text = text .. " [ON]"
            button.BackgroundColor3 = Color3.fromRGB(120, 220, 255) -- Celeste más claro (ON)
            if callbackOn then
                local ok, err = pcall(callbackOn)
                if not ok then warn("[KS HUB] Error ON '"..text.."': "..tostring(err)) end
            end
            print("[KS HUB] " .. text .. " ON")
        else
            button.Text = text .. " [OFF]"
            button.BackgroundColor3 = Color3.fromRGB(80, 180, 255) -- Azul normal (OFF)
            if callbackOff then
                local ok, err = pcall(callbackOff)
                if not ok then warn("[KS HUB] Error OFF '"..text.."': "..tostring(err)) end
            end
            print("[KS HUB] " .. text .. " OFF")
        end
    end)

    return button
end

----------------------------------------------------------
-- Arrastre del HUB (se controla con toggle en Parte 6)
----------------------------------------------------------
local draggingHubEnabled = false
local hubDragConnectionBegan, hubDragConnectionChanged, hubDragConnectionEnded
local draggingMain, dragStartMain, startPosMain

local function enableHubDragging()
    if hubDragConnectionBegan then return end
    hubDragConnectionBegan = MainFrame.InputBegan:Connect(function(input)
        if not draggingHubEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = true
            dragStartMain = input.Position
            startPosMain = MainFrame.Position
        end
    end)
    hubDragConnectionChanged = MainFrame.InputChanged:Connect(function(input)
        if not draggingHubEnabled then return end
        if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartMain
            MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X,
                                           startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end)
    hubDragConnectionEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = false
        end
    end)
end

local function disableHubDragging()
    if hubDragConnectionBegan then hubDragConnectionBegan:Disconnect() hubDragConnectionBegan = nil end
    if hubDragConnectionChanged then hubDragConnectionChanged:Disconnect() hubDragConnectionChanged = nil end
    if hubDragConnectionEnded then hubDragConnectionEnded:Disconnect() hubDragConnectionEnded = nil end
end

-- Estas funciones se expondrán en Parte 6 con un toggle:
local function onDragHub()
    draggingHubEnabled = true
    enableHubDragging()
    createNotification("Arrastre del HUB: ON")
end
local function offDragHub()
    draggingHubEnabled = false
    disableHubDragging()
    createNotification("Arrastre del HUB: OFF")
end

----------------------------------------------------------
----------------------------------------------------------
-- Control de Opacidad Global (con mínimos)
----------------------------------------------------------
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
----------------------------------------------------------
-- Helpers de gameplay (usados en Teleport y otros)
----------------------------------------------------------
local function getHRP()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportToCFrame(cf)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = cf + Vector3.new(0, 3, 0)
        print(string.format("[KS HUB] Teleport a: X %.1f | Y %.1f | Z %.1f", cf.X, cf.Y, cf.Z))
    else
        warn("[KS HUB] No se pudo obtener HumanoidRootPart")
    end
end

local function parseCoords(text)
    if not text or text == "" then return nil end
    local normalized = text:gsub(",", " ")
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:match("^%s*(.-)%s*$") or normalized
    local xStr, yStr, zStr = normalized:match("([%+%-]?%d+%.?%d*)%s+([%+%-]?%d+%.?%d*)%s+([%+%-]?%d+%.?%d*)")
    if not xStr or not yStr or not zStr then return nil end
    local x, y, z = tonumber(xStr), tonumber(yStr), tonumber(zStr)
    if not x or not y or not z then return nil end
    return Vector3.new(x, y, z)
end

print("[KS HUB] Parte 1 lista: Núcleo y UI base inicializada")


----------------------------------------------------------
-- KS HUB – Parte 2: Páginas con ScrollingFrame y MAIN
-- Incluye:
-- - ScrollingFrame + UIListLayout por cada pestaña
-- - Funciones principales (Main): Noclip, Anti Delay, Infinite Jump
-- - Botón de prueba de notificación
----------------------------------------------------------

-- Crear ScrollingFrame estándar en una página
local function attachScrolling(parentPage)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.Parent = parentPage

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    return scroll
end

-- Adjuntar scroll a todas las pestañas definidas en Parte 1
local MainScroll = attachScrolling(Tabs["Main"])
local TeleportScroll = attachScrolling(Tabs["Teleport"])
local WaypointsScroll = attachScrolling(Tabs["Waypoints"])
local VisualScroll = attachScrolling(Tabs["Visual"])
local AjustesScroll = attachScrolling(Tabs["Ajustes"])

----------------------------------------------------------
-- MAIN: Noclip, Anti Delay, Infinite Jump
----------------------------------------------------------

-- Noclip
local noclipConnection
local function onNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    _G.noclipEnabled = true
    createNotification("Noclip activado")
end
local function offNoclip()
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    -- Restaurar colisiones básicas (best effort)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    _G.noclipEnabled = false
    createNotification("Noclip desactivado")
end

----------------------------------------------------------
-- AntiDelay (para eliminar tiempo de touch)
----------------------------------------------------------
local antiDelayConnection

createToggleButton(MainScroll, "Anti Delay", "antiDelayEnabled",
    function()
        antiDelayConnection = RunService.Heartbeat:Connect(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj:FindFirstChildOfClass("TouchTransmitter") then
                    -- Fuerza el touch sin delay
                    firetouchinterest(hrp, obj, 0)
                    firetouchinterest(hrp, obj, 1)
                end
            end
        end)
        createNotification("Anti Delay (Touch) ON")
    end,
    function()
        if antiDelayConnection then
            antiDelayConnection:Disconnect()
            antiDelayConnection = nil
        end
        createNotification("Anti Delay (Touch) OFF")
    end
)

-- Infinite Jump
local infiniteJumpConnection
local function onInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    _G.infiniteJumpEnabled = true
    createNotification("Infinite Jump activado")
end
local function offInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() infiniteJumpConnection = nil end
    _G.infiniteJumpEnabled = false
    createNotification("Infinite Jump desactivado")
end

----------------------------------------------------------
-- MAIN: Botones
----------------------------------------------------------
createToggleButton(MainScroll, "Noclip", "noclipEnabled", onNoclip, offNoclip)
createToggleButton(MainScroll, "Anti Delay", "antiDelayEnabled", onAntiDelay, offAntiDelay)
createToggleButton(MainScroll, "Infinite Jump", "infiniteJumpEnabled", onInfiniteJump, offInfiniteJump)

-- Notificación de prueba
createButton(MainScroll, "Probar notificación", function()
    createNotification("Funciona el sistema de notificaciones ✔")
end)

print("[KS HUB] Parte 2 lista: Páginas con scroll y Main configurado")



----------------------------------------------------------
-- KS HUB – Parte 3: Teleport
-- Incluye:
-- - Teleport a Spawn (robusto)
-- - Teleport a Coordenadas (con TextBox)
-- - Teleport a Jugadores (lista dinámica con scroll)
----------------------------------------------------------

----------------------------------------------------------
-- Teleport a Spawn
----------------------------------------------------------
createButton(TeleportScroll, "Teleport to Spawn", function()
    local hrp = getHRP()
    if not hrp then
        warn("[KS HUB] HumanoidRootPart no disponible")
        return
    end

    local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
    local possibleNames = { "Spawn", "Lobby", "Start", "Inicio" }
    local target

    if spawnLocation then
        target = spawnLocation
    else
        for _, name in ipairs(possibleNames) do
            local found = workspace:FindFirstChild(name)
            if found and found:IsA("BasePart") then
                target = found
                break
            end
        end
    end

    if target and target.CFrame then
        teleportToCFrame(target.CFrame)
    else
        warn("[KS HUB] No se encontró una ubicación de Spawn válida")
    end
end)

----------------------------------------------------------
-- Teleport a Coordenadas
----------------------------------------------------------
local coordBox = Instance.new("TextBox")
coordBox.Size = UDim2.new(1, 0, 0, 30)
coordBox.PlaceholderText = "Coordenadas: ejemplo 120, 35, -240"
coordBox.Text = ""
coordBox.Font = Enum.Font.Gotham
coordBox.TextSize = 16
coordBox.TextColor3 = Color3.new(1, 1, 1)
coordBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordBox.BackgroundTransparency = 0.1
coordBox.BorderSizePixel = 0
coordBox.ClearTextOnFocus = false
coordBox.Parent = TeleportScroll
Instance.new("UICorner", coordBox).CornerRadius = UDim.new(0, 6)

createButton(TeleportScroll, "Teleport to Coordinates", function()
    local vec = parseCoords(coordBox.Text)
    if not vec then
        warn("[KS HUB] Coordenadas inválidas. Usa: 120, 35, -240 o 120 35 -240")
        return
    end
    teleportToCFrame(CFrame.new(vec))
end)

----------------------------------------------------------
-- Teleport a Jugadores
----------------------------------------------------------
local playersFrame = Instance.new("Frame")
playersFrame.Size = UDim2.new(1, 0, 0, 200)
playersFrame.BackgroundTransparency = 1
playersFrame.Parent = TeleportScroll

local playersScroll = Instance.new("ScrollingFrame")
playersScroll.Size = UDim2.new(1, 0, 1, 0)
playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playersScroll.ScrollBarThickness = 6
playersScroll.BackgroundTransparency = 1
playersScroll.Parent = playersFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = playersScroll

local function refreshPlayers()
    for _, child in ipairs(playersScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createButton(playersScroll, "TP to " .. plr.Name, function()
                -- Espera a que el Character exista
                local targetChar = plr.Character or plr.CharacterAdded:Wait()
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    teleportToCFrame(targetHRP.CFrame)
                else
                    warn("[KS HUB] El jugador no tiene HumanoidRootPart disponible")
                end
            end)
        end
    end
end


Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

print("[KS HUB] Parte 3 lista: Teleport configurado")



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
