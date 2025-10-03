--[[ KS HUB - v3.2 (MODIFICADO)
   Cambios:
   - UI_PADDING aumentado (más espacio entre opciones)
   - MainFrame más grande y LeftPanel más ancho (ventanilla más accesible)
   - Mejor padding y simetría
   - Nueva opción "Anti delay" (toggle) — fuerza HoldDuration = 0 en ProximityPrompts y restaura al apagar
   Mantiene todas las funciones originales (teleport, noclip, save/load, etc).
--]]

-- ===== BLOQUE 1: SERVICES / PREVENT DUPLICATES / CONFIG =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then Players.PlayerAdded:Wait(); LocalPlayer = Players.LocalPlayer end

pcall(function()
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        local old = LocalPlayer.PlayerGui:FindFirstChild("KSHUB")
        if old then old:Destroy() end
    end
    local core = game:GetService("CoreGui")
    if core and core:FindFirstChild("KSHUB") then core:FindFirstChild("KSHUB"):Destroy() end
end)

local HUB_COLORS = {
    Azul = Color3.fromRGB(0,85,170),
    Verde = Color3.fromRGB(50,205,50),
    Rojo = Color3.fromRGB(200,50,50),
    Amarillo = Color3.fromRGB(240,220,40),
}
local DEFAULT_COLOR_NAME = "Azul"
local DEFAULT_HUB_COLOR = HUB_COLORS[DEFAULT_COLOR_NAME]
local BTN_BASE = Color3.fromRGB(10,90,180) -- base for content buttons (will tint)
local FADE_TIME = 0.18
local DEFAULT_LEFT_TRANSP = 0.25

-- ++ Cambié esto a un valor mayor para más espacio entre cada opción:
local UI_PADDING = 18

