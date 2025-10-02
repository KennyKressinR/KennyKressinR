-- KS HUB - V2.1 (FIJADO Y ORGANIZADO)
-- Reescritura completa centrándolo y arreglando solapamientos.
-- Características: fade, cambio de color (afecta también botones), lista de jugadores clickeable para TP, noclip, fly, inf jump, save/load posiciones.
-- Copiá todo y pegalo en tu executor.

-- ===================== SERVICIOS =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
local FADE_TIME = 0.18
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
MainFrame.Size = UDim2.new(0, 640, 0, 480)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner") MainCorner.Parent = MainFrame; MainCorner.CornerRadius = UDim.new(0,12)

-- TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,52)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundColor3 = COLORS[DEFAULT_COLOR_NAME]
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleTxt = Instance.new("TextLabel")
TitleTxt.Name = "TitleTxt"
TitleTxt.Size = UDim2.new(1,-120,1,0)
TitleTxt.Position = UDim2.new(0,16,0,0)
TitleTxt.BackgroundTransparency = 1
TitleTxt.Text = "K S H U B"
TitleTxt.Font = Enum.Font.GothamBold
TitleTxt.TextSize = 20
TitleTxt.TextColor3 = Color3.new(1,1,1)
TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
TitleTxt.TextYAlignment = Enum.TextYAlignment.Center
TitleTxt.Parent = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(0,100,0,20)
TitleSub.Position = UDim2.new(1,-360,0,16)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = os.date("%d/%m/%Y %H:%M")
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextSize = 12
TitleSub.TextColor3 = Color3.new(1,1,1)
TitleSub.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0,40,0,34)
CloseBtn.Position = UDim2.new(1,-56,0,9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,55,55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner") CloseCorner.Parent = CloseBtn

-- LeftPanel / RightPanel
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0,180,1,-52)
LeftPanel.Position = UDim2.new(0,0,0,52)
LeftPanel.BackgroundColor3 = COLORS[DEFAULT_COLOR_NAME]
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame
local LeftCorner = Instance.new("UICorner") LeftCorner.Parent = LeftPanel; LeftCorner.CornerRadius = UDim.new(0,10)

local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(1,-180,1,-52)
RightPanel.Position = UDim2.new(0,180,0,52)
RightPanel.BackgroundColor3 = Color3.fromRGB(30,30,30)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame
local RightCorner = Instance.new("UICorner") RightCorner.Parent = RightPanel; RightCorner.CornerRadius = UDim.new(0,10)

-- Left layout spacing
local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftPanel
LeftLayout.Padding = UDim.new(0,8)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local LeftPadding = Instance.new("UIPadding")
LeftPadding.PaddingTop = UDim.new(0,8)
LeftPadding.PaddingLeft = UDim.new(0,8)
LeftPadding.Parent = LeftPanel

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
OpenBtn.Size = UDim2.new(0,120,0,36)
OpenBtn.Position = UDim2.new(1,-180,1,-100)
OpenBtn.BackgroundColor3 = COLORS[DEFAULT_COLOR_NAME]
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner") OpenCorner.Parent = OpenBtn

-- Table for tracking buttons so applyColor can recolor them
local trackedButtons = {}

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

-- ===================== TABS SYSTEM (sin solapamientos) =====================
local tabButtons = {}
local pages = {}

local function makeAutoCanvas(scrollFrame, content)
    local function update()
        scrollFrame.CanvasSize = UDim2.new(0,0,0, content.AbsoluteSize.Y + UI_PADDING)
    end
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
    update()
