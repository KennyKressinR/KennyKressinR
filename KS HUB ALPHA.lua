--========================================================
-- KS HUB - COMPLETO (AZUL+CELESTE, FULL BRIGHT, ESP, SCROLL EN MAIN)
-- Con prints de depuración y parent en PlayerGui
--========================================================

print("[KS HUB] Script iniciado")

--========================================================
-- [ SECCIÓN 1 ] SERVICIOS Y VARIABLES
--========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

print("[KS HUB] Servicios cargados")

--========================================================
-- [ SECCIÓN 2 ] GUI PRINCIPAL (AZUL + BOTONES CELESTES)
--========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
print("[KS HUB] ScreenGui parentado a PlayerGui")

-- Botón flotante
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(1, -70, 1, -70)
ToggleButton.Text = "≡"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 60, 120) -- azul oscuro
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton
print("[KS HUB] ToggleButton creado")

-- Marco principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 80) -- azul oscuro
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame
print("[KS HUB] MainFrame creado")

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
    tabButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255) -- celeste
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
        print("[KS HUB] Pestaña abierta:", name)
    end)
end

-- Crear pestañas
createTab("Main")
createTab("Teleport")
createTab("Visual")
createTab("Ajustes")

-- Mostrar/Ocultar HUB con el botón flotante
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    print("[KS HUB] Toggle HUB:", MainFrame.Visible)
end)

-- Función para crear botones (celeste)
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(80, 180, 255) -- celeste
    button.BorderSizePixel = 0
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    button.MouseButton1Click:Connect(function()
        print("[KS HUB] Botón pulsado:", text)
        local ok, err = pcall(callback)
        if not ok then
            warn("[KS HUB] Error en callback de botón '" .. text .. "': " .. tostring(err))
        end
    end)
    return button
end

print("[KS HUB] GUI principal lista")

--========================================================
-- [ SECCIÓN 3 ] FUNCIONES DEL HUB
--========================================================
local function getRoot(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function teleportToMouse()
    local root = getRoot(LocalPlayer)
    if root and Mouse and Mouse.Hit then
        root.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
        print("[KS HUB] Teleport al mouse ejecutado")
    else
        warn("[KS HUB] Teleport al mouse no disponible (Root o Mouse.Hit nulo)")
    end
end

local function teleportToPlayer(player)
    local myRoot = getRoot(LocalPlayer)
    local targetRoot = getRoot(player)
    if myRoot and targetRoot then
        LocalPlayer.Character:PivotTo(targetRoot.CFrame + Vector3.new(0, 3, 0))
        print("[KS HUB] Teleport a jugador:", player.Name)
    else
        warn("[KS HUB] No se pudo teletransportar a", player and player.Name or "nil")
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
        print("[KS HUB] Noclip ON")
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        print("[KS HUB] Noclip OFF")
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
    if not antiDelay then originalDurations = {} end
    print("[KS HUB] Anti-Delay:", antiDelay and "ON" or "OFF")
end

-- Velocidad y salto helpers
local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function setSpeed(v)
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = v print("[KS HUB] WalkSpeed =", v) else warn("[KS HUB] Humanoid no encontrado para WalkSpeed") end
end

local function getBaseJump()
    local hum = getHumanoid()
    if hum and hum.JumpPower and hum.JumpPower > 0 then return hum.JumpPower end
    return 50
end

local function setJumpMultiplier(mult)
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = getBaseJump() * mult
        print("[KS HUB] JumpPower mult =", mult, "=>", hum.JumpPower)
    else
        warn("[KS HUB] Humanoid no encontrado para JumpPower")
    end
end

print("[KS HUB] Funciones listas")

--========================================================
-- [ SECCIÓN 4 ] MAIN (SCROLL + TELEPORT SLOTS + VELOCIDAD + SALTO)
--========================================================
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

-- Botones principales
createButton(mainScroll, "Toggle Noclip", toggleNoclip)
createButton(mainScroll, "Toggle Anti-Delay", toggleAntiDelay)

-- Teleport Slots
local savedSlots = {nil, nil, nil, nil}
local function saveSlot(i)
    local root = getRoot(LocalPlayer)
    if root then
        savedSlots[i] = root.CFrame
        print("[KS HUB] Guardado slot", i)
    else
        warn("[KS HUB] No se pudo guardar slot", i, "(Root nulo)")
    end
end
local function loadSlot(i)
    local root = getRoot(LocalPlayer)
    if root and savedSlots[i] then
        LocalPlayer.Character:PivotTo(savedSlots[i])
        print("[KS HUB] Cargado slot", i)
    else
        warn("[KS HUB] Slot", i, "vacío o Root nulo")
    end
end

for i = 1, 4 do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = mainScroll

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.5, -4, 1, 0)
    saveBtn.Position = UDim2.new(0, 0, 0, 0)
    saveBtn.Text = "Save" .. i
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.TextSize = 16
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
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
    loadBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    loadBtn.BorderSizePixel = 0
    loadBtn.Parent = row
    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 6)
    loadCorner.Parent = loadBtn
    loadBtn.MouseButton1Click:Connect(function() loadSlot(i) end)
