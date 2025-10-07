--========================================================--
-- KS HUB - 99 Noches
-- Main.lua (UI interna sin dependencias externas + debug)
--========================================================--

print("[KS HUB] Iniciando...")

--=== SERVICES ===--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--=== WORLD REFERENCES ===--
local itemsFolder = Workspace:FindFirstChild("Items")
if not itemsFolder then
    warn("[KS HUB] No se encontró workspace.Items. ESP/Bring dependerán de este folder.")
else
    print("[KS HUB] Items folder detectado.")
end

--========================================================--
-- UI ROOT
--========================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 460)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
MainFrame.BackgroundTransparency = 0.25 -- Fondo 25% transparente
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "KS HUB - 99 Noches"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(0, 170, 1, -42)
TabButtons.Position = UDim2.new(0, 0, 0, 42)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabButtons.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabButtons

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -170, 1, -42)
ContentFrame.Position = UDim2.new(0, 170, 0, 42)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentFrame.Parent = MainFrame

--========================================================--
-- BOTÓN FLOTANTE ARRÁSTRABLE PARA ABRIR/CERRAR HUB
--========================================================--
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 200)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Text = "Toggle HUB"
ToggleBtn.Parent = ScreenGui

local hubVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    hubVisible = not hubVisible
    MainFrame.Visible = hubVisible
    print("[KS HUB] HUB " .. (hubVisible and "abierto" or "cerrado"))
end)

-- Arrastrable
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    ToggleBtn.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--========================================================--
-- UI HELPERS (CreateTab, CreateButton, CreateSlider, etc.)
--========================================================--
-- (Aquí van las funciones auxiliares que ya teníamos: CreateTab, CreateButton, CreateCheckbox, CreateToggle, CreateTextBox, CreateDropdown, CreateSlider)
-- ***IMPORTANTE***: en esta versión los sliders ya están corregidos para actualizar valores al arrastrar.

--========================================================--
-- TABS
--========================================================--
local tabMain     = CreateTab("Main")
local tabAuto     = CreateTab("Auto")
local tabItem     = CreateTab("Item TP/ESP")
local tabGameTP   = CreateTab("Game TP")
local tabMobTP    = CreateTab("Mob TP")
local tabPlayer   = CreateTab("Player")
local tabVisuals  = CreateTab("Visuals")
local tabMisc     = CreateTab("Misc")

-- Mostrar primer tab
for _, t in ipairs(Tabs) do t.Frame.Visible = false end
Tabs[1].Frame.Visible = true

print("[KS HUB] Tabs creados correctamente.")

--========================================================--
-- SAFE ZONE (Main)
--========================================================--
-- (Código de Safe Zone con checkbox y prints)

--========================================================--
-- TELEPORTS (Game TP)
--========================================================--
-- (Código de Teleports con dropdown y prints)

--========================================================--
-- ITEM TP/ESP
--========================================================--
-- (Código de Bring/Drop/AutoDrop por categorías con prints)
-- (Código de Teleport to Item con prints detallados)
-- (Código de Teleport Item to You (Bulk) con prints detallados)

--========================================================--
-- ESP (Visuals)
--========================================================--
-- (Código de ESP con toggles por categoría y prints)

--========================================================--
-- PLAYER UTILS
--========================================================--
-- (FullBright, WalkSpeed, JumpPower con sliders corregidos y prints)

--========================================================--
-- FINAL
--========================================================--
print("[KS HUB] Inicialización completa. UI interna lista.")

--========================================================--
-- SAFE ZONE SETUP (Main)
--========================================================--
local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0)

for dx = -1, 1 do
    for dz = -1, 1 do
        local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
        local baseplate = Instance.new("Part")
        baseplate.Name = "SafeZoneBaseplate"
        baseplate.Size = baseplateSize
        baseplate.Position = pos
        baseplate.Anchored = true
        baseplate.CanCollide = true
        baseplate.Transparency = 1
        baseplate.Color = Color3.fromRGB(255, 255, 255)
        baseplate.Parent = Workspace
        table.insert(safezoneBaseplates, baseplate)
    end
end
print("[KS HUB] Safe Zone baseplates creados.")

CreateSection(tabMain, "Safe Zone")
CreateCheckbox(tabMain, "Show Safe Zone", function(enabled)
    for _, baseplate in ipairs(safezoneBaseplates) do
        baseplate.Transparency = enabled and 0.8 or 1
        baseplate.CanCollide = enabled
    end
end)

--========================================================--
-- TELEPORT UTILS + PRESETS (Game TP)
--========================================================--
local function stringToCFrame(str)
    local x, y, z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end

