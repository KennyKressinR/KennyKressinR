-- KS HUB v2.3 - Script completo final (copia y pega)
-- Incluye: prevención duplicados, fade, drag, tabs sin solapamiento, recolor completo,
-- players clickable TP, noclip, fly básico, infinite jump, save/load positions, walkspeed/jump presets.

-- ===== SERVICES & PREVENT DUPLICATES =====
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

-- ===== CONFIG =====
local HUB_COLORS = {
    Azul = Color3.fromRGB(0,85,170),
    Verde = Color3.fromRGB(50,205,50),
    Rojo = Color3.fromRGB(200,50,50),
    Amarillo = Color3.fromRGB(240,220,40),
}
local DEFAULT_COLOR_NAME = "Azul"
local FADE_TIME = 0.18
local DEFAULT_LEFT_TRANSP = 0.25
local UI_PADDING = 8

-- ===== CREATE GUI =====
local guiParent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHUB"
ScreenGui.ResetOnSpawn = false
if type(syn) == "table" and type(syn.protect_gui) == "function" then
    pcall(function() syn.protect_gui(ScreenGui) end)
end
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0,640,0,480)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.fromScale(0.5,0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner"); MainCorner.Parent = MainFrame; MainCorner.CornerRadius = UDim.new(0,12)

-- Title bar (contains title text and clock)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,48)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = HUB_COLORS[DEFAULT_COLOR_NAME]
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1,-180,1,0)
TitleLabel.Position = UDim2.new(0,16,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "K S H U B"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local DateLabel = Instance.new("TextLabel")
DateLabel.Size = UDim2.new(0,160,0,20)
DateLabel.Position = UDim2.new(1,-180,0,8)
DateLabel.BackgroundTransparency = 1
DateLabel.Font = Enum.Font.Gotham
DateLabel.TextSize = 12
DateLabel.TextColor3 = Color3.new(1,1,1)
DateLabel.TextXAlignment = Enum.TextXAlignment.Right
DateLabel.Parent = TitleBar
spawn(function()
    while true do
        pcall(function() DateLabel.Text = os.date("%d/%m/%Y %H:%M") end)
        task.wait(30)
    end
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,36,0,32)
CloseBtn.Position = UDim2.new(1,-46,0,8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,55,55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner"); CloseCorner.Parent = CloseBtn

-- Panels
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0,180,1,-48)
LeftPanel.Position = UDim2.new(0,0,0,48)
LeftPanel.BackgroundColor3 = HUB_COLORS[DEFAULT_COLOR_NAME]
LeftPanel.BackgroundTransparency = DEFAULT_LEFT_TRANSP
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame
local LeftCorner = Instance.new("UICorner"); LeftCorner.Parent = LeftPanel; LeftCorner.CornerRadius = UDim.new(0,10)

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftPanel
LeftLayout.Padding = UDim.new(0,8)
LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local LeftPad = Instance.new("UIPadding"); LeftPad.Parent = LeftPanel; LeftPad.PaddingTop = UDim.new(0,10); LeftPad.PaddingLeft = UDim.new(0,12)

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1,-180,1,-48)
RightPanel.Position = UDim2.new(0,180,0,48)
RightPanel.BackgroundColor3 = Color3.fromRGB(28,28,28)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame
local RightCorner = Instance.new("UICorner"); RightCorner.Parent = RightPanel; RightCorner.CornerRadius = UDim.new(0,10)

-- Open button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,110,0,36)
OpenBtn.Position = UDim2.new(1,-170,1,-100)
OpenBtn.BackgroundColor3 = HUB_COLORS[DEFAULT_COLOR_NAME]
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner"); OpenCorner.Parent = OpenBtn

-- ===== TAB SYSTEM =====
local tabButtons = {}
local pages = {}
local contentButtons = {} -- botones de contenido que se tintan (no incluye color-picker buttons)

