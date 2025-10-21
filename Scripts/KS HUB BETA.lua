
--========================================================
-- KS HUB - SCRIPT COMPLETO
--========================================================

----------------------------------------------------------
-- PARTE 1: SERVICIOS Y VARIABLES
----------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Función para obtener el HumanoidRootPart
local function getRoot(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- Función para obtener el Humanoid
local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

print("[KS HUB] Parte 1 lista")
----------------------------------------------------------
-- PARTE 2: GUI PRINCIPAL
----------------------------------------------------------
-- [Bloque 2.1] ScreenGui y botón flotante
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(1, -70, 1, -70)
ToggleButton.Text = "≡"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
ToggleButton.BackgroundTransparency = 0.25
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- [Bloque 2.1.1] Hacer el botón flotante arrastrable
local dragging = false
local dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- [Bloque 2.2] Marco principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

----------------------------------------------------------
-- [Bloque 2.3] Botón Toggle (abrir/cerrar HUB)
----------------------------------------------------------
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 1, -120) -- más arriba para no tapar salto
ToggleButton.Text = "≡"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- Estado de anclado
local anchored = true
local initialPosition = ToggleButton.Position

-- Lógica de arrastre (solo si está desanclado)
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

ToggleButton.InputBegan:Connect(function(input)
    if not anchored and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if not anchored and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not anchored and input == dragInput and dragging then
        update(input)
    end
end)

----------------------------------------------------------
-- [Bloque 2.5] Contenido
----------------------------------------------------------
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 130, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

----------------------------------------------------------
-- [Bloque 2.6] Función para crear pestañas
----------------------------------------------------------
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 36)
    tabButton.Text = name
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 16
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    tabButton.BackgroundTransparency = 0.1
    tabButton.BorderSizePixel = 0
    tabButton.Parent = TabContainer
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

    -- 🔊 Sonido al presionar pestañas
    local tabClickSound = Instance.new("Sound")
    tabClickSound.SoundId = "rbxassetid://9120507525"
    tabClickSound.Volume = 1
    tabClickSound.Parent = tabButton

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
        tabClickSound:Play()
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

----------------------------------------------------------
-- [Bloque 2.7] Toggle HUB
----------------------------------------------------------
-- 🔊 Sonido al abrir/cerrar HUB
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://77300603936003"
toggleSound.Volume = 1
toggleSound.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    toggleSound:Play()
end)

----------------------------------------------------------
-- [Bloque 2.8] Función para crear botones
----------------------------------------------------------
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    -- 🔊 Sonido al presionar botones
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://9120507525"
    clickSound.Volume = 1
    clickSound.Parent = button

    button.MouseButton1Click:Connect(function()
        clickSound:Play()
        local ok, err = pcall(callback)
        if not ok then
            warn("[KS HUB] Error en botón:", err)
        end
    end)

    return button
end

print("[KS HUB] Parte 2 lista")

----------------------------------------------------------
-- PARTE 3: FUNCIONES DE UTILIDAD
----------------------------------------------------------
-- Teleports
local function teleportToMouse()
    local root = getRoot(LocalPlayer)
    if root and Mouse and Mouse.Hit then
        root.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end
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
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
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
                if originalDurations[obj] ~= nil then
                    obj.HoldDuration = originalDurations[obj]
                end
            end
        end
    end
    if not antiDelay then
        originalDurations = {}
    end
end -- ✅ Este end cierra la función correctamente
    
-- [Bloque 2.5] Contenido
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 130, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- [Bloque 2.6] Función para crear pestañas
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 36)
    tabButton.Text = name
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 16
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    tabButton.BackgroundTransparency = 0.1
    tabButton.BorderSizePixel = 0
    tabButton.Parent = TabContainer
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

    -- 🔊 Sonido al presionar pestañas
    local tabClickSound = Instance.new("Sound")
    tabClickSound.SoundId = "rbxassetid://9120507525"
    tabClickSound.Volume = 1
    tabClickSound.Parent = tabButton

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
        tabClickSound:Play() -- 🔊 Sonido al hacer click en pestaña
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

-- [Bloque 2.7] Toggle HUB
-- 🔊 Sonido al abrir/cerrar HUB
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://77300603936003"
toggleSound.Volume = 1
toggleSound.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    toggleSound:Play() -- 🔊 Sonido al abrir/cerrar HUB
end)

