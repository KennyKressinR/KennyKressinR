--========================================================--
-- PARTE 1: BASE Y SERVICIOS
--========================================================--

-- Servicios principales de Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--========================================================--
-- PARTE 1B: VARIABLES GLOBALES
--========================================================--

-- Carpeta de Items en el Workspace (ajustable según el juego)
local itemsFolder =
    Workspace:FindFirstChild("Items")
    or Workspace:FindFirstChild("WorldItems")
    or Workspace:FindFirstChild("Drops")
    or Workspace:FindFirstChild("ItemsFolder")

if not itemsFolder then
    warn("[KS HUB] itemsFolder no encontrado. Ajusta el nombre según el juego.")
end

--========================================================--
-- PARTE 1C: HELPERS DE UI
--========================================================--

-- Aquí van todas las funciones de creación de UI (CreateTab, CreateSection, etc.)
-- IMPORTANTE: Estas funciones deben estar definidas ANTES de usarlas en otras partes.

function CreateSection(parent, text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 24)
    Section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Section.TextColor3 = Color3.fromRGB(255, 255, 255)
    Section.Font = Enum.Font.SourceSansBold
    Section.TextSize = 14
    Section.Text = text
    Section.Parent = parent
    return Section
end

function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 200, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Text = text
    Btn.Parent = parent

    Btn.MouseButton1Click:Connect(function()
        local ok, err = pcall(function() callback() end)
        if not ok then warn("[KS HUB] Error en botón '"..text.."':", err) end
    end)

    return Btn
end

-- (Aquí irían CreateToggle, CreateSlider, CreateDropdown, etc. — ya los tienes definidos)

--========================================================--
-- PARTE 1D: HELPER MULTISELECT
--========================================================--

-- NUEVO: Lista multi‑select con highlight y contador
function CreateMultiSelectList(parent, titleText, options, onSelectionChanged)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 180)
    Frame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = "  " .. titleText
    Title.Parent = Frame

    local Count = Instance.new("TextLabel")
    Count.Size = UDim2.new(0, 60, 0, 24)
    Count.Position = UDim2.new(1, -64, 0, 0)
    Count.BackgroundTransparency = 1
    Count.TextColor3 = Color3.fromRGB(200, 200, 200)
    Count.Font = Enum.Font.SourceSans
    Count.TextSize = 14
    Count.Text = "0 sel."
    Count.Parent = Frame

    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(1, -10, 1, -34)
    List.Position = UDim2.new(0, 5, 0, 30)
    List.BackgroundTransparency = 1
    List.BorderSizePixel = 0
    List.ScrollBarThickness = 6
    List.Active = true
    List.Parent = Frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = List
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        List.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    local selected = {}

    local function updateCountAndCallback()
        local c = 0
        for name, s in pairs(selected) do if s then c += 1 end end
        Count.Text = tostring(c) .. " sel."
        if onSelectionChanged then
            local list = {}
            for name, s in pairs(selected) do if s then table.insert(list, name) end end
            local ok, err = pcall(function() onSelectionChanged(list) end)
            if not ok then warn("[KS HUB] MultiSelect callback error:", err) end
        end
    end

    for _, name in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = "  " .. name
        btn.Parent = List

        btn.MouseButton1Click:Connect(function()
            selected[name] = not selected[name]
            btn.BackgroundColor3 = selected[name] and Color3.fromRGB(90, 140, 90) or Color3.fromRGB(64, 64, 64)
            updateCountAndCallback()
        end)
    end

    local api = {}
    function api:GetSelected()
        local out = {}
        for name, s in pairs(selected) do if s then table.insert(out, name) end end
        return out
    end
    function api:ClearSelection()
        for _, child in ipairs(List:GetChildren()) do
            if child:IsA("TextButton") then
                local name = child.Text:sub(3)
                if selected[name] then
                    selected[name] = false
                    child.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
                end
            end
        end
        updateCountAndCallback()
    end

    return Frame, api
end
--========================================================--
-- PARTE 2: CREACIÓN DE PESTAÑAS DEL HUB
--========================================================--

-- Aquí asumimos que ya tienes creado el "Window" o "Library" de tu UI en la Parte 1.
-- Ejemplo: local Window = Library:CreateWindow("KS HUB")

