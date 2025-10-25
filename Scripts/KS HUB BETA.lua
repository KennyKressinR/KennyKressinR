----------------------------------------------------------
-- Parte 1: Servicios, estados globales y utilidades
----------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Sonidos (IDs configurables)
local CLICK_SOUND_ID = "rbxassetid://6723721422"
local OPEN_CLOSE_SOUND_ID = "rbxassetid://9118823106"
local CLOSE_CLICK_SOUND_ID = "rbxassetid://9118823106"

-- Estados globales
_G.dragHubEnabled = true

-- Estados visuales / funciones (se definen más adelante)
local createButton, createSectionLabel, attachScrolling, switchTab
local Tabs, Scrolls, TabButtons = {}, {}, {}

-- Utilidades
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportToCFrame(cf)
    local hrp = getHRP()
    if hrp then hrp.CFrame = cf end
end

local function createNotification(msg)
    print("[KS HUB] " .. msg)
end

----------------------------------------------------------
-- Parte 2: ScreenGui, MainFrame, TopBar, Toggle flotante
----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 420) -- altura aumentada
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 46)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KS HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 36, 0, 28)
CloseButton.Position = UDim2.new(1, -46, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
CloseButton.BackgroundTransparency = 0.1
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Ícono de candado para drag toggle
local DragLock = Instance.new("TextButton")
DragLock.Size = UDim2.new(0, 28, 0, 28)
DragLock.Position = UDim2.new(1, -86, 0, 4)
DragLock.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
DragLock.BackgroundTransparency = 0.1
DragLock.BorderSizePixel = 0
DragLock.Text = "🔓"
DragLock.TextColor3 = Color3.new(1,1,1)
DragLock.Font = Enum.Font.Gotham
DragLock.TextSize = 16
DragLock.Parent = TopBar
Instance.new("UICorner", DragLock).CornerRadius = UDim.new(0, 6)

-- Sonidos
local openCloseSound = Instance.new("Sound")
openCloseSound.SoundId = OPEN_CLOSE_SOUND_ID
openCloseSound.Volume = 0.75
openCloseSound.Parent = MainFrame

local closeClickSound = Instance.new("Sound")
closeClickSound.SoundId = CLOSE_CLICK_SOUND_ID
closeClickSound.Volume = 0.75
closeClickSound.Parent = CloseButton

-- Toggle flotante ≡
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 42, 0, 42)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -21)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
ToggleButton.BackgroundTransparency = 0.15
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = OPEN_CLOSE_SOUND_ID
toggleSound.Volume = 0.75
toggleSound.Parent = ToggleButton

-- Animaciones
local function openHub()
    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 1
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.25,
        Position = UDim2.new(0.5, -210, 0.5, -210)
    }):Play()
end

local function closeHub()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 600, 0.5, -210),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        MainFrame.Visible = false
        MainFrame.Position = UDim2.new(0.5, -210, 0.5, -210)
    end)
end

-- Acciones
CloseButton.MouseButton1Click:Connect(function()
    closeClickSound:Play()
    closeHub()
end)

ToggleButton.MouseButton1Click:Connect(function()
    if not MainFrame.Visible then openHub() else closeHub() end
    toggleSound:Play()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        if not MainFrame.Visible then openHub() else closeHub() end
        openCloseSound:Play()
    end
end)



----------------------------------------------------------
-- Parte 3: Sidebar vertical, páginas y helpers (mejorada)
----------------------------------------------------------
local TabsBar = Instance.new("Frame")
TabsBar.Name = "TabsBar"
TabsBar.Size = UDim2.new(0, 118, 1, -40)
TabsBar.Position = UDim2.new(0, 6, 0, 40)
TabsBar.BackgroundColor3 = Color3.fromRGB(22, 32, 52)
TabsBar.BackgroundTransparency = 0.2
TabsBar.BorderSizePixel = 0
TabsBar.Parent = MainFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
tabsLayout.Parent = TabsBar

local TabsContent = Instance.new("Frame")
TabsContent.Name = "TabsContent"
TabsContent.Size = UDim2.new(1, -130, 1, -50)
TabsContent.Position = UDim2.new(0, 130, 0, 45)
TabsContent.BackgroundTransparency = 1
TabsContent.Parent = MainFrame

