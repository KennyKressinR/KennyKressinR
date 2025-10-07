--========================================================--
-- UNIVERSAL ITEM SCANNER & BRING (con scroll y toggle)
--========================================================--

-- 🎛️ Toggle: botón flotante para abrir/cerrar la UI
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ItemsToggle"
ToggleBtn.Parent = game.CoreGui
ToggleBtn.Size = UDim2.new(0, 120, 0, 32)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "📦 Items (Abrir)"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = true

-- 🖼️ UI principal con Scroll
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalItemScanner"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 320, 0, 480)
Frame.Position = UDim2.new(0, 20, 0, 60)
Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Frame.BorderSizePixel = 0
Frame.Visible = false

local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -96, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Universal Item Scanner & Bring"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 80, 1, 0)
CloseBtn.Position = UDim2.new(1, -88, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "Cerrar"
CloseBtn.BorderSizePixel = 0

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Name = "List"
Scroll.Size = UDim2.new(1, -12, 1, -60)
Scroll.Position = UDim2.new(0, 6, 0, 48)
Scroll.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.Active = true
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local Footer = Instance.new("Frame", Frame)
Footer.Size = UDim2.new(1, -12, 0, 36)
Footer.Position = UDim2.new(0, 6, 1, -40)
Footer.BackgroundTransparency = 1

local RefreshBtn = Instance.new("TextButton", Footer)
RefreshBtn.Size = UDim2.new(0, 140, 1, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "🔄 Refrescar"
RefreshBtn.BorderSizePixel = 0

local CountLabel = Instance.new("TextLabel", Footer)
CountLabel.Size = UDim2.new(1, -150, 1, 0)
CountLabel.Position = UDim2.new(0, 150, 0, 0)
CountLabel.BackgroundTransparency = 1
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.TextXAlignment = Enum.TextXAlignment.Left
CountLabel.Text = "Items: 0"
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 12

-- 🔧 HRP helper (robusto)
local function getHRP()
    local plr = game.Players.LocalPlayer
    if not plr then return nil end
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

-- 🔧 Parte válida de un objeto
local function getValidPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Tool") then
        -- Busca handle o cualquier BasePart dentro de la Tool
        local handle = obj:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then return handle end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
        return nil
    end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
        return nil
    end
    -- Cualquier otro contenedor: busca un BasePart descendiente
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

-- 🧠 Categoría para ordenar (Tools → Models → BaseParts → otros)
local function getCategoryRank(obj)
    if obj:IsA("Tool") then return 1, "Tool" end
    if obj:IsA("Model") then
        -- Model con partes se considera “completo”
        local hasPart = getValidPart(obj) ~= nil
        return hasPart and 2 or 4, "Model"
    end
    if obj:IsA("BasePart") then return 3, "Part" end
    return 4, "Other"
end

-- 🚫 Filtros de exclusión (cosas del sistema/irrelevantes)
local function shouldSkip(obj)
    if obj == workspace.CurrentCamera then return true end
    if obj == workspace.Terrain then return true end
    if obj:IsDescendantOf(game.Players) then return true end
    -- Evita basura de CoreGui/StarterGui
    if obj:IsDescendantOf(game:GetService("StarterGui")) then return true end
    return false
end

-- 🔍 Escaneo recursivo
local function scanFolder(root, results)
    for _, obj in ipairs(root:GetChildren()) do
        if not shouldSkip(obj) then
            -- Si es contenedor, seguimos bajando
            if obj:IsA("Folder") or obj:IsA("Model") then
                scanFolder(obj, results)
            else
                table.insert(results, obj)
            end
        end
    end
end

-- 🧹 Limpiar lista
local function clearList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

-- 📏 Ajustar Canvas del scroll
local function updateCanvas()
    local contentSize = UIList.AbsoluteContentSize
    Scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 8)
end
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- 🔄 Refrescar y ordenar
local function refreshItems()
    clearList()
    local found = {}

    -- Escanea los espacios usuales
    scanFolder(workspace, found)
    scanFolder(game:GetService("ReplicatedStorage"), found)

    -- Orden: categoría y nombre
    table.sort(found, function(a, b)
        local ra = select(1, getCategoryRank(a))
        local rb = select(1, getCategoryRank(b))
        if ra ~= rb then return ra < rb end
        return tostring(a.Name) < tostring(b.Name)
    end)

    -- Crear botones
    local count = 0
    for _, obj in ipairs(found) do
        count += 1
        local rank, label = getCategoryRank(obj)

        local btn = Instance.new("TextButton")
        btn.Parent = Scroll
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(rank == 1 and 60 or rank == 2 and 50 or rank == 3 and 45 or 40, 45, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Text = string.format("[%s] %s", label, obj.Name)

        btn.MouseButton1Click:Connect(function()
            print("[Universal Scanner] Bring:", obj:GetFullName())
            local hrp = getHRP()
            if not hrp then
                warn("[Universal Scanner] HRP no encontrado")
                return
            end
            local part = getValidPart(obj)
            if part then
                -- 6 studs sobre la cabeza
                part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
                print("[Universal Scanner] Ítem traído encima:", obj.Name)
            else
                warn("[Universal Scanner] Sin parte válida:", obj.Name)
            end
        end)
    end

    CountLabel.Text = "Items: " .. tostring(count)
    updateCanvas()
end

-- 🧲 Toggle abrir/cerrar
local isOpen = false
local function setOpen(state)
    isOpen = state
    Frame.Visible = state
    ToggleBtn.Text = state and "📦 Items (Cerrar)" or "📦 Items (Abrir)"
end

ToggleBtn.MouseButton1Click:Connect(function()
    setOpen(not isOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

RefreshBtn.MouseButton1Click:Connect(refreshItems)

-- Primera carga (cerrado por defecto, pero lista preparada al abrir)
refreshItems()
setOpen(false)