--========================================================--
-- PESTAÑA PRINCIPAL (Main)
--========================================================--
local tabMain = Window:CreateTab("Main")
-- Aquí irán funciones generales como Chop Aura, Safe Zone, etc.

--========================================================--
-- PESTAÑA DE ITEMS (Item TP/ESP)
--========================================================--
local tabItem = Window:CreateTab("Item TP/ESP")
-- Aquí irán Bring, Drop, AutoDrop, AutoCook, AutoFuel, etc.

--========================================================--
-- PESTAÑA DE ESP (Visualización de objetos/jugadores)
--========================================================--
local tabESP = Window:CreateTab("ESP")
-- Aquí irán toggles y sliders para mostrar objetos, jugadores, mobs, etc.

--========================================================--
-- PESTAÑA DE TELEPORTS (Game TP)
--========================================================--
local tabGameTP = Window:CreateTab("Game TP")
-- Aquí irán los teleports predefinidos (campfire, safezone, machine, etc.)

--========================================================--
-- PESTAÑA DE AUTOMATIZACIÓN (Auto)
--========================================================--
local tabAuto = Window:CreateTab("Auto")
-- Aquí irán AutoCook, AutoFuel y cualquier otra automatización futura.

--========================================================--
-- PESTAÑA DE JUGADOR (Player Utils)
--========================================================--
local tabPlayer = Window:CreateTab("Player")
-- Aquí irán sliders de WalkSpeed, JumpPower, FullBright, etc.

--========================================================--
-- PARTE 3: FUNCIONES GENERALES
--========================================================--

--========================================================--
-- 3A: Obtener HumanoidRootPart del jugador
--========================================================--
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

--========================================================--
-- 3B: Detección de herramientas (para Chop Aura, combate, etc.)
--========================================================--

-- Devuelve cualquier herramienta con un atributo "damageId"
local function getAnyToolWithDamageID()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("damageId") then
            return tool, tool.damageId.Value
        end
    end
    return nil
end

-- Devuelve un hacha (para Chop Aura)
local function getAxeTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("axe") then
            return tool
        end
    end
    return nil
end

--========================================================--
-- 3C: Equipar y desequipar herramientas
--========================================================--

local function equipTool(tool)
    if not tool then return end
    local char = LocalPlayer.Character
    if char and not tool.Parent:IsDescendantOf(char) then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
        print("[KS HUB] Equipado:", tool.Name)
    end
end

local function unequipTool(tool)
    if not tool then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        tool.Parent = backpack
        print("[KS HUB] Desequipado:", tool.Name)
    end
end

--========================================================--
-- 3D: Funciones de utilidad varias
--========================================================--

-- Teletransportar al HRP a una posición (instantáneo)
local function teleportInstant(cf)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = cf
        print("[KS HUB] Teleport instantáneo a:", cf.Position)
    end
end

-- Teletransportar con tween (animado)
local function teleportTween(cf, duration)
    local hrp = getHRP()
    if hrp then
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, {CFrame = cf})
        tween:Play()
        print("[KS HUB] Teleport con tween a:", cf.Position)
    end
end
--========================================================--
-- PARTE 4: ITEM TP/ESP
--========================================================--

-- Posiciones de referencia para Drop
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos  = Vector3.new(21, 16, -5)

--========================================================--
-- 4A: Tabla de categorías de ítems
--========================================================--
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

--========================================================--
-- 4B: Funciones base de manipulación de ítems
--========================================================--

-- Bring: teletransporta ítems al HRP
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

-- Drop: teletransporta ítems a una posición
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

-- AutoDrop simple (para un ítem específico)
local autoDropTimer = 5
local function toggleAutoDrop(state, name, qty, pos)
    if state then
        print("[KS HUB] AutoDrop activado:", name)
        if toggleAutoDrop._conn then toggleAutoDrop._conn:Disconnect() end
        toggleAutoDrop._conn = RunService.Heartbeat:Connect(function()
            local now = tick()
            if not toggleAutoDrop._last or now - toggleAutoDrop._last >= autoDropTimer then
                toggleAutoDrop._last = now
                dropItemAt(name, qty, pos)
            end
        end)
    else
        if toggleAutoDrop._conn then toggleAutoDrop._conn:Disconnect() end
        toggleAutoDrop._conn = nil
        toggleAutoDrop._last = nil
        print("[KS HUB] AutoDrop desactivado")
    end