end

-- =========================
-- VELOCIDAD (SLIDER 16 - 150)
-- =========================
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
speedBar.BorderSizePixel = 0
speedBar.Parent = mainScroll
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedBar

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedBar
local speedFillCorner = Instance.new("UICorner")
speedFillCorner.CornerRadius = UDim.new(0, 6)
speedFillCorner.Parent = speedFill

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 16, 0, 16)
speedKnob.Position = UDim2.new(0, -8, 0.5, -8)
speedKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
speedKnob.BorderSizePixel = 0
speedKnob.Parent = speedBar
local speedKnobCorner = Instance.new("UICorner")
speedKnobCorner.CornerRadius = UDim.new(1, 0)
speedKnobCorner.Parent = speedKnob

local draggingSpeed = false
local function setSpeedFromX(x)
    local barAbsPos = speedBar.AbsolutePosition.X
    local barAbsSize = speedBar.AbsoluteSize.X
    local rel = math.clamp((x - barAbsPos) / barAbsSize, 0, 1)
    local value = math.floor(16 + (150 - 16) * rel)
    speedFill.Size = UDim2.new(rel, 0, 1, 0)
    speedKnob.Position = UDim2.new(rel, -8, 0.5, -8)
    speedLabel.Text = "Velocidad: " .. tostring(value)
    setSpeed(value)
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

-- -- =========================
-- SALTO (SLIDER 50 - 60)
-- =========================
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, 0, 0, 24)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Salto: 50"
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 16
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.Parent = mainScroll

local jumpBar = Instance.new("Frame")
jumpBar.Size = UDim2.new(1, 0, 0, 10)
jumpBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpBar.BorderSizePixel = 0
jumpBar.Parent = mainScroll
local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 6)
jumpCorner.Parent = jumpBar

local jumpFill = Instance.new("Frame")
jumpFill.Size = UDim2.new(0, 0, 1, 0)
jumpFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
jumpFill.BorderSizePixel = 0
jumpFill.Parent = jumpBar
local jumpFillCorner = Instance.new("UICorner")
jumpFillCorner.CornerRadius = UDim.new(0, 6)
jumpFillCorner.Parent = jumpFill

local jumpKnob = Instance.new("Frame")
jumpKnob.Size = UDim2.new(0, 16, 0, 16)
jumpKnob.Position = UDim2.new(0, -8, 0.5, -8)
jumpKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
jumpKnob.BorderSizePixel = 0
jumpKnob.Parent = jumpBar
local jumpKnobCorner = Instance.new("UICorner")
jumpKnobCorner.CornerRadius = UDim.new(1, 0)
jumpKnobCorner.Parent = jumpKnob

local draggingJump = false
local function setJumpFromX(x)
    local barAbsPos = jumpBar.AbsolutePosition.X
    local barAbsSize = jumpBar.AbsoluteSize.X
    local rel = math.clamp((x - barAbsPos) / barAbsSize, 0, 1)
    local value = math.floor(50 + (60 - 50) * rel) -- rango 50 a 60
    jumpFill.Size = UDim2.new(rel, 0, 1, 0)
    jumpKnob.Position = UDim2.new(rel, -8, 0.5, -8)
    jumpLabel.Text = "Salto: " .. tostring(value)
    setJumpMultiplier(value / 50) -- relativo al base 50
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