-- [Bloque 2.8] Función para crear botones
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    -- 🔊 Sonido al presionar botones
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://9120507525"
    clickSound.Volume = 1
    clickSound.Parent = button

    button.MouseButton1Click:Connect(function()
        clickSound:Play() -- 🔊 Sonido al hacer click
        local ok, err = pcall(callback)
        if not ok then
            warn("[KS HUB] Error en botón:", err)
        end
    end)

    return button
end

print("[KS HUB] Parte 2 lista")
----------------------------------------------------------
-- PARTE 3: FUNCIONES DE UTILIDAD
----------------------------------------------------------
-- [Bloque 3.X] Infinite Jump
local infiniteJumpEnabled = false

-- Evento de salto
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Toggle Infinite Jump
local function toggleInfiniteJump()
    infiniteJumpEnabled = not infiniteJumpEnabled
    print("[KS HUB] Infinite Jump " .. (infiniteJumpEnabled and "ON" or "OFF"))
end

-- [Bloque 3.1] Teleports
local function teleportToMouse()
    local root = getRoot(LocalPlayer)
    if root and Mouse and Mouse.Hit then
        root.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end

local function teleportToPlayer(player)
    local myRoot = getRoot(LocalPlayer)
    local targetRoot = getRoot(player)
    if myRoot and targetRoot then
        LocalPlayer.Character:PivotTo(targetRoot.CFrame + Vector3.new(0, 3, 0))
    end
end
-- [Bloque 3.2] Noclip
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
        print("[KS HUB] Noclip ON")
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        print("[KS HUB] Noclip OFF")
    end
end
-- [Bloque 3.3] Anti-delay
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
    if not antiDelay then originalDurations = {} end
end

print("[KS HUB] Parte 3 lista")
----------------------------------------------------------
-- PARTE 4: MAIN (SLIDERS + UTILIDADES + BRING ITEMS)
----------------------------------------------------------
-- Contenedor principal de la pestaña Main
local mainScroll = Instance.new("ScrollingFrame")
mainScroll.Size = UDim2.new(1, 0, 1, 0)
mainScroll.BackgroundTransparency = 1
mainScroll.ScrollBarThickness = 6
mainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
mainScroll.Parent = Tabs["Main"]

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 6)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Parent = mainScroll

-- Botón único para Noclip
createButton(mainScroll, "Toggle Noclip", toggleNoclip)

-- Botón Anti‑Delay
createButton(mainScroll, "Toggle Anti-Delay", toggleAntiDelay)

-- Botón para activar/desactivar Infinite Jump
createButton(mainScroll, "Toggle Infinite Jump", toggleInfiniteJump)
----------------------------------------------------------
-- SLIDER DE VELOCIDAD
----------------------------------------------------------
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 24)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Velocidad: 16"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 16
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Parent = mainScroll

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1, 0, 0, 10)
speedBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBar.BackgroundTransparency = 0.1
speedBar.BorderSizePixel = 0
speedBar.Parent = mainScroll
Instance.new("UICorner", speedBar).CornerRadius = UDim.new(0, 6)

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
speedFill.BackgroundTransparency = 0.1
speedFill.BorderSizePixel = 0
speedFill.Parent = speedBar
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0, 6)

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 16, 0, 16)
speedKnob.Position = UDim2.new(0, -8, 0.5, -8)
speedKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
speedKnob.BackgroundTransparency = 0.1
speedKnob.BorderSizePixel = 0
speedKnob.Parent = speedBar
Instance.new("UICorner", speedKnob).CornerRadius = UDim.new(1, 0)

local draggingSpeed = false
local function setSpeedFromX(x)
    local barAbsPos = speedBar.AbsolutePosition.X
    local barAbsSize = speedBar.AbsoluteSize.X
    local rel = math.clamp((x - barAbsPos) / barAbsSize, 0, 1)
    local value = math.floor(16 + (150 - 16) * rel)
    speedFill.Size = UDim2.new(rel, 0, 1, 0)
    speedKnob.Position = UDim2.new(rel, -8, 0.5, -8)
    speedLabel.Text = "Velocidad: " .. tostring(value)
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = value end
end

speedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = true
        setSpeedFromX(input.Position.X)
    end
