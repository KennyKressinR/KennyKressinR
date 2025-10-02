-- KS HUB v0.2.3 - Unificado, completo y dividido en 6 partes (comentarios con emojis)
-- Copia/pega entero en KS_HUB.lua

if not game:IsLoaded() then game.Loaded:Wait() end

-- =========================================================
-- 🟢 Parte 1: Servicios y personaje
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local pl = Players.LocalPlayer

-- Evitar duplicados al recargar
if pl:FindFirstChild("PlayerGui") and pl.PlayerGui:FindFirstChild("KSHub_v0_2_3") then
    pcall(function() pl.PlayerGui:FindFirstChild("KSHub_v0_2_3"):Destroy() end)
end

-- Personaje
local function waitChar()
    repeat task.wait() until pl and pl.Character
    local c = pl.Character or pl.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid")
    return c, h
end

local char, humanoid = waitChar()
local BASE_WALKSPEED = (humanoid and humanoid.WalkSpeed) or 16
local jumpBase = (humanoid and humanoid.JumpPower) or 50

-- Estado & conexiones
local delayActive, noclipActive = false, false
local waypoints = {nil, nil}
local antiVoidActive = false
local antiConn = nil
local antiVoidY = -30
local antiVoidSafe = CFrame.new(0, 50, 0)
local playersView = false
local playersHL = {}
local playersAddConn, playersRemConn = nil, nil
local promptOrig = {}
local promptConn, noclipConn = nil, nil
local lightInst = nil

-- Refresh al reaparecer
local function refresh()
    char, humanoid = waitChar()
    BASE_WALKSPEED = BASE_WALKSPEED or (humanoid and humanoid.WalkSpeed) or 16
    jumpBase = jumpBase or (humanoid and humanoid.JumpPower) or 50
end
pl.CharacterAdded:Connect(refresh)

-- =========================================================
-- 🔵 Parte 2: GUI raíz, ventana principal y pestañas
local SCREEN_W, SCREEN_H = 260, 440
local BUTTON_H = 30
local DEFAULT_TRANSPARENCY = 0.5
local HEADER_H = 42
local TABS_H = 40
local CONTENT_PADDING = 8
local CONTENT_TOP = HEADER_H + TABS_H + 6
local TOGGLE_KEY = Enum.KeyCode.Insert

local GUI = Instance.new("ScreenGui")
GUI.Name = "KSHub_v0_2_3"
GUI.ResetOnSpawn = false
GUI.Parent = pl:WaitForChild("PlayerGui")

local main = Instance.new("Frame", GUI)
main.Name = "KS_MainWindow"
main.Size = UDim2.new(0, SCREEN_W, 0, SCREEN_H)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(0,140,255)
main.BorderSizePixel = 0
main.BackgroundTransparency = DEFAULT_TRANSPARENCY
main.ZIndex = 1
main.Visible = true

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundTransparency = 1
header.ZIndex = 3

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, -12, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "KS HUB v0.2.3"
title.ZIndex = 4

local tabsBar = Instance.new("Frame", main)
tabsBar.Size = UDim2.new(1, 0, 0, TABS_H)
tabsBar.Position = UDim2.new(0, 0, 0, HEADER_H)
tabsBar.BackgroundTransparency = 1
tabsBar.ZIndex = 3

local function makeTab(parent, x, text, col)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.33, -8, 0.9, 0)
    b.Position = UDim2.new(x, 8, 0.05, 0)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = col
    b.AutoButtonColor = true
    b.ZIndex = 4
    return b
end

local tMain = makeTab(tabsBar, 0, "Principal", Color3.fromRGB(0,140,255))
local tVisual = makeTab(tabsBar, 0.33, "Visuales", Color3.fromRGB(0,130,240))
local tSettings = makeTab(tabsBar, 0.66, "Ajustes", Color3.fromRGB(0,120,220))

-- Close button
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, (HEADER_H - 32) / 2)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(10,10,10)
closeBtn.BorderSizePixel = 1
closeBtn.ZIndex = 5
closeBtn.AutoButtonColor = true

