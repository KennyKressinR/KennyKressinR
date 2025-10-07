--========================================================--
-- BLOQUE 1: CREACIÓN DE UI Y REFERENCIAS
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

shared.ItemsHub = shared.ItemsHub or {}
local HUB = shared.ItemsHub

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InteractableItemsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Botón flotante
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 180, 0, 36)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "📦 Items Hub (Abrir)"
ToggleBtn.BorderSizePixel = 0

-- Ventana principal
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 460, 0, 560)
Frame.Position = UDim2.new(0, 20, 0, 70)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false

-- Barra de título
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Text = "Universal Items Hub"

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 90, 1, 0)
CloseBtn.Position = UDim2.new(1, -95, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "Cerrar"
CloseBtn.BorderSizePixel = 0
--========================================================--
-- BLOQUE 2: TABS, LISTAS Y CONTROLES
--========================================================--

-- Tabs
local Tabs = Instance.new("Frame", Frame)
Tabs.Size = UDim2.new(1, 0, 0, 36)
Tabs.Position = UDim2.new(0, 0, 0, 40)
Tabs.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local BringTabBtn = Instance.new("TextButton", Tabs)
BringTabBtn.Size = UDim2.new(0.5, -2, 1, 0)
BringTabBtn.Text = "Bring Items"
BringTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BringTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local TpTabBtn = Instance.new("TextButton", Tabs)
TpTabBtn.Size = UDim2.new(0.5, -2, 1, 0)
TpTabBtn.Position = UDim2.new(0.5, 2, 0, 0)
TpTabBtn.Text = "Teleport to Items"
TpTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TpTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Scrolling lists
local BringFrame = Instance.new("ScrollingFrame", Frame)
BringFrame.Size = UDim2.new(1, -12, 1, -160)
BringFrame.Position = UDim2.new(0, 6, 0, 80)
BringFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
BringFrame.ScrollBarThickness = 6
BringFrame.Visible = true

local TpFrame = BringFrame:Clone()
TpFrame.Parent = Frame
TpFrame.Position = BringFrame.Position
TpFrame.Visible = false

local UIListBring = Instance.new("UIListLayout", BringFrame)
UIListBring.Padding = UDim.new(0, 4)
UIListBring.SortOrder = Enum.SortOrder.LayoutOrder

local UIListTp = Instance.new("UIListLayout", TpFrame)
UIListTp.Padding = UDim.new(0, 4)
UIListTp.SortOrder = Enum.SortOrder.LayoutOrder

-- Controles
local Controls = Instance.new("Frame", Frame)
Controls.Size = UDim2.new(1, -12, 0, 100)
Controls.Position = UDim2.new(0, 6, 1, -110)
Controls.BackgroundTransparency = 1

local SearchBox = Instance.new("TextBox", Controls)
SearchBox.Size = UDim2.new(1, -190, 0, 32)
SearchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Buscar (ej: apple)"
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

local RefreshBtn = Instance.new("TextButton", Controls)
RefreshBtn.Size = UDim2.new(0, 160, 0, 32)
RefreshBtn.Position = UDim2.new(0, 0, 0, 40)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "🔄 Refrescar"

local InstantBtn = Instance.new("TextButton", Controls)
InstantBtn.Size = UDim2.new(0, 200, 0, 32)
InstantBtn.Position = UDim2.new(1, -200, 0, 40)
InstantBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 60)
InstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantBtn.Text = "⚡ Interacción Instantánea: OFF"

local CountLabel = Instance.new("TextLabel", Controls)
CountLabel.Size = UDim2.new(0, 180, 0, 32)
CountLabel.Position = UDim2.new(1, -190, 0, 0)
CountLabel.BackgroundTransparency = 1
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 12
CountLabel.Text = "Items: 0"
--========================================================--
-- BLOQUE 3: ESCANEO Y CONSTRUCCIÓN DE BOTONES
--========================================================--

