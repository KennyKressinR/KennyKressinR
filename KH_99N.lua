--========================================================--
-- KS HUB - 99 Noches
-- ItemESP.lua (ESP de ítems por categorías)
--========================================================--

local ItemESP = {}
local Workspace = game:GetService("Workspace")

--========================================================--
-- BLOQUE: Categorías (usando tu bracket)
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

-- Colores por categoría
local colors = {
    weapons     = Color3.fromRGB(255, 0, 0),     -- rojo
    minifoods   = Color3.fromRGB(0, 255, 0),     -- verde
    meat        = Color3.fromRGB(255, 165, 0),   -- naranja
    armor       = Color3.fromRGB(0, 191, 255),   -- celeste
    ["guns/ammo"] = Color3.fromRGB(255, 255, 0), -- amarillo
    materials   = Color3.fromRGB(128, 128, 128), -- gris
    pelts       = Color3.fromRGB(160, 82, 45),   -- marrón
    misc_tools  = Color3.fromRGB(255, 20, 147)   -- fucsia
}

--========================================================--
-- BLOQUE: Funciones Auxiliares
--========================================================--
local function createESP(obj, color)
    if obj:FindFirstChild("ESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.Adornee = obj:IsA("Model") and obj.PrimaryPart or obj
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Text = obj.Name
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Parent = billboard

    billboard.Parent = obj
end

local function removeESP()
    for _, obj in ipairs(Workspace.Items:GetChildren()) do
        local esp = obj:FindFirstChild("ESP")
        if esp then esp:Destroy() end
    end
end

--========================================================--
-- BLOQUE: Inicialización del Tab
--========================================================--
function ItemESP.Init(tab)
    local sec = tab:NewSection("Item ESP por Categorías")

    sec:NewToggle("Activar ESP", "Muestra ítems categorizados", function(state)
        if state then
            for category, items in pairs(bracket) do
                for _, name in ipairs(items) do
                    for _, obj in ipairs(Workspace.Items:GetChildren()) do
                        if obj.Name == name then
                            createESP(obj, colors[category] or Color3.new(1,1,1))
                        end
                    end
                end
            end

            -- Detectar nuevos ítems que aparezcan
            Workspace.Items.ChildAdded:Connect(function(obj)
                for category, items in pairs(bracket) do
                    for _, name in ipairs(items) do
                        if obj.Name == name then
                            createESP(obj, colors[category] or Color3.new(1,1,1))
                        end
                    end
                end
            end)
        else
            removeESP()
        end
    end)
end

return ItemESP