local function makeAutoCanvas(scrollFrame, layout)
    local function update()
        local h = layout.AbsoluteContentSize.Y
        scrollFrame.CanvasSize = UDim2.new(0,0,0,h + UI_PADDING)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-24,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(10,90,180)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name
    btn.Parent = LeftPanel
    local btnCorner = Instance.new("UICorner"); btnCorner.Parent = btn
    tabButtons[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,-24,1,-24)
    page.Position = UDim2.new(0,12,0,12)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 8
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
    layout.Padding = UDim.new(0,10)

    makeAutoCanvas(page, layout)

    pages[name] = {Btn = btn, Page = page, Container = container, Layout = layout}

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do v.Page.Visible = false; tabButtons[k].BackgroundColor3 = Color3.fromRGB(10,90,180) end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(30,130,220)
        -- ensure active tab highlighted with hub color later when recolor applied
    end)

    return pages[name]
end

-- create tabs
CreateTab("Principal")
CreateTab("Teleport")
CreateTab("Player")
CreateTab("Ajustes")
CreateTab("Info")
pages["Principal"].Page.Visible = true
tabButtons["Principal"].BackgroundColor3 = Color3.fromRGB(30,130,220)

-- ===== HELPERS UI =====
local function CreateSection(parent, title)
    local sec = Instance.new("Frame")
    sec.BackgroundTransparency = 1
    sec.Parent = parent
    sec.AutomaticSize = Enum.AutomaticSize.Y
    sec.Size = UDim2.new(1,0,0,0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text = title or ""
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,0,0,0)
    body.BackgroundTransparency = 1
    body.Parent = sec
    body.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = body
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,8)

    return sec, body
end

local function CreateGridFrame(parent, cellX, cellY, pad, maxCols)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Size = UDim2.new(1,0,0,0)

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, cellX or 100, 0, cellY or 28)
    grid.CellPadding = UDim2.new(0, pad or 6, 0, pad or 6)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    if maxCols then
        grid.FillDirectionMaxCells = maxCols
    end
    grid.Parent = frame
    return frame, grid
end

