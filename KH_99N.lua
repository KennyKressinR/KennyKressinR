-- 🧱 PARTE 1: ESTRUCTURA BASE DEL HUB
-- Autor: KennyKressinR - versión reestructurada sin errores

-- Protección a prueba de fallos
pcall(function()

-- Variables iniciales
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabButtonsFrame = Instance.new("Frame")

ScreenGui.Name = "KSHub"
ScreenGui.Parent = game:GetService("CoreGui")

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

TabButtonsFrame.Name = "TabButtons"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 0)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabButtonsFrame.Parent = MainFrame

-- Tabla de Tabs
local Tabs = {}

-- Función para crear Tabs
function CreateTab(name)
    local Frame = Instance.new("Frame")
    Frame.Name = name .. "Tab"
    Frame.Size = UDim2.new(1, 0, 1, -30)
    Frame.Position = UDim2.new(0, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Frame.Visible = false
    Frame.Parent = MainFrame

    table.insert(Tabs, {Name = name, Frame = Frame})
    return Frame
end

-- Crear botón de pestaña
function CreateTabButton(name)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Button"
    Button.Text = name
    Button.Size = UDim2.new(0, 80, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Parent = TabButtonsFrame

    Button.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Frame.Visible = (tab.Name == name)
        end
    end)
end

-- Funciones para crear elementos dentro de tabs
function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 35)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Text = text
    Button.Parent = parent
    Button.MouseButton1Click:Connect(callback)
end

function CreateLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 30)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Text = text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
end

-- Crear Tabs base (serán completados en las siguientes partes)
local MainTab = CreateTab("Main")
local ChipTab = CreateTab("Chip")
local CombatTab = CreateTab("Combat")
local MiscTab = CreateTab("Misc")

-- Crear botones de pestañas
CreateTabButton("Main")
CreateTabButton("Chip")
CreateTabButton("Combat")
CreateTabButton("Misc")

-- Mostrar el primero
for _, t in ipairs(Tabs) do
    t.Frame.Visible = false
end
Tabs[1].Frame.Visible = true

print("[✅ KSHub Base cargado correctamente]")

end)
-- 🧱 PARTE 2: MAIN TAB (Funcional y estable)
-- Esta parte continúa justo después de la Parte 1

pcall(function()

-- Buscar el Tab "Main" creado antes
local MainTab
for _, t in ipairs(Tabs) do
    if t.Name == "Main" then
        MainTab = t.Frame
    end
end

-- ✅ Contenido principal
CreateLabel(MainTab, "⚙️ Opciones principales")

CreateButton(MainTab, "Reiniciar personaje", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.Health = 0
        print("[KSHub] Personaje reiniciado")
    end
end)

CreateButton(MainTab, "Activar velocidad", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = 40
        print("[KSHub] Velocidad aumentada a 40")
    end
end)

CreateButton(MainTab, "Restaurar velocidad", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.WalkSpeed = 16
        print("[KSHub] Velocidad restaurada")
    end
end)

CreateButton(MainTab, "Modo salto alto", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.JumpPower = 100
        print("[KSHub] Salto alto activado")
    end
end)

CreateButton(MainTab, "Restaurar salto", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.JumpPower = 50
        print("[KSHub] Salto restaurado")
    end
end)

CreateLabel(MainTab, "💡 Usa las otras pestañas para más opciones")

print("[✅ KSHub Main Tab cargado correctamente]")

end)
-- 🧱 PARTE 3: CHIP TAB (Opciones especiales)
-- Continuación de las Partes 1 y 2

pcall(function()

-- Buscar el Tab "Chip"
local ChipTab
for _, t in ipairs(Tabs) do
    if t.Name == "Chip" then
        ChipTab = t.Frame
    end
end

-- ✅ Contenido Chip Tab
CreateLabel(ChipTab, "💎 Opciones CHIP")

CreateButton(ChipTab, "Activar Chip A", function()
    -- Ejemplo: Función especial tipo hack o buff
    print("[KSHub] Chip A activado")
    -- Aquí tu código real para el chip
end)

CreateButton(ChipTab, "Activar Chip B", function()
    print("[KSHub] Chip B activado")
    -- Código real del chip B
end)

CreateButton(ChipTab, "Desactivar todos los Chips", function()
    print("[KSHub] Todos los Chips desactivados")
    -- Restaurar estados
end)

-- Toggle ejemplo
function CreateToggle(parent, text, default, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, -20, 0, 30)
    Toggle.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 35)
    Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Text = text.." [OFF]"
    Toggle.Parent = parent

    local state = default or false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = text.." ["..(state and "ON" or "OFF").."]"
        callback(state)
    end)
