--========================================================--
-- UNIVERSAL INTERACTABLE ITEMS HUB - Parte 1 (UI)
--========================================================--

print("[DEBUG][P1] Iniciando creación de UI...")

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
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = playerGui

-- Botón flotante (toggle)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ItemsToggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 180, 0, 36)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "📦 Items Hub (Abrir)"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = true
ToggleBtn.ZIndex = 10

-- Ventana principal
local Frame = Instance.new("Frame", ScreenGui)
Frame.Name = "Main"
Frame.Size = UDim2.new(0, 440, 0, 560)
Frame.Position = UDim2.new(0, 20, 0, 70)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = false

-- Barra de título (draggable)
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Name = "TitleBar"
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
Title.Text = "Universal Interactable Items Hub"

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 90, 1, 0)
CloseBtn.Position = UDim2.new(1, -95, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "Cerrar"
CloseBtn.BorderSizePixel = 0

-- Tabs
local Tabs = Instance.new("Frame", Frame)
Tabs.Name = "Tabs"
Tabs.Size = UDim2.new(1, 0, 0, 36)
Tabs.Position = UDim2.new(0, 0, 0, 40)
Tabs.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local BringTabBtn = Instance.new("TextButton", Tabs)
BringTabBtn.Name = "BringTabBtn"
BringTabBtn.Size = UDim2.new(0.5, -2, 1, 0)
BringTabBtn.Position = UDim2.new(0, 0, 0, 0)
BringTabBtn.Text = "Bring Items"
BringTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BringTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BringTabBtn.BorderSizePixel = 0

local TpTabBtn = Instance.new("TextButton", Tabs)
TpTabBtn.Name = "TpTabBtn"
TpTabBtn.Size = UDim2.new(0.5, -2, 1, 0)
TpTabBtn.Position = UDim2.new(0.5, 2, 0, 0)
TpTabBtn.Text = "Teleport to Items"
TpTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TpTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpTabBtn.BorderSizePixel = 0

-- Scrolling containers
local BringFrame = Instance.new("ScrollingFrame", Frame)
BringFrame.Name = "BringList"
BringFrame.Size = UDim2.new(1, -12, 1, -160)
BringFrame.Position = UDim2.new(0, 6, 0, 80)
BringFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
BringFrame.BorderSizePixel = 0
BringFrame.ScrollBarThickness = 6
BringFrame.Active = true
BringFrame.Visible = true

local TpFrame = Instance.new("ScrollingFrame", Frame)
TpFrame.Name = "TpList"
TpFrame.Size = BringFrame.Size
TpFrame.Position = BringFrame.Position
TpFrame.BackgroundColor3 = BringFrame.BackgroundColor3
TpFrame.BorderSizePixel = 0
TpFrame.ScrollBarThickness = 6
TpFrame.Active = true
TpFrame.Visible = false

local UIListBring = Instance.new("UIListLayout", BringFrame)
UIListBring.Padding = UDim.new(0, 4)
UIListBring.SortOrder = Enum.SortOrder.LayoutOrder

local UIListTp = Instance.new("UIListLayout", TpFrame)
UIListTp.Padding = UDim.new(0, 4)
UIListTp.SortOrder = Enum.SortOrder.LayoutOrder

-- Controles inferiores
local Controls = Instance.new("Frame", Frame)
Controls.Name = "Controls"
Controls.Size = UDim2.new(1, -12, 0, 100)
Controls.Position = UDim2.new(0, 6, 1, -110)
Controls.BackgroundTransparency = 1

local SearchBox = Instance.new("TextBox", Controls)
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -190, 0, 32)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Buscar (parcial, sin mayúsculas)..."
SearchBox.Text = ""
SearchBox.BorderSizePixel = 0
SearchBox.ClearTextOnFocus = false