local function CreateButton(parent, text, width)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width or 140, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(10,90,180)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner"); corner.Parent = b
    b.Parent = parent
    contentButtons[#contentButtons + 1] = b
    return b
end

-- ===== FUNCTIONS: gameplay helpers =====
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- noclip
local noclipState = false
local noclipConn = nil
local function enableNoclip()
    if noclipState then return end
    noclipState = true
    noclipConn = RunService.Stepped:Connect(function()
        local ch = LocalPlayer.Character
        if ch then
            for _, part in pairs(ch:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)
end
local function disableNoclip()
    if not noclipState then return end
    noclipState = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

-- teleport to mouse
local function teleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        local root = getRoot()
        if root then root.CFrame = mouse.Hit + Vector3.new(0,3,0) end
    end
end

-- teleport to player (Player object)
local function teleportToPlayerObj(pl)
    if not pl or not pl.Character then return end
    local tgt = pl.Character:FindFirstChild("HumanoidRootPart") or pl.Character:FindFirstChildWhichIsA("BasePart")
    local root = getRoot()
    if tgt and root then root.CFrame = tgt.CFrame + Vector3.new(0,3,0) end
end

-- save/load positions
local saved = {}
local function savePosition(slot)
    local root = getRoot()
    if root then saved[slot] = root.CFrame end
end
local function loadPosition(slot)
    local cf = saved[slot]
    local root = getRoot()
    if cf and root then root.CFrame = cf + Vector3.new(0,3,0) end
end

-- fly (simple BodyVelocity)
local flyState = false
local flyConn = nil
local flySpeed = 60
local flyControl = {W=false,A=false,S=false,D=false,Up=false,Down=false}
local function startFly()
    if flyState then return end
    local root = getRoot(); if not root then return end
    flyState = true
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.new(0,0,0); bv.Parent = root
    flyConn = RunService.RenderStepped:Connect(function()
        local move = Vector3.new(0,0,0)
        if flyControl.W then move = move + workspace.CurrentCamera.CFrame.LookVector end
        if flyControl.S then move = move - workspace.CurrentCamera.CFrame.LookVector end
        if flyControl.A then move = move - workspace.CurrentCamera.CFrame.RightVector end
        if flyControl.D then move = move + workspace.CurrentCamera.CFrame.RightVector end
        if flyControl.Up then move = move + Vector3.new(0,1,0) end
        if flyControl.Down then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0 then bv.Velocity = move.Unit * flySpeed else bv.Velocity = Vector3.new(0,0,0) end
    end)
end
local function stopFly()
    flyState = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local root = getRoot()
    if root then for _,v in pairs(root:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end end
end

-- infinite jump
local infJump = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ===== POPULATE UI (organized) =====
-- Principal page
do
    local page = pages["Principal"].Container
    local sec, body = CreateSection(page, "Accesos rápidos")
    local gridFrame, gridLayout = CreateGridFrame(body, 260, 36, 8, 2)

    local btnTpMouse = CreateButton(gridFrame, "TP a mouse", 260)
    btnTpMouse.MouseButton1Click:Connect(teleportToMouse)

    local btnToggleNoclip = CreateButton(gridFrame, "Toggle Noclip", 260)
    btnToggleNoclip.MouseButton1Click:Connect(function()
        if noclipState then disableNoclip(); btnToggleNoclip.Text = "Noclip: OFF" else enableNoclip(); btnToggleNoclip.Text = "Noclip: ON" end
    end)

    local btnFly = CreateButton(gridFrame, "Toggle Fly", 260)
    btnFly.MouseButton1Click:Connect(function()
        if flyState then stopFly(); btnFly.Text = "Fly: OFF" else startFly(); btnFly.Text = "Fly: ON" end
    end)

    local btnInfJump = CreateButton(gridFrame, "Toggle Infinite Jump", 260)
    btnInfJump.MouseButton1Click:Connect(function()
        infJump = not infJump
        btnInfJump.Text = "Infinite Jump: " .. (infJump and "ON" or "OFF")
    end)

    -- players list
    local secP, bodyP = CreateSection(page, "Jugadores (clic para TP)")
    local playersScroll = Instance.new("ScrollingFrame"); playersScroll.Size = UDim2.new(1,0,0,200); playersScroll.BackgroundTransparency = 1; playersScroll.Parent = bodyP; playersScroll.ScrollBarThickness = 8
    local playersContent = Instance.new("Frame"); playersContent.Size = UDim2.new(1,-12,0,0); playersContent.Position = UDim2.new(0,6,0,6); playersContent.BackgroundTransparency = 1; playersContent.Parent = playersScroll; playersContent.AutomaticSize = Enum.AutomaticSize.Y
    local playersLayout = Instance.new("UIListLayout"); playersLayout.Parent = playersContent; playersLayout.Padding = UDim.new(0,6)
    makeAutoCanvas(playersScroll, playersLayout)

    local function refreshPlayers()
        for _,c in pairs(playersContent:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,28); b.BackgroundColor3 = Color3.fromRGB(10,90,180); b.BorderSizePixel = 0; b.Text = pl.Name; b.Font = Enum.Font.Gotham; b.TextSize = 14; b.TextColor3 = Color3.new(1,1,1); b.Parent = playersContent
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

-- Teleport page
do
    local page = pages["Teleport"].Container
    local sec, body = CreateSection(page, "Guardar / Cargar posiciones")
    local gridF, grid = CreateGridFrame(body, 120, 36, 8, 4)
    for i = 1, 4 do
        local s = CreateButton(gridF, "Save "..i, 120)
        s.MouseButton1Click:Connect(function() savePosition(i) end)
        local l = CreateButton(gridF, "Load "..i, 120)
        l.MouseButton1Click:Connect(function() loadPosition(i) end)
    end

    local sec2, body2 = CreateSection(page, "Ir a coordenadas")
    local box = Instance.new("TextBox"); box.Size = UDim2.new(1,0,0,28); box.PlaceholderText = "x y z"; box.Parent = body2
    local go = CreateButton(body2, "Ir a coordenadas", 220)
    go.MouseButton1Click:Connect(function()
        local txt = box.Text
        local x,y,z = txt:match("(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)")
        if x and y and z then
            local cf = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
            local root = getRoot()
            if root then root.CFrame = cf end
        end
    end)
end

-- Player page (presets)
do
    local page = pages["Player"].Container
    local sec, body = CreateSection(page, "Presets Walk/Jump")
    local f, g = CreateGridFrame(body, 200, 36, 8, 2)

    local function setWalk(s) local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(); local hum = ch and ch:FindFirstChildWhichIsA("Humanoid"); if hum then pcall(function() hum.WalkSpeed = s end) end end
    local function setJump(j) local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(); local hum = ch and ch:FindFirstChildWhichIsA("Humanoid"); if hum then pcall(function() hum.JumpPower = j end) end end

    local b1 = CreateButton(f, "WalkSpeed 16", 200); b1.MouseButton1Click:Connect(function() setWalk(16) end)
    local b2 = CreateButton(f, "WalkSpeed 50", 200); b2.MouseButton1Click:Connect(function() setWalk(50) end)
    local b3 = CreateButton(f, "Jump 50", 200); b3.MouseButton1Click:Connect(function() setJump(50) end)
    local b4 = CreateButton(f, "Jump 80", 200); b4.MouseButton1Click:Connect(function() setJump(80) end)

    local sec2, body2 = CreateSection(page, "Infinite Jump")
    local ib = CreateButton(body2, "Toggle Infinite Jump", 200)
    ib.MouseButton1Click:Connect(function() infJump = not infJump; ib.Text = "Infinite Jump: "..(infJump and "ON" or "OFF") end)
end

-- Ajustes page (grid: opacity + color picker side-by-side)
do
    local page = pages["Ajustes"].Container
    local sec, body = CreateSection(page, "Ajustes de interfaz")

    local containerGrid = Instance.new("Frame"); containerGrid.BackgroundTransparency = 1; containerGrid.Parent = body; containerGrid.AutomaticSize = Enum.AutomaticSize.Y
    local grid = Instance.new("UIGridLayout"); grid.Parent = containerGrid; grid.CellSize = UDim2.new(0,300,0,160); grid.CellPadding = UDim2.new(0,12,0,12); grid.FillDirection = Enum.FillDirection.Horizontal; grid.FillDirectionMaxCells = 2

    -- Left: opacidad
    local leftFrame = Instance.new("Frame"); leftFrame.BackgroundTransparency = 1; leftFrame.Parent = containerGrid
    local s1, b1 = CreateSection(leftFrame, "Transparencia Left panel")
    local gf, gg = CreateGridFrame(b1, 84, 28, 8, 3)
    local options = {{"0%",0},{"25%",0.25},{"50%",0.5},{"75%",0.75},{"90%",0.9}}
    for _, opt in ipairs(options) do
        local bt = CreateButton(gf, opt[1], 84)
        bt.MouseButton1Click:Connect(function()
            LeftPanel.BackgroundTransparency = opt[2]
            TitleBar.BackgroundTransparency = opt[2]
            OpenBtn.BackgroundTransparency = opt[2]
        end)
    end

    -- Right: color picker
    local rightFrame = Instance.new("Frame"); rightFrame.BackgroundTransparency = 1; rightFrame.Parent = containerGrid
    local s2, b2 = CreateSection(rightFrame, "Color del HUB (Title & Left)")
    local cf, cg1 = CreateGridFrame(b2, 120, 36, 8, 2)
    for name, col in pairs(HUB_COLORS) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0,120,0,36)
        colorBtn.BackgroundColor3 = col
        colorBtn.Text = name
        colorBtn.Font = Enum.Font.Gotham
        colorBtn.TextSize = 14
        colorBtn.TextColor3 = Color3.new(0,0,0)
        colorBtn.BorderSizePixel = 0
        colorBtn.Parent = cf
        local cr = Instance.new("UICorner"); cr.Parent = colorBtn
        -- do NOT register colorBtn in contentButtons to avoid tinting it
        colorBtn.MouseButton1Click:Connect(function()
            -- apply hub color properly
            local c = col
            TitleBar.BackgroundColor3 = c
            LeftPanel.BackgroundColor3 = c
            OpenBtn.BackgroundColor3 = c
            -- recolor tab buttons: active/dim
            for k, tb in pairs(tabButtons) do
                tb.BackgroundColor3 = Color3.fromRGB(10,90,180) -- base neutral
            end
            for k, p in pairs(pages) do
                if p.Page.Visible and p.Btn then
                    p.Btn.BackgroundColor3 = c
                end
            end
            -- tint content buttons lightly (but keep readability)
            local tintFactor = 0.25
            for _, b in ipairs(contentButtons) do
                if b and b:IsA("TextButton") then
                    local r,g,bb = math.floor(c.R*255*tintFactor), math.floor(c.G*255*tintFactor), math.floor(c.B*255*tintFactor)
                    b.BackgroundColor3 = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(bb,0,255))
                end
            end
            -- highlight selected color visually
            for _, child in ipairs(cf:GetChildren()) do
                if child:IsA("TextButton") then child.BackgroundTransparency = (child==colorBtn) and 0 or 0.25 end
            end
        end)
    end
end

-- Info page
do
    local page = pages["Info"].Container
    local sec, body = CreateSection(page, "Acerca")
    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1; lbl.TextWrapped = true
    lbl.Text = "KS HUB v2.3 - Interfaz final. Click en nombre de jugador para teletransportarte. RightControl abre/oculta."
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.new(1,1,1)
    lbl.AutomaticSize = Enum.AutomaticSize.Y; lbl.Parent = body
end

-- ===== FADE, DRAG & SHORTCUT =====
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
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if MainFrame.Visible then fadeOut() else fadeIn() end
    end
    -- fly keys
    if input.KeyCode == Enum.KeyCode.W then flyControl.W = true end
    if input.KeyCode == Enum.KeyCode.S then flyControl.S = true end
    if input.KeyCode == Enum.KeyCode.A then flyControl.A = true end
    if input.KeyCode == Enum.KeyCode.D then flyControl.D = true end
    if input.KeyCode == Enum.KeyCode.E then flyControl.Up = true end
    if input.KeyCode == Enum.KeyCode.Q then flyControl.Down = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyControl.W = false end
    if input.KeyCode == Enum.KeyCode.S then flyControl.S = false end
    if input.KeyCode == Enum.KeyCode.A then flyControl.A = false end
    if input.KeyCode == Enum.KeyCode.D then flyControl.D = false end
    if input.KeyCode == Enum.KeyCode.E then flyControl.Up = false end
    if input.KeyCode == Enum.KeyCode.Q then flyControl.Down = false end
end)

