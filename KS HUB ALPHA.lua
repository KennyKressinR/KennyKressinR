-- KS HUB Reescrito desde cero
-- Autor: Reorganizado por Copilot
-- Versión: Limpia, modular, con interfaz mejorada

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Crear GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "KS HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = MainFrame

-- Contenedor de botones
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, -40, 1, -60)
ButtonContainer.Position = UDim2.new(0, 20, 0, 60)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

-- Función para crear botones
local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 18
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Parent = ButtonContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
end

-- Teleport al mouse
local function teleportToMouse()
    if Mouse.Hit then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
        end
    end
end

-- Noclip toggle
local noclip = false
local noclipConnection

local function toggleNoclip()
    noclip = not noclip
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end

-- Guardar/Cargar posición
local savedPosition

local function savePosition()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        savedPosition = root.CFrame
    end
end

local function loadPosition()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and savedPosition then
        root.CFrame = savedPosition
    end
end

-- Anti-delay para ProximityPrompt
local antiDelay = false
local originalDurations = {}

local function toggleAntiDelay()
    antiDelay = not antiDelay
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if antiDelay then
                originalDurations[prompt] = prompt.HoldDuration
                prompt.HoldDuration = 0
            else
                if originalDurations[prompt] then
                    prompt.HoldDuration = originalDurations[prompt]
                end
            end
        end
    end
end

createButton("Teleport al Mouse", teleportToMouse)
createButton("Toggle Noclip", toggleNoclip)
createButton("Guardar Posición", savePosition)
createButton("Cargar Posición", loadPosition)
createButton("Toggle Anti-Delay", toggleAntiDelay)

MainFrame.Visible = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)