end)
speedBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setSpeedFromX(input.Position.X)
    end
end)
----------------------------------------------------------
-- SLIDER DE SALTO
----------------------------------------------------------
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, 0, 0, 24)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Salto: 32"
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 16
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.Parent = mainScroll

local jumpBar = Instance.new("Frame")
jumpBar.Size = UDim2.new(1, 0, 0, 10)
jumpBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpBar.BackgroundTransparency = 0.1
jumpBar.BorderSizePixel = 0
jumpBar.Parent = mainScroll
Instance.new("UICorner", jumpBar).CornerRadius = UDim.new(0, 6)

local jumpFill = Instance.new("Frame")
jumpFill.Size = UDim2.new(0, 0, 1, 0)
jumpFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
jumpFill.BackgroundTransparency = 0.1
jumpFill.BorderSizePixel = 0
jumpFill.Parent = jumpBar
Instance.new("UICorner", jumpFill).CornerRadius = UDim.new(0, 6)

local jumpKnob = Instance.new("Frame")
jumpKnob.Size = UDim2.new(0, 16, 0, 16)
jumpKnob.Position = UDim2.new(0, -8, 0.5, -8)
jumpKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
jumpKnob.BackgroundTransparency = 0.1
jumpKnob.BorderSizePixel = 0
jumpKnob.Parent = jumpBar
Instance.new("UICorner", jumpKnob).CornerRadius = UDim.new(1, 0)

local draggingJump = false
local function setJumpFromX(x)
    local barAbsPos = jumpBar.AbsolutePosition.X
    local barAbsSize = jumpBar.AbsoluteSize.X
    local rel = math.clamp((x - barAbsPos) / barAbsSize, 0, 1)
    local value = math.floor(32 + (100 - 32) * rel)
    jumpFill.Size = UDim2.new(rel, 0, 1, 0)
    jumpKnob.Position = UDim2.new(rel, -8, 0.5, -8)
    jumpLabel.Text = "Salto: " .. tostring(value)
    local hum = getHumanoid()
    if hum then hum.JumpPower = value end
end

jumpBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingJump = true
        setJumpFromX(input.Position.X)
    end
end)
jumpBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingJump = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingJump and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setJumpFromX(input.Position.X)
    end
end)

----------------------------------------------------------
-- [Bloque 4.X] DEFENSAS AVANZADAS
----------------------------------------------------------

-- Anti-Hitbox: reduce tamaño del HRP para recibir menos golpes
local function antiHitbox()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Transparency = 0.7
        hrp.CanCollide = false
        print("[KS HUB] 🌀 Anti-Hitbox activado")
    else
        warn("[KS HUB] No se encontró HumanoidRootPart")
    end
end

-- Auto-Heal: cura automáticamente al perder vida
local function autoHeal()
    local hum = getHumanoid()
    if hum then
        hum.HealthChanged:Connect(function(hp)
            if hp < hum.MaxHealth then
                hum.Health = hum.MaxHealth
                print("[KS HUB] 💚 Auto-Heal aplicado")
            end
        end)
        print("[KS HUB] 💚 Auto-Heal activado")
    else
        warn("[KS HUB] No se encontró Humanoid")
    end
end

-- Teleport evasivo: se teletransporta si la vida baja del 50%
local function evasiveTP()
    local hum = getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        hum.HealthChanged:Connect(function(hp)
            if hp < (hum.MaxHealth * 0.5) then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 0, 30)
                print("[KS HUB] ⚡ Teleport evasivo activado")
            end
        end)
        print("[KS HUB] ⚡ Teleport evasivo listo")
    else
        warn("[KS HUB] No se encontró Humanoid o HRP")
    end
end

-- Botones en Main (dentro del scroll)
createButton(mainScroll, "🌀 Activar Anti-Hitbox", antiHitbox)
createButton(mainScroll, "💚 Activar Auto-Heal", autoHeal)
createButton(mainScroll, "⚡ Activar Teleport Evasivo", evasiveTP)
----------------------------------------------------------
-- PARTE 5: TELEPORT (BUSCADOR + SCROLL + LOADER)
----------------------------------------------------------
-- Contenedor scroll para toda la pestaña Teleport
local tpScroll = Instance.new("ScrollingFrame")
tpScroll.Size = UDim2.new(1, 0, 1, 0)
tpScroll.BackgroundTransparency = 1
tpScroll.ScrollBarThickness = 6
tpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpScroll.Parent = Tabs["Teleport"]

