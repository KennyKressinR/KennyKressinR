----------------------------------------------------------
-- PARTE 1: INICIALIZACIÓN
----------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Tabs = {}

print("[KS HUB] Parte 1 lista")

----------------------------------------------------------
-- PARTE 2: INTERFAZ PRINCIPAL
----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Botón Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 1, -120)
ToggleButton.Text = "≡"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

anchored, initialPosition = true, ToggleButton.Position

-- Contenedor de pestañas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -50)
TabContainer.Position = UDim2.new(0, 5, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabContainer

-- Contenido
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 130, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Crear pestañas
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 36)
    tabButton.Text = name
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 16
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
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
createTab("Waypoints")

-- Toggle HUB
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Funciones de botones
function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    button.MouseButton1Click:Connect(callback)
    return button
end

function createToggleButton(parent, text, stateVar, callbackOn, callbackOff)
    local button = createButton(parent, text .. " [OFF]", function()
        _G[stateVar] = not _G[stateVar]
        if _G[stateVar] then
            button.Text = text .. " [ON]"
            if callbackOn then callbackOn() end
        else
            button.Text = text .. " [OFF]"
            if callbackOff then callbackOff() end
        end
    end)
    _G[stateVar] = false
    return button
end

print("[KS HUB] Parte 2 lista")

----------------------------------------------------------
-- PARTE 3: MAIN
----------------------------------------------------------
local noclipConnection
createToggleButton(Tabs["Main"], "Noclip", "noclipEnabled",
    function()
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end,
    function() if noclipConnection then noclipConnection:Disconnect() end end
)

local antiDelayConnection
createToggleButton(Tabs["Main"], "Anti-Delay", "antiDelayEnabled",
    function()
        antiDelayConnection = game:GetService("RunService").Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
    end,
    function() if antiDelayConnection then antiDelayConnection:Disconnect() end end
)

local infiniteJumpConnection
createToggleButton(Tabs["Main"], "Infinite Jump", "infiniteJumpEnabled",
    function()
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if _G.infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end,
    function() if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end end
)

-- WalkSpeed y JumpPower
local wsBox = Instance.new("TextBox")
wsBox.Size = UDim2.new(1, 0, 0, 30)
wsBox.PlaceholderText = "WalkSpeed (default 16)"
wsBox.Parent = Tabs["Main"]
wsBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(wsBox.Text)
        if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end
end)

local jpBox = Instance.new("TextBox")
jpBox.Size = UDim2.new(1, 0, 0, 30)
jpBox.PlaceholderText = "JumpPower (default 50)"
jpBox.Parent = Tabs["Main"]
jpBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(jpBox.Text)
        if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
        end
    end
end)

print("[KS HUB] Parte 3 lista")


----------------------------------------------------------
-- PARTE 4: TELEPORT
----------------------------------------------------------

-- [Bloque 4.1] Lista automática de jugadores
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 0, 150)
playerList.BackgroundTransparency = 1
playerList.ScrollBarThickness = 6
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.Parent = Tabs["Teleport"]

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = playerList

local function refreshPlayerList()
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createButton(playerList, plr.Name, function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        print("[KS HUB] Teleport a " .. plr.Name)
                    end
                end
            end)
        end
    end
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

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

-- [Bloque 5.1] ESP (resalta jugadores con Highlight)
local espConnections = {}
createToggleButton(Tabs["Visual"], "ESP", "espEnabled",
    function() -- ON
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
        espConnections["PlayerAdded"] = Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                task.wait(1)
                if _G.espEnabled and char:FindFirstChild("HumanoidRootPart") then
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
    end,
    function() -- OFF
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("KSHUB_ESP") then
                plr.Character.KSHUB_ESP:Destroy()
            end
        end
        for _, conn in pairs(espConnections) do conn:Disconnect() end
        espConnections = {}
    end
)

-- [Bloque 5.2] Chams (colorea personajes con Neon)
createToggleButton(Tabs["Visual"], "Chams", "chamsEnabled",
    function() -- ON
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
    end,
    function() -- OFF
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
)

-- [Bloque 5.3] FullBright
local oldLightingSettings = {}
createToggleButton(Tabs["Visual"], "FullBright", "fullBrightEnabled",
    function() -- ON
        local Lighting = game:GetService("Lighting")
        oldLightingSettings = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            OutdoorAmbient = Lighting.OutdoorAmbient
        }
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e10
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end,
    function() -- OFF
        local Lighting = game:GetService("Lighting")
        for prop, val in pairs(oldLightingSettings) do
            Lighting[prop] = val
        end
    end
)

print("[KS HUB] Parte 5 lista")


----------------------------------------------------------
-- PARTE 6: AJUSTES
----------------------------------------------------------

-- ScrollingFrame para Ajustes
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
-- [Bloque 6.1] Reset Character
----------------------------------------------------------
createButton(ajustesScroll, "Reset Character", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
        print("[KS HUB] Character reset")
    end
end)

----------------------------------------------------------
-- [Bloque 6.2] Rejoin
----------------------------------------------------------
createButton(ajustesScroll, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    print("[KS HUB] Rejoin ejecutado")
end)

----------------------------------------------------------
-- [Bloque 6.3] Toggle Anclar/Desanclar Botón de abrir
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
-- PARTE 7: WAYPOINTS
----------------------------------------------------------

local waypoints = {}       -- Guardamos los CFrame
local waypointNames = {}   -- Guardamos nombres opcionales

for i = 1, 8 do
    -- Caja de texto para nombre opcional
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, 0, 0, 24)
    nameBox.PlaceholderText = "Nombre (opcional) para Slot " .. i
    nameBox.Text = ""
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.TextColor3 = Color3.new(1, 1, 1)
    nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    nameBox.BackgroundTransparency = 0.1
    nameBox.BorderSizePixel = 0
    nameBox.ClearTextOnFocus = false
    nameBox.Parent = Tabs["Waypoints"]
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 6)

    -- Botón Save
    createButton(Tabs["Waypoints"], "Save " .. i, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            waypoints[i] = hrp.CFrame
            waypointNames[i] = nameBox.Text ~= "" and nameBox.Text or ("Waypoint " .. i)
            print("[KS HUB] Guardado Waypoint " .. i .. " (" .. waypointNames[i] .. ")")
        else
            warn("[KS HUB] No se pudo guardar, personaje no encontrado")
        end
    end)

    -- Botón Load
    createButton(Tabs["Waypoints"], "Load " .. i, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and waypoints[i] then
            hrp.CFrame = waypoints[i]
            print("[KS HUB] Teleport a Waypoint " .. i .. " (" .. (waypointNames[i] or "sin nombre") .. ")")
        else
            warn("[KS HUB] No hay Waypoint guardado en slot " .. i)
        end
    end)
end

----------------------------------------------------------
-- Mensaje final de carga
----------------------------------------------------------
print("=======================================")
print("✅ KS HUB cargado correctamente")
print("✅ Todas las partes (1 a 7) listas")
print("=======================================")