end

--========================================================--
-- 4C: Interfaz por categoría con MultiSelect
--========================================================--

CreateSection(tabItem, "Bring / Drop por categoría (multi-select)")

-- Conexiones de AutoDrop por categoría
local autoDropConns = {}

for category, items in pairs(bracket) do
    -- Sub‑sección por categoría
    CreateSection(tabItem, "Categoría: " .. category)

    -- Lista multi‑select
    local listFrame, listAPI = CreateMultiSelectList(tabItem, "Selecciona ítems de " .. category, items, function(selectedNames)
        print("[KS HUB] Selección ("..category.."):", table.concat(selectedNames, ", "))
    end)

    -- Slider de cantidad
    local qtyValue = 1
    CreateSlider(tabItem, "Cantidad ("..category..")", 1, 50, 1, function(v)
        qtyValue = v
    end)

    -- Botón Bring
    CreateButton(tabItem, "Bring seleccionados ("..category..")", function()
        for _, name in ipairs(listAPI:GetSelected()) do
            bringItem(name, qtyValue)
        end
    end)

    -- Botón Drop Campfire
    CreateButton(tabItem, "Drop Campfire ("..category..")", function()
        for _, name in ipairs(listAPI:GetSelected()) do
            dropItemAt(name, qtyValue, campfireDropPos)
        end
    end)

    -- Botón Drop Machine
    CreateButton(tabItem, "Drop Machine ("..category..")", function()
        for _, name in ipairs(listAPI:GetSelected()) do
            dropItemAt(name, qtyValue, machineDropPos)
        end
    end)

    -- Toggle AutoDrop
    CreateToggle(tabItem, "AutoDrop ("..category..")", function(state)
        autoDropConns[category] = autoDropConns[category] or {}
        if state then
            for _, name in ipairs(listAPI:GetSelected()) do
                if autoDropConns[category][name] then
                    autoDropConns[category][name]:Disconnect()
                end
                autoDropConns[category][name] = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if not toggleAutoDrop._last or now - toggleAutoDrop._last >= autoDropTimer then
                        toggleAutoDrop._last = now
                        dropItemAt(name, qtyValue, campfireDropPos)
                    end
                end)
            end
        else
            for _, conn in pairs(autoDropConns[category]) do
                conn:Disconnect()
            end
            autoDropConns[category] = {}
        end
    end)

    -- Botón limpiar selección
    CreateButton(tabItem, "Limpiar selección ("..category..")", function()
        listAPI:ClearSelection()
    end)
end

print("[KS HUB] Item TP/ESP (Bring/Drop/AutoDrop) cargado")
--========================================================--
-- PARTE 5: FARMING (Chop Aura)
--========================================================--

-- Variables de control
local chopAuraToggle = false
local chopRadius = 150

-- Bucle principal de Chop Aura
local function chopAuraLoop()
    while chopAuraToggle do
        local axe = getAxeTool()
        if axe then
            equipTool(axe)
            -- Buscar árboles dentro del radio
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():find("tree") then
                    local primary = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                    if primary and (primary.Position - getHRP().Position).Magnitude <= chopRadius then
                        -- Intentar talar
                        local ok, err = pcall(function()
                            axe:Activate()
                        end)
                        if not ok then
                            warn("[KS HUB] Error talando árbol:", err)
                        end
                    end
                end
            end
            task.wait(0.3)
        else
            warn("[KS HUB] No se encontró hacha para Chop Aura")
            task.wait(1)
        end
    end
end

-- UI para Chop Aura
CreateSection(tabMain, "Farming")
CreateCheckbox(tabMain, "Chop Aura", function(state)
    chopAuraToggle = state
    if state then
        print("[KS HUB] Chop Aura activado")
        task.spawn(chopAuraLoop)
    else
        print("[KS HUB] Chop Aura desactivado")
        local tool,_ = getAnyToolWithDamageID()
        unequipTool(tool)
    end
end)

CreateSlider(tabMain, "Chop Aura Radius", 20, 300, 150, function(value)
    chopRadius = math.clamp(value, 20, 300)
    print("[KS HUB] Radio Chop Aura:", chopRadius)
end)

--========================================================--
-- PARTE 5B: SAFE ZONE
--========================================================--

