--// KSHUB UI Library (desde cero)
--// Autor: Scanny (adaptación)

-- Crear ScreenGui
local KSHUB = Instance.new("ScreenGui")
KSHUB.Name = "KSHUB"
KSHUB.Parent = game:GetService("CoreGui")

-- Ventana principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 85, 170) -- Azul
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = KSHUB

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 60, 140)
Title.BackgroundTransparency = 0.25
Title.Text = "KSHUB"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Pestañas (Botonera lateral)
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0,120,1,-40)
TabFrame.Position = UDim2.new(0,0,0,40)
TabFrame.BackgroundColor3 = Color3.fromRGB(0,60,120)
TabFrame.BackgroundTransparency = 0.25
TabFrame.Parent = MainFrame

-- Contenido de pestañas
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1,-120,1,-40)
Pages.Position = UDim2.new(0,120,0,40)
Pages.BackgroundColor3 = Color3.fromRGB(20,20,40)
Pages.BackgroundTransparency = 0.35
Pages.Parent = MainFrame

-- Función para crear botones de pestañas
local function CreateTab(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.Position = UDim2.new(0,5,0,#TabFrame:GetChildren()*35)
    Button.BackgroundColor3 = Color3.fromRGB(0,85,170)
    Button.BackgroundTransparency = 0.25
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = TabFrame

    -- Página correspondiente
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Pages

    -- Al presionar el botón, mostrar esa pestaña
    Button.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do
            p.Visible = false
        end
        Page.Visible = true
    end)

    return Page
end

-- Crear pestañas
local PrincipalPage = CreateTab("Principal")
local TeleportPage = CreateTab("Teleport")
local PlayerPage   = CreateTab("Player")
local AjustesPage  = CreateTab("Ajustes")
local InfoPage     = CreateTab("Info")

-- Ejemplo de contenido en "Info"
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1,0,0,40)
InfoLabel.Text = "KSHUB v1.0 - UI personalizada"
InfoLabel.TextColor3 = Color3.fromRGB(255,255,255)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 16
InfoLabel.BackgroundTransparency = 1
InfoLabel.Parent = InfoPage

-- Mostrar por defecto "Principal"
PrincipalPage.Visible = true
