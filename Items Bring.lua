--========================================================--
-- PARTE 1: BOOTSTRAP Y ESTADO COMPARTIDO
--========================================================--

-- [1.1] Servicios y jugador
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

-- [1.2] Espacio compartido
shared.ItemsHub = shared.ItemsHub or {}
local HUB = shared.ItemsHub

-- [1.3] Estado inicial
HUB.state = {
    isOpen = false,
    instantMode = false,
    searchTerm = "",
    lastCount = 0
}

-- [1.4] Paleta visual y layout
local COLORS = {
    bg = Color3.fromRGB(18,18,18),
    panel = Color3.fromRGB(30,30,30),
    title = Color3.fromRGB(42,42,42),
    accent = Color3.fromRGB(70,130,180),
    btn = Color3.fromRGB(52,52,52),
    btnHover = Color3.fromRGB(62,62,62),
    good = Color3.fromRGB(60,120,60),
    warn = Color3.fromRGB(180,120,60)
}
local MARGINS = {
    outer = 10,
    inner = 8,
    listTop = 86,
    controlsHeight = 100
}
--========================================================--
-- PARTE 2: CONSTRUCCIÓN DE UI Y ESTILO
--========================================================--

-- [2.1] ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalItemsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui
HUB.ScreenGui = ScreenGui

-- [2.2] Botón flotante (abrir/cerrar)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 190, 0, 36)
ToggleBtn.Position = UDim2.new(0, MARGINS.outer, 0, MARGINS.outer)
ToggleBtn.BackgroundColor3 = COLORS.btn
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "📦 Items Hub (Abrir)"
local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 6)
HUB.ToggleBtn = ToggleBtn

-- [2.3] Ventana principal
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 520, 0, 600)
Frame.Position = UDim2.new(0, MARGINS.outer, 0, MARGINS.outer + 40)
Frame.BackgroundColor3 = COLORS.bg
Frame.BorderSizePixel = 0
Frame.Visible = false
local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 8)
HUB.Frame = Frame

-- [2.4] Barra de título (arrastrable)
local TitleBar = Instance.new("Frame", Frame)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = COLORS.title
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -110, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Text = "Universal Interactable Items Hub"

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 96, 1, -8)
CloseBtn.Position = UDim2.new(1, -104, 0, 4)
CloseBtn.BackgroundColor3 = COLORS.btn
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Text = "Cerrar"
CloseBtn.BorderSizePixel = 0
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)
HUB.CloseBtn = CloseBtn

-- [2.5] Tabs
local Tabs = Instance.new("Frame", Frame)
Tabs.Name = "Tabs"
Tabs.Size = UDim2.new(1, -2*MARGINS.inner, 0, 36)
Tabs.Position = UDim2.new(0, MARGINS.inner, 0, 50)
Tabs.BackgroundColor3 = COLORS.panel
Tabs.BorderSizePixel = 0
local TabsCorner = Instance.new("UICorner", Tabs)
TabsCorner.CornerRadius = UDim.new(0, 6)

local BringTabBtn = Instance.new("TextButton", Tabs)
BringTabBtn.Name = "BringTabBtn"
BringTabBtn.Size = UDim2.new(0.5, -4, 1, 0)
BringTabBtn.Position = UDim2.new(0, 2, 0, 0)
BringTabBtn.BackgroundColor3 = COLORS.btn
BringTabBtn.TextColor3 = Color3.fromRGB(255,255,255)
BringTabBtn.Text = "Bring items → mí"
BringTabBtn.BorderSizePixel = 0
Instance.new("UICorner", BringTabBtn).CornerRadius = UDim.new(0, 6)

