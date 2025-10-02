-- KSHUB - KS HUB ALPHA (v0.006) - RELANZADO (correcciones visuales, fade, color + transparencia)
-- Ejecutable: loadstring(game:HttpGet("https://raw.githubusercontent.com/KennyKressinR/KennyKressinR/refs/heads/main/KS%20HUB%20ALPHA.lua"))()

-- ========== BLOQUE: PREVENIR DUPLICADOS ==========
pcall(function()
    local Players = game:GetService("Players")
    local pl = Players.LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") then
        local old = pl.PlayerGui:FindFirstChild("KSHUB")
        if old then old:Destroy() end
    end
    local core = game:GetService("CoreGui")
    if core and core:FindFirstChild("KSHUB") then
        core:FindFirstChild("KSHUB"):Destroy()
    end
end)

-- ========== BLOQUE: SERVICES Y PLAYER ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ========== BLOQUE: CONFIG ==========
local COLOR_BLUE = Color3.fromRGB(0, 85, 170)        -- color base para barra izquierda / title
local PANEL_DARK = Color3.fromRGB(20, 22, 30)       -- color del panel derecho (contenido)
local BTN_BLUE = Color3.fromRGB(10, 90, 180)        -- color botones (opaco)
local BUTTON_TRANSPARENCY = 0                       -- botones opacos
local DEFAULT_LEFT_TRANSP = 0.25                    -- transparencia inicial de barra izquierda
local UI_PADDING = 8
local FADE_TIME = 0.18

-- Colores extra (selector en Ajustes)
local HUB_COLORS = {
    Azul = Color3.fromRGB(0,85,170),
    Verde = Color3.fromRGB(50,205,50),
    Rojo = Color3.fromRGB(200,50,50),
    Amarillo = Color3.fromRGB(240,220,40),
}

-- ========== BLOQUE: GUI PARENT (PlayerGui) ==========
local guiParent = nil
if LocalPlayer then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end
if not guiParent then
    guiParent = game:GetService("CoreGui")
end
pcall(function() print("[KSHUB] guiParent elegido:", tostring(guiParent)) end)

-- ========== BLOQUE: CREAR SCREENGUI Y PROTECCIÓN ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHUB"
ScreenGui.ResetOnSpawn = false
if type(syn) == "table" and type(syn.protect_gui) == "function" then
    pcall(function() syn.protect_gui(ScreenGui) end)
    pcall(function() print("[KSHUB] syn.protect_gui aplicado.") end)
end
ScreenGui.Parent = guiParent

-- ========== BLOQUE: MAINFRAME (contenedor, transparente) ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.BackgroundTransparency = 1 -- contenedor transparente
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner"); MainCorner.Parent = MainFrame; MainCorner.CornerRadius = UDim.new(0, 8)

-- Barra superior (Title)
local Title = Instance.new("TextButton")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = COLOR_BLUE
Title.BackgroundTransparency = DEFAULT_LEFT_TRANSP
Title.BorderSizePixel = 0
Title.AutoButtonColor = false
Title.Text = "KSHUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = MainFrame

-- LeftPanel (barra de tabs)
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0, 140, 1, -40)
LeftPanel.Position = UDim2.new(0, 0, 0, 40)
LeftPanel.BackgroundColor3 = COLOR_BLUE
LeftPanel.BackgroundTransparency = DEFAULT_LEFT_TRANSP
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame
local LeftCorner = Instance.new("UICorner"); LeftCorner.Parent = LeftPanel; LeftCorner.CornerRadius = UDim.new(0,8)

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftPanel
LeftLayout.Padding = UDim.new(0, 8)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
local LeftPadding = Instance.new("UIPadding"); LeftPadding.Parent = LeftPanel; LeftPadding.PaddingTop = UDim.new(0,8); LeftPadding.PaddingLeft = UDim.new(0,8)

-- RightPanel (contenido)
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(1, -140, 1, -40)
RightPanel.Position = UDim2.new(0, 140, 0, 40)
RightPanel.BackgroundColor3 = PANEL_DARK
RightPanel.BackgroundTransparency = 0.08 -- muy sutil
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame
local RightCorner = Instance.new("UICorner"); RightCorner.Parent = RightPanel; RightCorner.CornerRadius = UDim.new(0,8)

