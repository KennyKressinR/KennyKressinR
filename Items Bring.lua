--========================================================--
-- UNIVERSAL INTERACTABLE ITEMS HUB (Remake Mejorado)
--========================================================--

print("[DEBUG] HUB Mejorado iniciado")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InteractableItemsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Botón flotante
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 160, 0, 36)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "📦 Items Hub (Abrir)"
ToggleBtn.BorderSizePixel = 0

-- Ventana principal
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 420, 0, 540)
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

-- Tabs
local Tabs = Instance.new("Frame", Frame)
Tabs.Size = UDim2.new(1, 0, 0, 36)
Tabs.Position = UDim2.new(0, 0, 0, 40)
Tabs.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local BringTabBtn = Instance.new("TextButton", Tabs)
BringTabBtn.Size = UDim2.new(0.5, -2, 1, 0)
BringTabBtn.Position = UDim2.new(0, 0, 0, 0)
BringTabBtn.Text = "Bring Items"
BringTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BringTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local TpTabBtn = Instance.new("TextButton", Tabs)
TpTabBtn.Size = UDim2.new(0.5, -2, 1, 0)
TpTabBtn.Position = UDim2.new(0.5, 2, 0, 0)
TpTabBtn.Text = "Teleport to Items"
TpTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TpTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Contenedores de listas
local BringFrame = Instance.new("ScrollingFrame", Frame)
BringFrame.Size = UDim2.new(1, -12, 1, -120)
BringFrame.Position = UDim2.new(0, 6, 0, 80)
BringFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
BringFrame.ScrollBarThickness = 6
BringFrame.Visible = true

local TpFrame = BringFrame:Clone()
TpFrame.Parent = Frame
TpFrame.Position = UDim2.new(0, 6, 0, 80)
TpFrame.Visible = false

local UIListBring = Instance.new("UIListLayout", BringFrame)
UIListBring.Padding = UDim.new(0, 4)
UIListBring.SortOrder = Enum.SortOrder.LayoutOrder

local UIListTp = Instance.new("UIListLayout", TpFrame)
UIListTp.Padding = UDim.new(0, 4)
UIListTp.SortOrder = Enum.SortOrder.LayoutOrder

-- Controles
local Controls = Instance.new("Frame", Frame)
Controls.Size = UDim2.new(1, -12, 0, 64)
Controls.Position = UDim2.new(0, 6, 1, -70)
Controls.BackgroundTransparency = 1

local SearchBox = Instance.new("TextBox", Controls)
SearchBox.Size = UDim2.new(1, -170, 0, 28)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Buscar..."
SearchBox.Text = ""
SearchBox.BorderSizePixel = 0
SearchBox.ClearTextOnFocus = false

local RefreshBtn = Instance.new("TextButton", Controls)
RefreshBtn.Size = UDim2.new(0, 160, 0, 28)
RefreshBtn.Position = UDim2.new(0, 0, 0, 32)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "🔄 Refrescar"
RefreshBtn.BorderSizePixel = 0

local InstantBtn = Instance.new("TextButton", Controls)
InstantBtn.Size = UDim2.new(0, 160, 0, 28)
InstantBtn.Position = UDim2.new(1, -160, 0, 32)
InstantBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 60)
InstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantBtn.Text = "⚡ Interacción Instantánea: OFF"
InstantBtn.BorderSizePixel = 0

-- Estado
local instantMode = false
local searchTerm = ""

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
    end
end

local function isInteractable(obj)
    if obj:IsA("Tool") then return true end
    if obj:IsA("Model") and getValidPart(obj) then return true end
    if obj:IsA("BasePart") and (not obj.Anchored or obj.Size.Magnitude < 20) then return true end
    return false
end

local function scanRoot(root, into)
    for _, obj in ipairs(root:GetChildren()) do
        if not obj:IsDescendantOf(Players) and obj ~= workspace.CurrentCamera then
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

-- Construcción de botones
local function buildButtons(container, list, action)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local shown = 0
    for _, obj in ipairs(list) do
        -- Filtro por búsqueda parcial (case-insensitive)
        if searchTerm == "" or string.find(string.lower(obj.Name), searchTerm, 1, true) then
            shown += 1
            local btn = Instance.new("TextButton")
            btn.Parent = container
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BorderSizePixel = 0
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = obj.Name

            btn.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if not hrp then
                    warn("[DEBUG] HRP no encontrado")
                    return
                end
                local part = getValidPart(obj)
                if not part then
                    warn("[DEBUG] No se encontró parte válida en:", obj.Name)
                    return
                end

                if action == "bring" then
                    part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG] Bring:", obj.Name)
                elseif action == "tp" then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
                    print("[DEBUG] Teleport to:", obj.Name)
                end

                if instantMode then
                    print("[DEBUG] Interacción instantánea activada")
                    -- Aquí podrías añadir lógica extra si el juego requiere "Hold to interact"
                    -- Por ejemplo, disparar RemoteEvents directamente en vez de esperar
                end
            end)
        end
    end
    return shown
end