-- Helpers
createButton = function(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 70, 120)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    end)

    btn.MouseButton1Click:Connect(function()
        local s = Instance.new("Sound")
        s.SoundId = CLICK_SOUND_ID
        s.Volume = 0.7
        s.Parent = btn
        s:Play()
        callback()
        s:Destroy()
    end)
    return btn
end

createSectionLabel = function(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "» " .. text
    lbl.TextColor3 = Color3.fromRGB(180, 200, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

attachScrolling = function(parentFrame)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 160, 220)
    scroll.BackgroundTransparency = 1
    scroll.Parent = parentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent = scroll

    return scroll
end

local tabsList = {"Main","Teleport","Waypoints","Visual","Ajustes"}
TabButtons = {}
Tabs = {}
Scrolls = {}

switchTab = function(tabName)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
        if TabButtons[name] then
            TabButtons[name].BackgroundColor3 = (name == tabName)
                and Color3.fromRGB(50, 90, 150)
                or Color3.fromRGB(30, 50, 80)
        end
    end
end

for _, name in ipairs(tabsList) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -10, 0, 30)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    tabBtn.BackgroundTransparency = 0.1
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.new(1,1,1)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 14
    tabBtn.Parent = TabsBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = TabsContent
    Tabs[name] = page

    Scrolls[name] = attachScrolling(page)
    TabButtons[name] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

switchTab("Main")



----------------------------------------------------------
----------------------------------------------------------
-- Parte 4: MAIN (actualizado y mejorado)
----------------------------------------------------------
local MainScroll = Scrolls["Main"]

----------------------------------------------------------
-- Sección: Interacciones
----------------------------------------------------------
createSectionLabel(MainScroll, "Interacciones")

-- Auto Interact (fusionado y mejorado)
local autoInteractConn
collectNameFilter = collectNameFilter or "coin"
collectRadius = collectRadius or 50

createButton(MainScroll, "Auto Interact (Touch/Click/Prompt)", function()
    if autoInteractConn then
        autoInteractConn:Disconnect()
        autoInteractConn = nil
        createNotification("Auto Interact OFF")
        updateAutoInteractHUD(false)
        return
    end

    autoInteractConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP()
        if not hrp then return end
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), collectNameFilter) then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < collectRadius then
                    local touch = obj:FindFirstChildOfClass("TouchTransmitter")
                    if touch then
                        firetouchinterest(hrp, obj, 0)
                        firetouchinterest(hrp, obj, 1)
                        count += 1
                    end
                    local click = obj:FindFirstChildOfClass("ClickDetector")
                    if click then fireclickdetector(click) count += 1 end
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and prompt.Enabled then
                        fireproximityprompt(prompt, math.huge)
                        count += 1
                    end
                end
            end
        end
        if count > 0 then
            print("[KS HUB] Auto Interact: "..count.." objetos en este ciclo")
        end
    end)

    createNotification("Auto Interact ON (Touch + Click + Prompt)")
    updateAutoInteractHUD(true)
end)

-- Quick Interact (mejorado con rango configurable)
local quickInteractRange = 20
createButton(MainScroll, "Quick Interact (Prompt cercano)", function()
    local hrp = getHRP()
    if not hrp then return end
    local closestPrompt, closestDist
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or nil
            if parentPart then
                local dist = (parentPart.Position - hrp.Position).Magnitude
                if not closestDist or dist < closestDist then
                    closestPrompt = obj
                    closestDist = dist
                end
            end
        end
    end
    if closestPrompt and closestDist < quickInteractRange then
        fireproximityprompt(closestPrompt, math.huge)
        createNotification("Quick Interact: " .. closestPrompt.Parent.Name)
    else
        createNotification("No hay prompt cercano (<"..quickInteractRange..")")
    end
end)

----------------------------------------------------------
-- Sección: Movilidad
----------------------------------------------------------
createSectionLabel(MainScroll, "Movilidad")

-- Noclip
local noclipConn
createButton(MainScroll, "Noclip (toggle)", function()
    _G.noclipEnabled = not _G.noclipEnabled
    if _G.noclipEnabled and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        createNotification("Noclip ON")
        updateNoclipHUD(true)
    elseif noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
        createNotification("Noclip OFF")
        updateNoclipHUD(false)
    end
end)

