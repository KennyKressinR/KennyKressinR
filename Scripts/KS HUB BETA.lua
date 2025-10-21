----------------------------------------------------------
-- PARTE 1: INICIALIZACIÓN
----------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Diccionario de pestañas
local Tabs = {}

print("[KS HUB] Parte 1 lista")

----------------------------------------------------------
-- PARTE 2: INTERFAZ PRINCIPAL
----------------------------------------------------------

-- [Bloque 2.1] ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- [Bloque 2.2] MainFrame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- [Bloque 2.3] Botón Toggle (abrir/cerrar HUB)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 1, -120)
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
anchored = true
initialPosition = ToggleButton.Position

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

-- [Bloque 2.4] Contenedor de pestañas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -50)
TabContainer.Position = UDim2.new(0, 5, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

-- [Bloque 2.5] Contenido
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 130, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- [Bloque 2.6] Función para crear pestañas
Tabs = {}

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

-- [Bloque 2.7] Toggle HUB
local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://77300603936003"
toggleSound.Volume = 1
toggleSound.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    toggleSound:Play()
end)

-- [Bloque 2.8] Funciones para crear botones
function createButton(parent, text, callback)
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

-- Botón con estado ON/OFF
function createToggleButton(parent, text, stateVar, callbackOn, callbackOff)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text .. " [OFF]"
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://9120507525"
    clickSound.Volume = 1
    clickSound.Parent = button

    _G[stateVar] = false

    button.MouseButton1Click:Connect(function()
        clickSound:Play()
        _G[stateVar] = not _G[stateVar]
        if _G[stateVar] then
            button.Text = text .. " [ON]"
            if callbackOn then callbackOn() end
        else
            button.Text = text .. " [OFF]"
            if callbackOff then callbackOff() end
        end
    end)

    return button
end

print("[KS HUB] Parte 2 lista")

----------------------------------------------------------
-- PARTE 3: MAIN
----------------------------------------------------------

-- [Bloque 3.1] Noclip
local noclipConnection
createToggleButton(Tabs["Main"], "Noclip", "noclipEnabled",
    function() -- ON
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        print("[KS HUB] Noclip ON")
    end,
    function() -- OFF
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        print("[KS HUB] Noclip OFF")
    end
)

----------------------------------------------------------
-- [Bloque 3.2] Anti-Delay
----------------------------------------------------------
local antiDelayConnection
createToggleButton(Tabs["Main"], "Anti-Delay", "antiDelayEnabled",
    function() -- ON
        antiDelayConnection = game:GetService("RunService").Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
        print("[KS HUB] Anti-Delay ON")
    end,
    function() -- OFF
        if antiDelayConnection then
            antiDelayConnection:Disconnect()
            antiDelayConnection = nil
        end
        print("[KS HUB] Anti-Delay OFF")
    end
)

----------------------------------------------------------
-- [Bloque 3.3] Infinite Jump
----------------------------------------------------------
local infiniteJumpConnection
createToggleButton(Tabs["Main"], "Infinite Jump", "infiniteJumpEnabled",
    function() -- ON
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if _G.infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
        print("[KS HUB] Infinite Jump ON")
    end,
    function() -- OFF
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
        print("[KS HUB] Infinite Jump OFF")
    end
)

----------------------------------------------------------
-- [Bloque 3.4] WalkSpeed y JumpPower
----------------------------------------------------------
-- WalkSpeed
local wsBox = Instance.new("TextBox")
wsBox.Size = UDim2.new(1, 0, 0, 30)
wsBox.PlaceholderText = "WalkSpeed (default 16)"
wsBox.Text = ""
wsBox.Font = Enum.Font.Gotham
wsBox.TextSize = 16
wsBox.TextColor3 = Color3.new(1, 1, 1)
wsBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
wsBox.BackgroundTransparency = 0.1
wsBox.BorderSizePixel = 0
wsBox.ClearTextOnFocus = false
wsBox.Parent = Tabs["Main"]
Instance.new("UICorner", wsBox).CornerRadius = UDim.new(0, 6)

wsBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(wsBox.Text)
        if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
            print("[KS HUB] WalkSpeed set to", val)
        end
    end
end)

-- JumpPower
local jpBox = Instance.new("TextBox")
jpBox.Size = UDim2.new(1, 0, 0, 30)
jpBox.PlaceholderText = "JumpPower (default 50)"
jpBox.Text = ""
jpBox.Font = Enum.Font.Gotham
jpBox.TextSize = 16
jpBox.TextColor3 = Color3.new(1, 1, 1)
jpBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jpBox.BackgroundTransparency = 0.1
jpBox.BorderSizePixel = 0
jpBox.ClearTextOnFocus = false
jpBox.Parent = Tabs["Main"]
Instance.new("UICorner", jpBox).CornerRadius = UDim.new(0, 6)

jpBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(jpBox.Text)
        if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
            print("[KS HUB] JumpPower set to", val)
        end
    end
end)

print("[KS HUB] Parte 3 lista")

----------------------------------------------------------
-- PARTE 4: TELEPORT
----------------------------------------------------------

-- [Bloque 4.1] Teleport a Jugadores
local function teleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            print("[KS HUB] Teleport a " .. playerName)
        end
    else
        warn("[KS HUB] Jugador no encontrado:", playerName)
    end
end

-- Caja de texto para escribir nombre de jugador
local tpBox = Instance.new("TextBox")
tpBox.Size = UDim2.new(1, 0, 0, 30)
tpBox.PlaceholderText = "Nombre del jugador"
tpBox.Text = ""
tpBox.Font = Enum.Font.Gotham
tpBox.TextSize = 16
tpBox.TextColor3 = Color3.new(1, 1, 1)
tpBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpBox.BackgroundTransparency = 0.1
tpBox.BorderSizePixel = 0
tpBox.ClearTextOnFocus = false
tpBox.Parent = Tabs["Teleport"]
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 6)

createButton(Tabs["Teleport"], "Teleport to Player", function()
    if tpBox.Text ~= "" then
        teleportToPlayer(tpBox.Text)
    else
        warn("[KS HUB] Ingresa un nombre de jugador")
    end
end)

----------------------------------------------------------
-- [Bloque 4.2] Teleport a CFrame personalizado
----------------------------------------------------------
local function teleportToCFrame(cf)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf
        print("[KS HUB] Teleport a CFrame:", cf)
    end
end

-- Caja de texto para coordenadas
local coordBox = Instance.new("TextBox")
coordBox.Size = UDim2.new(1, 0, 0, 30)
coordBox.PlaceholderText = "Coordenadas: x,y,z"
coordBox.Text = ""
coordBox.Font = Enum.Font.Gotham
coordBox.TextSize = 16
coordBox.TextColor3 = Color3.new(1, 1, 1)
coordBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordBox.BackgroundTransparency = 0.1
coordBox.BorderSizePixel = 0
coordBox.ClearTextOnFocus = false
coordBox.Parent = Tabs["Teleport"]
Instance.new("UICorner", coordBox).CornerRadius = UDim.new(0, 6)

createButton(Tabs["Teleport"], "Teleport to Coords", function()
    local coords = {}
    for num in string.gmatch(coordBox.Text, "([^,]+)") do
        table.insert(coords, tonumber(num))
    end
    if #coords == 3 then
        teleportToCFrame(CFrame.new(coords[1], coords[2], coords[3]))
    else
        warn("[KS HUB] Coordenadas inválidas, usa formato x,y,z")
    end
end)

----------------------------------------------------------
-- [Bloque 4.3] Teleport a Spawn
----------------------------------------------------------
createButton(Tabs["Teleport"], "Teleport to Spawn", function()
    local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
        print("[KS HUB] Teleport a Spawn")
    else
        warn("[KS HUB] No se encontró SpawnLocation")
    end
end)