--========================================================
-- [ SECCIÓN 5 ] TELEPORT MEJORADO (BUSCADOR + SCROLL + REFRESH)
--========================================================
createButton(Tabs["Teleport"], "Teleport al Mouse", teleportToMouse)

-- Caja de búsqueda
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, 0, 0, 30)
searchBox.Text = "" -- vacío, NO "TextBox"
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

-- Botón de refrescar
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

-- Lista con scroll
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, -100) -- espacio para controles
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

-- Poblar lista
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
    print("[KS HUB] Lista de jugadores poblada. Filtro:", filter == "" and "(todos)" or filter)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    populatePlayerList(searchBox.Text)
end)
refreshBtn.MouseButton1Click:Connect(function()
    populatePlayerList(searchBox.Text)
end)
Players.PlayerAdded:Connect(function() populatePlayerList(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() populatePlayerList(searchBox.Text) end)

populatePlayerList("")

print("[KS HUB] Teleport listo")

--========================================================
-- [ SECCIÓN 6 ] VISUAL (FULL BRIGHT + ESP)
--========================================================
-- Full Bright
local fullBright = false
local oldBrightness, oldAmbient, oldOutdoorAmbient

createButton(Tabs["Visual"], "Toggle Full Bright", function()
    fullBright = not fullBright
    if fullBright then
        oldBrightness, oldAmbient, oldOutdoorAmbient = Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient
        Lighting.Brightness = 5
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        print("[KS HUB] Full Bright ON")
    else
        if oldBrightness ~= nil then Lighting.Brightness = oldBrightness end
        if oldAmbient ~= nil then Lighting.Ambient = oldAmbient end
        if oldOutdoorAmbient ~= nil then Lighting.OutdoorAmbient = oldOutdoorAmbient end
        print("[KS HUB] Full Bright OFF")
    end
end)

-- ESP Jugadores (Highlight por jugador)
local espEnabled = false
local espConnections = {}
local function addHighlightToCharacter(char)
    if not char then return end
    if char:FindFirstChild("KS_ESP_Highlight") then return end
    local h = Instance.new("Highlight")
    h.Name = "KS_ESP_Highlight"
    h.FillTransparency = 1
    h.OutlineColor = Color3.fromRGB(0, 255, 255) -- celeste
    h.Adornee = char
    h.Parent = char
end

local function removeHighlightFromCharacter(char)
    if not char then return end
    local h = char:FindFirstChild("KS_ESP_Highlight")
    if h then h:Destroy() end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                addHighlightToCharacter(plr.Character)
                espConnections[#espConnections+1] = plr.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    addHighlightToCharacter(char)
                end)
            end
        end
        espConnections[#espConnections+1] = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                addHighlightToCharacter(char)
            end)
        end)
        print("[KS HUB] ESP ON")
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then removeHighlightFromCharacter(plr.Character) end
        end
        for _, c in ipairs(espConnections) do c:Disconnect() end
        espConnections = {}
        print("[KS HUB] ESP OFF")
    end
end

createButton(Tabs["Visual"], "Toggle ESP Jugadores", toggleESP)

print("[KS HUB] Visual listo")

--========================================================
-- [ SECCIÓN 7 ] AJUSTES (UTILIDADES)
--========================================================
createButton(Tabs["Ajustes"], "Cerrar HUB", function()
    MainFrame.Visible = false
    print("[KS HUB] HUB cerrado desde Ajustes")
end)

createButton(Tabs["Ajustes"], "Resetear Personaje", function()
    LocalPlayer:LoadCharacter()
    print("[KS HUB] Personaje reseteado")
end)

print("[KS HUB] Ajustes listo")

--========================================================
-- [ SECCIÓN 8 ] INICIALIZACIÓN DE PESTAÑA POR DEFECTO
--========================================================
for name, frame in pairs(Tabs) do
    frame.Visible = (name == "Main")
end
print("[KS HUB] Inicialización completa. Pestaña 'Main' visible por defecto")