-- Close / Open buttons
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.BackgroundTransparency = 0.1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner"); CloseCorner.Parent = CloseBtn

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 90, 0, 32)
OpenBtn.Position = UDim2.new(1, -110, 1, -70)
OpenBtn.BackgroundColor3 = COLOR_BLUE
OpenBtn.BackgroundTransparency = DEFAULT_LEFT_TRANSP
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
OpenBtn.Visible = false
local OpenCorner = Instance.new("UICorner"); OpenCorner.Parent = OpenBtn

-- ========== BLOQUE: TAB CREATOR (cada página es ScrollingFrame dentro de RightPanel) ==========
local tabs = {}
local pages = {}
local trackedButtons = {} -- para recolorear al cambiar color

local function makeAutoCanvas(scrollFrame, contentLayout)
    local function update()
        local sizeY = contentLayout.AbsoluteContentSize.Y
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, sizeY + UI_PADDING)
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function CreateTab(name)
    -- botón en LeftPanel (opaco para evitar tintes)
    local btn = Instance.new("TextButton")
    btn.Name = name.."TabBtn"
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = BTN_BLUE
    btn.BackgroundTransparency = BUTTON_TRANSPARENCY
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = LeftPanel
    local btnCorner = Instance.new("UICorner"); btnCorner.Parent = btn
    trackedButtons[#trackedButtons+1] = btn

    -- página en RightPanel (ScrollingFrame)
    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.Parent = RightPanel
    page.Visible = false

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 8)
    content.BackgroundTransparency = 1
    content.Parent = page
    content.AutomaticSize = Enum.AutomaticSize.Y

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)

    makeAutoCanvas(page, contentLayout)

    tabs[name] = btn
    pages[name] = { Page = page, Content = content, Layout = contentLayout }

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do v.Page.Visible = false; tabs[k].BackgroundColor3 = BTN_BLUE end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(30,130,220)
    end)

    return pages[name]
end

local Principal = CreateTab("Principal")
local Teleport = CreateTab("Teleport")
local Player = CreateTab("Player")
local Ajustes = CreateTab("Ajustes")
local Info = CreateTab("Info")
pages["Principal"].Page.Visible = true
tabs["Principal"].BackgroundColor3 = Color3.fromRGB(30,130,220)

-- Helpers UI
local function CreateSection(parent, title, height)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1,0,0,height or 60)
    sec.BackgroundTransparency = 1
    sec.Parent = parent

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,1,0)
    container.BackgroundTransparency = 1
    container.Parent = sec
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = container

    -- Título
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Text = title or ""
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.LayoutOrder = 0
    lbl.Parent = container

    -- Body para botones / controles
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,0,0,height and (height-18) or 36)
    body.BackgroundTransparency = 1
    body.LayoutOrder = 1
    body.Parent = container

    return sec, body
end

local function CreateGrid(parent, cellX, cellY, pad)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, cellX or 100, 0, cellY or 28)
    grid.CellPadding = UDim2.new(0, pad or 6, 0, pad or 6)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = parent
    return grid
end

local function CreateButton(parent, text, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 96, 0, 28)
    b.BackgroundColor3 = BTN_BLUE
    b.BackgroundTransparency = BUTTON_TRANSPARENCY
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner"); corner.Parent = b
    b.Parent = parent
    trackedButtons[#trackedButtons+1] = b
    return b
end

-- ========== BLOQUE: DRAG (robusto, clamp, respeta anchor) ==========
do
    local dragging = false
    local dragStartMouse = Vector2.new(0,0)
    local frameStartCenter = Vector2.new(0,0)

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartMouse = UserInputService:GetMouseLocation()
            frameStartCenter = Vector2.new(
                MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X/2,
                MainFrame.AbsolutePosition.Y + MainFrame.AbsoluteSize.Y/2
            )
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local now = UserInputService:GetMouseLocation()
            local delta = now - dragStartMouse
            local newCenter = frameStartCenter + delta

            local cam = workspace.CurrentCamera
            local viewport = (cam and cam.ViewportSize) or Vector2.new(1280, 720)

            local halfW = MainFrame.AbsoluteSize.X/2
            local halfH = MainFrame.AbsoluteSize.Y/2

            local clampedX = math.clamp(newCenter.X, halfW, viewport.X - halfW)
            local clampedY = math.clamp(newCenter.Y, halfH, viewport.Y - halfH)

            MainFrame.Position = UDim2.fromOffset(math.floor(clampedX), math.floor(clampedY))
        end
    end)
end