local tpLayout = Instance.new("UIListLayout")
tpLayout.Padding = UDim.new(0, 6)
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpLayout.Parent = tpScroll

-- [Bloque 5.1] Teleport al mouse
createButton(tpScroll, "Teleport al Mouse", teleportToMouse)

-- [Bloque 5.2] Caja de búsqueda de jugadores
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, 0, 0, 30)
searchBox.PlaceholderText = "Buscar jugador..."
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 16
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBox.BackgroundTransparency = 0.1
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
searchBox.Parent = tpScroll
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

-- [Bloque 5.3] Botón Refresh
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 30)
refreshBtn.Text = "Actualizar lista de jugadores"
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 16
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
refreshBtn.BackgroundTransparency = 0.1
refreshBtn.BorderSizePixel = 0
refreshBtn.Parent = tpScroll
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

-- Botón en pestaña Visuals (debajo de ESP Items)
createButton(Tabs["Visuals"], "📦 Bring Items", bringItems)

-- [Bloque 5.4] Scroll de jugadores
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 0, 200)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 6
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.Parent = tpScroll

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 6)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = playerScroll

-- Función para poblar lista de jugadores
local function populatePlayerList(filter)
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
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
                btn.BackgroundTransparency = 0.1
                btn.BorderSizePixel = 0
                btn.Parent = playerScroll
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

                btn.MouseButton1Click:Connect(function()
                    teleportToPlayer(plr)
                end)
            end
        end
    end
end

-- Conexiones de búsqueda y refresh
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    populatePlayerList(searchBox.Text)
end)
refreshBtn.MouseButton1Click:Connect(function()
    populatePlayerList(searchBox.Text)
end)
Players.PlayerAdded:Connect(function() populatePlayerList(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() populatePlayerList(searchBox.Text) end)

-- Inicializar lista
populatePlayerList("")

-- [Bloque 5.5] Teleport Loader (Save/Load posiciones)
local savedPositions = {}

local function savePosition(slot)
    local root = getRoot(LocalPlayer)
    if root then
        savedPositions[slot] = root.CFrame
        print("[KS HUB] Posición guardada en slot", slot)
    end
end

local function loadPosition(slot)
    local root = getRoot(LocalPlayer)
    if root and savedPositions[slot] then
        root.CFrame = savedPositions[slot]
        print("[KS HUB] Teleport a slot", slot)
    else
        warn("[KS HUB] Slot vacío:", slot)
    end
end

-- Crear botones Save/Load en filas
for i = 1, 3 do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = tpScroll

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.5, -3, 1, 0)
    saveBtn.Position = UDim2.new(0, 0, 0, 0)
    saveBtn.Text = "Save" .. i
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.TextSize = 16
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    saveBtn.BackgroundTransparency = 0.1
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = row
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    saveBtn.MouseButton1Click:Connect(function() savePosition(i) end)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.5, -3, 1, 0)
    loadBtn.Position = UDim2.new(0.5, 3, 0, 0)
    loadBtn.Text = "Load" .. i
    loadBtn.Font = Enum.Font.Gotham
    loadBtn.TextSize = 16
    loadBtn.TextColor3 = Color3.new(1, 1, 1)
    loadBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    loadBtn.BackgroundTransparency = 0.1
    loadBtn.BorderSizePixel = 0
    loadBtn.Parent = row
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)
    loadBtn.MouseButton1Click:Connect(function() loadPosition(i) end)
end

print("[KS HUB] Parte 5 lista")
----------------------------------------------------------
----------------------------------------------------------
-- PARTE 6: VISUALS (ESP + BRING ITEMS)
----------------------------------------------------------

-- Contenedor scroll para la pestaña Visuals
local visualScroll = Instance.new("ScrollingFrame")
visualScroll.Size = UDim2.new(1, 0, 1, 0)
visualScroll.BackgroundTransparency = 1
visualScroll.ScrollBarThickness = 6
visualScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
visualScroll.Parent = Tabs["Visual"]

local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0, 6)
visualLayout.SortOrder = Enum.SortOrder.LayoutOrder
visualLayout.Parent = visualScroll

