-- KS HUB ALPHA v0.003 (fix: drag, visible content, scrolls)
-- Ejecutable por loadstring
-- Mantiene bloques para edición futura

-- ========== BLOQUE: PREVENIR DUPLICADOS ==========
pcall(function()
    local core = game:GetService("CoreGui")
    if core:FindFirstChild("KSHUB") then
        core:FindFirstChild("KSHUB"):Destroy()
    end
    local pl = game:GetService("Players").LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") and pl.PlayerGui:FindFirstChild("KSHUB") then
        pl.PlayerGui:FindFirstChild("KSHUB"):Destroy()
    end
end)

-- ========== BLOQUE: SERVICES Y PLAYER ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ========== BLOQUE: CONFIG / CONSTANTES ==========
local DEFAULT_BLUE = Color3.fromRGB(0,85,170)
local DEFAULT_TRANSPARENCY = 0.25
local UI_PADDING = 8

-- ========== BLOQUE: GUI PARENT (robusto) ==========
local guiParent = nil
if type(gethui) == "function" then
    pcall(function() guiParent = gethui() end)
    if guiParent then print("[KSHUB] usando gethui()") end
end
if not guiParent and LocalPlayer then
    local ok, pg = pcall(function() return LocalPlayer:FindFirstChild("PlayerGui") end)
    if ok and pg then guiParent = pg print("[KSHUB] usando PlayerGui (FindFirstChild)") end
    if not guiParent then
        local suc, waited = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 3) end)
        if suc and waited then guiParent = waited print("[KSHUB] usando PlayerGui (WaitForChild)") end
    end
end
if not guiParent then
    guiParent = game:GetService("CoreGui")
    print("[KSHUB] fallback a CoreGui")
end

-- ========== BLOQUE: CREAR SCREENGUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHUB"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui and type(syn.protect_gui) == "function" then
    pcall(function() syn.protect_gui(ScreenGui) end)
    print("[KSHUB] syn.protect_gui aplicado.")
end
ScreenGui.Parent = guiParent
print("[KSHUB] ScreenGui.parent = ".. tostring(guiParent))

-- ========== BLOQUE: MAIN FRAME ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0,520,0,380)
MainFrame.Position = UDim2.new(0.5,-260,0.5,-190) -- inicial centrado por offset
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = DEFAULT_BLUE
MainFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Title (usado como handle para drag)
local Title = Instance.new("TextButton")
Title.Name = "Title"
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundColor3 = DEFAULT_BLUE
Title.BackgroundTransparency = DEFAULT_TRANSPARENCY
Title.BorderSizePixel = 0
Title.Text = "KSHUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.AutoButtonColor = false
Title.Parent = MainFrame

-- Left tabs
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(0,140,1,-40)
TabFrame.Position = UDim2.new(0,0,0,40)
TabFrame.BackgroundColor3 = DEFAULT_BLUE
TabFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabFrame
TabListLayout.Padding = UDim.new(0,8)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Pages container (derecha)
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Size = UDim2.new(1,-140,1,-40)
Pages.Position = UDim2.new(0,140,0,40)
Pages.BackgroundColor3 = Color3.fromRGB(20,20,40)
Pages.BackgroundTransparency = 0.35
Pages.BorderSizePixel = 0
Pages.Parent = MainFrame

-- Close / Open
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-34,0,6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
CloseBtn.BackgroundTransparency = 0.1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0,90,0,32)
OpenBtn.Position = UDim2.new(1,-110,1,-70)
OpenBtn.BackgroundColor3 = DEFAULT_BLUE
OpenBtn.BackgroundTransparency = DEFAULT_TRANSPARENCY
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.Parent = ScreenGui
OpenBtn.Visible = false

-- ========== BLOQUE: DRAG (FIX definitivo) ==========
do
    local dragging = false
    local dragStartPos = nil -- mouse position at start (Vector2)
    local frameStartCenter = nil -- frame center in pixels (Vector2)

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = UserInputService:GetMouseLocation()
            -- compute center pixel of frame
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
        if dragging and dragStartPos and frameStartCenter then
            local now = UserInputService:GetMouseLocation()
            local delta = now - dragStartPos
            local newCenter = frameStartCenter + delta
            -- set position so that anchorPoint (0.5,0.5) sits at newCenter
            MainFrame.Position = UDim2.new(0, math.floor(newCenter.X), 0, math.floor(newCenter.Y))
        end
    end)
end

-- ========== BLOQUE: TAB CREATOR (cada página es ScrollingFrame) ==========
local tabs = {}
local pages = {}