local safezoneBaseplates = {}
local baseplateSize = Vector3.new(1024, 1, 1024)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0)

-- Crear baseplates invisibles que forman la zona segura
for dx = -1,1 do
    for dz = -1,1 do
        local pos = centerPos + Vector3.new(dx*baseplateSize.X,0,dz*baseplateSize.Z)
        local baseplate = Instance.new("Part")
        baseplate.Name = "SafeZoneBaseplate"
        baseplate.Size = baseplateSize
        baseplate.Position = pos
        baseplate.Anchored = true
        baseplate.CanCollide = true
        baseplate.Transparency = 1
        baseplate.Color = Color3.fromRGB(255,255,255)
        baseplate.Parent = Workspace
        table.insert(safezoneBaseplates, baseplate)
    end
end
print("[KS HUB] Safe Zone baseplates creados")

-- UI para Safe Zone
CreateSection(tabMain, "Safe Zone")
CreateCheckbox(tabMain, "Show Safe Zone", function(enabled)
    for _,bp in ipairs(safezoneBaseplates) do
        bp.Transparency = enabled and 0.8 or 1
        bp.CanCollide = enabled
    end
    print("[KS HUB] Safe Zone toggled:", enabled)
end)
--========================================================--
-- PARTE 6: TELEPORTS (Game TP)
--========================================================--

-- Convierte un string "x, y, z" a un CFrame
local function stringToCFrame(str)
    local x, y, z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end

-- Teleport principal con opción de tween
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

--========================================================--
-- 6A: Sección de Teleports en el tab GameTP
--========================================================--

CreateSection(tabGameTP, "Teleports")

-- Lista de coordenadas predefinidas
local storyCoords = {
    { "[campsite] Camp Site", "0, 8, -0" },
    { "[safezone] Safe Zone", "0, 110, -0" },
    { "[machine] Crafting Machine", "21, 16, -5" },
    { "[campfire] Fogata Central", "0, 19, 0" },
    { "[tree zone] Bosque", "-60, 8, 0" },
    { "[ufo zone] Zona Alien", "120, 8, 0" }
}

-- Dropdown para seleccionar teleport
CreateDropdown(tabGameTP, "Teleports", storyCoords, function(value, label)
    teleportToTarget(stringToCFrame(value), 1)
end)
--========================================================--
-- PARTE 7: AUTOMATIZACIÓN (AutoCook + AutoFuel)
--========================================================--

--========================================================--
-- 7A: AutoCook
--========================================================--

-- Lista de carnes crudas que se deben cocinar
local rawMeats = { "Morsel", "Steak" }

local autoCookToggle = false

local function autoCookLoop()
    while autoCookToggle do
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                for _, meat in ipairs(rawMeats) do
                    if tool.Name == meat then
                        -- Drop automático sobre la fogata
                        dropItemAt(meat, 1, campfireDropPos)
                        print("[KS HUB] AutoCook: soltando", meat, "en fogata")
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(2)
    end
end

CreateSection(tabAuto, "AutoCook")
CreateCheckbox(tabAuto, "Activar AutoCook", function(state)
    autoCookToggle = state
    if state then
        print("[KS HUB] AutoCook activado")
        task.spawn(autoCookLoop)
    else
        print("[KS HUB] AutoCook desactivado")
    end
end)

--========================================================--
-- 7B: AutoFuel
--========================================================--

-- Lista de combustibles válidos
local fuels = { "Log", "Coal", "Fuel Canister" }

local autoFuelToggle = false

local function autoFuelLoop()
    while autoFuelToggle do
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                for _, fuel in ipairs(fuels) do
                    if tool.Name == fuel then
                        -- Drop automático sobre la máquina
                        dropItemAt(fuel, 1, machineDropPos)
                        print("[KS HUB] AutoFuel: soltando", fuel, "en máquina")
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(3)
    end
end

CreateSection(tabAuto, "AutoFuel")
CreateCheckbox(tabAuto, "Activar AutoFuel", function(state)
    autoFuelToggle = state
    if state then
        print("[KS HUB] AutoFuel activado")
        task.spawn(autoFuelLoop)
    else
        print("[KS HUB] AutoFuel desactivado")
    end
end)

--========================================================--
-- FIN DEL SCRIPT KS HUB
--========================================================--
print("[KS HUB] Carga completa de todas las partes (1–7)")