----------------------------------------------------------
-- [Bloque 6.1] Full Bright
----------------------------------------------------------
local fullBright = false
local oldBrightness, oldAmbient, oldOutdoorAmbient

createButton(visualScroll, "Toggle Full Bright", function()
    fullBright = not fullBright
    if fullBright then
        oldBrightness = Lighting.Brightness
        oldAmbient = Lighting.Ambient
        oldOutdoorAmbient = Lighting.OutdoorAmbient

        Lighting.Brightness = 5
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        print("[KS HUB] Full Bright ON")
    else
        if oldBrightness then Lighting.Brightness = oldBrightness end
        if oldAmbient then Lighting.Ambient = oldAmbient end
        if oldOutdoorAmbient then Lighting.OutdoorAmbient = oldOutdoorAmbient end
        print("[KS HUB] Full Bright OFF")
    end
end)

----------------------------------------------------------
-- [Bloque 6.2] ESP Jugadores
----------------------------------------------------------
local espEnabled = false
local espConnections = {}

local function addESP(plr)
    if not plr.Character then return end
    local char = plr.Character

    if not char:FindFirstChild("KS_ESP_Highlight") then
        local h = Instance.new("Highlight")
        h.Name = "KS_ESP_Highlight"
        h.FillTransparency = 1
        h.OutlineColor = Color3.fromRGB(0, 255, 255)
        h.Adornee = char
        h.Parent = char
    end

    if not char:FindFirstChild("KS_ESP_Name") then
        local head = char:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "KS_ESP_Name"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = char

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(0, 255, 255)
            label.Parent = billboard
        end
    end
end

local function removeESP(plr)
    if plr.Character then
        local char = plr.Character
        local h = char:FindFirstChild("KS_ESP_Highlight")
        if h then h:Destroy() end
        local b = char:FindFirstChild("KS_ESP_Name")
        if b then b:Destroy() end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                addESP(plr)
                espConnections[#espConnections+1] = plr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    addESP(plr)
                end)
            end
        end
        espConnections[#espConnections+1] = Players.PlayerAdded:Connect(function(plr)
            espConnections[#espConnections+1] = plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                addESP(plr)
            end)
        end)
        print("[KS HUB] ESP ON")
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                removeESP(plr)
            end
        end
        for _, c in ipairs(espConnections) do
            c:Disconnect()
        end
        espConnections = {}
        print("[KS HUB] ESP OFF")
    end
end

createButton(visualScroll, "Toggle ESP Jugadores", toggleESP)

----------------------------------------------------------
-- [Bloque 6.3] ESP Ítems (Highlight + Nombre manual)
----------------------------------------------------------
local itemESPEnabled = false
local itemESPConnections = {}
local itemESPName = ""

local itemSearchBox = Instance.new("TextBox")
itemSearchBox.Size = UDim2.new(1, 0, 0, 30)
itemSearchBox.PlaceholderText = "Nombre de ítem..."
itemSearchBox.Text = ""
itemSearchBox.Font = Enum.Font.Gotham
itemSearchBox.TextSize = 16
itemSearchBox.TextColor3 = Color3.new(1, 1, 1)
itemSearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemSearchBox.BackgroundTransparency = 0.1
itemSearchBox.BorderSizePixel = 0
itemSearchBox.ClearTextOnFocus = false
itemSearchBox.Parent = visualScroll
Instance.new("UICorner", itemSearchBox).CornerRadius = UDim.new(0, 6)

local function addItemESP(obj)
    if not itemESPEnabled or itemESPName == "" then return end
    if string.find(obj.Name:lower(), itemESPName:lower()) then
        local adornee = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChildWhichIsA("BasePart")
        if adornee then
            if not obj:FindFirstChild("KS_ItemESP_Highlight") then
                local h = Instance.new("Highlight")
                h.Name = "KS_ItemESP_Highlight"
                h.FillTransparency = 1
                h.OutlineColor = Color3.fromRGB(255, 255, 0)
                h.Adornee = obj
                h.Parent = obj
            end
            if not obj:FindFirstChild("KS_ItemESP") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "KS_ItemESP"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.Adornee = adornee
                billboard.AlwaysOnTop = true
                billboard.Parent = obj

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = obj.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(255, 255, 0)
                label.Parent = billboard
            end
        end
    end