local function makeAutoCanvas(scrollFrame, contentLayout)
    local function update()
        local y = contentLayout.AbsoluteContentSize.Y
        scrollFrame.CanvasSize = UDim2.new(0,0,0, y + UI_PADDING)
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(1,-12,0,34)
    btn.Position = UDim2.new(0,6,0,0)
    btn.BackgroundColor3 = DEFAULT_BLUE
    btn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = TabFrame

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1,0,1,0)
    page.Position = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.Parent = Pages
    page.Visible = false

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1,-16,0,0)
    content.Position = UDim2.new(0,8,0,8)
    content.BackgroundTransparency = 1
    content.Parent = page

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0,8)

    makeAutoCanvas(page, contentLayout)

    tabs[name] = btn
    pages[name] = {Page = page, Content = content, Layout = contentLayout}

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(pages) do v.Page.Visible = false end
        page.Visible = true
    end)

    return pages[name]
end

local Principal = CreateTab("Principal")
local Teleport = CreateTab("Teleport")
local Player = CreateTab("Player")
local Ajustes = CreateTab("Ajustes")
local Info = CreateTab("Info")
pages["Principal"].Page.Visible = true

-- ========== BLOQUE: UTILIDADES UI ==========
local function CreateSection(contentParent, title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1,0,0,60)
    sec.BackgroundTransparency = 1
    sec.Parent = contentParent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Parent = sec

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1,0,0,36)
    body.Position = UDim2.new(0,0,0,22)
    body.BackgroundTransparency = 1
    body.Parent = sec

    return sec, body
end

local function CreateGridButtons(parentFrame, cellSize, spacing)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = cellSize or UDim2.new(0,100,0,28)
    grid.CellPadding = spacing or UDim2.new(0,6,0,6)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = parentFrame
    return grid
end

-- ========== BLOQUE: PLAYER TAB ==========
do
    local content = Player.Content
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1,0,0,22)
    header.BackgroundTransparency = 1
    header.Text = "Player - Ajustes"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextColor3 = Color3.new(1,1,1)
    header.Parent = content

    -- WalkSpeed
    local sec, body = CreateSection(content, "Velocidad (WalkSpeed):")
    sec.Size = UDim2.new(1,0,0,64)
    CreateGridButtons(body, UDim2.new(0,92,0,28), UDim2.new(0,6,0,6))
    local function getDefaultWalkSpeed()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if h and h.WalkSpeed then return h.WalkSpeed end
        end
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
        b.Size = UDim2.new(0,92,0,28)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = v[1]
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = body
        b.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = v[2] end) end
        end)
    end

    -- JumpPower
    local secJ, bodyJ = CreateSection(content, "Impulso de salto (JumpPower):")
    secJ.Size = UDim2.new(1,0,0,64)
    CreateGridButtons(bodyJ, UDim2.new(0,120,0,28), UDim2.new(0,6,0,6))
    local function getDefaultJumpPower()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if h and h.JumpPower then return h.JumpPower end
        end
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
        b.Size = UDim2.new(0,120,0,28)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = v[1]
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = bodyJ
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
    local secN, bodyN = CreateSection(content, "Noclip:")
    secN.Size = UDim2.new(1,0,0,46)
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Size = UDim2.new(0,160,0,28)
    noclipBtn.BackgroundColor3 = DEFAULT_BLUE
    noclipBtn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    noclipBtn.BorderSizePixel = 0
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.Font = Enum.Font.Gotham
    noclipBtn.TextSize = 14
    noclipBtn.TextColor3 = Color3.new(1,1,1)
    noclipBtn.Parent = bodyN

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
end

