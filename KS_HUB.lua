-- KS HUB v0.2.x - UI mejorado (centrado, scroll correcto, toggle cerrar/abrir)
-- Pegar como LocalScript en StarterPlayerScripts

-- ===== Servicios y utilidades =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function safe(fn, ...) local ok, a = pcall(fn, ...) if not ok then return nil end return a end

-- ===== Estado =====
local hub = {
    noclip = false,
    antiVoid = false,
    highlights = false,
    fullbright = false,
    delay = false,
    savedWaypoints = {},
    highlightObjects = {},
    origCanCollide = {},
    origLighting = {}
}

-- referencias de personaje y re-conexión
local character, humanoid, hrp
local function setCharRefs()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = safe(function() return character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid") end)
    hrp = safe(function() return character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart") end)
    if humanoid then
        hub.baseWalkSpeed = humanoid.WalkSpeed
        hub.baseJumpPower = humanoid.JumpPower
    else
        hub.baseWalkSpeed = hub.baseWalkSpeed or 16
        hub.baseJumpPower = hub.baseJumpPower or 50
    end
end
setCharRefs()
player.CharacterAdded:Connect(function() wait(0.1) setCharRefs() end)

-- ===== Helpers UI =====
local MAIN_COLOR = Color3.fromRGB(0,102,204)
local BTN_COLOR = Color3.fromRGB(102,204,255)
local TEXT_COLOR = Color3.fromRGB(0,0,0)

local function new(class, props)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k] = v end end
    return o
end

-- ===== Crear ScreenGui y MainFrame centrado =====
local screenGui = new("ScreenGui",{Name = "KSHub",ResetOnSpawn = false,Parent = playerGui})
local main = new("Frame",{
    Name = "Main",
    Size = UDim2.new(0,360,0,480),
    Position = UDim2.new(0.5,0,0.5,0),
    AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundColor3 = MAIN_COLOR,
    BorderSizePixel = 0,
    Parent = screenGui
})

-- Header con drag y botón cerrar
local header = new("Frame",{Size = UDim2.new(1,0,0,40),BackgroundColor3 = Color3.fromRGB(0,76,153),Parent = main})
local title = new("TextLabel",{Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text="KS HUB v0.2.x",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.SourceSansBold,TextScaled=true,Parent=header})
local closeBtn = new("TextButton",{Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-50,0,0),BackgroundColor3=BTN_COLOR,Text="X",Font=Enum.Font.SourceSansBold,TextScaled=true,Parent=header})

-- Toggle button (aparece cuando cerrás el hub)
local toggleBtn = new("TextButton",{
    Name = "ToggleOpen",
    Size = UDim2.new(0,60,0,28),
    Position = UDim2.new(0,10,0,10),
    AnchorPoint = Vector2.new(0,0),
    BackgroundColor3 = BTN_COLOR,
    Text = "KS",
    Font = Enum.Font.SourceSansBold,
    TextScaled = true,
    Parent = screenGui,
    Visible = false
})

-- Tab bar
local tabBar = new("Frame",{Size = UDim2.new(1,0,0,30),Position = UDim2.new(0,0,0,40),BackgroundTransparency = 1,Parent = main})
local tabs = {"Principal","Visuales","Ajustes"}
local tabButtons = {}
local contentFrames = {}

for i,name in ipairs(tabs) do
    local btn = new("TextButton",{
        Size = UDim2.new(1/#tabs, -2, 1, 0),
        Position = UDim2.new((i-1)/#tabs, (i==1 and 1 or 1), 0, 0),
        BackgroundColor3 = BTN_COLOR,
        Text = name,
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        Parent = tabBar
    })
    btn.Position = UDim2.new((i-1)/#tabs, 4, 0, 0)
    tabButtons[i] = btn

    -- ScrollingFrame con Content (UIListLayout + Padding)
    local scroll = new("ScrollingFrame",{
        Name = name.."Scroll",
        Size = UDim2.new(1,-12,1,-100),
        Position = UDim2.new(0,6,0,80),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        Parent = main,
        Visible = (i==1)
    })
    local content = new("Frame",{Size = UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Parent = scroll})
    local layout = new("UIListLayout",{Parent = content,Padding = UDim.new(0,8),SortOrder = Enum.SortOrder.LayoutOrder})
    local pad = new("UIPadding",{Parent = content,PaddingLeft = UDim.new(0,8),PaddingRight = UDim.new(0,8),PaddingTop = UDim.new(0,8),PaddingBottom = UDim.new(0,8)})
    -- actualizar CanvasSize dinámicamente
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 6)
    end)

    contentFrames[i] = content
    scroll.Parent = main
end

-- Tab switching
for i,btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for j,frame in ipairs(contentFrames) do
            frame.Parent.Visible = (i==j)
        end
    end)
end

