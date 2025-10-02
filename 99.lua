-- 99 Noches HUB Modular Avanzado
-- Script reestructurado por Fernando + GPT
-- Minimalista, azul, prolijo, transparente y modular

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- ===========================
-- Configuración HUB
-- ===========================
local HUB_COLOR = Color3.fromRGB(0, 120, 255) -- azul
local HUB_TRANSPARENCY = 0.25
local WINDOW_NORMAL_SIZE = UDim2.new(0, 400, 0, 300)
local WINDOW_LARGE_SIZE = UDim2.new(0, 700, 0, 500)

-- ===========================
-- Crear GUI
-- ===========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NochesHub"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Botón abrir/cerrar
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.Text = "Abrir Hub"
ToggleButton.BackgroundColor3 = HUB_COLOR
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.TextSize = 18
ToggleButton.Parent = ScreenGui

-- Marco principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = WINDOW_NORMAL_SIZE
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = HUB_COLOR
MainFrame.BackgroundTransparency = HUB_TRANSPARENCY
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = HUB_COLOR
Title.BackgroundTransparency = HUB_TRANSPARENCY
Title.Text = "99 Noches Hub"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Botón cerrar
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 60, 0, 25)
CloseButton.Position = UDim2.new(1, -70, 0, 7)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Text = "Abrir Hub"
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleButton.Text = MainFrame.Visible and "Cerrar Hub" or "Abrir Hub"
end)

-- ===========================
-- Pestañas
-- ===========================
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 120, 1, -40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundColor3 = HUB_COLOR
TabsFrame.BackgroundTransparency = HUB_TRANSPARENCY
TabsFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
ContentFrame.Parent = MainFrame

local TabNames = {"Main","Player","Teleports","Bring Items","ESP","Settings"}
local TabFrames = {}
local CurrentTab = nil

for i, name in ipairs(TabNames) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.Position = UDim2.new(0, 0, 0, (i-1)*42)
    Button.BackgroundColor3 = HUB_COLOR
    Button.BackgroundTransparency = HUB_TRANSPARENCY
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 18
    Button.Parent = TabsFrame

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.CanvasSize = UDim2.new(0,0,0,600)
    TabContent.Visible = false
    TabContent.Parent = ContentFrame

    TabFrames[name] = TabContent

    Button.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Visible = false end
        TabContent.Visible = true
        CurrentTab = TabContent
    end)
end
TabFrames["Main"].Visible = true
CurrentTab = TabFrames["Main"]

-- ===========================
-- Funciones base
-- ===========================
local function DragItem(Item)
    ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(Item)
    wait(0.00001)
    ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(Item)
end

local function TeleportTo(Position)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(Position)
    end
end

local function ToggleNoclip(Enable)
    if not Player.Character then return end
    for _, part in pairs(Player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not Enable
        end
    end
end

-- ===========================
-- Fly
-- ===========================
local FLYING = false
local iyflyspeed = 1
local flyControl = {F=0,B=0,L=0,R=0,Q=0,E=0}
local flyKeyDown, flyKeyUp

local function StartFly()
    repeat wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChildOfClass("Humanoid")
    local T = Player.Character.HumanoidRootPart

    local BG = Instance.new('BodyGyro', T)
    BG.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BG.P = 9e4
    local BV = Instance.new('BodyVelocity', T)
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)

    FLYING = true
    flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then flyControl.F = iyflyspeed end
        if input.KeyCode == Enum.KeyCode.S then flyControl.B = -iyflyspeed end
        if input.KeyCode == Enum.KeyCode.A then flyControl.L = -iyflyspeed end
        if input.KeyCode == Enum.KeyCode.D then flyControl.R = iyflyspeed end
        if input.KeyCode == Enum.KeyCode.E then flyControl.Q = iyflyspeed*2 end
        if input.KeyCode == Enum.KeyCode.Q then flyControl.E = -iyflyspeed*2 end
    end)
    flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.W then flyControl.F = 0 end
        if input.KeyCode == Enum.KeyCode.S then flyControl.B = 0 end
        if input.KeyCode == Enum.KeyCode.A then flyControl.L = 0 end
        if input.KeyCode == Enum.KeyCode.D then flyControl.R = 0 end
        if input.KeyCode == Enum.KeyCode.E then flyControl.Q = 0 end
        if input.KeyCode == Enum.KeyCode.Q then flyControl.E = 0 end
    end)

    RunService.RenderStepped:Connect(function()
        if not FLYING then return end
        BV.Velocity = (workspace.CurrentCamera.CFrame.LookVector*(flyControl.F+flyControl.B) + workspace.CurrentCamera.CFrame.RightVector*(flyControl.R+flyControl.L) + Vector3.new(0,(flyControl.Q+flyControl.E),0))*50
        BG.CFrame = workspace.CurrentCamera.CFrame
    end)
end

local function StopFly()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
end

-- ===========================
-- Infinite Jump
-- ===========================
local InfiniteJumpActive = false
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpActive and Player.Character then
        local h = Player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ===========================
-- ESP
-- ===========================
local ActiveEspItems, ActiveEspEnemy, ActiveEspChildren, ActiveEspPeltTrader, ActiveDistanceEsp = false,false,false,false,false

local function CreateEsp(Char, Color, Text, Parent, Offset)
    if not Char then return end
    if Char:FindFirstChild("ESP") and Char:FindFirstChildOfClass("Highlight") then return end
    local highlight = Char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = Char

    local billboard = Char:FindFirstChild("ESP") or Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0,50,0,25)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0,Offset,0)
    billboard.Adornee = Parent
    billboard.Parent = Parent

    local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = Text
    label.TextColor3 = Color
    label.TextScaled = true
    label.Parent = billboard

    RunService.RenderStepped:Connect(function()
        if Parent and label and ActiveDistanceEsp then
            local dist = (workspace.CurrentCamera.CFrame.Position - Parent.Position).Magnitude
            label.Text = Text.." ("..math.floor(dist + 0.5).." m)"
        end
    end)
end

-- ===========================
-- Pestaña Player
-- ===========================
-- Noclip
local NoclipToggle = Instance.new("TextButton")
NoclipToggle.Size = UDim2.new(0,200,0,40)
NoclipToggle.Position = UDim2.new(0,10,0,10)
NoclipToggle.Text = "Noclip: OFF"
NoclipToggle.TextColor3 = Color3.fromRGB(255,255,255)
NoclipToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
NoclipToggle.Parent = TabFrames["Player"]

local NoclipActive = false
NoclipToggle.MouseButton1Click:Connect(function()
    NoclipActive = not NoclipActive
    NoclipToggle.Text = NoclipActive and "Noclip: ON" or "Noclip: OFF"
    ToggleNoclip(NoclipActive)
end)

-- Fly
local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0,200,0,40)
FlyToggle.Position = UDim2.new(0,10,0,60)
FlyToggle.Text = "Fly: OFF"
FlyToggle.TextColor3 = Color3.fromRGB(255,255,255)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
FlyToggle.Parent = TabFrames["Player"]

local FlyActive = false
FlyToggle.MouseButton1Click:Connect(function()
    FlyActive = not FlyActive
    FlyToggle.Text = FlyActive and "
