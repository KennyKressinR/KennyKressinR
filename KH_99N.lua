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

-- Botón flotante para abrir/cerrar HUB
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

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 42)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "KS HUB - 99 Noches"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
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
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -170, 1, -42)
ContentFrame.Position = UDim2.new(0, 170, 0, 42)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentFrame.Parent = MainFrame

--========================================================--
-- UI HELPERS
--========================================================--
local Tabs = {}

local function CreateTab(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -12, 0, 32)
    Button.Position = UDim2.new(0, 6, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.AutoButtonColor = true
    Button.Parent = TabButtons

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "Tab_"..name
    TabContainer.Size = UDim2.new(1, -20, 1, -20)
    TabContainer.Position = UDim2.new(0, 10, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 6
    TabContainer.Visible = false
    TabContainer.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = TabContainer

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    Button.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do
            t.Frame.Visible = false
        end
        TabContainer.Visible = true
        print("[KS HUB] Tab abierto:", name)
    end)

    table.insert(Tabs, {Button = Button, Frame = TabContainer})
    return TabContainer
end

local function CreateSection(parent, titleText)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -20, 0, 40)
    Section.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Section.BorderSizePixel = 0
    Section.Parent = parent

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -12, 1, 0)
    Title.Position = UDim2.new(0, 6, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = titleText
    Title.Parent = Section

    return Section
end

local function CreateButton(parent, text, onClick)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 16
    Btn.Text = text
    Btn.AutoButtonColor = true
    Btn.Parent = parent
    Btn.MouseButton1Click:Connect(function()
        print("[KS HUB] Click botón:", text)
        local ok, err = pcall(onClick)
        if not ok then
            warn("[KS HUB] Error en botón '"..text.."':", err)
        end
    end)
    return Btn
end

local function CreateCheckbox(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 16
    Btn.Text = "[ ] " .. text
    Btn.Parent = parent

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.Text = (enabled and "[X] " or "[ ] ") .. text
        print("[KS HUB] Checkbox '"..text.."' =", enabled)
        local ok, err = pcall(function() callback(enabled) end)
        if not ok then warn("[KS HUB] Error en checkbox '"..text.."':", err) end
    end)

    return Btn
end

local function CreateToggle(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 16
    Btn.Text = text .. " [OFF]"
    Btn.Parent = parent

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text .. (state and " [ON]" or " [OFF]")
        print("[KS HUB] Toggle '"..text.."' =", state)
        local ok, err = pcall(function() callback(state) end)
        if not ok then warn("[KS HUB] Error en toggle '"..text.."':", err) end
    end)

    return Btn
end

local function CreateTextBox(parent, labelText, defaultText, onSubmit)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 340, 0, 30)
    Container.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 160, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = labelText
    Label.Parent = Container

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -170, 1, 0)
    Box.Position = UDim2.new(0, 170, 0, 0)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 16
    Box.Text = defaultText or ""
    Box.ClearTextOnFocus = false
    Box.Parent = Container

    Box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            print("[KS HUB] TextBox '"..labelText.."' submit:", Box.Text)
            local ok, err = pcall(function() onSubmit(Box.Text) end)
            if not ok then warn("[KS HUB] Error TextBox '"..labelText.."':", err) end
        end
    end)

    return Container, Box
end

local function CreateDropdown(parent, labelText, options, onChoose)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 260, 0, 30 + (#options * 28))
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 16
    Label.Text = labelText
    Label.Parent = Frame

    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.Position = UDim2.new(0, 0, 0, 30 + (i - 1) * 28)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Text = type(opt) == "table" and opt[1] or tostring(opt)
        btn.Parent = Frame

        btn.MouseButton1Click:Connect(function()
            local value = type(opt) == "table" and (opt[2] or opt[1]) or opt
            print("[KS HUB] Dropdown '"..labelText.."' elegido:", btn.Text)
            local ok, err = pcall(function() onChoose(value, btn.Text) end)
            if not ok then warn("[KS HUB] Error dropdown '"..labelText.."':", err) end
        end)
    end

    return Frame
end

local function CreateSlider(parent, labelText, minValue, maxValue, defaultValue, onChange)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 360, 0, 48)
    Container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = labelText .. " ("..tostring(defaultValue)..")"
    Label.Parent = Container

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 8)
    Bar.Position = UDim2.new(0, 10, 0, 28)
    Bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Bar.BorderSizePixel = 0
    Bar.Parent = Container

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(120, 200, 120)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(minValue + rel * (maxValue - minValue))
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            Label.Text = labelText .. " ("..tostring(value)..")"
            local ok, err = pcall(function() onChange(value) end)
            if not ok then warn("[KS HUB] Error slider '"..labelText.."':", err) end
        end
    end)

    return Container
end

--========================================================--
-- CREATE TABS
--========================================================--
local tabMain     = CreateTab("Main")
local tabAuto     = CreateTab("Auto")
local tabItem     = CreateTab("Item TP/ESP")
local tabGameTP   = CreateTab("Game TP")
local tabMobTP    = CreateTab("Mob TP")
local tabPlayer   = CreateTab("Player")
local tabVisuals  = CreateTab("Visuals")
local tabMisc     = CreateTab("Misc")

-- Mostrar el primer tab por defecto
for _, t in ipairs(Tabs) do t.Frame.Visible = false end
Tabs[1].Frame.Visible = true

print("[KS HUB] Tabs creados correctamente.")

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