-- Dragging TitleBar
do
    local dragging = false
    local dragStart = Vector2.new()
    local frameStart = Vector2.new()
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            frameStart = Vector2.new(MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X/2, MainFrame.AbsolutePosition.Y + MainFrame.AbsoluteSize.Y/2)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
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

-- initialize defaults
LeftPanel.BackgroundTransparency = DEFAULT_LEFT_TRANSP
TitleBar.BackgroundTransparency = DEFAULT_LEFT_TRANSP
OpenBtn.BackgroundTransparency = DEFAULT_LEFT_TRANSP

-- apply initial hub color (default)
do
    local c = HUB_COLORS[DEFAULT_COLOR_NAME]
    TitleBar.BackgroundColor3 = c
    LeftPanel.BackgroundColor3 = c
    OpenBtn.BackgroundColor3 = c
    -- tint content buttons lightly
    local tintFactor = 0.25
    for _, b in ipairs(contentButtons) do
        if b and b:IsA("TextButton") then
            local r,g,bb = math.floor(c.R*255*tintFactor), math.floor(c.G*255*tintFactor), math.floor(c.B*255*tintFactor)
            b.BackgroundColor3 = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(bb,0,255))
        end
    end
    -- highlight active tab
    for k,p in pairs(pages) do if p.Page.Visible then p.Btn.BackgroundColor3 = c else p.Btn.BackgroundColor3 = Color3.fromRGB(10,90,180) end end
end

print("KS HUB v2.3 cargado — completo.")