local TpTabBtn = Instance.new("TextButton", Tabs)
TpTabBtn.Name = "TpTabBtn"
TpTabBtn.Size = UDim2.new(0.5, -4, 1, 0)
TpTabBtn.Position = UDim2.new(0.5, 2, 0, 0)
TpTabBtn.BackgroundColor3 = COLORS.btn
TpTabBtn.TextColor3 = Color3.fromRGB(255,255,255)
TpTabBtn.Text = "Teleport yo → items"
TpTabBtn.BorderSizePixel = 0
Instance.new("UICorner", TpTabBtn).CornerRadius = UDim.new(0, 6)
HUB.BringTabBtn = BringTabBtn
HUB.TpTabBtn = TpTabBtn

-- [2.6] Listas con scroll
local function makeList(parent, name)
    local Scroll = Instance.new("ScrollingFrame", parent)
    Scroll.Name = name
    Scroll.Size = UDim2.new(1, -2*MARGINS.inner, 1, -(MARGINS.listTop + MARGINS.controlsHeight))
    Scroll.Position = UDim2.new(0, MARGINS.inner, 0, MARGINS.listTop)
    Scroll.BackgroundColor3 = COLORS.panel
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.Active = true
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)
    local UIList = Instance.new("UIListLayout", Scroll)
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    return Scroll, UIList
end

local BringList, UIListBring = makeList(Frame, "BringList")
local TpList, UIListTp = makeList(Frame, "TpList")
TpList.Visible = false
HUB.BringList = BringList
HUB.TpList = TpList
HUB.UIListBring = UIListBring
HUB.UIListTp = UIListTp

-- [2.7] Controles inferiores
local Controls = Instance.new("Frame", Frame)
Controls.Name = "Controls"
Controls.Size = UDim2.new(1, -2*MARGINS.inner, 0, MARGINS.controlsHeight)
Controls.Position = UDim2.new(0, MARGINS.inner, 1, -(MARGINS.controlsHeight + MARGINS.inner))
Controls.BackgroundTransparency = 1
HUB.Controls = Controls

local SearchBox = Instance.new("TextBox", Controls)
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -210, 0, 36)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.BackgroundColor3 = COLORS.panel
SearchBox.TextColor3 = Color3.fromRGB(255,255,255)
SearchBox.PlaceholderText = "Buscar parcial (ej: apple)"
SearchBox.Text = ""
SearchBox.BorderSizePixel = 0
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
HUB.SearchBox = SearchBox

local RefreshBtn = Instance.new("TextButton", Controls)
RefreshBtn.Name = "RefreshBtn"
RefreshBtn.Size = UDim2.new(0, 160, 0, 36)
RefreshBtn.Position = UDim2.new(0, 0, 0, 50)
RefreshBtn.BackgroundColor3 = COLORS.btn
RefreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
RefreshBtn.Text = "🔄 Refrescar"
RefreshBtn.BorderSizePixel = 0
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
HUB.RefreshBtn = RefreshBtn

local InstantBtn = Instance.new("TextButton", Controls)
InstantBtn.Name = "InstantBtn"
InstantBtn.Size = UDim2.new(0, 220, 0, 36)
InstantBtn.Position = UDim2.new(1, -220, 0, 50)
InstantBtn.BackgroundColor3 = COLORS.warn
InstantBtn.TextColor3 = Color3.fromRGB(255,255,255)
InstantBtn.Text = "⚡ Interacción instantánea: OFF"
InstantBtn.BorderSizePixel = 0
Instance.new("UICorner", InstantBtn).CornerRadius = UDim.new(0, 6)
HUB.InstantBtn = InstantBtn

local CountLabel = Instance.new("TextLabel", Controls)
CountLabel.Name = "CountLabel"
CountLabel.Size = UDim2.new(0, 200, 0, 36)
CountLabel.Position = UDim2.new(1, -210, 0, 0)
CountLabel.BackgroundTransparency = 1
CountLabel.Text
--========================================================--
-- PARTE 3: UTILIDADES (ESCANEO, FILTROS, ORDEN)
--========================================================--

-- [3.1] HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- [3.2] Parte válida de un objeto
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