-- Infinite Jump
local infiniteJumpConn
createButton(MainScroll, "Infinite Jump (toggle)", function()
    _G.infiniteJumpEnabled = not _G.infiniteJumpEnabled
    if _G.infiniteJumpEnabled and not infiniteJumpConn then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        createNotification("Infinite Jump ON")
    elseif infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
        createNotification("Infinite Jump OFF")
    end
end)

----------------------------------------------------------
-- Sección: Utilidades
----------------------------------------------------------
createSectionLabel(MainScroll, "Utilidades")

-- Reset MAIN
createButton(MainScroll, "Reset MAIN", function()
    if autoInteractConn then autoInteractConn:Disconnect() autoInteractConn = nil end
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if infiniteJumpConn then infiniteJumpConn:Disconnect() infiniteJumpConn = nil end
    _G.noclipEnabled = false
    _G.infiniteJumpEnabled = false
    createNotification("MAIN reseteado (todo OFF)")
    updateAutoInteractHUD(false)
    updateNoclipHUD(false)
end)



----------------------------------------------------------
-- Parte 5: Teleport a jugadores
----------------------------------------------------------
local TeleportScroll = Scrolls["Teleport"]
createSectionLabel(TeleportScroll, "Jugadores")

local function refreshPlayers()
    for _, child in ipairs(TeleportScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createButton(TeleportScroll, "TP a " .. plr.Name, function()
                local targetChar = plr.Character or plr.CharacterAdded:Wait()
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    teleportToCFrame(targetHRP.CFrame)
                    createNotification("Teletransportado a " .. plr.Name)
                else
                    warn("[KS HUB] El jugador " .. plr.Name .. " no tiene HumanoidRootPart")
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()


----------------------------------------------------------
-- Parte 6: Waypoints (mejorado)
----------------------------------------------------------
local WaypointsScroll = Scrolls["Waypoints"]
createSectionLabel(WaypointsScroll, "Gestión de Waypoints")

local savedWaypoints = {}
local lastCreated = nil

local function refreshWaypoints()
    for _, child in ipairs(WaypointsScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for name, pos in pairs(savedWaypoints) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundTransparency = 1
        frame.Parent = WaypointsScroll

        local btnTP = createButton(frame, "TP: " .. name, function()
            teleportToCFrame(CFrame.new(pos))
            createNotification("Teletransportado a '"..name.."'")
        end)
        btnTP.Size = UDim2.new(0.65, -3, 1, 0)
        btnTP.Position = UDim2.new(0, 0, 0, 0)

        local btnDel = Instance.new("TextButton")
        btnDel.Size = UDim2.new(0.3, 0, 1, 0)
        btnDel.Position = UDim2.new(0.7, 0, 0, 0)
        btnDel.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        btnDel.Text = "DEL"
        btnDel.TextColor3 = Color3.new(1,1,1)
        btnDel.Font = Enum.Font.GothamBold
        btnDel.TextSize = 14
        btnDel.Parent = frame
        Instance.new("UICorner", btnDel).CornerRadius = UDim.new(0, 6)

        btnDel.MouseButton1Click:Connect(function()
            savedWaypoints[name] = nil
            if lastCreated == name then lastCreated = nil end
            refreshWaypoints()
            createNotification("Waypoint '"..name.."' eliminado")
        end)
    end
end

local wpBox = Instance.new("TextBox")
wpBox.Size = UDim2.new(1, 0, 0, 30)
wpBox.PlaceholderText = "Nombre del Waypoint"
wpBox.Text = ""
wpBox.Font = Enum.Font.Gotham
wpBox.TextSize = 16
wpBox.TextColor3 = Color3.new(1, 1, 1)
wpBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
wpBox.BackgroundTransparency = 0.1
wpBox.BorderSizePixel = 0
wpBox.ClearTextOnFocus = false
wpBox.Parent = WaypointsScroll
Instance.new("UICorner", wpBox).CornerRadius = UDim.new(0, 6)

createButton(WaypointsScroll, "Crear / Actualizar Waypoint", function()
    local hrp = getHRP()
    if hrp then
        local name = wpBox.Text ~= "" and wpBox.Text or ("WP"..tostring(#savedWaypoints+1))
        savedWaypoints[name] = hrp.Position
        lastCreated = name
        wpBox.Text = ""
        refreshWaypoints()
        createNotification("Waypoint '"..name.."' guardado/actualizado")
    end
end)

createButton(WaypointsScroll, "Renombrar último Waypoint", function()
    if lastCreated and savedWaypoints[lastCreated] then
        local newName = wpBox.Text
        if newName ~= "" then
            savedWaypoints[newName] = savedWaypoints[lastCreated]
            savedWaypoints[lastCreated] = nil
            lastCreated = newName
            wpBox.Text = ""
            refreshWaypoints()
            createNotification("Waypoint renombrado a '"..newName.."'")
        else
            createNotification("Escribe un nuevo nombre en la caja")
        end
    else
        createNotification("No hay waypoint reciente para renombrar")
    end
end)

local clearAllBtn = Instance.new("TextButton")
clearAllBtn.Size = UDim2.new(1, 0, 0, 30)
clearAllBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
clearAllBtn.Text = "Borrar TODOS los Waypoints"
clearAllBtn.TextColor3 = Color3.new(1,1,1)
clearAllBtn.Font = Enum.Font.GothamBold
clearAllBtn.TextSize = 14
clearAllBtn.Parent = WaypointsScroll
Instance.new("UICorner", clearAllBtn).CornerRadius = UDim.new(0, 6)

clearAllBtn.MouseButton1Click:Connect(function()
    savedWaypoints = {}
    lastCreated = nil
    refreshWaypoints()
    createNotification("Todos los waypoints borrados")
end)

refreshWaypoints()


----------------------------------------------------------
----------------------------------------------------------
-- Parte 7: Visual (actualizada)
----------------------------------------------------------
local VisualScroll = Scrolls["Visual"]

----------------------------------------------------------
-- ESP Jugadores
----------------------------------------------------------
createSectionLabel(VisualScroll, "ESP Jugadores")

local espPlayersEnabled = false
local espPlayerColor = Color3.fromRGB(120, 200, 255) -- azul clarito
local espPlayersConn = nil
local playerBillboards = {}

local function clearPlayerESP()
    for plr, bb in pairs(playerBillboards) do
        if bb then bb:Destroy() end
    end
    playerBillboards = {}
end

local function updatePlayerESP()
    clearPlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.Adornee = head
            bb.AlwaysOnTop = true
            bb.Parent = head

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = espPlayerColor
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.Parent = bb

            playerBillboards[plr] = bb
        end
    end
end

createButton(VisualScroll, "Toggle ESP Jugadores", function()
    espPlayersEnabled = not espPlayersEnabled
    if espPlayersEnabled then
        updatePlayerESP()
        espPlayersConn = Players.PlayerAdded:Connect(updatePlayerESP)
        Players.PlayerRemoving:Connect(updatePlayerESP)
        createNotification("ESP Jugadores ON")
    else
        if espPlayersConn then espPlayersConn:Disconnect() espPlayersConn = nil end
        clearPlayerESP()
        createNotification("ESP Jugadores OFF")
    end
end)

----------------------------------------------------------
-- FullBright
----------------------------------------------------------
createSectionLabel(VisualScroll, "FullBright")

local fullBrightEnabled = false
local oldLighting = {}

createButton(VisualScroll, "FullBright (toggle)", function()
    fullBrightEnabled = not fullBrightEnabled
    if fullBrightEnabled then
        -- Guardar valores actuales
        oldLighting.Ambient = Lighting.Ambient
        oldLighting.Brightness = Lighting.Brightness
        oldLighting.FogEnd = Lighting.FogEnd
        oldLighting.OutdoorAmbient = Lighting.OutdoorAmbient

        -- Aplicar FullBright
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Brightness = 5
        Lighting.FogEnd = 1e6
        createNotification("FullBright ON")
    else
        -- Restaurar
        if oldLighting.Ambient then
            Lighting.Ambient = oldLighting.Ambient
            Lighting.Brightness = oldLighting.Brightness
            Lighting.FogEnd = oldLighting.FogEnd
            Lighting.OutdoorAmbient = oldLighting.OutdoorAmbient
        end
        createNotification("FullBright OFF")
    end
end)

----------------------------------------------------------
-- ESP Ítems
----------------------------------------------------------
createSectionLabel(VisualScroll, "ESP Ítems")

local espItemsEnabled = false
local espItemNameFilter = "coin"
local espItemsConn = nil
local itemBillboards = {}

local itemNameBox = Instance.new("TextBox")
itemNameBox.Size = UDim2.new(1, 0, 0, 30)
itemNameBox.PlaceholderText = "Nombre ítem (ej: coin, gem)"
itemNameBox.Text = espItemNameFilter
itemNameBox.Font = Enum.Font.Gotham
itemNameBox.TextSize = 14
itemNameBox.TextColor3 = Color3.new(1,1,1)
itemNameBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
itemNameBox.BackgroundTransparency = 0.1
itemNameBox.BorderSizePixel = 0
itemNameBox.ClearTextOnFocus = false
itemNameBox.Parent = VisualScroll
Instance.new("UICorner", itemNameBox).CornerRadius = UDim.new(0, 6)

local function clearItemESP()
    for obj, bb in pairs(itemBillboards) do
        if bb then bb:Destroy() end
    end
    itemBillboards = {}
end

local function updateItemESP()
    clearItemESP()
    local hrp = getHRP()
    if not hrp then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(espItemNameFilter)) then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.Adornee = obj
            bb.AlwaysOnTop = true
            bb.Parent = obj

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = obj.Name
            label.TextColor3 = Color3.fromRGB(255, 220, 120)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.Parent = bb

            itemBillboards[obj] = bb
        end
    end
end

createButton(VisualScroll, "Toggle ESP Ítems", function()
    espItemsEnabled = not espItemsEnabled
    if espItemsEnabled then
        espItemNameFilter = itemNameBox.Text ~= "" and itemNameBox.Text or espItemNameFilter
        updateItemESP()
        espItemsConn = RunService.Heartbeat:Connect(updateItemESP)
        createNotification("ESP Ítems ON ("..espItemNameFilter..")")
    else
        if espItemsConn then espItemsConn:Disconnect() espItemsConn = nil end
        clearItemESP()
        createNotification("ESP Ítems OFF")
    end
end)





----------------------------------------------------------
-- Parte 8: Ajustes (opacidad con slider, drag, reset, etc.)
----------------------------------------------------------
local AjustesScroll = Scrolls["Ajustes"]

-- Apariencia
createSectionLabel(AjustesScroll, "Apariencia")

local opacityFrame = Instance.new("Frame")
opacityFrame.Size = UDim2.new(1, 0, 0, 40)
opacityFrame.BackgroundTransparency = 1
opacityFrame.Parent = AjustesScroll

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, -20, 0, 6)
sliderBar.Position = UDim2.new(0, 10, 0.5, -3)
sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = opacityFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.85, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 14, 0, 14)
sliderBtn.Position = UDim2.new(0.85, -7, 0.5, -7)
sliderBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
sliderBtn.Text = ""
sliderBtn.Parent = sliderBar
Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

local opacityValue = 0.85
local function setGlobalOpacity(alpha)
    alpha = math.clamp(alpha, 0.1, 1)
    opacityValue = alpha
    local function applyTransparency(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("TextLabel") then
            local bgTrans = 1 - alpha
            if bgTrans < 0.1 then bgTrans = 0.1 end
            obj.BackgroundTransparency = bgTrans
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local txtTrans = 1 - alpha
                if txtTrans < 0.2 then txtTrans = 0.2 end
                obj.TextTransparency = txtTrans
            end
        end
        for _, child in ipairs(obj:GetChildren()) do
            applyTransparency(child)
        end
    end
    applyTransparency(MainFrame)
    applyTransparency(ToggleButton)
end

local draggingSlider = false
sliderBtn.MouseButton1Down:Connect(function() draggingSlider = true end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0.1, 1)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        sliderBtn.Position = UDim2.new(relX, -7, 0.5, -7)
        setGlobalOpacity(relX)
    end
end)

-- Comportamiento
createSectionLabel(AjustesScroll, "Comportamiento")

createButton(AjustesScroll, "Toggle Drag HUB", function()
    _G.dragHubEnabled = not _G.dragHubEnabled
    DragLock.Text = _G.dragHubEnabled and "🔓" or "🔒"
    createNotification("Drag HUB: " .. (_G.dragHubEnabled and "ON" or "OFF"))
end)

-- Auto Collect (config de Auto Interact)
createSectionLabel(AjustesScroll, "Auto Interact – Filtro y Radio")
local nameFilterBox = Instance.new("TextBox")
nameFilterBox.Size = UDim2.new(1, 0, 0, 30)
nameFilterBox.PlaceholderText = "Filtro nombre (ej: coin, gem, star)"
nameFilterBox.Text = "coin"
nameFilterBox.Font = Enum.Font.Gotham
nameFilterBox.TextSize = 14
nameFilterBox.TextColor3 = Color3.new(1,1,1)
nameFilterBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
nameFilterBox.BackgroundTransparency = 0.1
nameFilterBox.BorderSizePixel = 0
nameFilterBox.ClearTextOnFocus = false
nameFilterBox.Parent = AjustesScroll
Instance.new("UICorner", nameFilterBox).CornerRadius = UDim.new(0, 6)

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.PlaceholderText = "Radio de recogida (ej: 50)"
radiusBox.Text = "50"
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 14
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusBox.BackgroundTransparency = 0.1
radiusBox.BorderSizePixel = 0
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = AjustesScroll
Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 6)

createButton(AjustesScroll, "Aplicar Auto Interact", function()
    local nf = nameFilterBox.Text ~= "" and string.lower(nameFilterBox.Text) or "coin"
    local r = tonumber(radiusBox.Text) or 50
    collectNameFilter = nf
    collectRadius = math.max(10, r)
    createNotification("Auto Interact: filtro '"..nf.."', radio "..tostring(collectRadius))
end)

-- Reset
createSectionLabel(AjustesScroll, "Reset")
createButton(AjustesScroll, "Restaurar Configuración", function()
    setGlobalOpacity(0.85)
    sliderFill.Size = UDim2.new(0.85, 0, 1, 0)
    sliderBtn.Position = UDim2.new(0.85, -7, 0.5, -7)
    _G.dragHubEnabled = true
    DragLock.Text = "🔓"
    collectNameFilter = "coin"
    collectRadius = 50
    nameFilterBox.Text = "coin"
    radiusBox.Text = "50"
    createNotification("Configuración restaurada")
end)



----------------------------------------------------------
-- Parte 9: Drag del HUB desde TopBar con candado
----------------------------------------------------------
local dragging, dragStart, startPos

DragLock.MouseButton1Click:Connect(function()
    _G.dragHubEnabled = not _G.dragHubEnabled
    DragLock.Text = _G.dragHubEnabled and "🔓" or "🔒"
    createNotification("Drag HUB: " .. (_G.dragHubEnabled and "ON" or "OFF"))
end)

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and _G.dragHubEnabled then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)