-- Dragging header (estable)
do
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = UDim2.new(0,0,0,0)
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            -- handled by InputChanged on UserInputService for smoothness
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Close / toggle behavior
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    toggleBtn.Visible = true
end)
toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    toggleBtn.Visible = false
end)

-- ===== Helpers para crear botones dentro de content frames =====
local function addLabel(parent, text)
    local lbl = new("TextLabel",{
        Size = UDim2.new(1,0,0,30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        Parent = parent
    })
    return lbl
end

local function addButton(parent, txt)
    local btn = new("TextButton",{
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = BTN_COLOR,
        Text = txt,
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
        Parent = parent
    })
    return btn
end

local function addTextBox(parent, placeholder)
    local tb = new("TextBox",{
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = Color3.fromRGB(245,245,245),
        Text = "",
        PlaceholderText = placeholder,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(0,0,0),
        Parent = parent
    })
    return tb
end

-- ===== Contenido Tab Principal (contentFrames[1]) =====
local principal = contentFrames[1]
addLabel(principal, "Principal - Funciones")

-- Noclip
local noclipBtn = addButton(principal, "Activar Noclip")
noclipBtn.MouseButton1Click:Connect(function()
    hub.noclip = not hub.noclip
    noclipBtn.Text = hub.noclip and "Desactivar Noclip" or "Activar Noclip"
    if hub.noclip then
        hub.origCanCollide = {}
        if character then
            for _,p in pairs(character:GetDescendants()) do
                if p:IsA("BasePart") then
                    hub.origCanCollide[p] = p.CanCollide
                    p.CanCollide = false
                end
            end
        end
    else
        for part,val in pairs(hub.origCanCollide) do
            if part and part.Parent then pcall(function() part.CanCollide = val end) end
        end
        hub.origCanCollide = {}
    end
end)

-- Delay toggle
local delayBtn = addButton(principal, "Delay: OFF")
delayBtn.MouseButton1Click:Connect(function()
    hub.delay = not hub.delay
    delayBtn.Text = hub.delay and "Delay: ON" or "Delay: OFF"
end)

-- AntiVoid
local antiVoidBtn = addButton(principal, "Activar AntiVoid")
antiVoidBtn.MouseButton1Click:Connect(function()
    hub.antiVoid = not hub.antiVoid
    antiVoidBtn.Text = hub.antiVoid and "Desactivar AntiVoid" or "Activar AntiVoid"
end)

-- Waypoints (2 slots)
addLabel(principal, "Waypoints (2 slots)")
local wpSave1 = addButton(principal, "Save 1")
local wpLoad1 = addButton(principal, "Load 1")
local wpSave2 = addButton(principal, "Save 2")
local wpLoad2 = addButton(principal, "Load 2")

wpSave1.MouseButton1Click:Connect(function() if hrp then hub.savedWaypoints[1] = hrp.CFrame end end)
wpLoad1.MouseButton1Click:Connect(function() if hub.savedWaypoints[1] and hrp then pcall(function() hrp.CFrame = hub.savedWaypoints[1] end) end end)
wpSave2.MouseButton1Click:Connect(function() if hrp then hub.savedWaypoints[2] = hrp.CFrame end end)
wpLoad2.MouseButton1Click:Connect(function() if hub.savedWaypoints[2] and hrp then pcall(function() hrp.CFrame = hub.savedWaypoints[2] end) end end)

-- WalkSpeed presets
addLabel(principal, "WalkSpeed Presets")
local wsBtns = {}
local wsValues = {["Normal"] = function() return hub.baseWalkSpeed end, ["30"]=30, ["50"]=50, ["75"]=75, ["150"]=150, ["200"]=200}
for name,val in pairs(wsValues) do
    local b = addButton(principal, tostring(name))
    b.MouseButton1Click:Connect(function()
        if humanoid then
            local v = (type(val)=="function") and val() or val
            pcall(function() humanoid.WalkSpeed = v end)
        end
    end)
end

-- JumpPower presets
addLabel(principal, "JumpPower Presets")
local jpReset = addButton(principal, "Reset Jump")
local jp25 = addButton(principal, "+25%")
local jp50 = addButton(principal, "+50%")
local jp100 = addButton(principal, "+100%")

jpReset.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = hub.baseJumpPower end) end end)
jp25.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 1.25) end) end end)
jp50.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 1.50) end) end end)
jp100.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 2.0) end) end end)

-- Teleport textbox + button
addLabel(principal, "Teleport a jugador (nombre parcial)")
local tpBox = addTextBox(principal, "Nombre parcial")
local tpBtn = addButton(principal, "TP")
tpBtn.MouseButton1Click:Connect(function()
    local q = tpBox.Text and tpBox.Text:lower():gsub("%s+","") or ""
    if q == "" then return end
    for _,pl in pairs(Players:GetPlayers()) do
        if pl ~= player and pl.Name:lower():gsub("%s+",""):find(q,1,true) and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() hrp.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0) end)
            break
        end
    end