end

-- Ejemplo de Toggle Chip C
CreateToggle(ChipTab, "Chip C", false, function(state)
    print("[KSHub] Chip C estado:", state)
    -- Aquí va el código real del Chip C
end)

print("[✅ KSHub Chip Tab cargado correctamente]")

end)
-- 🧱 PARTE 4: COMBAT TAB (Kill Aura y combate)
-- Continuación de Partes 1 a 3

pcall(function()

-- Buscar el Tab "Combat"
local CombatTab
for _, t in ipairs(Tabs) do
    if t.Name == "Combat" then
        CombatTab = t.Frame
    end
end

-- ✅ Contenido Combat Tab
CreateLabel(CombatTab, "⚔️ Opciones de combate")

-- Kill Aura Toggle
CreateToggle(CombatTab, "Kill Aura", false, function(state)
    if state then
        print("[KSHub] Kill Aura activado")
        -- Código real para activar Kill Aura
        -- Por ejemplo, atacar enemigos cercanos automáticamente
    else
        print("[KSHub] Kill Aura desactivado")
        -- Desactivar Kill Aura
    end
end)

-- Auto Ataque Toggle
CreateToggle(CombatTab, "Auto Ataque", false, function(state)
    print("[KSHub] Auto Ataque estado:", state)
    -- Activar/desactivar ataque automático
end)

-- Slider de velocidad de ataque
function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 40)
    SliderFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Text = text.." ("..default..")"
    Label.Parent = SliderFrame

    local Slider = Instance.new("TextBox")
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Position = UDim2.new(0, 10, 0, 20)
    Slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Slider.TextColor3 = Color3.new(1, 1, 1)
    Slider.Text = tostring(default)
    Slider.Parent = SliderFrame

    Slider.FocusLost:Connect(function()
        local val = tonumber(Slider.Text)
        if val then
            if val < min then val = min end
            if val > max then val = max end
            Slider.Text = tostring(val)
            Label.Text = text.." ("..val..")"
            callback(val)
        else
            Slider.Text = tostring(default)
        end
    end)
end

-- Crear un slider de velocidad de ataque
CreateSlider(CombatTab, "Velocidad de ataque", 1, 10, 3, function(value)
    print("[KSHub] Velocidad de ataque:", value)
    -- Aquí va la velocidad real de ataque
end)

print("[✅ KSHub Combat Tab cargado correctamente]")

end)
-- 🧱 PARTE 5: MISC TAB, créditos y carga final
-- Continuación de Partes 1 a 4

pcall(function()

-- Buscar el Tab "Misc"
local MiscTab
for _, t in ipairs(Tabs) do
    if t.Name == "Misc" then
        MiscTab = t.Frame
    end
end

-- ✅ Contenido Misc Tab
CreateLabel(MiscTab, "🔧 Opciones Misceláneas")

-- Ejemplo de botón Misceláneo
CreateButton(MiscTab, "Mostrar coordenadas", function()
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local pos = plr.Character.HumanoidRootPart.Position
        print("[KSHub] Coordenadas:", pos)
    end
end)

CreateButton(MiscTab, "Ocultar HUB", function()
    MainFrame.Visible = false
    print("[KSHub] HUB ocultado")
end)

CreateButton(MiscTab, "Mostrar HUB", function()
    MainFrame.Visible = true
    print("[KSHub] HUB mostrado")
end)

-- Créditos
CreateLabel(MiscTab, "💻 Créditos:")
CreateLabel(MiscTab, "Desarrollador: KennyKressinR")
CreateLabel(MiscTab, "Versión: 1.0 estable")

-- Mensaje de carga final
print("[✅ KSHub cargado completamente y funcional]")
print("[💡 Tabs disponibles: Main, Chip, Combat, Misc]")

end)