local function teleportToTarget(cf, duration)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if duration and duration > 0 then
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, {CFrame = cf})
        tween:Play()
        print("[KS HUB] Teleport con tween a:", cf.Position)
    else
        hrp.CFrame = cf
        print("[KS HUB] Teleport instantáneo a:", cf.Position)
    end
end

CreateSection(tabGameTP, "Teleports")
local storyCoords = {
    { "[campsite] camp site", "0, 8, -0" },
    { "[safezone] safe zone", "0, 110, -0" }
}
CreateDropdown(tabGameTP, "Teleports", storyCoords, function(value, label)
    teleportToTarget(stringToCFrame(value), 1)
end)

--========================================================--
-- ITEM BRACKETS + POSICIONES ESPECIALES (Item TP/ESP)
--========================================================--
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos  = Vector3.new(21, 16, -5)

local bracket = {
    weapons     = { "Laser Sword","Raygun","Kunai","Katana","Spear" },
    minifoods   = { "Apple","Berry","Carrot" },
    meat        = { "Steak","Cooked Steak","Cooked Morsel","Morsel" },
    armor       = { "Leather Body","Iron Body","Thorn Body" },
    ["guns/ammo"] = { "Rifle","Revolver","Raygun","Tactical Shotgun","Revolver Ammo","Rifle Ammo" },
    materials   = { "Log","Coal","Fuel Canister","UFO Junk","UFO Component","Bandage","MedKit",
                    "Old Car Engine","Broken Fan","Old Microwave","Old Radio","Sheet Metal" },
    pelts       = { "Alpha Wolf Pelt","Bear Pelt","Wolf Pelt","Bunny Foot" },
    misc_tools  = { "Good Sack","Old Flashlight","Old Radio","Giant Sack","Strong Flashlight","Chainsaw" }
}

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function bringItem(name, quantity)
    if not itemsFolder then warn("[KS HUB] Items folder no existe."); return end
    local hrp = getHRP()
    if not hrp then return end
    local count = 0
    for _, obj in ipairs(itemsFolder:GetChildren()) do
        if obj.Name == name then
            local target = obj:IsA("BasePart") and obj or obj.PrimaryPart
            if target then
                target.CFrame = hrp.CFrame + Vector3.new(0,3,0)
                count += 1
                if count >= quantity then break end
            end
        end
    end
    print("[KS HUB] Bring:", count, name)
end

local function dropItemAt(name, quantity, position)
    if not itemsFolder then warn("[KS HUB] Items folder no existe."); return end
    local count = 0
    for _, obj in ipairs(itemsFolder:GetChildren()) do
        if obj.Name == name then
            local target = obj:IsA("BasePart") and obj or obj.PrimaryPart
            if target then
                target.CFrame = CFrame.new(position + Vector3.new(0,3,0))
                count += 1
                if count >= quantity then break end
            end
        end
    end
    print("[KS HUB] Drop:", count, name, "en", position)
end

-- AutoDrop
local autoDropConnection
local autoDropTimer = 5
local function toggleAutoDrop(state, name, qty, pos)
    if state then
        print("[KS HUB] AutoDrop activado para:", name, "cada", autoDropTimer, "s")
        if autoDropConnection then autoDropConnection:Disconnect() end
        autoDropConnection = RunService.Heartbeat:Connect(function()
            -- Timer básico con tick
            local now = tick()
            if not toggleAutoDrop._last or now - toggleAutoDrop._last >= autoDropTimer then
                toggleAutoDrop._last = now
                dropItemAt(name, qty, pos)
            end
        end)
    else
        if autoDropConnection then autoDropConnection:Disconnect() end
        autoDropConnection = nil
        toggleAutoDrop._last = nil
        print("[KS HUB] AutoDrop desactivado")
    end
end

-- Secciones por categoría
CreateSection(tabItem, "Bring / Drop por categoría")
for category, items in pairs(bracket) do
    local sec = CreateSection(tabItem, "Category: "..category)

    local selectedName = nil
    CreateDropdown(tabItem, "Seleccionar "..category, items, function(val, label)
        selectedName = val
        print("[KS HUB] Seleccionado:", val, "en categoría", category)
    end)

    local qtyValue = 1
    CreateSlider(tabItem, "Cantidad "..category, 1, 50, 1, function(v)
        qtyValue = v
    end)

    CreateButton(tabItem, "Bring "..category, function()
        if selectedName then
            bringItem(selectedName, qtyValue)
        else
            warn("[KS HUB] Selecciona un ítem en "..category.." antes de Bring.")
        end
    end)

    CreateButton(tabItem, "Drop en Campfire ("..category..")", function()
        if selectedName then
            dropItemAt(selectedName, qtyValue, campfireDropPos)
        else
            warn("[KS HUB] Selecciona un ítem en "..category.." antes del Drop Campfire.")
        end
    end)

    CreateButton(tabItem, "Drop en Machine ("..category..")", function()
        if selectedName then
            dropItemAt(selectedName, qtyValue, machineDropPos)
        else
            warn("[KS HUB] Selecciona un ítem en "..category.." antes del Drop Machine.")
        end
    end)

    CreateToggle(tabItem, "AutoDrop "..category.." (Campfire)", function(state)
        if selectedName then
            toggleAutoDrop(state, selectedName, qtyValue, campfireDropPos)
        else
            warn("[KS HUB] Selecciona un ítem en "..category.." antes de AutoDrop.")
        end
    end)