-- [3.3] Filtro interactuable (ignora edificios)
local function isHugeAnchored(part)
    return part and part:IsA("BasePart") and part.Anchored and part.Size.Magnitude >= 20
end

local function isInteractable(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") then
        local p = getValidPart(obj)
        return p ~= nil and not isHugeAnchored(p)
    end
    if obj:IsA("BasePart") then
        if obj:IsDescendantOf(workspace.Terrain) then return false end
        if isHugeAnchored(obj) then return false end
        return (not obj.Anchored) or obj.Size.Magnitude < 20
    end
    return false
end

-- [3.4] Evitar basura
local function shouldSkip(obj)
    if obj == workspace.CurrentCamera then return true end
    if obj == workspace.Terrain then return true end
    if obj:IsDescendantOf(Players) then return true end
    return false
end

-- [3.5] Escaneo recursivo
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

-- [3.6] Orden: Tools > Models > Parts > Otros
local function sortItems(list)
    table.sort(list, function(a, b)
        local ra = a:IsA("Tool") and 1 or a:IsA("Model") and 2 or a:IsA("BasePart") and 3 or 4
        local rb = b:IsA("Tool") and 1 or b:IsA("Model") and 2 or b:IsA("BasePart") and 3 or 4
        if ra ~= rb then return ra < rb end
        return tostring(a.Name) < tostring(b.Name)
    end)
end

-- [3.7] Canvas auto
local function updateCanvas()
    HUB.BringList.CanvasSize = UDim2.new(0,0,0, HUB.UIListBring.AbsoluteContentSize.Y + 12)
    HUB.TpList.CanvasSize = UDim2.new(0,0,0, HUB.UIListTp.AbsoluteContentSize.Y + 12)
end
HUB.UIListBring:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
HUB.UIListTp:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
--========================================================--
-- PARTE 4: ACCIONES (BRING, TELEPORT, INSTANT)
--========================================================--

-- [4.1] Movimiento robusto de Model (SetPrimaryPartCFrame o fallback)
local function moveModelToCFrame(model, targetCFrame)
    if model.PrimaryPart then
        model:SetPrimaryPartCFrame(targetCFrame)
        return true
    else
        -- Fallback: mover cada BasePart manteniendo offset relativo
        local base = getValidPart(model)
        if not base then return false end
        local baseCF = base.CFrame
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then
                local rel = baseCF:ToObjectSpace(d.CFrame)
                d.CFrame = targetCFrame:ToWorldSpace(rel)
            end
        end
        return true
    end
end

-- [4.2] Bring objeto → jugador (6 studs arriba)
local function bringToPlayer(obj)
    local hrp = getHRP()
    if not hrp then return false, "HRP no encontrado" end
    local targetCF = hrp.CFrame + Vector3.new(0, 6, 0)

    if obj:IsA("Tool") then
        -- Equipar y posicionar handle si existe
        obj.Parent = player.Backpack
        pcall(function() player.Character.Humanoid:EquipTool(obj) end)
        local handle = obj:FindFirstChild("Handle")
        if handle then handle.CFrame = targetCF end
        return true
    end

    local part = getValidPart(obj)
    if not part then return false, "Parte válida no encontrada" end

    local wasAnchored = part.Anchored
    part.Anchored = true
    if obj:IsA("Model") then
        moveModelToCFrame(obj, targetCF)
    else
        part.CFrame = targetCF
    end
    part.Anchored = wasAnchored
    return true
end

-- [4.3] Teleport jugador → objeto (6 studs arriba)
local function tpToItem(obj)
    local hrp = getHRP()
    if not hrp then return false, "HRP no encontrado" end
    local part = getValidPart(obj)
    if not part then return false, "Parte válida no encontrada" end

    local targetCF = part.CFrame + Vector3.new(0, 6, 0)
    hrp.CFrame = targetCF
    return true
end

-- [4.4] Interacción instantánea (ej: tool Activate)
local function tryInstant(obj)
    if not HUB.state.instantMode then return end
    if obj:IsA("Tool") and obj.Activate then
        pcall(function() obj:Activate() end)
    end
end

-- [4.5] Fábrica de botón de ítem
local function makeItemButton(parentList, obj, mode) -- mode: "bring" | "tp"
    local btn = Instance.new("TextButton")
    btn.Parent = parentList
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = COLORS.btn
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextWrapped = false
    btn.TextTruncate = Enum.TextTruncate.None
    btn.Text = obj.Name
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    -- Hover
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = COLORS.btnHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = COLORS.btn end)

    btn.MouseButton1Click:Connect(function()
        local ok, err
        if mode == "bring" then
            ok, err = bringToPlayer(obj)
        else
            ok, err = tpToItem(obj)
        end
        if ok then
            tryInstant(obj)
        else
            warn("[HUB] Acción falló:", err or "error desconocido")
        end
    end)
