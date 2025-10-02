-- KS HUB ALPHA (base) -> KSHUB
-- Ejecutable por loadstring
-- Hecho para ejecutores en Roblox (LocalScript-like)

-- Evitar duplicados
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("KSHUB")
    if existing then existing:Destroy() end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
while not LocalPlayer do wait() end

-- Config inicial
local DEFAULT_BLUE = Color3.fromRGB(0, 85, 170)
local DEFAULT_TRANSPARENCY = 0.25 -- 25%

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHUB"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Ventana principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = DEFAULT_BLUE
MainFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
pcall(function() MainFrame.Draggable = true end) -- Draggable puede no funcionar en todos los entornos
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = DEFAULT_BLUE
Title.BackgroundTransparency = DEFAULT_TRANSPARENCY
Title.BorderSizePixel = 0
Title.Text = "KSHUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Botón cerrar (en el título, a la derecha)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
CloseBtn.BackgroundTransparency = 0.1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

-- Botón para reabrir cuando está cerrado (flotante)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 80, 0, 30)
OpenBtn.Position = UDim2.new(1, -100, 1, -50)
OpenBtn.AnchorPoint = Vector2.new(0,0)
OpenBtn.BackgroundColor3 = DEFAULT_BLUE
OpenBtn.BackgroundTransparency = DEFAULT_TRANSPARENCY
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "KSHUB"
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = Enum.Font.Gotham
OpenBtn.TextSize = 14
OpenBtn.Parent = ScreenGui
OpenBtn.Visible = false

-- Marco de pestañas (lado izquierdo)
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(0,140,1,-40)
TabFrame.Position = UDim2.new(0,0,0,40)
TabFrame.BackgroundColor3 = DEFAULT_BLUE
TabFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

-- Layout vertical para botones de pestaña
local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabFrame
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0,8)

-- Contenedor de páginas (derecha)
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Size = UDim2.new(1,-140,1,-40)
Pages.Position = UDim2.new(0,140,0,40)
Pages.BackgroundColor3 = Color3.fromRGB(20,20,40)
Pages.BackgroundTransparency = 0.35
Pages.BorderSizePixel = 0
Pages.Parent = MainFrame

-- Tabla para mantener páginas y botones
local tabs = {}
local pages = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, 0)
    btn.BackgroundColor3 = DEFAULT_BLUE
    btn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = TabFrame

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1,0,1,0)
    page.Position = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1
    page.Parent = Pages
    page.Visible = false

    tabs[name] = btn
    pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do
            v.Visible = false
        end
        page.Visible = true
    end)

    return page
end

-- Crear pestañas solicitadas
local PrincipalPage = CreateTab("Principal")
local TeleportPage  = CreateTab("Teleport")
local PlayerPage    = CreateTab("Player")
local AjustesPage   = CreateTab("Ajustes")
local InfoPage      = CreateTab("Info")

-- Mostrar Principal por defecto
pages["Principal"].Visible = true