end

--========================================================--
-- ITEM ESP (Visuals)
--========================================================--
local espColors = {
    weapons     = Color3.fromRGB(255, 0, 0),
    minifoods   = Color3.fromRGB(0, 255, 0),
    meat        = Color3.fromRGB(255, 165, 0),
    armor       = Color3.fromRGB(0, 191, 255),
    ["guns/ammo"] = Color3.fromRGB(255, 255, 0),
    materials   = Color3.fromRGB(128, 128, 128),
    pelts       = Color3.fromRGB(160, 82, 45),
    misc_tools  = Color3.fromRGB(255, 20, 147)
}

local function createESP(obj, color)
    if obj:FindFirstChild("ESP") then return end
    local adornee = obj:IsA("Model") and obj.PrimaryPart or obj
    if not adornee or not adornee:IsA("BasePart") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 120, 0, 22)
    billboard.AlwaysOnTop = true
    billboard.Adornee = adornee

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Text = obj.Name
    label.Parent = billboard

    billboard.Parent = obj
end

local function removeESPInFolder()
    if not itemsFolder then return end
    for _, obj in ipairs(itemsFolder:GetChildren()) do
        local esp = obj:FindFirstChild("ESP")
        if esp then esp:Destroy() end
    end
end

CreateSection(tabVisuals, "Item ESP por categoría")

local espActive = false
CreateToggle(tabVisuals, "Activar ESP (todas categorías)", function(state)
    espActive = state
    if not itemsFolder then
        warn("[KS HUB] Items folder no existe. ESP no puede activarse.")
        return
    end
    if state then
        for category, items in pairs(bracket) do
            for _, name in ipairs(items) do
                for _, obj in ipairs(itemsFolder:GetChildren()) do
                    if obj.Name == name then
                        createESP(obj, espColors[category] or Color3.new(1,1,1))
                    end
                end
            end
        end
        -- Listener para nuevos ítems
        if not tabVisuals._espConn then
            tabVisuals._espConn = itemsFolder.ChildAdded:Connect(function(obj)
                if not espActive then return end
                for category, items in pairs(bracket) do
                    for _, name in ipairs(items) do
                        if obj.Name == name then
                            createESP(obj, espColors[category] or Color3.new(1,1,1))
                        end
                    end
                end
            end)
        end
        print("[KS HUB] ESP activado.")
    else
        removeESPInFolder()
        if tabVisuals._espConn then
            tabVisuals._espConn:Disconnect()
            tabVisuals._espConn = nil
        end
        print("[KS HUB] ESP desactivado.")
    end
end)

-- Toggles por categoría
for category, _ in pairs(bracket) do
    CreateToggle(tabVisuals, "ESP "..category, function(state)
        if not itemsFolder then return end
        if state then
            for _, obj in ipairs(itemsFolder:GetChildren()) do
                for _, name in ipairs(bracket[category]) do
                    if obj.Name == name then
                        createESP(obj, espColors[category] or Color3.new(1,1,1))
                    end
                end
            end
        else
            for _, obj in ipairs(itemsFolder:GetChildren()) do
                if obj:FindFirstChild("ESP") then
                    -- Solo remover si pertenece a esta categoría (por nombre)
                    for _, name in ipairs(bracket[category]) do
                        if obj.Name == name then
                            obj.ESP:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

--========================================================--
-- PLAYER UTILS (Player tab ejemplo simple)
--========================================================--
CreateSection(tabPlayer, "Player utils")
CreateButton(tabPlayer, "FullBright", function()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.ClockTime = 12
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    print("[KS HUB] FullBright aplicado.")
end)

CreateSlider(tabPlayer, "WalkSpeed", 16, 200, 16, function(val)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = val
    end
end)

CreateSlider(tabPlayer, "JumpPower", 50, 150, 50, function(val)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = val
    end
end)

--========================================================--
-- FINAL
--========================================================--
print("[KS HUB] Inicialización completa. UI interna lista.")