-- ===== BLOQUE 2: CREAR GUI PRINCIPAL =====
local guiParent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHUB"
ScreenGui.ResetOnSpawn = false
if type(syn)=="table" and type(syn.protect_gui)=="function" then pcall(function() syn.protect_gui(ScreenGui) end) end
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
-- ++ Ventanilla más grande:
MainFrame.Size = UDim2.new(0.82,0,0.82,0)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.fromScale(0.5,0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner"); MainCorner.Parent = MainFrame; MainCorner.CornerRadius = UDim.new(0,10)
MainFrame.ClipsDescendants = true

-- TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,64)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = DEFAULT_HUB_COLOR
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner"); TitleCorner.Parent = TitleBar; TitleCorner.CornerRadius = UDim.new(0,8)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1,-220,0,40)
TitleLabel.Position = UDim2.new(0,18,0,12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "K S H U B · v3.2"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local DateLabel = Instance.new("TextLabel")
DateLabel.Name = "DateLabel"
DateLabel.Size = UDim2.new(0,200,0,20)
DateLabel.Position = UDim2.new(1,-220,0,12)
DateLabel.BackgroundTransparency = 1
DateLabel.Font = Enum.Font.Gotham
DateLabel.TextSize = 12
DateLabel.TextColor3 = Color3.new(1,1,1)
DateLabel.TextXAlignment = Enum.TextXAlignment.Right
DateLabel.Parent = TitleBar
spawn(function() while true do pcall(function() DateLabel.Text = os.date("%d/%m/%Y %H:%M") end); task.wait(30) end end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0,38,0,34)
CloseBtn.Position = UDim2.new(1,-72,0,12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,55,55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner"); CloseCorner.Parent = CloseBtn

-- Left / Right panels
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
-- ++ LeftPanel más ancho:
LeftPanel.Size = UDim2.new(0,230,1,-64)
LeftPanel.Position = UDim2.new(0,0,0,64)
LeftPanel.BackgroundColor3 = DEFAULT_HUB_COLOR
LeftPanel.BackgroundTransparency = DEFAULT_LEFT_TRANSP
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame
local LeftCorner = Instance.new("UICorner"); LeftCorner.Parent = LeftPanel; LeftCorner.CornerRadius = UDim.new(0,8)

-- LEFT SCROLL (nuevo) para las pestañas
local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Name = "LeftScroll"
LeftScroll.Size = UDim2.new(1,-12,1,-12)
LeftScroll.Position = UDim2.new(0,6,0,6)
LeftScroll.BackgroundTransparency = 1
LeftScroll.ScrollBarThickness = 8
LeftScroll.Parent = LeftPanel

local LeftContent = Instance.new("Frame")
LeftContent.Name = "LeftContent"
LeftContent.Size = UDim2.new(1,0,0,0)
LeftContent.Position = UDim2.new(0,0,0,0)
LeftContent.BackgroundTransparency = 1
LeftContent.Parent = LeftScroll
LeftContent.AutomaticSize = Enum.AutomaticSize.Y

local LeftList = Instance.new("UIListLayout")
LeftList.Parent = LeftContent
LeftList.SortOrder = Enum.SortOrder.LayoutOrder
-- ++ Usar UI_PADDING para espaciado
LeftList.Padding = UDim.new(0, UI_PADDING)

local LeftPad = Instance.new("UIPadding"); LeftPad.Parent = LeftPanel; LeftPad.PaddingTop = UDim.new(0,16); LeftPad.PaddingLeft = UDim.new(0,12)

-- Right panel
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
-- ++ Ajustar posición y tamaño acorde al nuevo LeftPanel
RightPanel.Size = UDim2.new(1,-230,1,-64)
RightPanel.Position = UDim2.new(0,230,0,64)
RightPanel.BackgroundColor3 = Color3.fromRGB(26,26,26)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame
local RightCorner = Instance.new("UICorner"); RightCorner.Parent = RightPanel; RightCorner.CornerRadius = UDim.new(0,8)

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0,120,0,36)
OpenBtn.Position = UDim2.new(1,-220,1,-120)
OpenBtn.BackgroundColor3 = DEFAULT_HUB_COLOR
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner"); OpenCorner.Parent = OpenBtn

-- ===== BLOQUE 3: TABS & PAGINAS (tabs ahora se crean en LeftContent) =====
local tabButtons = {}
local pages = {}
local contentButtons = {}

local function makeAutoCanvas(scrollFrame, layout)
    local function update()
        local h = layout.AbsoluteContentSize.Y
        scrollFrame.CanvasSize = UDim2.new(0,0,0,h + UI_PADDING)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function dimColor(c, f) f = f or 0.75 return Color3.new(math.clamp(c.R*f,0,1), math.clamp(c.G*f,0,1), math.clamp(c.B*f,0,1)) end
local function brightColor(c, f) f = f or 1.06 return Color3.new(math.clamp(c.R*f,0,1), math.clamp(c.G*f,0,1), math.clamp(c.B*f,0,1)) end

local currentHubColor = DEFAULT_HUB_COLOR
local function applyHubColor(c)
    if not c then return end
    currentHubColor = c
    TitleBar.BackgroundColor3 = c
    LeftPanel.BackgroundColor3 = c
    OpenBtn.BackgroundColor3 = c
    -- recolor tab buttons (dimmed), active brightened
    for name,btn in pairs(tabButtons) do btn.BackgroundColor3 = dimColor(c, 0.7) end
    for name, p in pairs(pages) do
        if p.Page.Visible then p.Btn.BackgroundColor3 = brightColor(c,1.06) end
    end
    -- tint content buttons
    tintContentButtons = tintContentButtons or function(col)
        local tintFactor = 0.28
        for _,b in ipairs(contentButtons) do
            if b and b:IsA("TextButton") then
                local r = math.floor(col.R*255*tintFactor)
                local g = math.floor(col.G*255*tintFactor)
                local bb = math.floor(col.B*255*tintFactor)
                b.BackgroundColor3 = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(bb,0,255))
            end
        end
    end
    tintContentButtons(c)