-- =========================================================
-- 🟡 Parte 3: ScrollingFrames y helpers UI
local function newScroll(parent)
    local s = Instance.new("ScrollingFrame", parent)
    s.Position = UDim2.new(0, CONTENT_PADDING, 0, CONTENT_TOP)
    s.Size = UDim2.new(1, -CONTENT_PADDING*2, 0, SCREEN_H - CONTENT_TOP - CONTENT_PADDING)
    s.ScrollBarThickness = 8
    s.BackgroundTransparency = 1
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    s.ZIndex = 2
    local pad = Instance.new("UIPadding", s)
    pad.PaddingTop = UDim.new(0,6)
    pad.PaddingBottom = UDim.new(0,8)
    pad.PaddingLeft = UDim.new(0,6)
    pad.PaddingRight = UDim.new(0,6)
    local list = Instance.new("UIListLayout", s)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,6)
    return s
end

local scMain = newScroll(main)
local scVisual = newScroll(main); scVisual.Visible = false
local scSettings = newScroll(main); scSettings.Visible = false

local function sec(parent, name)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, 0, 0, 26)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 17
    l.Text = name
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren() or 0) + 1
    return l
end

local function grid(parent, items)
    local rows = math.ceil(#items / 2)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, rows * (BUTTON_H + 6))
    container.BackgroundTransparency = 1
    container.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren() or 0) + 1

    local gridLayout = Instance.new("UIGridLayout", container)
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.CellPadding = UDim2.new(0,8,0,6)
    gridLayout.CellSize = UDim2.new(0.5, -8, 0, BUTTON_H)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    for i, it in ipairs(items) do
        local b = Instance.new("TextButton", container)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(0,200,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16
        b.TextColor3 = Color3.fromRGB(0,0,80)
        b.Text = it.text
        b.AutoButtonColor = true
        b.ZIndex = 3
        b.LayoutOrder = i
        if it.cb then
            b.MouseButton1Click:Connect(it.cb)
        end
    end

    return container
end

-- =========================================================
-- 🔴 Parte 4: Funciones principales (core)
-- Interacción retrasada
local function toggleDelay(s)
    delayActive = s
    if s then
        for _, o in pairs(Workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") then
                pcall(function()
                    if not promptOrig[o] then promptOrig[o] = o.HoldDuration end
                    o.HoldDuration = 0
                end)
            end
        end
        if not promptConn then
            promptConn = Workspace.DescendantAdded:Connect(function(o)
                if o:IsA("ProximityPrompt") and delayActive then
                    pcall(function()
                        if not promptOrig[o] then promptOrig[o] = o.HoldDuration end
                        o.HoldDuration = 0
                    end)
                end
            end)
        end
    else
        for o, v in pairs(promptOrig) do
            if o and o.Parent then pcall(function() o.HoldDuration = v end) end
        end
        promptOrig = {}
        if promptConn then promptConn:Disconnect(); promptConn = nil end
    end
end

-- Noclip
local function toggleNoclip(s)
    noclipActive = s
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if s then
        noclipConn = RunService.Stepped:Connect(function()
            refresh()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        refresh()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- Waypoints
local function saveWP(i) refresh(); if char and char:FindFirstChild("HumanoidRootPart") then waypoints[i] = char.HumanoidRootPart.CFrame end end
local function loadWP(i) refresh(); if waypoints[i] and char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = waypoints[i] end end

-- WalkSpeed y Jump
local function setWS(v) refresh(); if humanoid then humanoid.WalkSpeed = v end end
local function setWSNorm() refresh(); if humanoid then humanoid.WalkSpeed = BASE_WALKSPEED end end
local function adjustJump(p)
    refresh()
    if humanoid then
        if not jumpBase or jumpBase == 0 then jumpBase = (humanoid and humanoid.JumpPower) or 50 end
        humanoid.JumpPower = jumpBase * (1 + p/100)
    end
end

-- Teleport a jugador (compatibilidad parcial/nombre/display/subcadena)
local function tpTo(name)
    if not name or name == "" then return end
    local target = Players:FindFirstChild(name)
    if not target then
        local low = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == low or (p.DisplayName and p.DisplayName:lower() == low) then target = p; break end
        end
    end
    if not target then
        local low = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #low) == low or (p.DisplayName and p.DisplayName:lower():sub(1, #low) == low) then target = p; break end
        end
    end
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        refresh()
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- offset to reduce getting stuck inside
            char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        end
    end
end

-- AntiVoid
local function toggleAntiVoid(s)
    antiVoidActive = s
    if antiConn then antiConn:Disconnect(); antiConn = nil end
    if s then
        antiConn = RunService.Heartbeat:Connect(function()
            refresh()
            if char and char.Parent and char:FindFirstChild("HumanoidRootPart") then
                local y = char.HumanoidRootPart.Position.Y
                if y <= antiVoidY then
                    pcall(function() char.HumanoidRootPart.CFrame = antiVoidSafe end)
                    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
                end
            end
        end)
    end
end

-- =========================================================
-- 🟣 Parte 5: Visuales (Highlight jugadores y luz)
local function addHL(p)
    if not p or not p.Character or playersHL[p] then return end
    local ok, hl = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "KS_Highlight"
        h.Parent = p.Character
        return h
    end)
    if ok and hl then playersHL[p] = hl end
end

local function removeHL(p)
    if playersHL[p] then
        pcall(function() playersHL[p]:Destroy() end)
        playersHL[p] = nil
    else
        if p and p.Character then
            local e = p.Character:FindFirstChild("KS_Highlight")
            if e then pcall(function() e:Destroy() end) end
        end
    end
end

local function togglePlayersView(s)
    playersView = s
    if playersAddConn then playersAddConn:Disconnect(); playersAddConn = nil end
    if playersRemConn then playersRemConn:Disconnect(); playersRemConn = nil end
    if s then
        for _, p in pairs(Players:GetPlayers()) do if p ~= pl then addHL(p) end end
        playersAddConn = Players.PlayerAdded:Connect(function(p)
            if p ~= pl then
                p.CharacterAdded:Connect(function() addHL(p) end)
                addHL(p)
            end
        end)
        playersRemConn = Players.PlayerRemoving:Connect(function(p) removeHL(p) end)
    else
        for p, _ in pairs(playersHL) do removeHL(p) end
        playersHL = {}
    end
end

local function toggleLight(s)
    refresh()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if s then
        if hrp and not hrp:FindFirstChild("KS_PointLight") then
            local plight = Instance.new("PointLight")
            plight.Name = "KS_PointLight"
            plight.Range = 16
            plight.Brightness = 2
            plight.Parent = hrp
            lightInst = plight
        end
    else
        if hrp and hrp:FindFirstChild("KS_PointLight") then
            pcall(function() hrp:FindFirstChild("KS_PointLight"):Destroy() end)
            lightInst = nil
        end
    end
end

-- =========================================================
-- ⚫ Parte 6: Eventos GUI, pestañas, contenido y drag
-- Construcción del contenido (Principal)
do
    local p = scMain

    sec(p, "Interacción Retrasada")
    grid(p, {
        { text = "Activar", cb = function() toggleDelay(true) end },
        { text = "Desactivar", cb = function() toggleDelay(false) end },
    })

    sec(p, "Noclip")
    grid(p, {
        { text = "Activar", cb = function() toggleNoclip(true) end },
        { text = "Desactivar", cb = function() toggleNoclip(false) end },
    })

    sec(p, "Puntos de camino")
    grid(p, {
        { text = "Save1", cb = function() saveWP(1) end },
        { text = "Save2", cb = function() saveWP(2) end },
        { text = "Load1", cb = function() loadWP(1) end },
        { text = "Load2", cb = function() loadWP(2) end },
    })

    sec(p, "Velocidad de Caminata")
    grid(p, {
        { text = "Normal", cb = function() setWSNorm() end },
        { text = "30", cb = function() setWS(30) end },
        { text = "50", cb = function() setWS(50) end },
        { text = "75", cb = function() setWS(75) end },
        { text = "150", cb = function() setWS(150) end },
        { text = "200", cb = function() setWS(200) end },
    })

    sec(p, "Impulso de salto")
    grid(p, {
        { text = "Desactivar", cb = function() adjustJump(0) end },
        { text = "+25%", cb = function() adjustJump(25) end },
        { text = "+50%", cb = function() adjustJump(50) end },
        { text = "+100%", cb = function() adjustJump(100) end },
    })

    sec(p, "Teleport a jugador")
    local tbFrame = Instance.new("Frame", p)
    tbFrame.Size = UDim2.new(1, 0, 0, BUTTON_H + 6)
    tbFrame.BackgroundTransparency = 1
    tbFrame.LayoutOrder = (p:FindFirstChildOfClass("UIListLayout") and #p:GetChildren() or 0) + 1

    local tb = Instance.new("TextBox", tbFrame)
    tb.Size = UDim2.new(1, -84, 1, 0)
    tb.Position = UDim2.new(0, 0, 0, 0)
    tb.Text = ""
    tb.PlaceholderText = "Nombre del jugador"
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 15
    tb.ClearTextOnFocus = true
    tb.ZIndex = 3

    local tpBtn = Instance.new("TextButton", tbFrame)
    tpBtn.Size = UDim2.new(0, 80, 1, 0)
    tpBtn.Position = UDim2.new(1, -80, 0, 0)
    tpBtn.Text = "TP"
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 15
    tpBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
    tpBtn.ZIndex = 3
    tpBtn.AutoButtonColor = true
    tpBtn.MouseButton1Click:Connect(function() tpTo(tb.Text) end)

    -- Lista dinámica de jugadores (botones)
    local playersFrame = Instance.new("Frame", p)
    playersFrame.Size = UDim2.new(1, 0, 0, 200)
    playersFrame.BackgroundTransparency = 1
    playersFrame.LayoutOrder = (p:FindFirstChildOfClass("UIListLayout") and #p:GetChildren() or 0) + 1

    local playersScroll = Instance.new("ScrollingFrame", playersFrame)
    playersScroll.Size = UDim2.new(1, 0, 1, 0)
    playersScroll.BackgroundTransparency = 1
    playersScroll.ScrollBarThickness = 6
    playersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    playersScroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    playersScroll.ZIndex = 3

    local listLayout = Instance.new("UIListLayout", playersScroll)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)

    local function addPlayerButton(player)
        if not player or player == pl then return end
        if playersScroll:FindFirstChild("btn_" .. player.Name) then return end
        local btn = Instance.new("TextButton", playersScroll)
        btn.Size = UDim2.new(1, -4, 0, BUTTON_H)
        btn.BackgroundColor3 = Color3.fromRGB(0,200,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.TextColor3 = Color3.fromRGB(0,0,80)
        local display = player.DisplayName or player.Name
        btn.Text = display .. " (@" .. player.Name .. ")"
        btn.AutoButtonColor = true
        btn.Name = "btn_" .. player.Name
        btn.MouseButton1Click:Connect(function() tpTo(player.Name) end)
    end

    local function removePlayerButton(player)
        local b = playersScroll:FindFirstChild("btn_" .. player.Name)
        if b then b:Destroy() end
    end

    -- Inicializar lista
    for _, player in pairs(Players:GetPlayers()) do addPlayerButton(player) end
    Players.PlayerAdded:Connect(addPlayerButton)
    Players.PlayerRemoving:Connect(removePlayerButton)

    -- AntiVoid
    sec(p, "AntiVoid")
    grid(p, {
        { text = "Activar", cb = function() toggleAntiVoid(true) end },
        { text = "Desactivar", cb = function() toggleAntiVoid(false) end },
    })

end

-- Visual tab
do
    local p = scVisual
    sec(p, "Ver jugadores")
    grid(p, {
        { text = "Activar", cb = function() togglePlayersView(true) end },
        { text = "Desactivar", cb = function() togglePlayersView(false) end },
    })
    sec(p, "Iluminación")
    grid(p, {
        { text = "Activar", cb = function() toggleLight(true) end },
        { text = "Desactivar", cb = function() toggleLight(false) end },
    })
end

-- Settings tab
do
    local p = scSettings
    sec(p, "Transparencia GUI")
    grid(p, {
        { text = "Normal", cb = function() main.BackgroundTransparency = 0 end },
        { text = "50%", cb = function() main.BackgroundTransparency = 0.5 end },
    })
    local change = Instance.new("TextLabel", p)
    change.Size = UDim2.new(1, 0, 0, 120)
    change.BackgroundTransparency = 1
    change.TextWrapped = true
    change.TextYAlignment = Enum.TextYAlignment.Top
    change.Font = Enum.Font.Gotham
    change.TextSize = 14
    change.TextColor3 = Color3.new(1,1,1)
    change.Text = "📌 Changelog - KS HUB v0.2.3\n\n- Base v0.2 estable mantenida\n- TP lista + textbox\n- Noclip, AntiVoid, Waypoints, Delay, Highlights, Light\n- Toggle con Insert + boton X/Reopen"
    change.LayoutOrder = 1000
end

-- Pestañas (switch)
tMain.MouseButton1Click:Connect(function() scMain.Visible = true; scVisual.Visible = false; scSettings.Visible = false end)
tVisual.MouseButton1Click:Connect(function() scMain.Visible = false; scVisual.Visible = true; scSettings.Visible = false end)
tSettings.MouseButton1Click:Connect(function() scMain.Visible = false; scVisual.Visible = false; scSettings.Visible = true end)

-- Close / Reopen
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    if GUI:FindFirstChild("KS_ReopenBtn") then return end
    local reopen = Instance.new("TextButton", GUI)
    reopen.Name = "KS_ReopenBtn"
   
