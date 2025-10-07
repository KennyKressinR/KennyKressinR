--========================================================--
-- UNIVERSAL ITEM SCANNER & BRING SCRIPT
-- Independiente, no depende de otros hubs
--========================================================--

-- ⚡ Configuración mínima de UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 400)
Frame.Position = UDim2.new(0, 20, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 2)

-- 🔧 Función auxiliar: obtener HRP
local function getHRP()
    local plr = game.Players.LocalPlayer
    if plr and plr.Character then
        return plr.Character:FindFirstChild("HumanoidRootPart")
    end
end

-- 🔧 Función auxiliar: obtener parte válida de un objeto
local function getValidPart(obj)
    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") and obj.PrimaryPart then
        return obj.PrimaryPart
    else
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

-- 🔍 Escaneo recursivo
local function scanFolder(folder, results)
    for _, obj in ipairs(folder:GetChildren()) do
        if obj ~= game.Players and obj ~= workspace.CurrentCamera then
            if obj:IsA("Folder") or obj:IsA("Model") then
                scanFolder(obj, results)
            else
                table.insert(results, obj)
            end
        end
    end
end

-- 🧹 Limpiar UI
local function clearUI()
    for _, child in ipairs(Frame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

-- 🔄 Refrescar lista
local function refreshItems()
    clearUI()

    local foundItems = {}
    scanFolder(workspace, foundItems)
    scanFolder(game.ReplicatedStorage, foundItems)

    if #foundItems == 0 then
        warn("[Universal Scanner] No se detectaron ítems")
    end

    for _, obj in ipairs(foundItems) do
        local btn = Instance.new("TextButton", Frame)
        btn.Size = UDim2.new(1, -4, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = obj.Name

        btn.MouseButton1Click:Connect(function()
            print("[Universal Scanner] Bring:", obj.Name)
            local hrp = getHRP()
            if hrp then
                local part = getValidPart(obj)
                if part then
                    part.CFrame = hrp.CFrame + Vector3.new(0, 6, 0)
                    print("[Universal Scanner] Ítem traído encima:", obj.Name)
                else
                    warn("[Universal Scanner] No se encontró parte válida en:", obj.Name)
                end
            else
                warn("[Universal Scanner] HRP no encontrado")
            end
        end)
    end
end

-- Botón de refresco
local refreshBtn = Instance.new("TextButton", Frame)
refreshBtn.Size = UDim2.new(1, -4, 0, 28)
refreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
refreshBtn.Text = "🔄 Refrescar Ítems"
refreshBtn.MouseButton1Click:Connect(refreshItems)

-- Primera carga
refreshItems()