end

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-12,0,44)
    btn.BackgroundColor3 = dimColor(currentHubColor,0.7)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name
    btn.Parent = LeftContent -- importante: ahora dentro del LeftContent scrollable
    local btnCorner = Instance.new("UICorner"); btnCorner.Parent = btn
    tabButtons[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,-24,1,-28)
    page.Position = UDim2.new(0,12,0,12)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 10
    page.Parent = RightPanel
    page.Visible = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,0)
    container.BackgroundTransparency = 1
    container.Parent = page
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    -- ++ usar UI_PADDING para espacio interno
    layout.Padding = UDim.new(0, UI_PADDING)

    makeAutoCanvas(page, layout)

    pages[name] = { Btn = btn, Page = page, Container = container, Layout = layout }

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do v.Page.Visible = false; tabButtons[k].BackgroundColor3 = dimColor(currentHubColor,0.7) end
        page.Visible = true
        btn.BackgroundColor3 = brightColor(currentHubColor,1.06)
    end)

    -- ensure left scroll canvas updates when tabs change length
    makeAutoCanvas(LeftScroll, LeftList)

    return pages[name]
end

-- create tabs
CreateTab("Principal")
CreateTab("Teleport")
CreateTab("Player")
CreateTab("Ajustes")
CreateTab("Info")

-- show principal
pages["Principal"].Page.Visible = true
tabButtons["Principal"].BackgroundColor3 = brightColor(currentHubColor,1.06)
-- update left scroll canvas initially
makeAutoCanvas(LeftScroll, LeftList)

-- ===== BLOQUE 4: HELPERS UI =====
local function CreateSection(parent, title)
    local sec = Instance.new("Frame"); sec.BackgroundTransparency = 1; sec.Parent = parent; sec.AutomaticSize = Enum.AutomaticSize.Y; sec.Size = UDim2.new(1,0,0,0)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,0,0,30); lbl.BackgroundTransparency = 1; lbl.Text = title or ""; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 16; lbl.TextColor3 = Color3.new(1,1,1); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = sec
    local spacer = Instance.new("Frame"); spacer.Size = UDim2.new(1,0,0,6); spacer.BackgroundTransparency = 1; spacer.Parent = sec
    local body = Instance.new("Frame"); body.Size = UDim2.new(1,0,0,0); body.BackgroundTransparency = 1; body.Parent = sec; body.AutomaticSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout"); layout.Parent = body; layout.SortOrder = Enum.SortOrder.LayoutOrder
    -- ++ mayor padding entre elementos dentro de cada sección:
    layout.Padding = UDim.new(0, math.floor(UI_PADDING/2))
    return sec, body
end

local function CreateSeparator(parent)
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(1,0,0,18)
    sep.BackgroundTransparency = 1
    sep.Text = "______________________________"
    sep.Font = Enum.Font.Gotham
    sep.TextSize = 16
    sep.TextColor3 = Color3.fromRGB(200,200,200)
    sep.TextXAlignment = Enum.TextXAlignment.Center
    sep.Parent = parent
    return sep
end

local function CreateGridFrame(parent, cellX, cellY, pad, maxCols)
    local frame = Instance.new("Frame"); frame.BackgroundTransparency = 1; frame.Parent = parent; frame.AutomaticSize = Enum.AutomaticSize.Y; frame.Size = UDim2.new(1,0,0,0)
    local grid = Instance.new("UIGridLayout"); grid.Parent = frame; grid.CellSize = UDim2.new(0, cellX or 140, 0, cellY or 36); grid.CellPadding = UDim2.new(0, pad or 8, 0, pad or 8); grid.FillDirection = Enum.FillDirection.Horizontal; grid.SortOrder = Enum.SortOrder.LayoutOrder
    if maxCols then grid.FillDirectionMaxCells = maxCols end
    return frame, grid
end