end
--========================================================--
-- PARTE 5: WIRING FINAL (BÚSQUEDA, REFRESH, TABS, TOGGLE)
--========================================================--

-- [5.1] Limpieza de lista
local function clearList(list)
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

-- [5.2] Build de listas con filtro parcial
local function buildLists(found)
    clearList(HUB.BringList)
    clearList(HUB.TpList)
    local term = string.lower(HUB.state.searchTerm or "")
    local shown = 0

    for _, obj in ipairs(found) do
        local nameLower = string.lower(obj.Name or "")
        if term == "" or string.find(nameLower, term, 1, true) then
            makeItemButton(HUB.BringList, obj, "bring")
            makeItemButton(HUB.TpList, obj, "tp")
            shown += 1
        end
    end

    HUB.state.lastCount = shown
    HUB.CountLabel.Text = "Items: " .. tostring(shown)
    updateCanvas()
end

-- [5.3] Refresh (scan + sort + build)
local function refresh()
    local found = {}
    scanRoot(workspace, found)
    scanRoot(RS, found)
    sortItems(found)
    buildLists(found)
end
HUB.refresh = refresh

-- [5.4] Tabs
HUB.BringTabBtn.MouseButton1Click:Connect(function()
    HUB.BringTabBtn.BackgroundColor3 = COLORS.accent
    HUB.TpTabBtn.BackgroundColor3 = COLORS.btn
    HUB.BringList.Visible = true
    HUB.TpList.Visible = false
end)
HUB.TpTabBtn.MouseButton1Click:Connect(function()
    HUB.TpTabBtn.BackgroundColor3 = COLORS.accent
    HUB.BringTabBtn.BackgroundColor3 = COLORS.btn
    HUB.BringList.Visible = false
    HUB.TpList.Visible = true
end)

-- [5.5] Toggle abrir/cerrar
local function setOpen(state)
    HUB.state.isOpen = state
    HUB.Frame.Visible = state
    HUB.ToggleBtn.Text = state and "📦 Items Hub (Cerrar)" or "📦 Items Hub (Abrir)"
end
HUB.ToggleBtn.MouseButton1Click:Connect(function() setOpen(not HUB.state.isOpen) end)
HUB.CloseBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- [5.6] Búsqueda parcial
HUB.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    HUB.state.searchTerm = string.lower(HUB.SearchBox.Text or "")
    refresh()
end)

-- [5.7] Botón refrescar
HUB.RefreshBtn.MouseButton1Click:Connect(refresh)

-- [5.8] Toggle Instant
HUB.InstantBtn.MouseButton1Click:Connect(function()
    HUB.state.instantMode = not HUB.state.instantMode
    HUB.InstantBtn.Text = HUB.state.instantMode and "⚡ Interacción instantánea: ON" or "⚡ Interacción instantánea: OFF"
    HUB.InstantBtn.BackgroundColor3 = HUB.state.instantMode and COLORS.good or COLORS.warn
end)

-- [5.9] Primera carga y estado inicial
setOpen(true)
HUB.BringTabBtn.BackgroundColor3 = COLORS.accent
refresh()