-- Detectar si un objeto es interactuable
local function isInteractable(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") and getValidPart(obj) then return true end
    if obj:IsA("BasePart") and (not obj.Anchored or obj.Size.Magnitude < 20) then return true end
    return false
end

-- Evitar basura (Players, Camera, Terrain)
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

-- Limpiar lista
local function clearList(container)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

-- Construcción de botones
local function buildButtons(container, list, action)
    clearList(container)
    local shown = 0
    local term = string.lower(shared.ItemsHub.searchTerm or "")

    for _, obj in ipairs(list) do
        local nameLower = string.lower(obj.Name or "")
        if term == "" or string.find(nameLower, term, 1, true) then
            shown += 1
            local btn = Instance.new("TextButton")
            btn.Parent = container
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(action == "bring" and 55 or 65, 55, 55)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BorderSizePixel = 0
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextWrapped = false
            btn.TextTruncate = Enum.TextTruncate.None
            btn.Text = obj.Name

            btn.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if not hrp then
                    warn("[DEBUG] HRP no encontrado")
                    return
                end
                local part = getValidPart(obj)
                if not part then
                    warn("[DEBUG] Parte válida no encontrada:", obj.Name)
                    return
                end

                if action == "bring" then
                    part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG] Bring:", obj:GetFullName())
                elseif action == "tp" then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG] Teleport to:", obj:GetFullName())
                end

                if shared.ItemsHub.instantMode then
                    local tool = obj:IsA("Tool") and obj or nil
                    if tool and tool.Activate then
                        pcall(function() tool:Activate() end)
                        print("[DEBUG] Instant: tool Activate()")
                    end
                end
            end)
        end
    end

    return shown
end
--========================================================--
-- BLOQUE 4: EVENTOS Y LÓGICA FINAL
--========================================================--

-- Refrescar listas
local function refresh()
    print("[DEBUG] Escaneando ítems...")
    local found = {}
    scanRoot(workspace, found)
    scanRoot(ReplicatedStorage, found)
    print("[DEBUG] Detectados interactuables:", #found)

    -- Ordenar Tools > Models > Parts
    table.sort(found, function(a, b)
        local ra = a:IsA("Tool") and 1 or a:IsA("Model") and 2 or a:IsA("BasePart") and 3 or 4
        local rb = b:IsA("Tool") and 1 or b:IsA("Model") and 2 or b:IsA("BasePart") and 3 or 4
        if ra ~= rb then return ra < rb end
        return tostring(a.Name) < tostring(b.Name)
    end)

    local shownBring = buildButtons(BringFrame, found, "bring")
    local shownTp = buildButtons(TpFrame, found, "tp")
    CountLabel.Text = "Items: " .. tostring(math.max(shownBring, shownTp))
end

-- Toggle HUB
local function setOpen(state)
    Frame.Visible = state
    ToggleBtn.Text = state and "📦 Items Hub (Cerrar)" or "📦 Items Hub (Abrir)"
end

ToggleBtn.MouseButton1Click:Connect(function()
    setOpen(not Frame.Visible)
end)
CloseBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

-- Tabs
BringTabBtn.MouseButton1Click:Connect(function()
    BringFrame.Visible = true
    TpFrame.Visible = false
end)
TpTabBtn.MouseButton1Click:Connect(function()
    BringFrame.Visible = false
    TpFrame.Visible = true
end)

-- Búsqueda parcial
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    shared.ItemsHub.searchTerm = string.lower(SearchBox.Text or "")
    refresh()
end)

-- Botón refrescar
RefreshBtn.MouseButton1Click:Connect(refresh)

-- Toggle interacción instantánea
InstantBtn.MouseButton1Click:Connect(function()
    shared.ItemsHub.instantMode = not shared.ItemsHub.instantMode
    InstantBtn.Text = shared.ItemsHub.instantMode and "⚡ Interacción Instantánea: ON" or "⚡ Interacción Instantánea: OFF"
    InstantBtn.BackgroundColor3 = shared.ItemsHub.instantMode and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(90, 60, 60)
end)

-- Primera carga
shared.ItemsHub.searchTerm = ""
shared.ItemsHub.instantMode = false
refresh()
setOpen(true)
print("[DEBUG] HUB listo y operativo")
