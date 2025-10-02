-- KS HUB v1.0 - Rebuild desde 0 (bonito, robusto, 3 partes)
-- =========================================================
-- 🟩 PARTE 1 — Núcleo, servicios, estado y utilidades
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "Player no encontrado")

-- Evita múltiples GUIs al recargar
local GUI_NAME = "KS_HUB_v1_0"
if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(GUI_NAME) then
    pcall(function() LocalPlayer.PlayerGui:FindFirstChild(GUI_NAME):Destroy() end)
end

-- Estado global
local state = {
    char = nil,
    humanoid = nil,
    BASE_WALKSPEED = 16,
    BASE_JUMP = 50,
    delayActive = false,
    noclipActive = false,
    antiVoidActive = false,
    antiConn = nil,
    antiVoidY = -30,
    antiVoidSafe = CFrame.new(0,50,0),
    waypoints = { nil, nil },
    playersHL = {},
    playersHLAddConn = nil,
    playersHLRemConn = nil,
    promptOrig = {},
    promptConn = nil,
    noclipConn = nil,
    lightInst = nil,
    connections = {}, -- para cleanup
}

-- util: registra conexión para desconectar fácil
local function trackConn(conn)
    if conn then table.insert(state.connections, conn) end
end

-- espera personaje y guarda referencias
local function waitChar()
    repeat task.wait() until LocalPlayer and LocalPlayer.Character
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid")
    state.char = c
    state.humanoid = h
    state.BASE_WALKSPEED = state.BASE_WALKSPEED or (h and h.WalkSpeed) or 16
    state.BASE_JUMP = state.BASE_JUMP or (h and h.JumpPower) or 50
    return c, h
end
waitChar()
LocalPlayer.CharacterAdded:Connect(function() waitChar() end)

local function safePcall(f,...)
    local ok, a, b, c = pcall(f, ...)
    return ok, a, b, c
end

-- pequeño helper: find player by name or substring
local function findPlayerByString(str)
    if not str or str == "" then return nil end
    local exact = Players:FindFirstChild(str)
    if exact then return exact end
    local low = str:lower()
    for _,p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == low or (p.DisplayName and p.DisplayName:lower() == low) then return p end
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1,#low) == low or (p.DisplayName and p.DisplayName:lower():sub(1,#low) == low) then return p end
    end
    return nil
end

-- limpieza general: desconecta todo
local function cleanupAll()
    for _,c in pairs(state.connections) do
        pcall(function() c:Disconnect() end)
    end
    state.connections = {}
    if state.playersHLAddConn then pcall(function() state.playersHLAddConn:Disconnect() end) end
    if state.playersHLRemConn then pcall(function() state.playersHLRemConn:Disconnect() end) end
    if state.promptConn then pcall(function() state.promptConn:Disconnect() end) end
    if state.noclipConn then pcall(function() state.noclipConn:Disconnect() end) end
    if state.antiConn then pcall(function() state.antiConn:Disconnect() end) end
end

-- =========================================================
-- 🟦 PARTE 2 — UI (bonito) : creación helpers y layout
-- Root GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = GUI_NAME
GUI.ResetOnSpawn = false
GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- main frame
local MAIN_W, MAIN_H = 340, 480
local main = Instance.new("Frame", GUI)
main.Name = "Main"
main.Size = UDim2.fromOffset(MAIN_W, MAIN_H)
main.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -MAIN_H/2)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
main.BorderSizePixel = 0
main.ClipsDescendants = true

local uic = Instance.new("UICorner", main); uic.CornerRadius = UDim.new(0,12)
local uistroke = Instance.new("UIStroke", main); uistroke.Thickness = 1; uistroke.Transparency = 0.8

-- header
local header = Instance.new("Frame", main)
header.Name = "Header"
header.Size = UDim2.new(1,0,0,54)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, -12, 1, 0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "KS HUB — v1.0"
title.TextXAlignment = Enum.TextXAlignment.Left

local sub = Instance.new("TextLabel", header)
sub.Size = UDim2.new(0.3, -12, 1, 0)
sub.Position = UDim2.new(0.7, 12, 0, 0)
sub.BackgroundTransparency = 1
sub.Font = Enum.Font.Gotham
sub.TextSize = 12
sub.TextColor3 = Color3.fromRGB(200,200,200)
sub.TextXAlignment = Enum.TextXAlignment.Right
sub.Text = "Bonito · Robust · Modular"

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,38,0,30)
btnClose.Position = UDim2.new(1, -46, 0, 12)
btnClose.AnchorPoint = Vector2.new(0,0)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.TextColor3 = Color3.fromRGB(255,255,255)
btnClose.BackgroundColor3 = Color3.fromRGB(36, 42, 55)
btnClose.BorderSizePixel = 0
local btnCloseCorner = Instance.new("UICorner", btnClose); btnCloseCorner.CornerRadius = UDim.new(0,8)