print("[KS HUB] Parte 4 lista")

----------------------------------------------------------
-- PARTE 5: VISUAL
----------------------------------------------------------

-- [Bloque 5.1] ESP básico (resaltar jugadores con Box/Highlight)
local espEnabled = false
local espConnections = {}

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        print("[KS HUB] ESP ON")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "KSHUB_ESP"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = plr.Character
            end
        end

        -- Conexión para nuevos jugadores
        espConnections["PlayerAdded"] = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                task.wait(1)
                if espEnabled and char:FindFirstChild("HumanoidRootPart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "KSHUB_ESP"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                end
            end)
        end)
    else
        print("[KS HUB] ESP OFF")
        -- Eliminar highlights
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("KSHUB_ESP") then
                plr.Character.KSHUB_ESP:Destroy()
            end
        end
        -- Desconectar eventos
        for _, conn in pairs(espConnections) do
            conn:Disconnect()
        end
        espConnections = {}
    end
end

createButton(Tabs["Visual"], "Toggle ESP", toggleESP)

----------------------------------------------------------
-- [Bloque 5.2] Chams (colorear personajes)
----------------------------------------------------------
local chamsEnabled = false

local function toggleChams()
    chamsEnabled = not chamsEnabled
    if chamsEnabled then
        print("[KS HUB] Chams ON")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    else
        print("[KS HUB] Chams OFF")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Plastic
                        part.Color = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    end
end

createButton(Tabs["Visual"], "Toggle Chams", toggleChams)

----------------------------------------------------------
-- [Bloque 5.3] FullBright
----------------------------------------------------------
local fullBrightEnabled = false
local oldLightingSettings = {}

local function toggleFullBright()
    fullBrightEnabled = not fullBrightEnabled
    local Lighting = game:GetService("Lighting")
    if fullBrightEnabled then
        oldLightingSettings.Brightness = Lighting.Brightness
        oldLightingSettings.ClockTime = Lighting.ClockTime
        oldLightingSettings.FogEnd = Lighting.FogEnd
        oldLightingSettings.GlobalShadows = Lighting.GlobalShadows
        oldLightingSettings.OutdoorAmbient = Lighting.OutdoorAmbient

        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e10
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

        print("[KS HUB] FullBright ON")
    else
        for prop, val in pairs(oldLightingSettings) do
            Lighting[prop] = val
        end
        print("[KS HUB] FullBright OFF")
    end
end

createButton(Tabs["Visual"], "Toggle FullBright", toggleFullBright)

print("[KS HUB] Parte 5 lista")

----------------------------------------------------------
-- PARTE 6: AJUSTES
----------------------------------------------------------

-- [Bloque 6.1] ScrollingFrame para Ajustes
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

----------------------------------------------------------
-- [Bloque 6.2] Reset Character
----------------------------------------------------------
createButton(ajustesScroll, "Reset Character", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
        print("[KS HUB] Character reset")
    end
end)

----------------------------------------------------------
-- [Bloque 6.3] Rejoin
----------------------------------------------------------
createButton(ajustesScroll, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    print("[KS HUB] Rejoin ejecutado")
end)

----------------------------------------------------------
-- [Bloque 6.4] Toggle Anclar/Desanclar Botón de abrir
----------------------------------------------------------
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

----------------------------------------------------------
-- PARTE 7: EXTRAS Y CIERRE
----------------------------------------------------------

-- Aquí puedes añadir funciones adicionales en el futuro,
-- como AutoFarm, AutoCollect, o cualquier otro módulo.

-- Ejemplo de plantilla para un botón extra:
-- createButton(Tabs["Main"], "Mi nueva función", function()
--     print("[KS HUB] Nueva función ejecutada")
-- end)

----------------------------------------------------------
-- Mensaje final de carga
----------------------------------------------------------
print("=======================================")
print("✅ KS HUB cargado correctamente")
print("✅ Todas las partes (1 a 7) listas")
print("=======================================")
