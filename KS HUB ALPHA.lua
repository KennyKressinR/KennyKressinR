--========================================================
-- KS HUB - Rehecho y Adaptado para Móviles
-- Autor: Kenny + Copilot
--========================================================

--========================================================
-- [ SECCIÓN 1 ] SERVICIOS Y VARIABLES
--========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--========================================================
-- [ SECCIÓN 2 ] GUI PRINCIPAL
--========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Botón flotante para abrir/cerrar
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(1, -70, 1, -70)
ToggleButton.Text = "≡"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Marco principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "KS HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = MainFrame

-- Contenedor de pestañas
local Tabs = {}
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame
local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabContainer

-- Contenido
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 130, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Función para crear pestañas
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 36)
    tabButton.Text = name
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 16
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButton.BorderSizePixel = 0
    tabButton.Parent = TabContainer
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton

    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 1, 0)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Visible = false
    sectionFrame.Parent = ContentFrame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = sectionFrame

    Tabs[name] = sectionFrame
    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(Tabs) do frame.Visible = false end
        sectionFrame.Visible = true
    end)
end

-- Crear pestañas
createTab("Main")
createTab("Teleport")
createTab("Visual")
createTab("Ajustes")

-- Mostrar/Ocultar HUB
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Utilidad: crear botón
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    button.MouseButton1Click:Connect(callback)
    return button
end

--========================================================
-- [ SECCIÓN 3 ] FUNCIONES DEL HUB
--========================================================
local function getRoot(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Teleport al mouse
local function teleportToMouse()
    local root = getRoot(LocalPlayer)
    if root and Mouse.Hit then
        root.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end

-- Teleport a jugador
local function teleportToPlayer(player)
    local myRoot = getRoot(LocalPlayer)
    local targetRoot = getRoot(player)
    if myRoot and targetRoot then
        LocalPlayer.Character:PivotTo(targetRoot.CFrame + Vector3.new(0, 3, 0))
    end
end

-- Noclip
local noclip = false
local noclipConnection
local function toggleNoclip()
    noclip = not noclip
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

-- Guardar/Cargar posición
local savedCFrame
local function savePosition()
    local root = getRoot(LocalPlayer)
    if root then savedCFrame = root.CFrame end
end
local function loadPosition()
    if savedCFrame then LocalPlayer.Character:PivotTo(savedCFrame) end
end

-- Anti-delay
local antiDelay = false
local originalDurations = {}
local function toggleAntiDelay()
    antiDelay = not antiDelay
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if antiDelay then
                originalDurations[obj] = obj.HoldDuration
                obj.HoldDuration = 0
            else
                if originalDurations[obj] then obj.HoldDuration = originalDurations[obj] end
            end
        end
    end
end

-- Transparencia
local userTransparency = 0
local function applyTransparency(value)
    userTransparency = math.clamp(value, 0, 1)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = userTransparency end
        end
    end
end

--========================================================
-- [ SECCIÓN 4 ] BOTONES MAIN (TELEPORT SLOTS + VELOCIDAD + SALTO)
--========================================================

-- Noclip y AntiDelay
createButton(Tabs["Main"], "Toggle Noclip", toggleNoclip)
createButton(Tabs["Main"], "Toggle Anti-Delay", toggleAntiDelay)

-- =========================
-- TELEPORT SLOTS
-- =========================
local savedSlots = {nil, nil, nil, nil}

local function saveSlot(i)
    local root = getRoot(LocalPlayer)
    if root then
        savedSlots[i] = root.CFrame
    end
end

local function loadSlot(i)
    local root = getRoot(LocalPlayer)
    if root and savedSlots[i] then
        LocalPlayer.Character:PivotTo(savedSlots[i])
    end
end

-- Crear 4 filas de botones Save/Load
for i = 1, 4 do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = Tabs["Main"]

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.5, -4, 1, 0)
    saveBtn.Position = UDim2.new(0, 0, 0, 0)
    saveBtn.Text = "Save" .. i
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.TextSize = 16
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = row
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 6)
    saveCorner.Parent = saveBtn
    saveBtn.MouseButton1Click:Connect(function() saveSlot(i) end)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.5, -4, 1, 0)
    loadBtn.Position = UDim2.new(0.5, 4, 0, 0)
    loadBtn.Text = "Load" .. i
    loadBtn.Font = Enum.Font.Gotham
    loadBtn.TextSize = 16
    loadBtn.TextColor3 = Color3.new(1, 1, 1)
    loadBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loadBtn.BorderSizePixel = 0
    loadBtn.Parent = row
    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 6)
    loadCorner.Parent = loadBtn
    loadBtn.MouseButton1Click:Connect(function() loadSlot(i) end)
end

-- =========================
-- VELOCIDAD
-- =========================
createButton(Tabs["Main"], "Velocidad: 30", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 30 end
end)
createButton(Tabs["Main"], "Velocidad: 75", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 75 end
end)
createButton(Tabs["Main"], "Velocidad: 150", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 150 end
end)

-- =========================
-- SALTO
-- =========================
local function getBaseJump()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return 50 end
    return hum.JumpPower > 0 and hum.JumpPower or 50
end

createButton(Tabs["Main"], "Salto +30%", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = getBaseJump() * 1.3 end
end)
createButton(Tabs["Main"], "Salto +75%", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = getBaseJump() * 1.75 end
end)
createButton(Tabs["Main"], "Salto +150%", function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = getBaseJump() * 2.5 end
end)

--========================================================
-- [ SECCIÓN 5 ] TELEPORT MEJORADO (BUSCADOR + SCROLL + REFRESH)
--========================================================

-- Botón: Teleport al mouse
createButton(Tabs["Teleport"], "Teleport al Mouse", teleportToMouse)

