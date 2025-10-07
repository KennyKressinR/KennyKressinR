--========================================================--
-- UNIVERSAL INTERACTABLE ITEMS HUB (Remake desde cero)
--========================================================--

print("[DEBUG] Remake HUB iniciado")

-- Servicios y jugador
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InteractableItemsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = playerGui
print("[DEBUG] ScreenGui creado en PlayerGui")

-- Botón flotante abrir/cerrar
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ItemsToggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 140, 0, 36)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "📦 Items (Abrir)"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = true

-- Ventana principal
local Frame = Instance.new("Frame", ScreenGui)
Frame.Name = "Main"
Frame.Size = UDim2.new(0, 380, 0, 520)
Frame.Position = UDim2.new(0, 20, 0, 70)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false

-- Barra de título (draggable)
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Text = "Universal Interactable Items Hub"

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 90, 1, 0)
CloseBtn.Position = UDim2.new(1, -95, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "Cerrar"

-- Controles superiores
local Controls = Instance.new("Frame", Frame)
Controls.Name = "Controls"
Controls.Size = UDim2.new(1, -12, 0, 64)
Controls.Position = UDim2.new(0, 6, 0, 48)
Controls.BackgroundTransparency = 1

local SearchBox = Instance.new("TextBox", Controls)
SearchBox.Size = UDim2.new(1, -170, 0, 28)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Buscar por nombre..."
SearchBox.Text = ""
SearchBox.BorderSizePixel = 0
SearchBox.ClearTextOnFocus = false

local FilterDropdown = Instance.new("TextButton", Controls)
FilterDropdown.Size = UDim2.new(0, 160, 0, 28)
FilterDropdown.Position = UDim2.new(1, -160, 0, 0)
FilterDropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
FilterDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterDropdown.BorderSizePixel = 0
FilterDropdown.Text = "Filtro: All"

local RefreshBtn = Instance.new("TextButton", Controls)
RefreshBtn.Size = UDim2.new(0, 160, 0, 28)
RefreshBtn.Position = UDim2.new(0, 0, 0, 32)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Text = "🔄 Refrescar"

local CountLabel = Instance.new("TextLabel", Controls)
CountLabel.Size = UDim2.new(1, -170, 0, 28)
CountLabel.Position = UDim2.new(1, -170, 0, 32)
CountLabel.BackgroundTransparency = 1
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 12
CountLabel.Text = "Items: 0"

-- Scrolling list
local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Name = "List"
Scroll.Size = UDim2.new(1, -12, 1, -120)
Scroll.Position = UDim2.new(0, 6, 0, 116)
Scroll.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.Active = true
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Draggable
do
    local dragging = false
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Helpers
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function getValidPart(obj)
    if obj:IsA("Tool") then
        return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    elseif obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    elseif obj:IsA("BasePart") then
        return obj
    else
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end
end

local function isHugeAnchoredPart(part)
    return part:IsA("BasePart") and part.Anchored and part.Size.Magnitude >= 20
end

local function isInteractable(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") then
        local p = getValidPart(obj)
        if p and not isHugeAnchoredPart(p) then return true end
        return false
    end
    if obj:IsA("BasePart") then
        if obj:IsDescendantOf(workspace.Terrain) then return false end
        if isHugeAnchoredPart(obj) then return false end
        return (not obj.Anchored) or obj.Size.Magnitude < 20
    end
    return false
end

local function categoryOf(obj)
    if obj:IsA("Tool") then return "Tool", 1 end
    if obj:IsA("Model") then return "Item", 2 end
    if obj:IsA("BasePart") then return "Part", 3 end
    return "Other", 4
end

local function shouldSkip(obj)
    if obj == workspace.CurrentCamera then return true end
    if obj == workspace.Terrain then return true end
    if obj:IsDescendantOf(Players) then return true end
    return false
end

-- Escaneo recursivo
local function scanRoot(root, into)
    for _, obj in ipairs(root:GetChildren()) do
        if not shouldSkip(obj) then
            if obj:IsA("Folder") or obj:IsA("Model") then
                scanRoot(obj, into)
            else
                if isInteractable(obj) then
                    table.insert(into, obj)
                end
            end
        end
    end
end

-- UI utils
local function clearList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

local function updateCanvas()
    local size = UIList.AbsoluteContentSize
    Scroll.CanvasSize = UDim2.new(0, 0, 0, size.Y + 8)
end
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- Estado de filtro
local currentFilter = "All" -- All, Tools, Items, Parts

FilterDropdown.MouseButton1Click:Connect(function()
    if currentFilter == "All" then currentFilter = "Tools"
    elseif currentFilter == "Tools" then currentFilter = "Items"
    elseif currentFilter == "Items" then currentFilter = "Parts"
    else currentFilter = "All" end
    FilterDropdown.Text = "Filtro: " .. currentFilter
    print("[DEBUG] Filtro cambiado a:", currentFilter)
end)

-- Búsqueda reactiva
local searchTerm = ""
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchTerm = string.lower(SearchBox.Text or "")
end)

-- Construcción de ítem UI
local function addItemButton(obj)
    local cat, rank = categoryOf(obj)
    -- Filtro por categoría
    if currentFilter == "Tools" and cat ~= "Tool" then return end
    if currentFilter == "Items" and cat ~= "Item" then return end
    if currentFilter == "Parts" and cat ~= "Part" then return end
    -- Filtro por texto
    if searchTerm ~= "" and not string.find(string.lower(obj.Name), searchTerm, 1, true) then return end

    local btn = Instance.new("TextButton")
    btn.Parent = Scroll
    btn.Size = UDim2.new(1, -8, 0, 30)
    local bg = rank == 1 and Color3.fromRGB(60, 80, 60) or rank == 2 and Color3.fromRGB(55, 70, 85) or rank == 3 and Color3.fromRGB(70, 60, 60) or Color3.fromRGB(55, 55, 55)
    btn.BackgroundColor3 = bg
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = string.format("[%s] %s", cat, obj.Name)

    btn.MouseButton1Click:Connect(function()
        print("[DEBUG] Bring:", obj:GetFullName())
        local hrp = getHRP()
        if not hrp then
            warn("[DEBUG] HRP no encontrado")
            return
        end
        local part = getValidPart(obj)
        if part then
            part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
            print("[DEBUG] Ítem traído encima:", obj.Name)
        else
            warn("[DEBUG] Sin parte válida:", obj.Name)
        end
    end)
end

-- Refrescar (con orden y seguridad)
local function refresh()
    print("[DEBUG] Refrescando (scan + build UI)...")
    clearList()
    local found = {}

    -- Escanear fuentes comunes
    scanRoot(workspace, found)
    scanRoot(ReplicatedStorage, found)
    print("[DEBUG] Detectados interactuables:", #found)

    -- Orden: rank y nombre
    table.sort(found, function(a, b)
        local _, ra = categoryOf(a)
        local _, rb = categoryOf(b)
        if ra ~= rb then return ra < rb end
        return tostring(a.Name) < tostring(b.Name)
    end)

    local shown = 0
    for _, obj in ipairs(found) do
        addItemButton(obj)
        shown += 1
    end
    CountLabel.Text = "Items: " .. tostring(shown)
    updateCanvas()
    print("[DEBUG] Construidos en UI:", shown)
end

-- Toggle
local function setOpen(state)
    Frame.Visible = state
    ToggleBtn.Text = state and "📦 Items (Cerrar)" or "📦 Items (Abrir)"
    print("[DEBUG] HUB Visible:", state)
end
ToggleBtn.MouseButton1Click:Connect(function()
    setOpen(not Frame.Visible)
end)
CloseBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

-- Botón refrescar
RefreshBtn.MouseButton1Click:Connect(refresh)

-- Primera carga
refresh()
setOpen(true)
print("[DEBUG] HUB listo")