-- ========== BLOQUE: TELEPORT TAB ==========
do
    local content = Teleport.Content
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1,0,0,22)
    header.BackgroundTransparency = 1
    header.Text = "Teleport - Save / Load"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextColor3 = Color3.new(1,1,1)
    header.Parent = content

    -- Save / Load
    local secSave, bodySave = CreateSection(content, "Tp - Save (Guarda tu posición actual):")
    secSave.Size = UDim2.new(1,0,0,60)
    CreateGridButtons(bodySave, UDim2.new(0,96,0,28), UDim2.new(0,6,0,6))
    local saved = {}

    for i=1,4 do
        local idx = i
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,96,0,28)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = "Save"..idx
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = bodySave
        b.MouseButton1Click:Connect(function()
            local ch = LocalPlayer.Character
            if ch then
                local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChildWhichIsA("BasePart")
                if hrp then saved[idx] = hrp.CFrame; pcall(function() print("[KSHUB] Guardado Save"..idx) end) end
            end
        end)
    end

    local secLoad, bodyLoad = CreateSection(content, "Tp - Load (Carga la posición):")
    secLoad.Size = UDim2.new(1,0,0,60)
    CreateGridButtons(bodyLoad, UDim2.new(0,96,0,28), UDim2.new(0,6,0,6))

    for i=1,4 do
        local idx = i
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,96,0,28)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = "Load"..idx
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = bodyLoad
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
    local secPlayers, bodyPlayers = CreateSection(content, "Teleport to Player:")
    secPlayers.Size = UDim2.new(1,0,0,170)

    local playersScroll = Instance.new("ScrollingFrame")
    playersScroll.Size = UDim2.new(1,0,0,132)
    playersScroll.Position = UDim2.new(0,0,0,24)
    playersScroll.BackgroundTransparency = 1
    playersScroll.CanvasSize = UDim2.new(0,0,0,0)
    playersScroll.ScrollBarThickness = 6
    playersScroll.Parent = secPlayers

    local playersContent = Instance.new("Frame")
    playersContent.Size = UDim2.new(1, -12, 0, 0)
    playersContent.Position = UDim2.new(0,6,0,6)
    playersContent.BackgroundTransparency = 1
    playersContent.Parent = playersScroll

    local playersLayout = Instance.new("UIListLayout")
    playersLayout.Parent = playersContent
    playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playersLayout.Padding = UDim.new(0,6)

    makeAutoCanvas(playersScroll, playersLayout)

    local function refreshPlayersList()
        for _,c in ipairs(playersContent:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,0,0,28)
                b.BackgroundColor3 = DEFAULT_BLUE
                b.BackgroundTransparency = DEFAULT_TRANSPARENCY
                b.BorderSizePixel = 0
                b.Text = pl.Name
                b.Font = Enum.Font.Gotham
                b.TextSize = 14
                b.TextColor3 = Color3.new(1,1,1)
                b.Parent = playersContent
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

    refreshPlayersList()
    Players.PlayerAdded:Connect(refreshPlayersList)
    Players.PlayerRemoving:Connect(refreshPlayersList)
end

-- ========== BLOQUE: AJUSTES TAB ==========
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

    local sec, body = CreateSection(content, "Transparencia de interfaz:")
    sec.Size = UDim2.new(1,0,0,48)

    CreateGridButtons(body, UDim2.new(0,84,0,28), UDim2.new(0,6,0,6))
    local options = {
        {"0%", 0},
        {"25%", 0.25},
        {"50%", 0.5},
        {"75%", 0.75},
        {"90%", 0.9},
    }
    local function applyTransparency(t)
        pcall(function()
            MainFrame.BackgroundTransparency = t
            Title.BackgroundTransparency = t
            TabFrame.BackgroundTransparency = t
            OpenBtn.BackgroundTransparency = t
            Pages.BackgroundTransparency = math.clamp(t + 0.1, 0, 1)
            for _, v in pairs(TabFrame:GetDescendants()) do
                if v:IsA("TextButton") then if v.BackgroundTransparency ~= 1 then v.BackgroundTransparency = t end end
            end
            for _, pg in pairs(pages) do
                for _, v in pairs(pg.Page:GetDescendants()) do
                    if v:IsA("TextButton") then if v.BackgroundTransparency ~= 1 then v.BackgroundTransparency = t end end
                end
            end
        end)
    end

    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,84,0,28)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = opt[1]
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = body
        b.MouseButton1Click:Connect(function() applyTransparency(opt[2]) end)
    end
end

-- ========== BLOQUE: INFO TAB ==========
do
    local content = Info.Content
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,80)
    label.BackgroundTransparency = 1
    label.TextWrapped = true
    label.Text = "KSHUB - KS HUB ALPHA (v0.003)\nInterfaz azul con transparencia ajustable.\nPestañas: Principal, Teleport, Player, Ajustes, Info"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = content
end

-- ========== BLOQUE: PRINCIPAL TAB (contenido visible) ==========
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
    info.Text = "Consejo: arrastra desde la barra superior (KSHUB). Usa Ajustes -> Transparencia para cambiar apariencia."
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.TextColor3 = Color3.new(1,1,1)
    info.Parent = content
end

-- ========== BLOQUE: OPEN / CLOSE ==========
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- ========== BLOQUE: INICIAL ==========
do
    MainFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
    Title.BackgroundTransparency = DEFAULT_TRANSPARENCY
    TabFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
    OpenBtn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    Pages.BackgroundTransparency = math.clamp(DEFAULT_TRANSPARENCY + 0.1, 0, 1)
end

pcall(function() print("[KSHUB v0.003] cargado correctamente.") end)
