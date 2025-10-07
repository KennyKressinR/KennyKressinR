--========================================================--
-- UNIVERSAL INTERACTABLE ITEM SCANNER & BRING
-- Optimizado para Tools y objetos usables
--========================================================--

print("[DEBUG] Script iniciado (Interactables Only)")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ItemsToggle"
ToggleBtn.Parent = game.CoreGui
ToggleBtn.Size = UDim2.new(0, 140, 0, 32)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "📦 Items (Abrir)"
ToggleBtn.BorderSizePixel = 0

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "InteractableScanner"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 480)
Frame.Position = UDim2.new(0, 20, 0, 60)
Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Frame.BorderSizePixel = 0
Frame.Visible = false

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(1, -12, 1, -50)
Scroll.Position = UDim2.new(0, 6, 0, 40)
Scroll.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.Active = true
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local RefreshBtn = Instance.new("TextButton", Frame)
RefreshBtn.Size = UDim2.new(0, 140, 0, 28)
RefreshBtn.Position = UDim2.new(0, 6, 1, -34)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "🔄 Refrescar"
RefreshBtn.BorderSizePixel = 0

-- 🔧 Helpers
local function getHRP()
    local plr = game.Players.LocalPlayer
    if plr and plr.Character then
        return plr.Character:FindFirstChild("HumanoidRootPart")
    end
end

local function getValidPart(obj)
    if obj:IsA("Tool") then
        return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    elseif obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

-- 🧠 Filtro de objetos interactuables
local function isInteractable(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") and getValidPart(obj) then return true end
    -- Evitar partes sueltas que son de edificios (ej: Anchored y enormes)
    if obj:IsA("BasePart") then
        if obj.Anchored and obj.Size.Magnitude > 20 then
            return false
        end
        return true
    end
    return false
end

-- 🔍 Escaneo recursivo
local function scanFolder(root, results)
    for _, obj in ipairs(root:GetChildren()) do
        if not obj:IsDescendantOf(game.Players) and obj ~= workspace.CurrentCamera then
            if obj:IsA("Folder") or obj:IsA("Model") then
                scanFolder(obj, results)
            else
                if isInteractable(obj) then
                    table.insert(results, obj)
                end
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

-- 🔄 Refrescar
local function refreshItems()
    print("[DEBUG] Refrescando lista de ítems interactuables...")
    clearList()
    local found = {}
    scanFolder(workspace, found)
    scanFolder(game.ReplicatedStorage, found)
    print("[DEBUG] Total detectados:", #found)

    for _, obj in ipairs(found) do
        local btn = Instance.new("TextButton", Scroll)
        btn.Size = UDim2.new(1, -8, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = obj.Name

        btn.MouseButton1Click:Connect(function()
            print("[DEBUG] Bring:", obj:GetFullName())
            local hrp = getHRP()
            if hrp then
                local part = getValidPart(obj)
                if part then
                    part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG] Ítem traído:", obj.Name)
                else
                    warn("[DEBUG] No se encontró parte válida en:", obj.Name)
                end
            else
                warn("[DEBUG] HRP no encontrado")
            end
        end)
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 8)
end

-- Toggle abrir/cerrar
ToggleBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    ToggleBtn.Text = Frame.Visible and "📦 Items (Cerrar)" or "📦 Items (Abrir)"
    print("[DEBUG] HUB Visible:", Frame.Visible)
end)

RefreshBtn.MouseButton1Click:Connect(refreshItems)

-- Primera carga
refreshItems()