local function CreateButton(parent, text, width)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width or 160, 0, 36)
    b.BackgroundColor3 = BTN_BASE
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner"); corner.Parent = b
    b.Parent = parent
    contentButtons[#contentButtons+1] = b
    return b
end

-- ===== BLOQUE 5: FUNCIONES (teleport, noclip, save/load) =====
local function getRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end

local noclipState = false
local noclipConn = nil
local function enableNoclip()
    if noclipState then return end
    noclipState = true
    noclipConn = RunService.Stepped:Connect(function()
        local ch = LocalPlayer.Character
        if ch then
            for _, part in pairs(ch:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
            end
        end
    end)
end
local function disableNoclip()
    if not noclipState then return end
    noclipState = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

local function teleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        local root = getRoot()
        if root then pcall(function() root.CFrame = mouse.Hit + Vector3.new(0,3,0) end) end
    end
end

local function teleportToPlayerObj(pl)
    if not pl or not pl.Character then return end
    local tgt = pl.Character:FindFirstChild("HumanoidRootPart") or pl.Character:FindFirstChildWhichIsA("BasePart")
    local root = getRoot()
    if tgt and root then pcall(function() root.CFrame = tgt.CFrame + Vector3.new(0,3,0) end) end
end

local saved = {}
local function savePosition(slot)
    local root = getRoot(); if root then saved[slot] = root.CFrame end
end
local function loadPosition(slot)
    local cf = saved[slot]; local root = getRoot(); if cf and root then pcall(function() root.CFrame = cf + Vector3.new(0,3,0) end) end
end

-- helper: tint content buttons
local function tintContentButtons(col)
    local tintFactor = 0.28
    for _,b in ipairs(contentButtons) do
        if b and b:IsA("TextButton") then
            local r = math.floor(col.R*255*tintFactor)
            local g = math.floor(col.G*255*tintFactor)
            local bb = math.floor(col.B*255*tintFactor)
            b.BackgroundColor3 = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(bb,0,255))
        end
    end
end

-- ===== BLOQUE 5.1: ANTI DELAY (NUEVO) =====
-- antiDelay: setea ProximityPrompt.HoldDuration = 0 en todos los prompts locales y restaura al desactivar.
local antiDelayEnabled = false
local originalHold = {} -- tabla: [ProximityPrompt] = originalHoldDuration
local descAddedConn = nil

local function applyAntiDelayToPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if originalHold[prompt] == nil then
        -- guardar original (si existe)
        originalHold[prompt] = prompt.HoldDuration
    end
    -- forzar a 0 (instantáneo en cliente)
    pcall(function() prompt.HoldDuration = 0 end)
end

local function restorePromptHold(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    local orig = originalHold[prompt]
    if orig ~= nil then
        pcall(function() prompt.HoldDuration = orig end)
        originalHold[prompt] = nil
    end
end

local function enableAntiDelay()
    if antiDelayEnabled then return end
    antiDelayEnabled = true
    -- aplicar a los prompts existentes
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            applyAntiDelayToPrompt(d)
        end
    end
    -- escuchar prompts que aparezcan después
    descAddedConn = workspace.DescendantAdded:Connect(function(d)
        if d:IsA("ProximityPrompt") and antiDelayEnabled then
            -- pequeño delay para asegurarnos propiedades estén listas
            task.defer(function()
                if d and d.Parent then applyAntiDelayToPrompt(d) end
            end)
        end
    end)
end

local function disableAntiDelay()
    if not antiDelayEnabled then return end
    antiDelayEnabled = false
    -- restaurar valores guardados
    for prompt, orig in pairs(originalHold) do
        pcall(function()
            if prompt and prompt.Parent then
                prompt.HoldDuration = orig
            end
        end)
    end
    originalHold = {}
    if descAddedConn then descAddedConn:Disconnect(); descAddedConn = nil end
end

local function toggleAntiDelay()
    if antiDelayEnabled then disableAntiDelay() else enableAntiDelay() end
end

-- ===== BLOQUE 6: POBLAR UI =====
-- PRINCIPAL
do
    local page = pages["Principal"].Container
    local sec, body = CreateSection(page, "Accesos rápidos")
    local gridF, grid = CreateGridFrame(body, 320, 40, 12, 2)
    local b1 = CreateButton(gridF, "TP a mouse", 320); b1.MouseButton1Click:Connect(teleportToMouse)
    local b2 = CreateButton(gridF, "Toggle Noclip", 320);
    b2.MouseButton1Click:Connect(function()
        if noclipState then disableNoclip(); b2.Text = "Noclip: OFF" else enableNoclip(); b2.Text = "Noclip: ON" end
    end)
    CreateSeparator(body)
end

-- TELEPORT
do
    local page = pages["Teleport"].Container
    local sec, body = CreateSection(page, "Guardar / Cargar posiciones")
    local gridF, grid = CreateGridFrame(body, 140, 36, 10, 4)
    for i=1,4 do
        local s = CreateButton(gridF, "Save "..i, 140); s.MouseButton1Click:Connect(function() savePosition(i) end)
        local l = CreateButton(gridF, "Load "..i, 140); l.MouseButton1Click:Connect(function() loadPosition(i) end)
    end
    CreateSeparator(body)

    local sec2, body2 = CreateSection(page, "Ir a coordenadas (x y z)")
    local box = Instance.new("TextBox"); box.Size = UDim2.new(1,0,0,34); box.PlaceholderText = "x y z"; box.Font = Enum.Font.Gotham; box.Parent = body2
    local go = CreateButton(body2, "Ir a coordenadas", 260)
    go.MouseButton1Click:Connect(function()
        local txt = box.Text
        local x,y,z = txt:match("(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)")
        if x and y and z then
            local cf = CFrame.new(tonumber(x), tonumber(y), tonumber(z));
            local root = getRoot();
            if root then pcall(function() root.CFrame = cf end) end
        end
    end)

    CreateSeparator(body)
    local secP, bodyP = CreateSection(page, "Jugadores (clic para TP)")

    local playersScroll = Instance.new("ScrollingFrame");
    playersScroll.Size = UDim2.new(1,0,0,220);
    playersScroll.BackgroundTransparency = 1;
    playersScroll.Parent = bodyP;
    playersScroll.ScrollBarThickness = 10

    local playersContent = Instance.new("Frame");
    playersContent.Size = UDim2.new(1,-12,0,0);
    playersContent.Position = UDim2.new(0,6,0,6);
    playersContent.BackgroundTransparency = 1;
    playersContent.Parent = playersScroll;
    playersContent.AutomaticSize = Enum.AutomaticSize.Y

    local playersLayout = Instance.new("UIListLayout");
    playersLayout.Parent = playersContent;
    playersLayout.Padding = UDim.new(0,10)
    makeAutoCanvas(playersScroll, playersLayout)

    local function refreshPlayers()
        for _,c in pairs(playersContent:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton");
                b.Size = UDim2.new(1,0,0,36);
                b.BackgroundColor3 = BTN_BASE;
                b.BorderSizePixel = 0;
                b.Text = pl.Name;
                b.Font = Enum.Font.Gotham;
                b.TextSize = 14;
                b.TextColor3 = Color3.new(1,1,1);
                b.Parent = playersContent
                local cr = Instance.new("UICorner"); cr.Parent = b
                contentButtons[#contentButtons+1] = b
                b.MouseButton1Click:Connect(function() teleportToPlayerObj(pl) end)
            end
        end
    end
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)
    refreshPlayers()
end

-- PLAYER (Velocidad e Impulso de salto)
do
    local page = pages["Player"].Container
    -- Velocidad
    local secV, bodyV = CreateSection(page, "Velocidad")
    local gf, gg = CreateGridFrame(bodyV, 120, 36, 10, 3)
    local function getDefaultWalkSpeed()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if h and h.WalkSpeed then return h.WalkSpeed end
        end
        return 16
    end
    local defaultWalk = getDefaultWalkSpeed()
    local speeds = { {"Normal("..tostring(math.floor(defaultWalk))..")", defaultWalk}, {"30",30}, {"50",50}, {"100",100}, {"150",150}, {"200",200} }
    for _,v in ipairs(speeds) do
        local btn = CreateButton(gf, v[1], 120)
        btn.MouseButton1Click:Connect(function()
            local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = v[2] end) end
        end)
    end
    CreateSeparator(page)

    -- Impulso de salto
    local secJ, bodyJ = CreateSection(page, "Impulso de salto")
    local gf2, gg2 = CreateGridFrame(bodyJ, 140, 36, 10, 3)
    local function getDefaultJumpPower()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if h and (h.JumpPower or h.JumpHeight) then return h.JumpPower or 50 end
        end
        return 50
    end
    local defaultJump = getDefaultJumpPower()
    local jumps = { {"Normal",1}, {"+25%",1.25}, {"+50%",1.5}, {"+100%",2} }
    for _,v in ipairs(jumps) do
        local label = (v[1] == "Normal") and ("Normal ("..tostring(math.floor(defaultJump))..")") or v[1]
        local btn = CreateButton(gf2, label, 140)
        btn.MouseButton1Click:Connect(function()
            local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
            if hum then local target = math.floor(defaultJump * v[2]); pcall(function() hum.JumpPower = target end) end
        end)
    end
end

-- AJUSTES
do
    local page = pages["Ajustes"].Container
    local sec, body = CreateSection(page, "Ajustes de interfaz")
    local containerGrid = Instance.new("Frame"); containerGrid.BackgroundTransparency = 1; containerGrid.Parent = body; containerGrid.AutomaticSize = Enum.AutomaticSize.Y
    local grid = Instance.new("UIGridLayout"); grid.Parent = containerGrid; grid.CellSize = UDim2.new(0,320,0,180); grid.CellPadding = UDim2.new(0,12,0,12); grid.FillDirection = Enum.FillDirection.Horizontal; grid.FillDirectionMaxCells = 2

    -- Opacidad
    local leftFrame = Instance.new("Frame"); leftFrame.BackgroundTransparency = 1; leftFrame.Parent = containerGrid
    local s1, b1 = CreateSection(leftFrame, "Transparencia Left panel")
    local gf, gg = CreateGridFrame(b1, 100, 36, 10, 3)
    local options = {{"0%",0},{"25%",0.25},{"50%",0.5},{"75%",0.75},{"90%",0.9}}
    for _, opt in ipairs(options) do
        local bt = CreateButton(gf, opt[1], 100)
        bt.MouseButton1Click:Connect(function() LeftPanel.BackgroundTransparency = opt[2] TitleBar.BackgroundTransparency = opt[2] OpenBtn.BackgroundTransparency = opt[2] end)
    end

    -- Color picker
    local rightFrame = Instance.new("Frame"); rightFrame.BackgroundTransparency = 1; rightFrame.Parent = containerGrid
    local s2, b2 = CreateSection(rightFrame, "Color del HUB (Title & Left & Tabs)")
    local cf, cg1 = CreateGridFrame(b2, 160, 44, 10, 2)
    for name, col in pairs(HUB_COLORS) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0,160,0,44)
        colorBtn.BackgroundColor3 = col
        colorBtn.Text = name
        colorBtn.Font = Enum.Font.Gotham
        colorBtn.TextSize = 14
        colorBtn.TextColor3 = Color3.new(0,0,0)
        colorBtn.BorderSizePixel = 0
        colorBtn.Parent = cf
        local cr = Instance.new("UICorner"); cr.Parent = colorBtn
        colorBtn.MouseButton1Click:Connect(function()
            applyHubColor(col)
            for k,p in pairs(pages) do if p.Page.Visible then p.Btn.BackgroundColor3 = brightColor(col,1.06) else p.Btn.BackgroundColor3 = dimColor(col,0.7) end end
            for _, child in ipairs(cf:GetChildren()) do if child:IsA("TextButton") then child.BackgroundTransparency = (child==colorBtn) and 0 or 0.35 end end
        end)
    end

    -- NUEVO: Botón Anti delay (ProximityPrompt instantáneo)
    local s3, b3 = CreateSection(rightFrame, "Funciones")
    local antiBtn = CreateButton(b3, "Anti delay: OFF", 220)
    antiBtn.MouseButton1Click:Connect(function()
        toggleAntiDelay()
        antiBtn.Text = antiDelayEnabled and "Anti delay: ON" or "Anti delay: OFF"
    end)
end

-- INFO
do
    local page = pages["Info"].Container
    local sec, body = CreateSection(page, "Acerca")
    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1; lbl.TextWrapped = true
    lbl.Text = "KS HUB v3.2 - Versión modificada: left panel scrollable; hub dimensionado; tabs tintables; agregado 'Anti delay' (ProximityPrompt instant)."
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.new(1,1,1); lbl.AutomaticSize = Enum.AutomaticSize.Y; lbl.Parent = body
end

-- ===== BLOQUE 7: FADE, DRAG, HOTKEYS E INICIALIZACIÓN =====
local function fadeIn()
    if MainFrame.Visible then return end
    MainFrame.BackgroundTransparency = 1; TitleBar.BackgroundTransparency = 1; LeftPanel.BackgroundTransparency = 1
    MainFrame.Visible = true; OpenBtn.Visible = false
    TweenService:Create(MainFrame, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 0}):Play()
    TweenService:Create(TitleBar, TweenInfo.new(FADE_TIME), {BackgroundTransparency = DEFAULT_LEFT_TRANSP}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(FADE_TIME), {BackgroundTransparency = DEFAULT_LEFT_TRANSP}):Play()
