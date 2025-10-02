-- KS HUB - V2.0 (COMPLETO)
-- Hub completo: tabs, fade, color picker, noclip, teleport (a jugadores y a mouse), save/load positions, fly, infinite jump, walk/jump presets.
-- Uso: pegar este archivo en tu executor y ejecutar. Evita duplicados.

-- ===================== SERVICIOS =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then Players.PlayerAdded:Wait(); LocalPlayer = Players.LocalPlayer end

-- ===================== CONFIG =====================
local COLORS = {
    Azul = Color3.fromRGB(0,110,200),
    Verde = Color3.fromRGB(50,205,50),
    Rojo = Color3.fromRGB(200,50,50),
    Amarillo = Color3.fromRGB(240,220,40),
}
local DEFAULT_COLOR_NAME = "Azul"
local FADE_TIME = 0.20
local BUTTON_HEIGHT = 36
local UI_PADDING = 10

-- ===================== PREVENIR DUPLICADOS =====================
pcall(function()
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        local old = LocalPlayer.PlayerGui:FindFirstChild("KSHUB")
        if old then old:Destroy() end
    end
    local cg = game:GetService("CoreGui")
    if cg and cg:FindFirstChild("KSHUB") then cg:FindFirstChild("KSHUB"):Destroy() end
end)

-- ===================== CREAR GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHUB"
ScreenGui.ResetOnSpawn = false
if type(syn) == "table" and syn.protect_gui then pcall(function() syn.protect_gui(ScreenGui) end) end
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 460)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner") MainCorner.Parent = MainFrame; MainCorner.CornerRadius = UDim.new(0,12)

-- Title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,46)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = COLORS[DEFAULT_COLOR_NAME]
TitleBar.Parent = MainFrame
local TitleTxt = Instance.new("TextLabel")
TitleTxt.Size = UDim2.new(1,-90,1,0)
TitleTxt.Position = UDim2.new(0,16,0,0)
TitleTxt.BackgroundTransparency = 1
TitleTxt.Text = "K S H U B"
TitleTxt.Font = Enum.Font.GothamBold
TitleTxt.TextSize = 18
TitleTxt.TextColor3 = Color3.new(1,1,1)
TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
TitleTxt.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,36,0,32)
CloseBtn.Position = UDim2.new(1,-46,0,7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,55,55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner") CloseCorner.Parent = CloseBtn

-- Panels
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0,170,1,-46)
LeftPanel.Position = UDim2.new(0,0,0,46)
LeftPanel.BackgroundColor3 = COLORS[DEFAULT_COLOR_NAME]
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame
local LeftCorner = Instance.new("UICorner") LeftCorner.Parent = LeftPanel; LeftCorner.CornerRadius = UDim.new(0,10)

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1,-170,1,-46)
RightPanel.Position = UDim2.new(0,170,0,46)
RightPanel.BackgroundColor3 = Color3.fromRGB(30,30,30)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame
local RightCorner = Instance.new("UICorner") RightCorner.Parent = RightPanel; RightCorner.CornerRadius = UDim.new(0,10)

-- Left list layout
local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftPanel
LeftLayout.Padding = UDim.new(0,8)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Right content container
local RightContent = Instance.new("Frame")
RightContent.Size = UDim2.new(1,-20,1,-20)
RightContent.Position = UDim2.new(0,10,0,10)
RightContent.BackgroundTransparency = 1
RightContent.Parent = RightPanel
local RightLayout = Instance.new("UIListLayout")
RightLayout.Parent = RightContent
RightLayout.Padding = UDim.new(0,10)
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Open button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0,110,0,36)
OpenBtn.Position = UDim2.new(1,-160,1,-100)
OpenBtn.AnchorPoint = Vector2.new(0,0)
OpenBtn.BackgroundColor3 = COLORS[DEFAULT_COLOR_NAME]
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner") OpenCorner.Parent = OpenBtn

-- ===================== FADE FUNCIONES =====================
local function fadeIn()
    if MainFrame.Visible then return end
    MainFrame.BackgroundTransparency = 1
    TitleBar.BackgroundTransparency = 1
    LeftPanel.BackgroundTransparency = 1
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 0}):Play()
    TweenService:Create(TitleBar, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 0}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 0}):Play()
end
local function fadeOut()
    if not MainFrame.Visible then return end
    local t = TweenService:Create(MainFrame, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 1})
    local t2 = TweenService:Create(TitleBar, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 1})
    local t3 = TweenService:Create(LeftPanel, TweenInfo.new(FADE_TIME), {BackgroundTransparency = 1})
    t:Play(); t2:Play(); t3:Play()
    t.Completed:Wait()
    MainFrame.Visible = false
