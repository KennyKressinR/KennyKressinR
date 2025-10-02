-- KS HUB v0.2.x - Single-file LocalScript
-- Hecho para pegar directo en StarterPlayerScripts (o PlayerGui)
-- Colores: Main azul (0,102,204) - Botones celeste (102,204,255)
-- Funcionalidades: Noclip, AntiVoid, Waypoints (2), Teleport jugador, WalkSpeed/JumpPower presets,
-- Highlights, FullBright, GUI transparencia, Delay toggle, Changelog, Drag header, Close/reopen.
-- Nota: se usan pcall para seguridad. Si algo falla, revisa permisos del juego (algunos juegos bloquean cambios).

-- === Setup servicios y utilidades ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function safePcall(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    return ok, a, b, c
end

-- === Estado global ===
local hub = {
    enabled = true,
    noclip = false,
    antiVoid = false,
    highlights = false,
    fullbright = false,
    delay = false,
    connections = {},
    origCanCollide = {},
    savedWaypoints = {}, -- array of CFrame
    highlightObjects = {}, -- player.UserId -> Highlight instance
    origLighting = {},
    baseWalkSpeed = 16,
    baseJumpPower = 50
}

-- espera y setea referencias de personaje (y re-conecta cuando reaparece)
local character, humanoid, hrp
local function setCharacterRefs()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
    hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
    -- guardar valores base
    hub.baseWalkSpeed = humanoid and humanoid.WalkSpeed or hub.baseWalkSpeed
    hub.baseJumpPower = humanoid and humanoid.JumpPower or hub.baseJumpPower
end
setCharacterRefs()
player.CharacterAdded:Connect(function()
    wait(0.2)
    setCharacterRefs()
end)

-- helper para acciones con delay opcional
local function doAction(action)
    if hub.delay then
        spawn(function()
            wait(0.5) -- delay fijo, puedes ajustar
            pcall(action)
        end)
    else
        pcall(action)
    end
end

-- === UI builder helpers ===
local MAIN_COLOR = Color3.fromRGB(0,102,204)
local BTN_COLOR = Color3.fromRGB(102,204,255)
local TEXT_COLOR = Color3.fromRGB(0,0,0)

local function new(name, class, props)
    local obj = Instance.new(class)
    obj.Name = name
    if props then
        for k,v in pairs(props) do obj[k] = v end
    end
    return obj
end

-- === Construcción GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KSHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = new("MainFrame","Frame",{
    Size = UDim2.new(0,420,0,520),
    Position = UDim2.new(0.5,-210,0.5,-260),
    BackgroundColor3 = MAIN_COLOR,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5,0.5)
})
mainFrame.Parent = screenGui

-- Header
local header = new("Header","Frame",{
    Size = UDim2.new(1,0,0,40),
    Position = UDim2.new(0,0,0,0),
    BackgroundColor3 = Color3.fromRGB(0,76,153),
    Parent = mainFrame
})
local title = new("Title","TextLabel",{
    Size = UDim2.new(1,-50,1,0),
    Position = UDim2.new(0,0,0,0),
    BackgroundTransparency = 1,
    Text = "KS HUB v0.2.x",
    TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.SourceSansBold,
    TextScaled = true,
    Parent = header
})
local closeBtn = new("CloseBtn","TextButton",{
    Size = UDim2.new(0,50,1,0),
    Position = UDim2.new(1,-50,0,0),
    BackgroundColor3 = BTN_COLOR,
    Text = "X",
    Font = Enum.Font.SourceSansBold,
    TextScaled = true,
    Parent = header
})

-- Drag implementation (manual, fiable)
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(inp)
                if inp == input and dragging then
                    local delta = inp.Position - dragStart
                    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            hub.connections["drag"] = moveConn
        end
    end)