end

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Name = name.."TabBtn"
    btn.Size = UDim2.new(1,-16,0,BUTTON_HEIGHT)
    btn.BackgroundColor3 = Color3.fromRGB(10,90,180)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = LeftPanel
    local btnCorner = Instance.new("UICorner") btnCorner.Parent = btn
    trackedButtons[#trackedButtons+1] = btn

    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1,-20,1,-20)
    page.Position = UDim2.new(0,10,0,10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 8
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

    makeAutoCanvas(page, container)

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
    b.Size = UDim2.new(0, w or 200, 0, BUTTON_HEIGHT)
    b.BackgroundColor3 = Color3.fromRGB(10,90,180)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner") corner.Parent = b
    b.Parent = parent
    trackedButtons[#trackedButtons+1] = b
    return b
end

local function CreateLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,0)
    l.BackgroundTransparency = 1
    l.TextWrapped = true
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextColor3 = Color3.new(1,1,1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- ===================== FUNCIONALIDADES =====================
-- helpers: get humanoidrootpart
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

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
    -- No restauramos cada CanCollide original por simplicidad
end

-- Teleport a mouse
local function teleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        local root = getRoot()
        if root then root.CFrame = mouse.Hit + Vector3.new(0,3,0) end
    end
end

-- Teleport a jugador (por objeto player)
local function teleportToPlayerObj(target)
    if not target or not target.Character then return false end
    local rootT = target.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = getRoot()
    if rootT and myRoot then myRoot.CFrame = rootT.CFrame + Vector3.new(0,3,0); return true end
    return false
end

-- Save / Load positions
local savedPositions = {}
for i=1,4 do savedPositions[i] = nil end
local function savePosition(slot)
    local root = getRoot()
    if root then savedPositions[slot] = root.CFrame end
end
local function loadPosition(slot)
    local cf = savedPositions[slot]
    local root = getRoot()
    if cf and root then root.CFrame = cf + Vector3.new(0,3,0) end
end

-- Fly (simple)
local flyState = false
local flySpeed = 60
local flyConn = nil
local flyControl = {W=false,A=false,S=false,D=false,Up=false,Down=false}
local function startFly()
    if flyState then return end
    local root = getRoot()
    if not root then return end
    flyState = true
    local controller = Instance.new("BodyVelocity")
    controller.MaxForce = Vector3.new(9e9,9e9,9e9)
    controller.Velocity = Vector3.new(0,0,0)
    controller.Parent = root
    flyConn = RunService.RenderStepped:Connect(function(dt)
        local move = Vector3.new(0,0,0)
        if flyControl.W then move = move + workspace.CurrentCamera.CFrame.LookVector end
        if flyControl.S then move = move - workspace.CurrentCamera.CFrame.LookVector end
        if flyControl.A then move = move - workspace.CurrentCamera.CFrame.RightVector end
        if flyControl.D then move = move + workspace.CurrentCamera.CFrame.RightVector end
        if flyControl.Up then move = move + Vector3.new(0,1,0) end
        if flyControl.Down then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0 then controller.Velocity = move.Unit * flySpeed else controller.Velocity = Vector3.new(0,0,0) end
    end)
end
local function stopFly()
    flyState = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local root = getRoot()
    if root then for _,v in pairs(root:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end end
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

-- ===================== UI POBLADO (organizado y centrado) =====================
-- Principal
local function clearContainer(frame)
    for _,v in pairs(frame:GetChildren()) do if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then v:Destroy() end end
end

-- PRIMERA PÁGINA: Principal
clearContainer(pPrincipal.Container)
local s1, b1 = CreateSection(pPrincipal.Container, "Accesos rápidos")
local grid1 = Instance.new("Frame") grid1.BackgroundTransparency = 1 grid1.Parent = b1
local gridLayout1 = Instance.new("UIGridLayout") gridLayout1.Parent = grid1 gridLayout1.CellSize = UDim2.new(0,220,0,BUTTON_HEIGHT) gridLayout1.CellPadding = UDim2.new(0,8,0,8) gridLayout1.FillDirection = Enum.FillDirection.Horizontal

local btnTpMouse = CreateButton(grid1, "TP a mouse (pos)")
local btnNoclip = CreateButton(grid1, "Toggle Noclip")
local btnFly = CreateButton(grid1, "Toggle Fly")
local btnInf = CreateButton(grid1, "Toggle Infinite Jump")

btnTpMouse.MouseButton1Click:Connect(function() teleportToMouse() end)
btnNoclip.MouseButton1Click:Connect(function()
    if noclipState then disableNoclip() else enableNoclip() end
    btnNoclip.Text = "Noclip: "..(noclipState and "ON" or "OFF")
end)
btnFly.MouseButton1Click:Connect(function()
    if flyState then stopFly() else startFly() end
    btnFly.Text = "Fly: "..(flyState and "ON" or "OFF")
end)
btnInf.MouseButton1Click:Connect(function()
    if infJump then disableInfJump(); btnInf.Text = "Infinite Jump: OFF" else enableInfJump(); btnInf.Text = "Infinite Jump: ON" end
end)

-- Jugadores list (teleport tocando nombre)
local s2, b2 = CreateSection(pPrincipal.Container, "Jugadores (clic para TP)")
local playersList = Instance.new("Frame") playersList.BackgroundTransparency = 1 playersList.Parent = b2
local playersLayout = Instance.new("UIListLayout") playersLayout.Parent = playersList playersLayout.Padding = UDim.new(0,6) playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersList.AutomaticSize = Enum.AutomaticSize.Y

local function refreshPlayersList()
    for _,v in pairs(playersList:GetChildren()) do if not v:IsA("UIListLayout") then v:Destroy() end end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1,-12,0,BUTTON_HEIGHT)
            pBtn.BackgroundColor3 = Color3.fromRGB(10,90,180)
            pBtn.BorderSizePixel = 0
            pBtn.Text = plr.Name
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 14
            pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.Parent = playersList
            local pCorner = Instance.new("UICorner") pCorner.Parent = pBtn
            trackedButtons[#trackedButtons+1] = pBtn
            pBtn.MouseButton1Click:Connect(function()
                teleportToPlayerObj(plr)
            end)
        end
    end
end
Players.PlayerAdded:Connect(refreshPlayersList)
Players.PlayerRemoving:Connect(refreshPlayersList)
refreshPlayersList()

-- TELEPORT PAGE (save/load y coords)
clearContainer(pTeleport.Container)
local sp, bp = CreateSection(pTeleport.Container, "Guardar / Cargar posiciones (4 slots)")
local slots = Instance.new("Frame") slots.BackgroundTransparency = 1 slots.Parent = bp
local slotsGrid = Instance.new("UIGridLayout") slotsGrid.Parent = slots slotsGrid.CellSize = UDim2.new(0,260,0,BUTTON_HEIGHT) slotsGrid.CellPadding = UDim2.new(0,8,0,8)
for i=1,4 do
    local sbtn = CreateButton(slots, "Guardar slot "..i, 120)
    local lbtn = CreateButton(slots, "Ir slot "..i, 120)
    sbtn.MouseButton1Click:Connect(function() savePosition(i) end)
    lbtn.MouseButton1Click:Connect(function() loadPosition(i) end)
end
local sc2, bc2 = CreateSection(pTeleport.Container, "Teleport a coordenadas")
local coordBox = Instance.new("TextBox") coordBox.Size = UDim2.new(1,0,0,28) coordBox.PlaceholderText = "x y z" coordBox.Parent = bc2
local goBtn = CreateButton(bc2, "Ir a coordenadas", 180)
goBtn.MouseButton1Click:Connect(function()
    local txt = coordBox.Text
    local x,y,z = txt:match("(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)")
    if x and y and z then
        local cf = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
        local root = getRoot()
        if root then root.CFrame = cf end
    end
end)

-- PLAYER PAGE (presets)
clearContainer(pPlayer.Container)
local spc, bpc = CreateSection(pPlayer.Container, "Presets Walk/Jump")
local gridP = Instance.new("Frame") gridP.BackgroundTransparency = 1 gridP.Parent = bpc
local gLayoutP = Instance.new("UIGridLayout") gLayoutP.Parent = gridP gLayoutP.CellSize = UDim2.new(0,200,0,BUTTON_HEIGHT) gLayoutP.CellPadding = UDim2.new(0,8,0,8)
local w16 = CreateButton(gridP, "WalkSpeed 16")
local w50 = CreateButton(gridP, "WalkSpeed 50")
local j50 = CreateButton(gridP, "Jump 50")
local j80 = CreateButton(gridP, "Jump 80")
w16.MouseButton1Click:Connect(function() setWalkSpeed(16) end)
w50.MouseButton1Click:Connect(function() setWalkSpeed(50) end)
j50.MouseButton1Click:Connect(function() setJumpPower(50) end)
j80.MouseButton1Click:Connect(function() setJumpPower(80) end)

local sInf, bInf = CreateSection(pPlayer.Container, "Infinite Jump")
local infBtn = CreateButton(bInf, "Toggle Infinite Jump", 220)
infBtn.MouseButton1Click:Connect(function()
    if infJump then disableInfJump(); infBtn.Text = "Infinite Jump: OFF" else enableInfJump(); infBtn.Text = "Infinite Jump: ON" end
end)

-- AJUSTES: color
clearContainer(pAjustes.Container)
local sC, bC = CreateSection(pAjustes.Container, "Color del HUB")
local colorFrame = Instance.new("Frame") colorFrame.BackgroundTransparency = 1 colorFrame.Parent = bC
local colorGrid = Instance.new("UIGridLayout") colorGrid.Parent = colorFrame colorGrid.CellSize = UDim2.new(0,140,0,BUTTON_HEIGHT) colorGrid.CellPadding = UDim2.new(0,8,0,8)

local colorButtons = {}
local currentColorName = DEFAULT_COLOR_NAME
local function applyHubColor(name)
    local c = COLORS[name]
    if not c then return end
    TitleBar.BackgroundColor3 = c
    LeftPanel.BackgroundColor3 = c
    OpenBtn.BackgroundColor3 = c
    -- recolor tracked buttons (menú, acciones) pero mantener highlight tab
    for _, b in pairs(trackedButtons) do
        if b and b.Parent and b:IsA("TextButton") then
            b.BackgroundColor3 = Color3.fromRGB(10,90,180)
        end
    end
    -- Make active tab standout
    for k, tb in pairs(tabButtons) do
        if tb then
            if tb.BackgroundColor3 == Color3.fromRGB(30,130,220) then
                tb.BackgroundColor3 = Color3.fromRGB(30,130,220)
            else
                tb.BackgroundColor3 = Color3.fromRGB(10,90,180)
            end
        end
    end
    -- Also tint buttons lightly with hub color for consistency (but keep readable)
    for _, b in pairs(trackedButtons) do
        if b and b:IsA("TextButton") then
            b.BackgroundColor3 = Color3.fromRGB(math.clamp(math.floor(c.R*255*0.35),0,255), math.clamp(math.floor(c.G*255*0.35),0,255), math.clamp(math.floor(c.B*255*0.35),0,255))
        end
    end
    currentColorName = name
end

for name, c in pairs(COLORS) do
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0,140,0,BUTTON_HEIGHT)
    cb.BackgroundColor3 = c
    cb.Text = name
    cb.Font = Enum.Font.Gotham
    cb.TextSize = 14
    cb.TextColor3 = Color3.new(0,0,0)
    cb.BorderSizePixel = 0
    local cc = Instance.new("UICorner") cc.Parent = cb
    cb.Parent = colorFrame
    colorButtons[name] = cb
    cb.MouseButton1Click:Connect(function()
        applyHubColor(name)
        for nm,btn in pairs(colorButtons) do btn.BackgroundTransparency = (nm==name) and 0 or 0.18 end
    end)
end
applyHubColor(DEFAULT_COLOR_NAME)
for nm,btn in pairs(colorButtons) do if nm~=DEFAULT_COLOR_NAME then btn.BackgroundTransparency = 0.18 end end

-- INFO
clearContainer(pInfo.Container)
local si, bi = CreateSection(pInfo.Container, "Acerca")
local infoLbl = CreateLabel(bi, "KS HUB v2.1 — Interfaz reorganizada. Click en el nombre del jugador para teletransportarte a él. Hotkey: RightControl.")

-- ===================== DRAG Y CONTROLES =====================
local dragging, dragStart, startPos = false, nil, nil
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

-- OPEN/CLOSE & HOTKEY
OpenBtn.MouseButton1Click:Connect(function() fadeIn() end)
CloseBtn.MouseButton1Click:Connect(function() fadeOut() end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if MainFrame.Visible then fadeOut() else fadeIn() end
    end
    -- fly controls
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

-- Actualizar hora en el título cada 30s
spawn(function()
    while true do
        TitleSub.Text = os.date("%d/%m/%Y %H:%M")
        task.wait(30)
    end
end)

print("KS HUB v2.1 cargado: interfaz reorganizada y botones arreglados.")