end

-- ===================== TABS SYSTEM =====================
local tabButtons = {}
local pages = {}

local function CreateTab(name)
    -- button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,BUTTON_HEIGHT)
    btn.BackgroundColor3 = Color3.fromRGB(10,90,180)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = LeftPanel
    local btnCorner = Instance.new("UICorner") btnCorner.Parent = btn

    -- page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,-20,1,-20)
    page.Position = UDim2.new(0,10,0,10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 6
    page.Visible = false
    page.Parent = RightPanel

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-16,0,0)
    container.Position = UDim2.new(0,8,0,8)
    container.BackgroundTransparency = 1
    container.Parent = page
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateCanvas()
        page.CanvasSize = UDim2.new(0,0,0,container.AbsoluteSize.Y + UI_PADDING)
    end
    container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
    updateCanvas()

    tabButtons[name] = btn
    pages[name] = { Page = page, Container = container, Btn = btn }

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do v.Page.Visible = false; tabButtons[k].BackgroundColor3 = Color3.fromRGB(10,90,180) end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(30,130,220)
    end)

    return pages[name]
end

local pPrincipal = CreateTab("Principal")
local pTeleport = CreateTab("Teleport")
local pPlayer = CreateTab("Player")
local pAjustes = CreateTab("Ajustes")
local pInfo = CreateTab("Info")

-- default
pages["Principal"].Page.Visible = true
tabButtons["Principal"].BackgroundColor3 = Color3.fromRGB(30,130,220)

-- ===================== HELPERS UI =====================
local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1,0,0,0)
    section.BackgroundTransparency = 1
    section.Parent = parent
    section.AutomaticSize = Enum.AutomaticSize.Y

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,0,0,20)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Color3.new(1,1,1)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = section

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,0,0,0)
    body.BackgroundTransparency = 1
    body.Parent = section
    body.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = body
    layout.Padding = UDim.new(0,8)

    return section, body
end

local function CreateButton(parent, text, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 160, 0, BUTTON_HEIGHT)
    b.BackgroundColor3 = Color3.fromRGB(10,90,180)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner") corner.Parent = b
    b.Parent = parent
    return b
end