-- ========== BLOQUE: PLAYER TAB (WalkSpeed / Jump / Noclip) ==========
do
    local content = Player.Content

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Text = "Player - Ajustes"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextColor3 = Color3.new(1,1,1)
    header.Parent = content

    -- WalkSpeed
    local sec, body = CreateSection(content, "Velocidad (WalkSpeed):", 64)
    CreateGrid(body, 92, 28, 6)
    local function getDefaultWalkSpeed()
        local ch = LocalPlayer.Character
        if ch then local h = ch:FindFirstChildWhichIsA("Humanoid") if h and h.WalkSpeed then return h.WalkSpeed end end
        return 16
    end
    local defaultWalkSpeed = getDefaultWalkSpeed()
    local speeds = {
        {"Normal", defaultWalkSpeed},
        {"25", 25},
        {"50", 50},
        {"100", 100},
        {"200", 200},
    }
    for _, v in ipairs(speeds) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 92, 0, 28)
        b.BackgroundColor3 = BTN_BLUE
        b.BackgroundTransparency = BUTTON_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = v[1]
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = body
        trackedButtons[#trackedButtons+1] = b
        b.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = v[2] end) end
        end)
    end

    -- JumpPower
    local secJ, bodyJ = CreateSection(content, "Impulso de salto (JumpPower):", 64)
    CreateGrid(bodyJ, 120, 28, 6)
    local function getDefaultJumpPower()
        local ch = LocalPlayer.Character
        if ch then local h = ch:FindFirstChildWhichIsA("Humanoid") if h and h.JumpPower then return h.JumpPower end end
        return 50
    end
    local defaultJump = getDefaultJumpPower()
    local jumps = {
        {"Normal (predet)", 1},
        {"+50%", 1.5},
        {"+100%", 2},
        {"+200%", 3},
    }
    for _, v in ipairs(jumps) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 120, 0, 28)
        b.BackgroundColor3 = BTN_BLUE
        b.BackgroundTransparency = BUTTON_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = v[1]
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = bodyJ
        trackedButtons[#trackedButtons+1] = b
        b.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                local target = math.floor(defaultJump * v[2])
                pcall(function() hum.JumpPower = target end)
            end
        end)
    end

    -- Noclip
    local secN, bodyN = CreateSection(content, "Noclip:", 46)
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Size = UDim2.new(0, 160, 0, 28)
    noclipBtn.BackgroundColor3 = BTN_BLUE
    noclipBtn.BackgroundTransparency = BUTTON_TRANSPARENCY
    noclipBtn.BorderSizePixel = 0
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.Font = Enum.Font.Gotham
    noclipBtn.TextSize = 14
    noclipBtn.TextColor3 = Color3.new(1,1,1)
    noclipBtn.Parent = bodyN
    trackedButtons[#trackedButtons+1] = noclipBtn

    local noclipState = false
    local noclipConn = nil
    local function enableNoclip()
        if noclipState then return end
        noclipState = true
        noclipBtn.Text = "Noclip: ON"
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
        noclipBtn.Text = "Noclip: OFF"
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
    noclipBtn.MouseButton1Click:Connect(function()
        if noclipState then disableNoclip() else enableNoclip() end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        defaultWalkSpeed = getDefaultWalkSpeed()
        defaultJump = getDefaultJumpPower()
        if noclipState then enableNoclip() end
    end)
end

-- ========== BLOQUE: TELEPORT TAB ==========
do
    local content = Teleport.Content

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1,0,0,22)
    hdr.BackgroundTransparency = 1
    hdr.Text = "Teleport - Save / Load"
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 16
    hdr.TextColor3 = Color3.new(1,1,1)
    hdr.Parent = content

    -- Save / Load
    local secSave, bodySave = CreateSection(content, "Tp - Save (guarda tu posición):", 60)
    CreateGrid(bodySave, 96, 28, 6)
    local saved = {}

    for i=1,4 do
        local idx = i
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,96,0,28)
        b.BackgroundColor3 = BTN_BLUE
        b.BackgroundTransparency = BUTTON_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = "Save"..idx
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = bodySave
        trackedButtons[#trackedButtons+1] = b
        b.MouseButton1Click:Connect(function()
            local ch = LocalPlayer.Character
            if ch then
                local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChildWhichIsA("BasePart")
                if hrp then saved[idx] = hrp.CFrame; pcall(function() print("[KSHUB] Save"..idx.." guardada.") end) end
            end
        end)
    end

    local secLoad, bodyLoad = CreateSection(content, "Tp - Load (carga posición):", 60)
    CreateGrid(bodyLoad, 96, 28, 6)
    for i=1,4 do
        local idx = i
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,96,0,28)
        b.BackgroundColor3 = BTN_BLUE
        b.BackgroundTransparency = BUTTON_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = "Load"..idx
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = bodyLoad
        trackedButtons[#trackedButtons+1] = b
        b.MouseButton1Click:Connect(function()
            local pos = saved[idx]
            if pos then
                local ch = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChildWhichIsA("BasePart")
                if hrp then pcall(function() hrp.CFrame = pos + Vector3.new(0,3,0) end) end
            else pcall(function() print("[KSHUB] No hay Save"..idx) end) end
        end)
    end

    -- Players list
    local secPlayers, bodyPlayers = CreateSection(content, "Teleport to Player:", 170)
    local playersScroll = Instance.new("ScrollingFrame")
    playersScroll.Size = UDim2.new(1,0,0,132)
    playersScroll.Position = UDim2.new(0,0,0,24)
    playersScroll.BackgroundTransparency = 1
    playersScroll.ScrollBarThickness = 6
    playersScroll.CanvasSize = UDim2.new(0,0,0,0)
    playersScroll.Parent = secPlayers

    local playersContent = Instance.new("Frame")
    playersContent.Size = UDim2.new(1, -12, 0, 0)
    playersContent.Position = UDim2.new(0,6,0,6)
    playersContent.BackgroundTransparency = 1
    playersContent.Parent = playersScroll
    playersContent.AutomaticSize = Enum.AutomaticSize.Y

    local playersLayout = Instance.new("UIListLayout")
    playersLayout.Parent = playersContent
    playersLayout.Padding = UDim.new(0,6)
    playersLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeAutoCanvas(playersScroll, playersLayout)

    local function refreshPlayers()
        for _,c in ipairs(playersContent:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,0,0,28)
                b.BackgroundColor3 = BTN_BLUE
                b.BackgroundTransparency = BUTTON_TRANSPARENCY
                b.BorderSizePixel = 0
                b.Text = pl.Name
                b.Font = Enum.Font.Gotham
                b.TextSize = 14
                b.TextColor3 = Color3.new(1,1,1)
                b.Parent = playersContent
                local bCorner = Instance.new("UICorner"); bCorner.Parent = b
                trackedButtons[#trackedButtons+1] = b
                b.MouseButton1Click:Connect(function()
                    local targetChar = pl.Character
                    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    if targetChar and myChar then
                        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChildWhichIsA("BasePart")
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChildWhichIsA("BasePart")
                        if targetHRP and myHRP then pcall(function() myHRP.CFrame = targetHRP.CFrame + Vector3.new(0,3,0) end) end
                    end
                end)
            end
        end
    end

    refreshPlayers()
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)
end

-- ========== BLOQUE: AJUSTES TAB (transparencia solo LeftPanel & Title) ==========
do
    local content = Ajustes.Content
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1,0,0,22)
    header.BackgroundTransparency = 1
    header.Text = "Ajustes de interfaz"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextColor3 = Color3.new(1,1,1)
    header.Parent = content

    -- Transparencia
    local sec, body = CreateSection(content, "Transparencia de la barra izquierda:", 48)
    CreateGrid(body, 84, 28, 6)
    local options = {
        {"0%", 0},
        {"25%", 0.25},
        {"50%", 0.5},
        {"75%", 0.75},
        {"90%", 0.9},
    }
    local function applyLeftTransparency(t)
        pcall(function()
            LeftPanel.BackgroundTransparency = t
            Title.BackgroundTransparency = t
            OpenBtn.BackgroundTransparency = t
            -- RightPanel y botones NO se tocan -> evita \"capa azul\"
        end)
    end
    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,84,0,28)
        b.BackgroundColor3 = BTN_BLUE
        b.BackgroundTransparency = BUTTON_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = opt[1]
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        local bCorner = Instance.new("UICorner"); bCorner.Parent = b
        b.Parent = body
        trackedButtons[#trackedButtons+1] = b
        b.MouseButton1Click:Connect(function() applyLeftTransparency(opt[2]) end)
    end

    -- Separador (pequeño)
    local sep = Instance.new("Frame"); sep.Size = UDim2.new(1,0,0,8); sep.BackgroundTransparency = 1; sep.Parent = content

    -- Color picker (adicional: recolorea botones)
    local secC, bodyC = CreateSection(content, "Color del HUB (Title & Left):", 48)
    CreateGrid(bodyC, 96, 28, 6)
    local function applyHubColor(c)
        if not c then return end
        Title.BackgroundColor3 = c
        LeftPanel.BackgroundColor3 = c
        OpenBtn.BackgroundColor3 = c
        -- Tint ligero a botones para visual consistente (mantener legibilidad)
        local tintFactor = 0.28
        for _, btn in ipairs(trackedButtons) do
            if btn and btn:IsA("TextButton") then
                local r,g,b = c.R * 255 * tintFactor, c.G * 255 * tintFactor, c.B * 255 * tintFactor
                btn.BackgroundColor3 = Color3.fromRGB(math.clamp(math.floor(r),0,255), math.clamp(math.floor(g),0,255), math.clamp(math.floor(b),0,255))
            end
        end
    end

    for name, col in pairs(HUB_COLORS) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,96,0,28)
        b.BackgroundColor3 = col
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(0,0,0)
        b.BorderSizePixel = 0
        local bCorner = Instance.new("UICorner"); bCorner.Parent = b
        b.Parent = bodyC
        b.MouseButton1Click:Connect(function()
            applyHubColor(col)
            -- marcar selección visual
            for _, child in ipairs(bodyC:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = (child==b) and 0 or 0.25
                end
            end
        end)
    end
end

-- ========== BLOQUE: INFO TAB ==========
do
    local content = Info.Content
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,80)
    label.BackgroundTransparency = 1
    label.TextWrapped = true
    label.Text = "KSHUB - KS HUB ALPHA (v0.006)\nSeparación de paneles para evitar capa azul. Botones opacos."
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = content
end

