--========================================================--
-- KS HUB - 99 Noches
-- ItemTP.lua (Bring Items avanzado con posiciones especiales)
--========================================================--

local ItemTP = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Referencias
local itemsFolder = Workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteConsume = remoteEvents:WaitForChild("RequestConsumeItem")

-- Posiciones especiales
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos  = Vector3.new(21, 16, -5)

--========================================================--
-- BLOQUE: Categorías de ítems (usando tu bracket)
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
-- BLOQUE: Funciones Auxiliares
--========================================================--
local function getHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- Traer ítems al jugador
local function bringItem(name, quantity)
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
    print("[KS HUB] Bring completado: "..count.." de "..name)
end

-- Aparecer ítems en posiciones especiales
local function dropItemAt(name, quantity, position)
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
    print("[KS HUB] Drop completado: "..count.." de "..name.." en "..tostring(position))
end

--========================================================--
-- BLOQUE: Inicialización del Tab
--========================================================--
function ItemTP.Init(tab)
    for category, items in pairs(bracket) do
        local sec = tab:NewSection("Bring "..category)
        local selected = nil
        sec:NewDropdown("Seleccionar "..category, "Elige un ítem", items, function(val)
            selected = val
        end)
        sec:NewSlider("Cantidad "..category, "Cuántos traer", 50, 1, function(val)
            _G["Qty_"..category] = val
        end)
        sec:NewButton("Bring "..category, "Trae al jugador", function()
            if selected then
                bringItem(selected, _G["Qty_"..category] or 1)
            else
                warn("Debes seleccionar un ítem en "..category)
            end
        end)
        sec:NewButton("Drop en Campfire", "Aparece en la fogata", function()
            if selected then
                dropItemAt(selected, _G["Qty_"..category] or 1, campfireDropPos)
            end
        end)
        sec:NewButton("Drop en Machine", "Aparece en la máquina", function()
            if selected then
                dropItemAt(selected, _G["Qty_"..category] or 1, machineDropPos)
            end
        end)
    end
end

return ItemTP