----------------------------------------------------------
-- Parte 10: Mini HUD de estado
----------------------------------------------------------
local StatusHud = Instance.new("Frame")
StatusHud.Size = UDim2.new(0, 140, 0, 50)
StatusHud.Position = UDim2.new(1, -160, 0, 20)
StatusHud.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
StatusHud.BackgroundTransparency = 0.2
StatusHud.BorderSizePixel = 0
StatusHud.Parent = ScreenGui
Instance.new("UICorner", StatusHud).CornerRadius = UDim.new(0, 8)

local hudLabel1 = Instance.new("TextLabel")
hudLabel1.Size = UDim2.new(1, -10, 0, 22)
hudLabel1.Position = UDim2.new(0, 5, 0, 4)
hudLabel1.BackgroundTransparency = 1
hudLabel1.Text = "AutoInteract: OFF"
hudLabel1.TextColor3 = Color3.new(1,1,1)
hudLabel1.Font = Enum.Font.Gotham
hudLabel1.TextSize = 14
hudLabel1.TextXAlignment = Enum.TextXAlignment.Left
hudLabel1.Parent = StatusHud

local hudLabel2 = Instance.new("TextLabel")
hudLabel2.Size = UDim2.new(1, -10, 0, 22)
hudLabel2.Position = UDim2.new(0, 5, 0, 26)
hudLabel2.BackgroundTransparency = 1
hudLabel2.Text = "Noclip: OFF"
hudLabel2.TextColor3 = Color3.new(1,1,1)
hudLabel2.Font = Enum.Font.Gotham
hudLabel2.TextSize = 14
hudLabel2.TextXAlignment = Enum.TextXAlignment.Left
hudLabel2.Parent = StatusHud

