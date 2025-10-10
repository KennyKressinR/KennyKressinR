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

local function getRoot(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

print("[KS HUB] Parte 1 lista")

----------------------------------------------------------
-- PARTE 2: GUI PRINCIPAL
----------------------------------------------------------
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

-- Botón arrastrable
local dragging = false
local dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Marco principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "KS HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = MainFrame

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
    tabButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    tabButton.BackgroundTransparency = 0.1
    tabButton.BorderSizePixel = 0
    tabButton.Parent = TabContainer
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)

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

createTab("Main")
createTab("Teleport")
createTab("Visual")
createTab("Ajustes")

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

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
    button.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then warn("[KS HUB] Error en botón:", err) end
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

----------------------------------------------------------
-- PARTE 3: FUNCIONES DE UTILIDAD
----------------------------------------------------------

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

-- Botones Noclip ON / OFF
createButton(mainScroll, "Noclip ON", function()
    if not noclip then toggleNoclip() end
end)
createButton(mainScroll, "Noclip OFF", function()
    if noclip then toggleNoclip() end
end)

-- Botón Anti‑Delay
createButton(mainScroll, "Toggle Anti-Delay", toggleAntiDelay)

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
-- BRING ITEMS (Tools cercanos)
----------------------------------------------------------
createButton(mainScroll, "Bring Items (Tools)", function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = getRoot(LocalPlayer)
    if not root then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local dist = (obj.Handle.Position - root.Position).Magnitude
            if dist < 100 then
                obj.Handle.CFrame = root.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

print("[KS HUB] Parte 4 lista")


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
-- PARTE 6: VISUAL + AJUSTES + INICIALIZACIÓN
----------------------------------------------------------

-- [Bloque 6.1] Full Bright
local fullBright = false
local oldBrightness, oldAmbient, oldOutdoorAmbient

createButton(Tabs["Visual"], "Toggle Full Bright", function()
    fullBright = not fullBright
    if fullBright then
        -- Guardar valores originales
        oldBrightness = Lighting.Brightness
        oldAmbient = Lighting.Ambient
        oldOutdoorAmbient = Lighting.OutdoorAmbient

        -- Forzar brillo
        Lighting.Brightness = 5
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        print("[KS HUB] Full Bright ON")
    else
        -- Restaurar valores
        if oldBrightness then Lighting.Brightness = oldBrightness end
        if oldAmbient then Lighting.Ambient = oldAmbient end
        if oldOutdoorAmbient then Lighting.OutdoorAmbient = oldOutdoorAmbient end
        print("[KS HUB] Full Bright OFF")
    end
end)

-- [Bloque 6.2] ESP Jugadores (Highlight + Nombre)
local espEnabled = false
local espConnections = {}

local function addESP(plr)
    if not plr.Character then return end
    local char = plr.Character

    -- Highlight
    if not char:FindFirstChild("KS_ESP_Highlight") then
        local h = Instance.new("Highlight")
        h.Name = "KS_ESP_Highlight"
        h.FillTransparency = 1
        h.OutlineColor = Color3.fromRGB(0, 255, 255)
        h.Adornee = char
        h.Parent = char
    end

    -- Billboard con nombre
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
        -- Añadir ESP a jugadores existentes
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                addESP(plr)
                espConnections[#espConnections+1] = plr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    addESP(plr)
                end)
            end
        end
        -- Nuevos jugadores
        espConnections[#espConnections+1] = Players.PlayerAdded:Connect(function(plr)
            espConnections[#espConnections+1] = plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                addESP(plr)
            end)
        end)
        print("[KS HUB] ESP ON")
    else
        -- Quitar ESP de todos
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                removeESP(plr)
            end
        end
        for _, c in ipairs(espConnections) do c:Disconnect() end
        espConnections = {}
        print("[KS HUB] ESP OFF")
    end
end

createButton(Tabs["Visual"], "Toggle ESP Jugadores", toggleESP)

-- [Bloque 6.3] Ajustes
createButton(Tabs["Ajustes"], "Cerrar HUB", function()
    MainFrame.Visible = false
end)

createButton(Tabs["Ajustes"], "Resetear Personaje", function()
    LocalPlayer:LoadCharacter()
end)

-- [Bloque 6.4] Inicialización
for name, frame in pairs(Tabs) do
    frame.Visible = (name == "Main")
end

print("[KS HUB] HUB cargado correctamente")