local function CreateLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextColor3 = Color3.new(1,1,1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- ===================== FUNCIONALIDADES =====================
-- Noclip
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
    noclipState = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    -- restablecer colisiones simples (no forzamos restaurar todos los valores originales)
    local ch = LocalPlayer.Character
    if ch then
        for _, part in pairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
end

-- Teleport a mouse
local function teleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = mouse.Hit + Vector3.new(0,3,0) end
    end
end

-- Teleport a jugador (por nombre)
local function teleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return false end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and myRoot then
        myRoot.CFrame = root.CFrame + Vector3.new(0,3,0)
        return true
    end
    return false
end

-- Save / Load positions
local savedPositions = {} -- table of Vector3
for i=1,4 do savedPositions[i] = nil end
local function savePosition(slot)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then savedPositions[slot] = root.CFrame end
end
local function loadPosition(slot)
    local cf = savedPositions[slot]
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if cf and root then root.CFrame = cf + Vector3.new(0,3,0) end
end

-- Fly (simple)
local flyState = false
local flySpeed = 50
local flyConn = nil
local flyControl = {W=false,A=false,S=false,D=false,Up=false,Down=false}
local function startFly()
    if flyState then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flyState = true
    local controller = Instance.new("BodyVelocity")
    controller.MaxForce = Vector3.new(9e9,9e9,9e9)
    controller.Velocity = Vector3.new(0,0,0)
    controller.Parent = root
    flyConn = RunService.RenderStepped:Connect(function(dt)
        local move = Vector3.new(0,0,0)
        if flyControl.W then move = move + (workspace.CurrentCamera.CFrame.LookVector) end
        if flyControl.S then move = move - (workspace.CurrentCamera.CFrame.LookVector) end
        if flyControl.A then move = move - (workspace.CurrentCamera.CFrame.RightVector) end
        if flyControl.D then move = move + (workspace.CurrentCamera.CFrame.RightVector) end
        if flyControl.Up then move = move + Vector3.new(0,1,0) end
        if flyControl.Down then move = move - Vector3.new(0,1,0) end
        controller.Velocity = move.Unit == move.Unit and move.Unit * flySpeed or Vector3.new(0,0,0)
    end)
end
local function stopFly()
    flyState = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for _, v in pairs(root:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end
    end
end

-- Infinite jump
local infJump = false
local function enableInfJump() infJump = true end
local function disableInfJump() infJump = false end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Walk / Jump presets
local function setWalkSpeed(speed)
    local ch = LocalPlayer.Character
    if ch then local h = ch:FindFirstChildWhichIsA("Humanoid") if h then pcall(function() h.WalkSpeed = speed end) end end
end
local function setJumpPower(power)
    local ch = LocalPlayer.Character
    if ch then local h = ch:FindFirstChildWhichIsA("Humanoid") if h then pcall(function() h.JumpPower = power end) end end
end

-- Restore defaults on character spawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if noclipState then enableNoclip() end
end)

-- ===================== RELLENO DE UI: Principal =====================
do
    local page = pPrincipal.Container
    local sec, body = CreateSection(page, "Accesos rápidos")
    local grid = Instance.new("Frame") grid.BackgroundTransparency = 1 grid.Parent = body
    local gridLayout = Instance.new("UIGridLayout") gridLayout.Parent = grid gridLayout.CellSize = UDim2.new(0, 180, 0, BUTTON_HEIGHT) gridLayout.CellPadding = UDim2.new(0,8,0,8)

    local bTpMouse = CreateButton(grid, "TP a mouse (Pos)" )
    local bTpPlayer = CreateButton(grid, "TP a jugador (Lista)")
    local bNoclip = CreateButton(grid, "Toggle Noclip")
    local bFly = CreateButton(grid, "Toggle Fly")

    bTpMouse.MouseButton1Click:Connect(function() teleportToMouse() end)
    bNoclip.MouseButton1Click:Connect(function()
        if noclipState then disableNoclip() else enableNoclip() end
        bNoclip.Text = "Noclip: " .. (noclipState and "ON" or "OFF")
    end)
    bFly.MouseButton1Click:Connect(function()
        if flyState then stopFly() else startFly() end
        bFly.Text = "Fly: "..(flyState and "ON" or "OFF")
    end)

    -- Lista de players breve
    local sec2, body2 = CreateSection(page, "Jugadores (teleport)")
    local pList = Instance.new("Frame") pList.BackgroundTransparency = 1 pList.Parent = body2
    local listLayout = Instance.new("UIListLayout") listLayout.Parent = pList listLayout.Padding = UDim.new(0,6) listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    -- crear botones por jugador dinámicamente
    local function refreshPlayerList()
        for i,v in pairs(pList:GetChildren()) do if not v:IsA("UIListLayout") then v:Destroy() end end
        for i, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -20, 0, BUTTON_HEIGHT)
                btn.BackgroundColor3 = Color3.fromRGB(10,90,180)
                btn.Text = plr.Name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Parent = pList
                local corner = Instance.new("UICorner") corner.Parent = btn
                btn.MouseButton1Click:Connect(function()
                    teleportToPlayer(plr.Name)
                end)
            end
        end
    end
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)
    refreshPlayerList()
end

-- ===================== TELEPORT PAGE (save/load) =====================
do
    local page = pTeleport.Container
    local sec, body = CreateSection(page, "Guardar / Cargar posiciones (4 slots)")
    local slotsFrame = Instance.new("Frame") slotsFrame.BackgroundTransparency = 1 slotsFrame.Parent = body
    local grid = Instance.new("UIGridLayout") grid.Parent = slotsFrame grid.CellSize = UDim2.new(0, 260, 0, BUTTON_HEIGHT) grid.CellPadding = UDim2.new(0,8,0,8)

    for i=1,4 do
        local sBtn = CreateButton(slotsFrame, "Guardar slot "..i, 120)
        local lBtn = CreateButton(slotsFrame, "Ir slot "..i, 120)
        sBtn.MouseButton1Click:Connect(function() savePosition(i) end)
        lBtn.MouseButton1Click:Connect(function() loadPosition(i) end)
    end

    local sec2, body2 = CreateSection(page, "Teleport a coordenadas (X Y Z)")
    local instr = CreateLabel(body2, "Pegá las coordenadas manualmente en formato x y z y presiona 'Ir' (ej: 0 10 0)")
    local coordBox = Instance.new("TextBox") coordBox.Size = UDim2.new(1,0,0,28) coordBox.Parent = body2 coordBox.PlaceholderText = "x y z"
    local goBtn = CreateButton(body2, "Ir a coordenadas", 180)
    goBtn.MouseButton1Click:Connect(function()
        local txt = coordBox.Text
        local x,y,z = txt:match("(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)")
        if x and y and z then
            local cf = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = cf end
        end
    end)
end