end

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Tabs
local tabs = {"Principal","Visuales","Ajustes"}
local tabButtons = {}
local contentFrames = {}
for i,name in ipairs(tabs) do
    local btn = new("TabBtn"..i,"TextButton",{
        Size = UDim2.new(1/#tabs,0,0,30),
        Position = UDim2.new((i-1)/#tabs,0,0,40),
        BackgroundColor3 = BTN_COLOR,
        Text = name,
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        Parent = mainFrame
    })
    tabButtons[i] = btn

    local frame = new("Content"..i,"ScrollingFrame",{
        Size = UDim2.new(1,-10,1,-80),
        Position = UDim2.new(0,5,0,80),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0,0,1,0),
        Visible = (i==1),
        Parent = mainFrame
    })
    contentFrames[i] = frame

    btn.MouseButton1Click:Connect(function()
        for j,f in ipairs(contentFrames) do f.Visible = (i==j) end
    end)
end

-- Helper para añadir botones ordenados verticalmente
local function addButton(parent, text, y)
    local btn = new("Btn_"..text,"TextButton",{
        Size = UDim2.new(0,170,0,32),
        Position = UDim2.new(0,12,0,y),
        BackgroundColor3 = BTN_COLOR,
        Text = text,
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        Parent = parent
    })
    return btn
end

local function addLabel(parent, text, y)
    local lbl = new("Lbl_"..text,"TextLabel",{
        Size = UDim2.new(1,-20,0,24),
        Position = UDim2.new(0,10,0,y),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        Parent = parent
    })
    return lbl
end

-- === Contenido Tab Principal ===
local principal = contentFrames[1]
addLabel(principal, "Principal - Funciones", 6)

-- Noclip toggle
local noclipBtn = addButton(principal, "Activar Noclip", 40)
noclipBtn.MouseButton1Click:Connect(function()
    doAction(function()
        hub.noclip = not hub.noclip
        noclipBtn.Text = hub.noclip and "Desactivar Noclip" or "Activar Noclip"
        if hub.noclip then
            -- guardar CanCollide actuales y setear false
            hub.origCanCollide = {}
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    hub.origCanCollide[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        else
            -- restaurar
            for part, val in pairs(hub.origCanCollide) do
                if part and part.Parent then
                    pcall(function() part.CanCollide = val end)
                end
            end
            hub.origCanCollide = {}
        end
    end)
end)

-- Delay toggle (retrasa la ejecución de botones)
local delayBtn = addButton(principal, "Delay: OFF", 80)
delayBtn.MouseButton1Click:Connect(function()
    doAction(function()
        hub.delay = not hub.delay
        delayBtn.Text = hub.delay and "Delay: ON" or "Delay: OFF"
    end)
end)

-- AntiVoid
local antiVoidBtn = addButton(principal, "Activar AntiVoid", 120)
antiVoidBtn.MouseButton1Click:Connect(function()
    doAction(function()
        hub.antiVoid = not hub.antiVoid
        antiVoidBtn.Text = hub.antiVoid and "Desactivar AntiVoid" or "Activar AntiVoid"
    end)
end)

-- Waypoints: Save1 Save2 Load1 Load2
addLabel(principal,"Waypoints (2 slots)", 160)
local save1 = addButton(principal,"Save 1", 190)
local load1 = addButton(principal,"Load 1", 190 + 36)
local save2 = addButton(principal,"Save 2", 190 + 72)
local load2 = addButton(principal,"Load 2", 190 + 108)

save1.MouseButton1Click:Connect(function()
    doAction(function()
        if hrp then hub.savedWaypoints[1] = hrp.CFrame end
    end)
end)
save2.MouseButton1Click:Connect(function()
    doAction(function()
        if hrp then hub.savedWaypoints[2] = hrp.CFrame end
    end)
end)
load1.MouseButton1Click:Connect(function()
    doAction(function()
        if hub.savedWaypoints[1] and hrp then
            pcall(function() hrp.CFrame = hub.savedWaypoints[1] end)
        end
    end)
end)
load2.MouseButton1Click:Connect(function()
    doAction(function()
        if hub.savedWaypoints[2] and hrp then
            pcall(function() hrp.CFrame = hub.savedWaypoints[2] end)
        end
    end)
end)

-- WalkSpeed presets
addLabel(principal,"WalkSpeed Presets", 320)
local wsNormal = addButton(principal,"Normal", 350)
local ws30 = addButton(principal,"30", 350 + 36)
local ws50 = addButton(principal,"50", 350 + 72)
local ws75 = addButton(principal,"75", 350 + 108)
local ws150 = addButton(principal,"150", 350 + 144)
local ws200 = addButton(principal,"200", 350 + 180)

local function setWalkSpeed(v)
    doAction(function()
        if humanoid then pcall(function() humanoid.WalkSpeed = v end) end
    end)
end

wsNormal.MouseButton1Click:Connect(function() setWalkSpeed(hub.baseWalkSpeed) end)
ws30.MouseButton1Click:Connect(function() setWalkSpeed(30) end)
ws50.MouseButton1Click:Connect(function() setWalkSpeed(50) end)
ws75.MouseButton1Click:Connect(function() setWalkSpeed(75) end)
ws150.MouseButton1Click:Connect(function() setWalkSpeed(150) end)
ws200.MouseButton1Click:Connect(function() setWalkSpeed(200) end)

-- JumpPower presets
addLabel(principal,"JumpPower Presets", 520)
local jpReset = addButton(principal,"Reset Jump", 550)
local jp25 = addButton(principal,"+25%", 550 + 36)
local jp50 = addButton(principal,"+50%", 550 + 72)
local jp100 = addButton(principal,"+100%", 550 + 108)

local function setJumpPercent(mult)
    doAction(function()
        if humanoid then
            pcall(function()
                humanoid.JumpPower = math.floor(hub.baseJumpPower * (1 + mult))
            end)
        end
    end)
end
jpReset.MouseButton1Click:Connect(function() doAction(function() if humanoid then pcall(function() humanoid.JumpPower = hub.baseJumpPower end) end end) end)
jp25.MouseButton1Click:Connect(function() setJumpPercent(0.25) end)
jp50.MouseButton1Click:Connect(function() setJumpPercent(0.5) end)
jp100.MouseButton1Click:Connect(function() setJumpPercent(1.0) end)

-- Teleport a jugador (textbox + button)
addLabel(principal,"Teleport a jugador (nombre parcial)", 610)
local tpBox = new("TPBox","TextBox",{
    Size = UDim2.new(0,220,0,30),
    Position = UDim2.new(0,10,0,640),
    Text = "",
    PlaceholderText = "Escribe nombre (parcial o completo)",
    Parent = principal,
    ClearTextOnFocus = false
})
local tpBtn = addButton(principal,"TP", 640)
tpBtn.Position = UDim2.new(0,240,0,640)
tpBtn.MouseButton1Click:Connect(function()
    doAction(function()
        local query = tpBox.Text:lower():gsub("%s+","")
        if query == "" then return end
        local target
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= player and pl.Name:lower():gsub("%s+",""):find(query,1,true) then
                target = pl
                break
            end
        end
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            end)
        end
    end)
end)

-- === Contenido Tab Visuales ===
local visuals = contentFrames[2]
addLabel(visuals, "Visuales - Mostrar jugadores / fullbright", 6)

-- Highlights players toggle
local hlBtn = addButton(visuals, "Toggle Highlights Jugadores", 40)
hlBtn.MouseButton1Click:Connect(function()
    doAction(function()
        hub.highlights = not hub.highlights
        hlBtn.Text = hub.highlights and "Highlights: ON" or "Highlights: OFF"
        if hub.highlights then
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= player and pl.Character and not hub.highlightObjects[pl.UserId] then
                    local ok, h = pcall(function()
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = pl.Character
                        highlight.Adornee = pl.Character
                        highlight.FillTransparency = 0.6
                        highlight.OutlineTransparency = 0.8
                        hub.highlightObjects[pl.UserId] = highlight
                    end)
                end
            end
        else
            for id, highlight in pairs(hub.highlightObjects) do
                if highlight and highlight.Parent then
                    pcall(function() highlight:Destroy() end)
                end
                hub.highlightObjects[id] = nil
            end
        end
    end)
end)

-- Auto-add highlights on player join when toggled
Players.PlayerAdded:Connect(function(pl)
    if hub.highlights then
        spawn(function()
            wait(0.2)
            if pl.Character then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = pl.Character
                    highlight.Adornee = pl.Character
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0.8
                    hub.highlightObjects[pl.UserId] = highlight
                end)
            end
        end)
    end
end)
Players.PlayerRemoving:Connect(function(pl)
    if hub.highlightObjects[pl.UserId] then
        hub.highlightObjects[pl.UserId] = nil
    end
end)