-- Hooks para actualizar HUD (llamar estos cuando cambian estados)
local function updateAutoInteractHUD(isOn)
    hudLabel1.Text = "AutoInteract: " .. (isOn and "ON" or "OFF")
    hudLabel1.TextColor3 = isOn and Color3.fromRGB(140,255,140) or Color3.new(1,1,1)
end
local function updateNoclipHUD(isOn)
    hudLabel2.Text = "Noclip: " .. (isOn and "ON" or "OFF")
    hudLabel2.TextColor3 = isOn and Color3.fromRGB(140,255,140) or Color3.new(1,1,1)
end

-- Parchar botones para que actualicen HUD
-- Auto Interact:
-- En Parte 4, después de togglear, añadimos:
-- updateAutoInteractHUD(autoInteractConn ~= nil)
-- Noclip:
-- updateNoclipHUD(_G.noclipEnabled)

-- Aplicar parches directamente:
do
    -- Re-bindeo simple: interceptar notificaciones y estados (no invasivo)
    local oldNotify = createNotification
    createNotification = function(msg)
        oldNotify(msg)
        if msg:find("Auto Interact ON") then updateAutoInteractHUD(true)
        elseif msg:find("Auto Interact OFF") then updateAutoInteractHUD(false)
        elseif msg:find("Noclip ON") then updateNoclipHUD(true)
        elseif msg:find("Noclip OFF") then updateNoclipHUD(false)
        end
    end