-- tabs row
local tabsRow = Instance.new("Frame", main)
tabsRow.Size = UDim2.new(1, -24, 0, 40)
tabsRow.Position = UDim2.new(0,12,0,58)
tabsRow.BackgroundTransparency = 1

local function makeTabBtn(text, x)
    local b = Instance.new("TextButton", tabsRow)
    b.Size = UDim2.new(0.33, -4, 1, 0)
    b.Position = UDim2.new(x, 4, 0, 0)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    b.TextColor3 = Color3.fromRGB(220,220,220)
    b.AutoButtonColor = true
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,8)
    return b
end

local tabMainBtn = makeTabBtn("Principal", 0)
local tabVisualBtn = makeTabBtn("Visuales", 0.33)
local tabSettingsBtn = makeTabBtn("Ajustes", 0.66)

-- content area
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -24, 1, -120)
content.Position = UDim2.new(0,12,0,110)
content.BackgroundTransparency = 1

-- scrolling pages
local function newPage()
    local f = Instance.new("ScrollingFrame", content)
    f.Size = UDim2.new(1,0,1,0)
    f.CanvasSize = UDim2.new(0,0)
    f.BackgroundTransparency = 1
    f.ScrollBarThickness = 8
    local layout = Instance.new("UIListLayout", f)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,8)
    return f
end

local pageMain = newPage()
local pageVisual = newPage(); pageVisual.Visible = false
local pageSettings = newPage(); pageSettings.Visible = false

-- helpers para secciones y grid
local function makeSec(parent, txt)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1,0,0,22)
    L.BackgroundTransparency = 1
    L.Font = Enum.Font.GothamBold
    L.TextSize = 16
    L.TextColor3 = Color3.fromRGB(230,230,230)
    L.Text = txt
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.LayoutOrder = #parent:GetChildren() + 1
    return L
end

local function makeGrid(parent, items)
    local rows = math.ceil(#items / 2)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1,0,0, rows * (36 + 8))
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren() + 1
    local grid = Instance.new("UIGridLayout", container)
    grid.CellSize = UDim2.new(0.5, -8, 0, 36)
    grid.CellPadding = UDim2.new(0,8,0,8)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    for i,it in ipairs(items) do
        local b = Instance.new("TextButton", container)
        b.Size = UDim2.new(1,0,1,0)
        b.Text = it.text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.BackgroundColor3 = Color3.fromRGB(50,120,255)
        b.TextColor3 = Color3.fromRGB(18, 26, 50)
        b.AutoButtonColor = true
        b.LayoutOrder = i
        b.MouseButton1Click:Connect(function() pcall(it.cb) end)
        local corner = Instance.new("UICorner", b); corner.CornerRadius = UDim.new(0,8)
    end
    return container
end

-- mini status bar bottom
local statusBar = Instance.new("Frame", main)
statusBar.Size = UDim2.new(1,0,0,40)
statusBar.Position = UDim2.new(0,0,1, -40)
statusBar.BackgroundColor3 = Color3.fromRGB(14,18,28)
local statusTxt = Instance.new("TextLabel", statusBar)
statusTxt.Size = UDim2.new(1, -12, 1, 0)
statusTxt.Position = UDim2.new(0,6,0,0)
statusTxt.BackgroundTransparency = 1
statusTxt.Font = Enum.Font.Gotham
statusTxt.TextSize = 13
statusTxt.TextColor3 = Color3.fromRGB(170,170,170)
statusTxt.Text = "KS HUB listo — Insert para toggle"
statusTxt.TextXAlignment = Enum.TextXAlignment.Left

-- =========================================================
-- 🟪 PARTE 3 — Funciones (TP, Noclip, AntiVoid, Waypoints, Delay, Visuals) + wiring UI
-- 1) Core actions

