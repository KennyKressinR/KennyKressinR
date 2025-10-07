--========================================================--
-- KS HUB - 99 Noches
-- Main.lua (UI interno sin dependencias externas)
--========================================================--

print("[KS HUB] Iniciando...")

-- === SERVICES ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--========================================================--
-- UI CREATION
--========================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "KS HUB - 99 Noches"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Tabs container
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(0, 150, 1, -40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabButtons.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -150, 1, -40)
ContentFrame.Position = UDim2.new(0, 150, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentFrame.Parent = MainFrame

--========================================================--
-- TAB SYSTEM
--========================================================--
local Tabs = {}
local function CreateTab(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = TabButtons

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = ContentFrame

    Button.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Frame.Visible = false
        end
        TabFrame.Visible = true
        print("[KS HUB] Tab abierto:", name)
    end)

    local tabObj = {Button = Button, Frame = TabFrame}
    table.insert(Tabs, tabObj)
    return TabFrame
end

--========================================================--
-- CREATE ALL TABS
--========================================================--
local mainTab        = CreateTab("Main")
local autofarmTab    = CreateTab("Auto")
local itemtpTab      = CreateTab("Item TP/ESP")
local gametpTab      = CreateTab("Game TP")
local mobtpTab       = CreateTab("Mob TP")
local playerTab      = CreateTab("Player")
local visualsTab     = CreateTab("Visuals")
local miscTab        = CreateTab("Misc")

print("[KS HUB] Tabs creados correctamente.")

--========================================================--
-- MODULE LOADER
--========================================================--
local function LoadModule(name, tab)
    local ok, module = pcall(function()
        return require(script.Modules[name])
    end)
    if ok and module then
        print("[KS HUB] Módulo cargado:", name)
        if module.Init then
            local ok2, err2 = pcall(function()
                module.Init(tab)
            end)
            if ok2 then
                print("[KS HUB] Módulo inicializado:", name)
            else
                warn("[KS HUB] Error inicializando módulo:", name, err2)
            end
        end
    else
        warn("[KS HUB] Error cargando módulo:", name, module)
    end
end

--========================================================--
-- LOAD ALL MODULES
--========================================================--
LoadModule("ItemTP", itemtpTab)
LoadModule("ItemESP", visualsTab)
LoadModule("Teleports", gametpTab)
LoadModule("Player", playerTab)
LoadModule("Visuals", visualsTab)
LoadModule("AutoFarm", autofarmTab)
LoadModule("Stronghold", gametpTab)
LoadModule("Extras", miscTab)

print("[KS HUB] Inicialización completa.")