end



----------------------------------------------------------
-- Parte 11: Sistema de temas (Dark, Light, Neon)
----------------------------------------------------------
local Themes = {
    Dark = {
        main = Color3.fromRGB(20, 30, 46),
        top = Color3.fromRGB(25, 40, 70),
        accent = Color3.fromRGB(30, 50, 80),
        highlight = Color3.fromRGB(50, 90, 150)
    },
    Light = {
        main = Color3.fromRGB(230, 235, 245),
        top = Color3.fromRGB(210, 220, 240),
        accent = Color3.fromRGB(200, 210, 230),
        highlight = Color3.fromRGB(140, 170, 220)
    },
    Neon = {
        main = Color3.fromRGB(18, 20, 28),
        top = Color3.fromRGB(30, 30, 60),
        accent = Color3.fromRGB(40, 70, 120),
        highlight = Color3.fromRGB(0, 200, 255)
    }
}

local function applyTheme(t)
    MainFrame.BackgroundColor3 = t.main
    TopBar.BackgroundColor3 = t.top
    TabsBar.BackgroundColor3 = t.top
    -- Botones activos/hover usan highlight/accent
    for name, btn in pairs(TabButtons) do
        btn.BackgroundColor3 = t.accent
    end
    -- Reaplicar resaltado de tab activa
    local activeTab
    for name, frame in pairs(Tabs) do
        if frame.Visible then activeTab = name break end
    end
    if activeTab and TabButtons[activeTab] then
        TabButtons[activeTab].BackgroundColor3 = t.highlight
    end
    createNotification("Tema aplicado")
