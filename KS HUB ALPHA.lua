-- KS HUB Rehecho y Adaptado para Móviles
-- Autor: Kenny + Copilot

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============ GUI PRINCIPAL ============
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
ToggleButton.AutoButtonColor = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

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
        for _, frame in pairs(Tabs) do
            frame.Visible = false
        end
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
    button.AutoButtonColor = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

-- ============ FUNCIONES ============
local function getRoot(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- Teleport al mouse (nota: en móvil, usa donde toques la pantalla si hay raycast válido)
local function teleportToMouse()
    local root = getRoot(LocalPlayer)
    if root and Mouse.Hit then
        root.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end

-- Teleport a jugador robusto
local function teleportToPlayer(player)
    local myRoot = getRoot(LocalPlayer)
    local targetRoot = getRoot(player)
    if myRoot and targetRoot then
        -- Usa PivotTo para mayor estabilidad
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
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- Restaurar colisiones
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Guardar/Cargar posición
local savedCFrame
local function savePosition()
    local root = getRoot(LocalPlayer)
    if root then
        savedCFrame = root.CFrame
    end
end
local function loadPosition()
    local root = getRoot(LocalPlayer)
    if root and savedCFrame then
        LocalPlayer.Character:PivotTo(savedCFrame)
    end
end

-- Anti-delay ProximityPrompt
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
                if originalDurations[obj] ~= nil then
                    obj.HoldDuration = originalDurations[obj]
                end
            end
        end
    end
    if not antiDelay then
        originalDurations = {}
    end
end

-- Transparencia configurable
local userTransparency = 0
local function applyTransparency(value)
    userTransparency = math.clamp(value, 0, 1)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = userTransparency
        end
    end
end

-- ============ SECCIÓN MAIN ============
local noclipBtn = createButton(Tabs["Main"], "Toggle Noclip", toggleNoclip)
local saveBtn = createButton(Tabs["Main"], "Guardar Posición", savePosition)
local loadBtn = createButton(Tabs["Main"], "Cargar Posición", loadPosition)
local antiDelayBtn = createButton(Tabs["Main"], "Toggle Anti-Delay", toggleAntiDelay)

-- ============ SECCIÓN TELEPORT ============
createButton(Tabs["Teleport"], "Teleport al Mouse", teleportToMouse)

-- Scrolling de jugadores
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, -44)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 6
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.Parent = Tabs["Teleport"]

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = playerScroll

local refreshPlayersBtn = createButton(Tabs["Teleport"], "Actualizar lista de jugadores", function()
    -- Solo para dar opción manual si el servidor es grande
    task.defer(function()
        local function updatePlayerList()
            -- Borra solo botones (mantén el layout)
            for _, child in ipairs(playerScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 36)
                    btn.Text = "Teleport a: " .. plr.DisplayName .. " (" .. plr.Name .. ")"
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
        updatePlayerList()
    end)
end)

-- Poblado inicial y eventos dinámicos
local function updatePlayerListDynamic()
    -- Reutiliza el botón de refresh internamente
    refreshPlayersBtn:Activate()
end

-- Llamada inicial
updatePlayerListDynamic()
-- Actualiza cuando se une/va alguien
Players.PlayerAdded:Connect(updatePlayerListDynamic)
Players.PlayerRemoving:Connect(updatePlayerListDynamic)

-- ============ SECCIÓN VISUAL ============
createButton(Tabs["Visual"], "Transparencia 50%", function()
    applyTransparency(0.5)
end)
createButton(Tabs["Visual"], "Transparencia 0%", function()
    applyTransparency(0)
end)

-- ============ SECCIÓN AJUSTES ============
-- Slider de transparencia (0 a 1)
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
    applyTransparency(rel)
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

-- Presets rápidos
createButton(Tabs["Ajustes"], "Transparencia 25%", function() setSliderFromX(sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * 0.25) end)
createButton(Tabs["Ajustes"], "Transparencia 75%", function() setSliderFromX(sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X * 0.75) end)

-- Botones útiles
createButton(Tabs["Ajustes"], "Cerrar HUB", function()
    MainFrame.Visible = false
end)
createButton(Tabs["Ajustes"], "Resetear Personaje", function()
    LocalPlayer:LoadCharacter()
end)

-- Mostrar por defecto la pestaña Main
for name, frame in pairs(Tabs) do
    frame.Visible = (name == "Main")
end