-- FullBright toggle (intenta cambiar Lighting localmente)
local fbBtn = addButton(visuals, "Toggle FullBright", 90)
fbBtn.MouseButton1Click:Connect(function()
    doAction(function()
        hub.fullbright = not hub.fullbright
        fbBtn.Text = hub.fullbright and "FullBright: ON" or "FullBright: OFF"
        if hub.fullbright then
            -- guardar originales
            hub.origLighting.Brightness = Lighting:FindFirstChild("Brightness") and Lighting.Brightness or Lighting:GetAttribute("KSHub_Brightness") or Lighting.Brightness
            hub.origLighting.Ambient = Lighting.Ambient
            hub.origLighting.OutdoorAmbient = Lighting.OutdoorAmbient
            hub.origLighting.GlobalShadows = Lighting.GlobalShadows
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(255,255,255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
                Lighting.GlobalShadows = false
            end)
        else
            -- restaurar
            pcall(function()
                if hub.origLighting.Ambient then Lighting.Ambient = hub.origLighting.Ambient end
                if hub.origLighting.OutdoorAmbient then Lighting.OutdoorAmbient = hub.origLighting.OutdoorAmbient end
                if hub.origLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = hub.origLighting.GlobalShadows end
            end)
            hub.origLighting = {}
        end
    end)
end)