end

-- Agregar selector de temas en Ajustes
createSectionLabel(AjustesScroll, "Tema")
createButton(AjustesScroll, "Tema Dark", function() applyTheme(Themes.Dark) end)
createButton(AjustesScroll, "Tema Light", function() applyTheme(Themes.Light) end)
createButton(AjustesScroll, "Tema Neon", function() applyTheme(Themes.Neon) end)


----------------------------------------------------------
-- Parte 12: QoL, arranque y limpieza
----------------------------------------------------------

-- Abrir HUB al iniciar y pestaña principal
openHub()
switchTab("Main")

-- Actualizar icono de candado inicial
DragLock.Text = _G.dragHubEnabled and "🔓" or "🔒"

-- Reset de estados al respawnear (opcional)
LocalPlayer.CharacterAdded:Connect(function()
    -- Estados que preferimos resetear por seguridad visual
    -- No apagamos manualmente Auto Interact; permanece como estaba
    -- Visuales (Chams/Drawing) se limpian por si el juego respawnea distinto
    -- Nota: Si quieres hard reset, invoca el botón "Reset Visual" automáticamente.
    createNotification("Personaje respawneado")
end)

print("[KS HUB] Inicializado: UI profesional, sidebar, MAIN fusionado, Waypoints, Visuales (ESP), Ajustes con slider, drag lock, HUD, temas.")