end

local function removeItemESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local esp = obj:FindFirstChild("KS_ItemESP")
        if esp then esp:Destroy() end
        local h = obj:FindFirstChild("KS_ItemESP_Highlight")
        if h then h:Destroy() end
    end
end

local function toggleItemESP()
    itemESPEnabled = not itemESPEnabled
    removeItemESP()
    for _, c in ipairs(itemESPConnections) do c:Disconnect() end
    itemESPConnections = {}

    if itemESPEnabled and itemESPName ~= "" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            addItemESP(obj)
        end
        table.insert(itemESPConnections, workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.2)
            addItemESP(obj)
        end))
        print("[KS HUB] ESP Ítems ON")
    else
        print("[KS HUB] ESP Ítems OFF")
    end
end

itemSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    itemESPName = itemSearchBox.Text
    if itemESPEnabled then
        toggleItemESP()
        toggleItemESP()
    end
end)

createButton(visualScroll, "Toggle ESP Ítems", toggleItemESP)

----------------------------------------------------------
-- [Bloque 6.4] Bring Items (filtrado + cantidad)
----------------------------------------------------------
bringCountBox.TextColor3 = Color3.new(1, 1, 1)
bringCountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bringCountBox.BackgroundTransparency = 0.1
bringCountBox.BorderSizePixel = 0
bringCountBox.ClearTextOnFocus = false
Instance.new("UICorner", bringCountBox).CornerRadius = UDim.new(0, 6)

local function bringFilteredItems()
    local hrp = getHRP()
    if not hrp then
        warn("[KS HUB] No se encontró HumanoidRootPart")
        return
    end

    if itemESPName == "" then
        warn("[KS HUB] No hay nombre de ítem en el buscador ESP")
        return
    end

    -- Cantidad a traer
    local maxCount = tonumber(bringCountBox.Text)
    if not maxCount then maxCount = math.huge end

    -- Buscar ítems que coincidan con el nombre
    local items = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name:lower(), itemESPName:lower()) then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                table.insert(items, {obj = obj, part = part, dist = dist})
            end
        end
    end

    -- Ordenar por distancia
    table.sort(items, function(a, b)
        return a.dist < b.dist
    end)

    -- Traerlos encima del jugador en fila
    local offsetY = 5
    local count = 0
    for i, data in ipairs(items) do
        if count >= maxCount then break end
        local targetPos = hrp.Position + Vector3.new(0, offsetY + (i * 3), 0)
        local part = data.part
        part.Anchored = false
        part.CanCollide = false
        part.CFrame = CFrame.new(targetPos)
        if data.obj:IsA("Tool") and data.obj:FindFirstChild("Handle") then
            data.obj.Handle.CFrame = CFrame.new(targetPos)
        end
        count += 1
    end

    print("[KS HUB] 📦 Bring Items ejecutado, total: " .. tostring(count))
end

createButton(visualScroll, "📦 Bring Items (filtrados)", bringFilteredItems)

----------------------------------------------------------
-- PARTE 6.5: AJUSTES
----------------------------------------------------------
local ajustesScroll = Instance.new("ScrollingFrame")
ajustesScroll.Size = UDim2.new(1, 0, 1, 0)
ajustesScroll.BackgroundTransparency = 1
ajustesScroll.ScrollBarThickness = 6
ajustesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ajustesScroll.Parent = Tabs["Ajustes"]

local ajustesLayout = Instance.new("UIListLayout")
ajustesLayout.Padding = UDim.new(0, 6)
ajustesLayout.SortOrder = Enum.SortOrder.LayoutOrder
ajustesLayout.Parent = ajustesScroll

-- Botón Reset Character
createButton(ajustesScroll, "Reset Character", function()
    LocalPlayer.Character:BreakJoints()
end)

-- Botón Rejoin
createButton(ajustesScroll, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Botón para anclar/desanclar ToggleButton
createButton(ajustesScroll, "Toggle Anclar Botón Abrir", function()
    anchored = not anchored
    if anchored then
        ToggleButton.Position = initialPosition
        print("[KS HUB] 📌 Botón de abrir ANCLADO")
    else
        print("[KS HUB] 📌 Botón de abrir DESANCLADO (puede moverse)")
    end
end)

print("[KS HUB] Parte 6 lista")