end)

-- ===== Contenido Tab Visuales (contentFrames[2]) =====
local visuals = contentFrames[2]
addLabel(visuals, "Visuales")
local highlightsBtn = addButton(visuals, "Toggle Highlights Jugadores")
highlightsBtn.MouseButton1Click:Connect(function()
    hub.highlights = not hub.highlights
    highlightsBtn.Text = hub.highlights and "Highlights: ON" or "Highlights: OFF"
    if hub.highlights then
        for _,pl in pairs(Players:GetPlayers()) do
            if pl ~= player and pl.Character and not hub.highlightObjects[pl.UserId] then
                pcall(function()
                    local h = Instance.new("Highlight", pl.Character)
                    h.Adornee = pl.Character
                    h.FillTransparency = 0.6
                    h.OutlineTransparency = 0.8
                    hub.highlightObjects[pl.UserId] = h
                end)
            end
        end
    else
        for id,h in pairs(hub.highlightObjects) do if h and h.Parent then pcall(function() h:Destroy() end) end hub.highlightObjects[id]=nil end
    end
end)

Players.PlayerAdded:Connect(function(pl)
    if hub.highlights then
        wait(0.2)
        if pl.Character then
            pcall(function()
                local h = Instance.new("Highlight", pl.Character)
                h.Adornee = pl.Character
                h.FillTransparency = 0.6
                h.OutlineTransparency = 0.8
                hub.highlightObjects[pl.UserId] = h
            end)
        end
    end
end)
Players.PlayerRemoving:Connect(function(pl) hub.highlightObjects[pl.UserId] = nil end)

-- FullBright toggle
local fbBtn = addButton(visuals, "Toggle FullBright")
fbBtn.MouseButton1Click:Connect(function()
    hub.fullbright = not hub.fullbright
    fbBtn.Text = hub.fullbright and "FullBright: ON" or "FullBright: OFF"
    if hub.fullbright then
        hub.origLighting.Ambient = Lighting.Ambient
        hub.origLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        hub.origLighting.GlobalShadows = Lighting.GlobalShadows
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.GlobalShadows = false
        end)
    else
        pcall(function()
            if hub.origLighting.Ambient then Lighting.Ambient = hub.origLighting.Ambient end
            if hub.origLighting.OutdoorAmbient then Lighting.OutdoorAmbient = hub.origLighting.OutdoorAmbient end
            if hub.origLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = hub.origLighting.GlobalShadows end
        end)
        hub.origLighting = {}
    end
end)

-- ===== Contenido Tab Ajustes (contentFrames[3]) =====
local ajustes = contentFrames[3]
addLabel(ajustes, "Ajustes")
addLabel(ajustes, "Transparencia GUI")
local t75 = addButton(ajustes, "75%")
local t50 = addButton(ajustes, "50%")
local t25 = addButton(ajustes, "25%")
t75.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.75 end)
t50.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.5 end)
t25.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.25 end)

local changelog = new("TextLabel",{
    Size = UDim2.new(1,0,0,130),
    BackgroundTransparency = 0.2,
    BackgroundColor3 = Color3.fromRGB(10,40,80),
    TextColor3 = Color3.fromRGB(255,255,255),
    Text = "Changelog v0.2.x:\n- UI centrado y compacto\n- Scroll arreglado (UIListLayout)\n- Botón toggle para reabrir\n- Ajustes visuales",
    Font = Enum.Font.SourceSans,
    TextWrapped = true,
    Parent = ajustes
})

-- ===== Core loops: Noclip y AntiVoid =====
RunService.RenderStepped:Connect(function()
    -- noclip
    if hub.noclip and character then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then
                if hub.origCanCollide[p] == nil then hub.origCanCollide[p] = p.CanCollide end
                if p.CanCollide then pcall(function() p.CanCollide = false end) end
            end
        end
    end

    -- antiVoid
    if hub.antiVoid and hrp and hrp.Position.Y < -50 then
        if hub.savedWaypoints[1] then
            pcall(function() hrp.CFrame = hub.savedWaypoints[1] + Vector3.new(0,5,0) end)
        else
            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then pcall(function() hrp.CFrame = spawn.CFrame + Vector3.new(0,5,0) end)
            else pcall(function() hrp.CFrame = CFrame.new(0,50,0) end) end
        end
    end
end)

-- ===== Limpieza simple =====
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        -- restaurar collides
        for part,val in pairs(hub.origCanCollide) do if part and part.Parent then pcall(function() part.CanCollide = val end) end end
        -- destruir highlights
        for id,h in pairs(hub.highlightObjects) do if h and h.Parent then pcall(function() h:Destroy() end) end end
    end
end)

print("[KS HUB] UI actualizado y centrado.")