end
local function fadeOut()
    if not MainFrame.Visible then return end
    local t = TweenService:Create(MainFrame, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 1})
    local t2 = TweenService:Create(TitleBar, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 1})
    local t3 = TweenService:Create(LeftPanel, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 1})
    t:Play(); t2:Play(); t3:Play(); t.Completed:Wait()
    MainFrame.Visible = false; OpenBtn.Visible = true
end

OpenBtn.MouseButton1Click:Connect(fadeIn)
CloseBtn.MouseButton1Click:Connect(fadeOut)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if MainFrame.Visible then fadeOut() else fadeIn() end
    end
end)

-- Drag TitleBar (mejorado: respeta límites de pantalla)
do
    local dragging = false
    local dragStart = Vector2.new()
    local frameStart = Vector2.new()
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            frameStart = Vector2.new(MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X/2, MainFrame.AbsolutePosition.Y + MainFrame.AbsoluteSize.Y/2)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local now = UserInputService:GetMouseLocation()
            local delta = now - dragStart
            local newCenter = frameStart + delta
            local cam = workspace.CurrentCamera
            local viewport = cam and cam.ViewportSize or Vector2.new(1280,720)
            local halfW, halfH = MainFrame.AbsoluteSize.X/2, MainFrame.AbsoluteSize.Y/2
            local clampedX = math.clamp(newCenter.X, halfW, viewport.X - halfW)
            local clampedY = math.clamp(newCenter.Y, halfH, viewport.Y - halfH)
            MainFrame.Position = UDim2.fromOffset(math.floor(clampedX), math.floor(clampedY))
        end
    end)
end

-- Init
applyHubColor(DEFAULT_HUB_COLOR)
LeftPanel.BackgroundTransparency = DEFAULT_LEFT_TRANSP
TitleBar.BackgroundTransparency = DEFAULT_LEFT_TRANSP
OpenBtn.BackgroundTransparency = DEFAULT_LEFT_TRANSP
-- update left scroll canvas on start
makeAutoCanvas(LeftScroll, LeftList)

print("[KS HUB v3.2 - MOD] cargado — Left panel scrollable, hub dimensionado y 'Anti delay' disponible.")