-- Caja de búsqueda
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, 0, 0, 30)
searchBox.Text = "" -- ✅ Importante: vacío, no "TextBox"
searchBox.PlaceholderText = "Buscar jugador..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 16
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
searchBox.Parent = Tabs["Teleport"]

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

-- Botón de refrescar lista
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 30)
refreshBtn.Text = "Actualizar lista de jugadores"
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 16
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
refreshBtn.BorderSizePixel = 0
refreshBtn.Parent = Tabs["Teleport"]

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshBtn

-- Scrolling de jugadores
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, -100) -- Ajustado para dejar espacio a los controles
playerScroll.Position = UDim2.new(0, 0, 0, 70)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 6
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = Tabs["Teleport"]

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = playerScroll

-- Función para poblar lista con filtro
local function populatePlayerList(filter)
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr) end
    end
    table.sort(list, function(a, b) return a.DisplayName:lower() < b.DisplayName:lower() end)

    for _, plr in ipairs(list) do
        local match = true
        if filter and filter ~= "" then
            local f = filter:lower()
            match = (string.find(plr.Name:lower(), f) ~= nil) or (string.find(plr.DisplayName:lower(), f) ~= nil)
        end
        if match then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = true
            btn.Parent = playerScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                teleportToPlayer(plr)
            end)
        end
    end
end

-- Eventos de búsqueda y actualización dinámica
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    populatePlayerList(searchBox.Text)
end)

refreshBtn.MouseButton1Click:Connect(function()
    populatePlayerList(searchBox.Text)
end)

Players.PlayerAdded:Connect(function()
    populatePlayerList(searchBox.Text)
end)
Players.PlayerRemoving:Connect(function()
    populatePlayerList(searchBox.Text)
end)

-- Inicial
populatePlayerList("")
 

-- Scrolling de jugadores
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, -30 - 34 - 36) -- resto: search (30) + controlBar (34) + boton teleport mouse (36)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 6
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.Parent = Tabs["Teleport"]

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = playerScroll

-- Función para poblar lista con filtro
local function populatePlayerList(filter)
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- Ordenar jugadores alfabéticamente por DisplayName
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr) end
    end
    table.sort(list, function(a, b) return a.DisplayName:lower() < b.DisplayName:lower() end)

    for _, plr in ipairs(list) do
        local match = true
        if filter and filter ~= "" then
            local f = filter:lower()
            match = (string.find(plr.Name:lower(), f) ~= nil) or (string.find(plr.DisplayName:lower(), f) ~= nil)
        end
        if match then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = true
            btn.Parent = playerScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                teleportToPlayer(plr)
            end)
        end
    end
end

-- Eventos de búsqueda y actualización dinámica
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    populatePlayerList(searchBox.Text)
end)

refreshBtn.MouseButton1Click:Connect(function()
    populatePlayerList(searchBox.Text)
end)

Players.PlayerAdded:Connect(function()
    populatePlayerList(searchBox.Text)
end)
Players.PlayerRemoving:Connect(function()
    populatePlayerList(searchBox.Text)
end)

-- Inicial
populatePlayerList("")

--========================================================
-- [ SECCIÓN 6 ] VISUAL (PRESETS RÁPIDOS)
--========================================================

createButton(Tabs["Visual"], "Transparencia 0%", function()
    applyTransparency(0)
end)
createButton(Tabs["Visual"], "Transparencia 50%", function()
    applyTransparency(0.5)
end)
createButton(Tabs["Visual"], "Transparencia 100%", function()
    applyTransparency(1)
end)

--========================================================
--========================================================
-- [ SECCIÓN 7 ] AJUSTES (SLIDER + PRESETS + UTILIDADES)
--========================================================

-- Slider de transparencia
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 24)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Transparencia (arrastrar): " .. tostring(userTransparency)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 16
sliderLabel.TextColor3 = Color3.new(1, 1, 1)
sliderLabel.Parent = Tabs["Ajustes"]

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, 0, 0, 10)
sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = Tabs["Ajustes"]
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 6)
sliderCorner.Parent = sliderBar

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar
local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 6)
sliderFillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBar
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

local dragging = false
local function setSliderFromX(x)
    local barAbsPos = sliderBar.AbsolutePosition.X
    local barAbsSize = sliderBar.AbsoluteSize.X
    local rel = math.clamp((x - barAbsPos) / barAbsSize, 0, 1)
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    sliderKnob.Position = UDim2.new(rel, -8, 0.5, -8)
    applyTransparency(rel) -- ✅ Aplica en tiempo real
    sliderLabel.Text = "Transparencia (arrastrar): " .. string.format("%.2f", rel)
end

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        setSliderFromX(input.Position.X)
    end
end)
sliderBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setSliderFromX(input.Position.X)
    end
end)
-- Presets rápidos de transparencia en Ajustes
createButton(Tabs["Ajustes"], "Transparencia 25%", function()
    local x = sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * 0.25
    setSliderFromX(x)
end)
createButton(Tabs["Ajustes"], "Transparencia 75%", function()
    local x = sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * 0.75
    setSliderFromX(x)
end)

-- Utilidades
createButton(Tabs["Ajustes"], "Cerrar HUB", function()
    MainFrame.Visible = false
end)
createButton(Tabs["Ajustes"], "Resetear Personaje", function()
    LocalPlayer:LoadCharacter()
end)

--========================================================
-- [ SECCIÓN 8 ] INICIALIZACIÓN DE PESTAÑA POR DEFECTO
--========================================================
for name, frame in pairs(Tabs) do
    frame.Visible = (name == "Main") -- Al iniciar, se muestra la pestaña Main
end

--========================================================
-- [ FIN DEL SCRIPT KS HUB ]
--========================================================