local RefreshBtn = Instance.new("TextButton", Controls)
RefreshBtn.Name = "RefreshBtn"
RefreshBtn.Size = UDim2.new(0, 160, 0, 32)
RefreshBtn.Position = UDim2.new(0, 0, 0, 40)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "🔄 Refrescar"
RefreshBtn.BorderSizePixel = 0

local InstantBtn = Instance.new("TextButton", Controls)
InstantBtn.Name = "InstantBtn"
InstantBtn.Size = UDim2.new(0, 200, 0, 32)
InstantBtn.Position = UDim2.new(1, -200, 0, 40)
InstantBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 60)
InstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantBtn.Text = "⚡ Interacción Instantánea: OFF"
InstantBtn.BorderSizePixel = 0

local CountLabel = Instance.new("TextLabel", Controls)
CountLabel.Name = "CountLabel"
CountLabel.Size = UDim2.new(0, 180, 0, 32)
CountLabel.Position = UDim2.new(1, -190, 0, 0)
CountLabel.BackgroundTransparency = 1
CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextSize = 12
CountLabel.Text = "Items: 0"

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
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Guardar referencias para Parte 2
HUB.ScreenGui = ScreenGui
HUB.ToggleBtn = ToggleBtn
HUB.Frame = Frame
HUB.BringFrame = BringFrame
HUB.TpFrame = TpFrame
HUB.UIListBring = UIListBring
HUB.UIListTp = UIListTp
HUB.SearchBox = SearchBox
HUB.RefreshBtn = RefreshBtn
HUB.InstantBtn = InstantBtn
HUB.CountLabel = CountLabel
HUB.BringTabBtn = BringTabBtn
HUB.TpTabBtn = TpTabBtn
HUB.ReplicatedStorage = ReplicatedStorage
HUB.Players = Players
HUB.player = player

print("[DEBUG][P1] UI creada y referencias listas")
--========================================================--
-- UNIVERSAL INTERACTABLE ITEMS HUB - Parte 2 (Lógica)
--========================================================--

print("[DEBUG][P2] Iniciando lógica...")

local HUB = shared.ItemsHub
assert(HUB and HUB.Frame and HUB.ToggleBtn, "[P2] UI no encontrada: ejecuta Parte 1 primero")

local Players = HUB.Players
local ReplicatedStorage = HUB.ReplicatedStorage
local player = HUB.player

-- Estado
HUB.instantMode = HUB.instantMode or false
HUB.searchTerm = ""

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
    return part and part:IsA("BasePart") and part.Anchored and part.Size.Magnitude >= 20
end

local function isInteractable(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") then
        local p = getValidPart(obj)
        return p ~= nil and not isHugeAnchoredPart(p)
    end
    if obj:IsA("BasePart") then
        if obj:IsDescendantOf(workspace.Terrain) then return false end
        if isHugeAnchoredPart(obj) then return false end
        return (not obj.Anchored) or obj.Size.Magnitude < 20
    end
    return false
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
local function clearList(container)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

local function updateCanvas()
    HUB.BringFrame.CanvasSize = UDim2.new(0, 0, 0, HUB.UIListBring.AbsoluteContentSize.Y + 8)
    HUB.TpFrame.CanvasSize = UDim2.new(0, 0, 0, HUB.UIListTp.AbsoluteContentSize.Y + 8)
end
HUB.UIListBring:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
HUB.UIListTp:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- Construcción de botones (búsqueda parcial y acción)
local function buildButtons(container, list, action)
    clearList(container)
    local shown = 0
    local term = string.lower(HUB.searchTerm or "")

    for _, obj in ipairs(list) do
        local nameLower = string.lower(obj.Name or "")
        if term == "" or string.find(nameLower, term, 1, true) then
            shown += 1
            local btn = Instance.new("TextButton")
            btn.Parent = container
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(action == "bring" and 45 or 50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BorderSizePixel = 0
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = obj.Name

            btn.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if not hrp then
                    warn("[DEBUG][P2] HRP no encontrado")
                    return
                end
                local part = getValidPart(obj)
                if not part then
                    warn("[DEBUG][P2] Parte válida no encontrada:", obj.Name)
                    return
                end

                if action == "bring" then
                    part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG][P2] Bring:", obj:GetFullName())
                elseif action == "tp" then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG][P2] Teleport to:", obj:GetFullName())
                end

                if HUB.instantMode then
                    -- Ejemplo: activar tool si está equipada
                    local tool = obj:IsA("Tool") and obj or nil
                    if tool and tool.Activate then
                        pcall(function() tool:Activate() end)
                        print("[DEBUG][P2] Instant: tool Activate()")
                    end
                end
            end)
        end
    end

    return shown