-- === Funciones utilitarias para elementos UI (rápido) ===
local function CreateLabel(parent, text, sizeY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, sizeY or 24)
    lbl.Position = UDim2.new(0,8,0,8 + (#parent:GetChildren() * 2))
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Parent = parent
    return lbl
end

-- === PLAYER PAGE CONTENT ===
do
    local pPage = pages["Player"]

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -16, 0, 22)
    header.Position = UDim2.new(0,8,0,8)
    header.BackgroundTransparency = 1
    header.Text = "Player - Ajustes"
    header.TextColor3 = Color3.new(1,1,1)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.Parent = pPage

    -- Subframe para WalkSpeed (botones horizontal)
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -16, 0, 48)
    speedFrame.Position = UDim2.new(0,8,0,40)
    speedFrame.BackgroundTransparency = 1
    speedFrame.Parent = pPage

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1,0,0,18)
    speedLabel.Position = UDim2.new(0,0,0,0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Velocidad (WalkSpeed):"
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Color3.new(1,1,1)
    speedLabel.Parent = speedFrame

    local speedButtonsFrame = Instance.new("Frame")
    speedButtonsFrame.Size = UDim2.new(1,0,0,28)
    speedButtonsFrame.Position = UDim2.new(0,0,0,20)
    speedButtonsFrame.BackgroundTransparency = 1
    speedButtonsFrame.Parent = speedFrame

    local speedLayout = Instance.new("UIListLayout")
    speedLayout.Parent = speedButtonsFrame
    speedLayout.FillDirection = Enum.FillDirection.Horizontal
    speedLayout.SortOrder = Enum.SortOrder.LayoutOrder
    speedLayout.Padding = UDim.new(0,6)

    local function makeSpeedButton(text, speedValue)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 84, 1, 0)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = speedButtonsFrame
        b.MouseButton1Click:Connect(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                pcall(function() humanoid.WalkSpeed = speedValue end)
            end
        end)
        return b
    end

    -- Guardar valores: Normal será el WalkSpeed actual al momento de ejecutar
    local function getDefaultWalkSpeed()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if h and h.WalkSpeed then return h.WalkSpeed end
        end
        return 16
    end
    local defaultWalkSpeed = getDefaultWalkSpeed()

    -- Crear botones (lado a lado)
    makeSpeedButton("Normal", defaultWalkSpeed)
    makeSpeedButton("25", 25)
    makeSpeedButton("50", 50)
    makeSpeedButton("100", 100)
    makeSpeedButton("200", 200)

    -- JumpPower (impulso de salto)
    local jumpFrame = Instance.new("Frame")
    jumpFrame.Size = UDim2.new(1, -16, 0, 48)
    jumpFrame.Position = UDim2.new(0,8,0,100)
    jumpFrame.BackgroundTransparency = 1
    jumpFrame.Parent = pPage

    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(1,0,0,18)
    jumpLabel.Position = UDim2.new(0,0,0,0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Impulso de salto (JumpPower):"
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextSize = 14
    jumpLabel.TextColor3 = Color3.new(1,1,1)
    jumpLabel.Parent = jumpFrame

    local jumpButtonsFrame = Instance.new("Frame")
    jumpButtonsFrame.Size = UDim2.new(1,0,0,28)
    jumpButtonsFrame.Position = UDim2.new(0,0,0,20)
    jumpButtonsFrame.BackgroundTransparency = 1
    jumpButtonsFrame.Parent = jumpFrame

    local jumpLayout = Instance.new("UIListLayout")
    jumpLayout.Parent = jumpButtonsFrame
    jumpLayout.FillDirection = Enum.FillDirection.Horizontal
    jumpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    jumpLayout.Padding = UDim.new(0,6)

    local function getDefaultJumpPower()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if h and h.JumpPower then return h.JumpPower end
        end
        return 50
    end
    local defaultJump = getDefaultJumpPower()

    local function makeJumpButton(text, factor) -- factor: multiplier (1 = normal)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 120, 1, 0)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = jumpButtonsFrame
        b.MouseButton1Click:Connect(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                local target = math.floor(defaultJump * factor)
                pcall(function() humanoid.JumpPower = target end)
            end
        end)
        return b
    end

    -- Normal(predet), +50%, +100%, +200%
    makeJumpButton("Normal (predet)", 1)
    makeJumpButton("+50%", 1.5)
    makeJumpButton("+100%", 2)
    makeJumpButton("+200%", 3)

    -- Noclip toggle
    local noclipState = false
    local noclipConn = nil
    local savedCanCollide = {} -- map part -> original cancollide

    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Size = UDim2.new(0, 120, 0, 30)
    noclipBtn.Position = UDim2.new(0, 8, 0, 170)
    noclipBtn.BackgroundColor3 = DEFAULT_BLUE
    noclipBtn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    noclipBtn.BorderSizePixel = 0
    noclipBtn.Font = Enum.Font.Gotham
    noclipBtn.TextSize = 14
    noclipBtn.TextColor3 = Color3.new(1,1,1)
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.Parent = pPage

    local function enableNoclip()
        if noclipState then return end
        noclipState = true
        noclipBtn.Text = "Noclip: ON"
        savedCanCollide = {}
        local function noclipStep()
            local ch = LocalPlayer.Character
            if ch then
                for _, part in pairs(ch:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if savedCanCollide[part] == nil then
                            savedCanCollide[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end
            end
        end
        noclipConn = RunService.Stepped:Connect(noclipStep)
    end

    local function disableNoclip()
        if not noclipState then return end
        noclipState = false
        noclipBtn.Text = "Noclip: OFF"
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        -- Restaurar valores guardados
        for part, original in pairs(savedCanCollide) do
            if part and part.Parent then
                pcall(function() part.CanCollide = original end)
            end
        end
        savedCanCollide = {}
    end

    noclipBtn.MouseButton1Click:Connect(function()
        if noclipState then disableNoclip() else enableNoclip() end
    end)

    -- Reaplicar default values en respawn
    LocalPlayer.CharacterAdded:Connect(function(char)
        wait(0.5)
        defaultWalkSpeed = getDefaultWalkSpeed()
        defaultJump = getDefaultJumpPower()
        if noclipState then
            -- reinstaurar noclip en nuevo character
            enableNoclip()
        end
    end)
end

-- === AJUSTES PAGE CONTENT (transparencias) ===
do
    local aPage = pages["Ajustes"]
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 22)
    label.Position = UDim2.new(0,8,0,8)
    label.BackgroundTransparency = 1
    label.Text = "Ajustes de interfaz"
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = aPage

    local options = {
        {name = "0%", value = 0},
        {name = "25%", value = 0.25},
        {name = "50%", value = 0.5},
        {name = "75%", value = 0.75},
        {name = "90%", value = 0.9},
    }

    local optFrame = Instance.new("Frame")
    optFrame.Size = UDim2.new(1, -16, 0, 40)
    optFrame.Position = UDim2.new(0,8,0,40)
    optFrame.BackgroundTransparency = 1
    optFrame.Parent = aPage

    local optLayout = Instance.new("UIListLayout")
    optLayout.Parent = optFrame
    optLayout.FillDirection = Enum.FillDirection.Horizontal
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Padding = UDim.new(0,8)

    local function applyTransparency(t)
        -- Aplica la transparencia a los elementos principales de la UI
        pcall(function()
            MainFrame.BackgroundTransparency = t
            Title.BackgroundTransparency = t
            TabFrame.BackgroundTransparency = t
            OpenBtn.BackgroundTransparency = t
            -- Pages tiene su propio fondo semitransparente, ajustamos proporcionalmente
            if Pages then
                Pages.BackgroundTransparency = math.clamp(t + 0.1, 0, 1)
            end
            -- Además ajustar todos los botones (opcionales): recorremos TabFrame y Pages
            for _, v in pairs(TabFrame:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("TextLabel") then
                    -- no tocar transparencia de texto, solo fondo
                    if v.BackgroundTransparency ~= 1 then
                        v.BackgroundTransparency = t
                    end
                end
            end
        end)
    end

    for _, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 84, 1, 0)
        b.BackgroundColor3 = DEFAULT_BLUE
        b.BackgroundTransparency = DEFAULT_TRANSPARENCY
        b.BorderSizePixel = 0
        b.Text = opt.name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.Parent = optFrame
        b.MouseButton1Click:Connect(function()
            applyTransparency(opt.value)
        end)
    end
end

-- === INFO PAGE CONTENT ===
do
    local iPage = pages["Info"]
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 80)
    label.Position = UDim2.new(0,8,0,8)
    label.BackgroundTransparency = 1
    label.Text = "KSHUB - KS HUB ALPHA (base)\nInterfaz azul con transparencia ajustable.\nPestañas: Principal, Teleport, Player, Ajustes, Info"
    label.TextColor3 = Color3.new(1,1,1)
    label.TextWrapped = true
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = iPage
end