-- === Contenido Tab Ajustes ===
local ajustes = contentFrames[3]
addLabel(ajustes, "Ajustes - Transparencia / Changelog", 6)

-- Transparencia GUI
local transLabel = addLabel(ajustes, "Transparencia GUI", 50)
local t75 = addButton(ajustes, "75%", 90)
local t50 = addButton(ajustes, "50%", 90 + 36)
local t25 = addButton(ajustes, "25%", 90 + 72)
t75.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.75 end)
t50.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.5 end)
t25.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.25 end)

-- Changelog (simple)
local changelog = new("Changelog","TextLabel",{
    Size = UDim2.new(1,-20,0,150),
    Position = UDim2.new(0,10,0,170),
    BackgroundTransparency = 0.2,
    BackgroundColor3 = Color3.fromRGB(10,40,80),
    TextColor3 = Color3.fromRGB(255,255,255),
    Text = "Changelog v0.2.x:\n- Noclip\n- AntiVoid\n- Waypoints (2)\n- Teleport por nombre parcial\n- Highlights & FullBright\n- WalkSpeed & Jump presets\n- Delay toggle y UI ajustes",
    Font = Enum.Font.SourceSans,
    TextWrapped = true,
    TextScaled = false,
    Parent = ajustes
})

-- === Core loops: Noclip y AntiVoid ===
-- RenderStepped loop
hub.connections["render"] = RunService.RenderStepped:Connect(function()
    -- Noclip (si activado): asegurar que partes tengan CanCollide = false
    if hub.noclip and character and character.Parent then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if hub.origCanCollide[part] == nil then
                    hub.origCanCollide[part] = part.CanCollide
                end
                if part.CanCollide then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end

    -- AntiVoid
    if hub.antiVoid and hrp and hrp.Position.Y < -50 then
        -- si hay waypoint 1 o 2, usar la primera guardada; sino teleport near spawn
        if hub.savedWaypoints[1] then
            pcall(function() hrp.CFrame = hub.savedWaypoints[1] + Vector3.new(0,5,0) end)
        else
            -- intentar Teleport al SpawnLocation del mapa (si existe)
            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                pcall(function() hrp.CFrame = spawn.CFrame + Vector3.new(0,5,0) end)
            else
                -- fallback (0,50,0)
                pcall(function() hrp.CFrame = CFrame.new(0,50,0) end)
            end
        end
    end
end)

-- Limpieza al desconectar (si hace falta) - por si el script es destruido
local function cleanup()
    -- desconectar conexiones
    for k, conn in pairs(hub.connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
        hub.connections[k] = nil
    end
    -- restaurar collisions
    for part, val in pairs(hub.origCanCollide) do
        if part and part.Parent then pcall(function() part.CanCollide = val end) end
    end
    hub.origCanCollide = {}
    -- destruir highlights
    for id, highlight in pairs(hub.highlightObjects) do
        if highlight and highlight.Parent then pcall(function() highlight:Destroy() end) end
    end
    hub.highlightObjects = {}
    -- restore lighting
    if hub.fullbright then
        pcall(function()
            if hub.origLighting.Ambient then Lighting.Ambient = hub.origLighting.Ambient end
            if hub.origLighting.OutdoorAmbient then Lighting.OutdoorAmbient = hub.origLighting.OutdoorAmbient end
            if hub.origLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = hub.origLighting.GlobalShadows end
        end)
    end
    -- destroy gui
    if screenGui and screenGui.Parent then pcall(function() screenGui:Destroy() end) end
end

-- Bind cleanup when player leaves or script destroyed
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then cleanup() end
end)

-- Mensaje final (pequeño)
print("[KS HUB] cargado. Usa la GUI para activar funciones.")

-- === Fin de script ===