end

-- Refrescar: escanear y construir ambas listas
local function refresh()
    print("[DEBUG][P2] Refrescando (scan + build UI)...")
    local found = {}
    scanRoot(workspace, found)
    scanRoot(ReplicatedStorage, found)
    print("[DEBUG][P2] Detectados interactuables:", #found)

    table.sort(found, function(a, b)
        local ra = a:IsA("Tool") and 1 or a:IsA("Model") and 2 or a:IsA("BasePart") and 3 or 4
        local rb = b:IsA("Tool") and 1 or b:IsA("Model") and 2 or b:IsA("BasePart") and 3 or 4
        if ra ~= rb then return ra < rb end
        return tostring(a.Name) < tostring(b.Name)
    end)

    local shownBring = buildButtons(HUB.BringFrame, found, "bring")
    local shownTp = buildButtons(HUB.TpFrame, found, "tp")
    HUB.CountLabel.Text = "Items: " .. tostring(math.max(shownBring, shownTp))
    updateCanvas()
    print("[DEBUG][P2] Construidos en UI:", shownBring, shownTp)
end

-- Toggle abrir/cerrar
local function setOpen(state)
    HUB.Frame.Visible = state
    HUB.ToggleBtn.Text = state and "📦 Items Hub (Cerrar)" or "📦 Items Hub (Abrir)"
    print("[DEBUG][P2] HUB Visible:", state)
end

HUB.ToggleBtn.MouseButton1Click:Connect(function()
    setOpen(not HUB.Frame.Visible)
end)
HUB.CloseConnection = HUB.CloseConnection or HUB.Frame.TitleBar:FindFirstChildOfClass("TextButton")
-- CloseBtn viene de Parte 1, pero lo tomamos vía TitleBar
local CloseBtn = HUB.Frame.TitleBar:FindFirstChildOfClass("TextButton")
if CloseBtn then
    CloseBtn.MouseButton1Click:Connect(function() setOpen(false) end)
end

-- Tabs
HUB.BringTabBtn.MouseButton1Click:Connect(function()
    HUB.BringFrame.Visible = true
    HUB.TpFrame.Visible = false
end)
HUB.TpTabBtn.MouseButton1Click:Connect(function()
    HUB.BringFrame.Visible = false
    HUB.TpFrame.Visible = true
end)

-- Búsqueda parcial
HUB.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    HUB.searchTerm = string.lower(HUB.SearchBox.Text or "")
    refresh()
end)

-- Botón refrescar
HUB.RefreshBtn.MouseButton1Click:Connect(refresh)

-- Toggle interacción instantánea
HUB.InstantBtn.MouseButton1Click:Connect(function()
    HUB.instantMode = not HUB.instantMode
    HUB.InstantBtn.Text = HUB.instantMode and "⚡ Interacción Instantánea: ON" or "⚡ Interacción Instantánea: OFF"
    HUB.InstantBtn.BackgroundColor3 = HUB.instantMode and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(90, 60, 60)
    print("[DEBUG][P2] Instant mode:", HUB.instantMode)
end)

-- Primera carga y abrir
refresh()
setOpen(true)
print("[DEBUG][P2] HUB listo y operativo")