-- === Teleport (placeholder) y Principal (placeholder) ===
do
    local pp = pages["Principal"]
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -16, 0, 40)
    t.Position = UDim2.new(0,8,0,8)
    t.BackgroundTransparency = 1
    t.Text = "Bienvenido a KSHUB - Principal"
    t.TextColor3 = Color3.new(1,1,1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 18
    t.Parent = pp

    local tp = pages["Teleport"]
    local tpLabel = Instance.new("TextLabel")
    tpLabel.Size = UDim2.new(1, -16, 0, 40)
    tpLabel.Position = UDim2.new(0,8,0,8)
    tpLabel.BackgroundTransparency = 1
    tpLabel.Text = "Teleport: Añade aquí tus botones de teletransporte."
    tpLabel.TextColor3 = Color3.new(1,1,1)
    tpLabel.Font = Enum.Font.Gotham
    tpLabel.TextSize = 14
    tpLabel.Parent = tp
end

-- === Botones cerrar / abrir funcionalidad ===
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- Inicializar transparencia por defecto
do
    MainFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
    Title.BackgroundTransparency = DEFAULT_TRANSPARENCY
    TabFrame.BackgroundTransparency = DEFAULT_TRANSPARENCY
    OpenBtn.BackgroundTransparency = DEFAULT_TRANSPARENCY
    Pages.BackgroundTransparency = math.clamp(DEFAULT_TRANSPARENCY + 0.1, 0, 1)
end

-- Mensaje en consola para confirmar carga
pcall(function() print("[KSHUB] cargado correctamente.") end)