-- ========== BLOQUE: PRINCIPAL (contenido mínimo) ==========
do
    local content = Principal.Content
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1,0,0,40)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Bienvenido a KSHUB - Principal"
    welcome.Font = Enum.Font.GothamBold
    welcome.TextSize = 18
    welcome.TextColor3 = Color3.new(1,1,1)
    welcome.Parent = content

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,0,0,60)
    info.BackgroundTransparency = 1
    info.TextWrapped = true
    info.Text = "Arrastra desde la barra superior. Ajustes -> Transparencia solo afecta la barra izquierda."
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.TextColor3 = Color3.new(1,1,1)
    info.Parent = content
end

-- ========== BLOQUE: FADE OPEN/CLOSE (suave) ==========
local function fadeOut()
    if not MainFrame.Visible then return end
    local t = TweenService:Create(MainFrame, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    local t2 = TweenService:Create(Title, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    local t3 = TweenService:Create(LeftPanel, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    t:Play(); t2:Play(); t3:Play()
    t.Completed:Wait()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end

local function fadeIn()
    if MainFrame.Visible then return end
    MainFrame.BackgroundTransparency = 1
    Title.BackgroundTransparency = 1
    LeftPanel.BackgroundTransparency = 1
    MainFrame.Visible = true
    OpenBtn.Visible = false
    TweenService:Create(MainFrame, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = DEFAULT_LEFT_TRANSP}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = DEFAULT_LEFT_TRANSP}):Play()
end

-- ========== BLOQUE: OPEN/CLOSE ==========
CloseBtn.MouseButton1Click:Connect(function()
    fadeOut()
end)
OpenBtn.MouseButton1Click:Connect(function()
    fadeIn()
end)

-- Inicializar transparencias y colores por defecto
do
    LeftPanel.BackgroundTransparency = DEFAULT_LEFT_TRANSP
    Title.BackgroundTransparency = DEFAULT_LEFT_TRANSP
    OpenBtn.BackgroundTransparency = DEFAULT_LEFT_TRANSP
    RightPanel.BackgroundTransparency = 0.08
    -- aplicar color base a botones tint ligero
    local base = COLOR_BLUE
    local tintFactor = 0.28
    for _, btn in ipairs(trackedButtons) do
        if btn and btn:IsA("TextButton") then
            local r,g,b = base.R * 255 * tintFactor, base.G * 255 * tintFactor, base.B * 255 * tintFactor
            btn.BackgroundColor3 = Color3.fromRGB(math.clamp(math.floor(r),0,255), math.clamp(math.floor(g),0,255), math.clamp(math.floor(b),0,255))
        end
    end
end

pcall(function() print("[KSHUB v0.006] cargado correctamente. (sin capa azul) ✅") end)