-- ===================== PLAYER PAGE (presets e infinite jump) =====================
do
    local page = pPlayer.Container
    local sec, body = CreateSection(page, "Presets Walk/Jump")
    local grid = Instance.new("Frame") grid.BackgroundTransparency = 1 grid.Parent = body
    local gridLayout = Instance.new("UIGridLayout") gridLayout.Parent = grid gridLayout.CellSize = UDim2.new(0,180,0,BUTTON_HEIGHT) gridLayout.CellPadding = UDim2.new(0,8,0,8)

    local wb1 = CreateButton(grid, "WalkSpeed 16")
    local wb2 = CreateButton(grid, "WalkSpeed 50")
    local jb1 = CreateButton(grid, "Jump 50")
    local jb2 = CreateButton(grid, "Jump 80")
    wb1.MouseButton1Click:Connect(function() setWalkSpeed(16) end)
    wb2.MouseButton1Click:Connect(function() setWalkSpeed(50) end)
    jb1.MouseButton1Click:Connect(function() setJumpPower(50) end)
    jb2.MouseButton1Click:Connect(function() setJumpPower(80) end)

    local sec2, body2 = CreateSection(page, "Infinite Jump")
    local infBtn = CreateButton(body2, "Toggle Infinite Jump", 220)
    infBtn.MouseButton1Click:Connect(function()
        if infJump then disableInfJump(); infBtn.Text = "Infinite Jump: OFF" else enableInfJump(); infBtn.Text = "Infinite Jump: ON" end
    end)

    local sec3, body3 = CreateSection(page, "Restaurar valores")
    local restBtn = CreateButton(body3, "Restaurar a defaults", 220)
    restBtn.MouseButton1Click:Connect(function()
        setWalkSpeed(16); setJumpPower(50)
    end)
end

-- ===================== AJUSTES (Color) =====================
do
    local page = pAjustes.Container
    local sec, body = CreateSection(page, "Color del HUB")
    local grid = Instance.new("Frame") grid.BackgroundTransparency = 1 grid.Parent = body
    local gridLayout = Instance.new("UIGridLayout") gridLayout.Parent = grid gridLayout.CellSize = UDim2.new(0,120,0,BUTTON_HEIGHT) gridLayout.CellPadding = UDim2.new(0,8,0,8)

    local colorButtons = {}
    local currentColorName = DEFAULT_COLOR_NAME
    local function applyColor(name)
        local c = COLORS[name]
        if not c then return end
        TitleBar.BackgroundColor3 = c
        LeftPanel.BackgroundColor3 = c
        OpenBtn.BackgroundColor3 = c
        currentColorName = name
    end
    for name, c in pairs(COLORS) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,120,0,BUTTON_HEIGHT)
        b.BackgroundColor3 = c
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(0,0,0)
        b.BorderSizePixel = 0
        local corner = Instance.new("UICorner") corner.Parent = b
        b.Parent = grid
        colorButtons[name] = b
        b.MouseButton1Click:Connect(function()
            applyColor(name)
            for nm,btn in pairs(colorButtons) do
                btn.BackgroundTransparency = (nm==name) and 0 or 0.18
            end
        end)
    end
    applyColor(DEFAULT_COLOR_NAME)
    for nm,btn in pairs(colorButtons) do if nm~=DEFAULT_COLOR_NAME then btn.BackgroundTransparency = 0.18 end end
end

-- ===================== INFO =====================
do
    local page = pInfo.Container
    local sec, body = CreateSection(page, "Acerca")
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1,0,0,80) lbl.BackgroundTransparency = 1 lbl.TextWrapped = true
    lbl.Text = "KS HUB v2.0 - Reescritura completa.\nIncluye: noclip, teleport a mouse y a jugadores, save/load posiciones, fly, infinite jump, presets de velocidad.\nHotkey: RightControl para abrir/ocultar." lbl.Font = Enum.Font.Gotham lbl.TextSize = 14 lbl.TextColor3 = Color3.new(1,1,1) lbl.Parent = body
end

-- ===================== DRAG MAINFRAME =====================
do
    local dragging = false
    local dragStart = nil
    local startPos = nil

    TitleTxt.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Vector2.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - MainFrame.AbsoluteSize.X)
            local newY = math.clamp(startPos.Y + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - MainFrame.AbsoluteSize.Y)
            MainFrame.Position = UDim2.fromOffset(newX + MainFrame.AbsoluteSize.X/2, newY + MainFrame.AbsoluteSize.Y/2)
        end
    end)
end

-- ===================== OPEN/CLOSE & HOTKEY =====================
OpenBtn.MouseButton1Click:Connect(function() fadeIn() end)
CloseBtn.MouseButton1Click:Connect(function() fadeOut() end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if MainFrame.Visible then fadeOut() else fadeIn() end
    end
    -- Fly controls keys
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

-- ===================== FIN =====================
print("KS HUB v2.0 cargado — pestañas y funciones principales listas.")