-- Delay (ProximityPrompt hold -> 0)
local function toggleDelay(on)
    state.delayActive = on
    if on then
        for _,o in pairs(Workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") then
                pcall(function()
                    if not state.promptOrig[o] then state.promptOrig[o] = o.HoldDuration end
                    o.HoldDuration = 0
                end)
            end
        end
        if not state.promptConn then
            state.promptConn = Workspace.DescendantAdded:Connect(function(o)
                if o:IsA("ProximityPrompt") and state.delayActive then
                    pcall(function()
                        if not state.promptOrig[o] then state.promptOrig[o] = o.HoldDuration end
                        o.HoldDuration = 0
                    end)
                end
            end)
            trackConn(state.promptConn)
        end
        statusTxt.Text = "Delay: ON"
    else
        for o,v in pairs(state.promptOrig) do
            if o and o.Parent then pcall(function() o.HoldDuration = v end) end
        end
        state.promptOrig = {}
        if state.promptConn then pcall(function() state.promptConn:Disconnect() end); state.promptConn = nil end
        statusTxt.Text = "Delay: OFF"
    end
end

-- Noclip
local function toggleNoclip(on)
    state.noclipActive = on
    if state.noclipConn then pcall(function() state.noclipConn:Disconnect() end); state.noclipConn = nil end
    if on then
        state.noclipConn = RunService.Stepped:Connect(function()
            refresh()
            if state.char then
                for _,part in pairs(state.char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        trackConn(state.noclipConn)
        statusTxt.Text = "Noclip: ON"
    else
        refresh()
        if state.char then
            for _,part in pairs(state.char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        statusTxt.Text = "Noclip: OFF"
    end
end

-- Waypoints
local function saveWP(i) refresh(); if state.char and state.char:FindFirstChild("HumanoidRootPart") then state.waypoints[i] = state.char.HumanoidRootPart.CFrame; statusTxt.Text = "Waypoint "..i.." guardado" end end
local function loadWP(i) refresh(); if state.waypoints[i] and state.char and state.char:FindFirstChild("HumanoidRootPart") then state.char.HumanoidRootPart.CFrame = state.waypoints[i]; statusTxt.Text = "Waypoint "..i.." cargado" end end

-- WalkSpeed & Jump
local function setWS(v) refresh(); if state.humanoid then state.humanoid.WalkSpeed = v; statusTxt.Text = "WalkSpeed "..tostring(v) end end
local function setWSNorm() refresh(); if state.humanoid then state.humanoid.WalkSpeed = state.BASE_WALKSPEED; statusTxt.Text = "WalkSpeed restaurado" end end
local function adjustJump(p)
    refresh()
    if state.humanoid then
        if not state.BASE_JUMP or state.BASE_JUMP == 0 then state.BASE_JUMP = state.humanoid.JumpPower end
        state.humanoid.JumpPower = state.BASE_JUMP * (1 + p/100)
        statusTxt.Text = "Jump x"..(1 + p/100)
    end
end

-- Teleport
local function tpTo(name)
    if not name or name == "" then return end
    local p = findPlayerByString(name)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        refresh()
        if state.char and state.char:FindFirstChild("HumanoidRootPart") then
            local ok = pcall(function()
                state.char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end)
            if ok then statusTxt.Text = "TP → "..p.Name end
        end
    else
        statusTxt.Text = "Jugador no encontrado"
    end
end

-- AntiVoid
local function toggleAntiVoid(on)
    state.antiVoidActive = on
    if state.antiConn then pcall(function() state.antiConn:Disconnect() end); state.antiConn = nil end
    if on then
        state.antiConn = RunService.Heartbeat:Connect(function()
            refresh()
            if state.char and state.char.Parent and state.char:FindFirstChild("HumanoidRootPart") then
                local y = state.char.HumanoidRootPart.Position.Y
                if y <= state.antiVoidY then
                    pcall(function() state.char.HumanoidRootPart.CFrame = state.antiVoidSafe end)
                    if state.humanoid then pcall(function() state.humanoid:ChangeState(Enum.HumanoidStateType.Physics) end) end
                end
            end
        end)
        trackConn(state.antiConn)
        statusTxt.Text = "AntiVoid: ON"
    else
        statusTxt.Text = "AntiVoid: OFF"
    end
end

-- Visuals: Highlights
local function addHLToPlayer(p)
    if not p or not p.Character then return end
    if state.playersHL[p] then return end
    local ok, hl = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "KS_Highlight"
        h.Adornee = p.Character
        h.Parent = p.Character
        return h
    end)
    if ok and hl then state.playersHL[p] = hl end
end

local function removeHLFromPlayer(p)
    if state.playersHL[p] then
        pcall(function() state.playersHL[p]:Destroy() end)
        state.playersHL[p] = nil
    else
        if p and p.Character then
            local e = p.Character:FindFirstChild("KS_Highlight")
            if e then pcall(function() e:Destroy() end) end
        end
    end
end

local function togglePlayersHighlight(on)
    if on then
        for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then addHLToPlayer(p) end end
        state.playersHLAddConn = Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then p.CharacterAdded:Connect(function() addHLToPlayer(p) end); addHLToPlayer(p) end end)
        state.playersHLRemConn = Players.PlayerRemoving:Connect(function(p) removeHLFromPlayer(p) end)
        trackConn(state.playersHLAddConn); trackConn(state.playersHLRemConn)
        statusTxt.Text = "Highlights: ON"
    else
        for p,_ in pairs(state.playersHL) do removeHLFromPlayer(p) end
        state.playersHL = {}
        statusTxt.Text = "Highlights: OFF"
    end
end

-- PointLight on player
local function togglePointLight(on)
    refresh()
    if not state.char then return end
    local hrp = state.char:FindFirstChild("HumanoidRootPart")
    if on then
        if hrp and not hrp:FindFirstChild("KS_PointLight") then
            local pl = Instance.new("PointLight")
            pl.Name = "KS_PointLight"; pl.Range = 18; pl.Brightness = 2.5; pl.Parent = hrp
            state.lightInst = pl
            statusTxt.Text = "Luz: ON"
        end
    else
        if hrp and hrp:FindFirstChild("KS_PointLight") then
            pcall(function() hrp:FindFirstChild("KS_PointLight"):Destroy() end)
            state.lightInst = nil
            statusTxt.Text = "Luz: OFF"
        end
    end
end

-- =========================================================
--  UI wiring: rellenar páginas con controls (botones / textbox / lista)
-- Main page: controls
do
    local p = pageMain

    makeSec(p, "Interacción rápida")
    makeGrid(p, {
        { text = "Delay ON", cb = function() toggleDelay(true) end },
        { text = "Delay OFF", cb = function() toggleDelay(false) end },
    })

    makeSec(p, "Noclip")
    makeGrid(p, {
        { text = "Noclip ON", cb = function() toggleNoclip(true) end },
        { text = "Noclip OFF", cb = function() toggleNoclip(false) end },
    })

    makeSec(p, "Waypoints")
    makeGrid(p, {
        { text = "Save 1", cb = function() saveWP(1) end },
        { text = "Save 2", cb = function() saveWP(2) end },
        { text = "Load 1", cb = function() loadWP(1) end },
        { text = "Load 2", cb = function() loadWP(2) end },
    })

    makeSec(p, "Velocidad / Salto")
    makeGrid(p, {
        { text = "WalkNorm", cb = function() setWSNorm() end },
        { text = "Walk 50", cb = function() setWS(50) end },
        { text = "+25% Jump", cb = function() adjustJump(25) end },
        { text = "+100% Jump", cb = function() adjustJump(100) end },
    })

    makeSec(p, "Teleport")
    -- textbox + TP button
    local tbFrame = Instance.new("Frame", p)
    tbFrame.Size = UDim2.new(1,0,0,36)
    tbFrame.BackgroundTransparency = 1
    tbFrame.LayoutOrder = #p:GetChildren() + 1
    local tb = Instance.new("TextBox", tbFrame)
    tb.Size = UDim2.new(0.68, -8,1,0)
    tb.Position = UDim2.new(0,0,0,0)
    tb.PlaceholderText = "Nombre o @substring"
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    local tpbtn = Instance.new("TextButton", tbFrame)
    tpbtn.Size = UDim2.new(0.32,0,1,0)
    tpbtn.Position = UDim2.new(0.68, 8, 0, 0)
    tpbtn.Text = "TP"
    tpbtn.Font = Enum.Font.GothamBold
    tpbtn.TextSize = 14
    tpbtn.MouseButton1Click:Connect(function() tpTo(tb.Text) end)

    -- player list (dynamic)
    makeSec(p, "Lista de jugadores")
    local listFrame = Instance.new("Frame", p)
    listFrame.Size = UDim2.new(1,0,0,220)
    listFrame.BackgroundTransparency = 1
    listFrame.LayoutOrder = #p:GetChildren() + 1
    local s = Instance.new("ScrollingFrame", listFrame)
    s.Size = UDim2.new(1,0,1,0)
    s.BackgroundTransparency = 1
    s.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", s)
    layout.Padding = UDim.new(0,6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function makePlayerBtn(plr)
        if not plr or plr == LocalPlayer then return end
        if s:FindFirstChild("btn_"..plr.Name) then return end
        local btn = Instance.new("TextButton", s)
        btn.Name = "btn_"..plr.Name
        btn.Size = UDim2.new(1, -8, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(80,180,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(10,20,40)
        btn.Text = (plr.DisplayName or plr.Name).." (@"..plr.Name..")"
        local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,8)
        btn.MouseButton1Click:Connect(function() tpTo(plr.Name) end)
    end

    for _,plr in pairs(Players:GetPlayers()) do makePlayerBtn(plr) end
    Players.PlayerAdded:Connect(makePlayerBtn)
    Players.PlayerRemoving:Connect(function(plr)
        local b = s:FindFirstChild("btn_"..plr.Name)
        if b then pcall(function() b:Destroy() end) end
    end)
end

-- Visual page
do
    local p = pageVisual
    makeSec(p, "Jugadores (Highlight)")
    makeGrid(p, {
        { text = "HL ON", cb = function() togglePlayersHighlight(true) end },
        { text = "HL OFF", cb = function() togglePlayersHighlight(false) end },
    })
    makeSec(p, "Iluminación personal")
    makeGrid(p, {
        { text = "Light ON", cb = function() togglePointLight(true)
