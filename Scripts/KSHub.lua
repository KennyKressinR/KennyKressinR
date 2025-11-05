--========================================================
-- KS HUB (Completo, Reorganizado y Funcional)
--========================================================

-- UI library (Rayfield). Cámbialo si usas otra.
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Servicios y referencias
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Estado global
local State = {
    FarmEnabled = false,
    FarmMode = "Rápido",
    ESPEnabled = false,
    HitboxEnabled = false,
    NightEnabled = false,
    ChamsEnabled = false,
    TracersEnabled = false,
    FlyEnabled = false,
    NoclipEnabled = false,
    Spectating = nil,
    Automatizacion = false,          -- Botón maestro
    AutoDelay = 0.5                  -- Delay entre interacciones automáticas
}

--========================================================
-- Ventana
--========================================================
local Window = Rayfield:CreateWindow({
    Name = "KS HUB",
    LoadingTitle = "KS HUB",
    LoadingSubtitle = "by KennyKressinR",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KS_HUB",
        FileName = "Config"
    }
})

--========================================================
-- MAIN TAB
--========================================================
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://123456" })

----------------------------------------------------------
-- Sección: Jugador
----------------------------------------------------------
MainTab:AddSection({ Name = "Jugador" })

local SelectedPlayer = nil
local PlayerDropdown = MainTab:AddDropdown({
    Name = "Seleccionar jugador",
    Options = {},
    Default = "",
    Callback = function(value)
        SelectedPlayer = Players:FindFirstChild(value)
    end
})

local function refreshPlayerDropdown()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    PlayerDropdown:Set(names)
    if SelectedPlayer and not table.find(names, SelectedPlayer.Name) then
        SelectedPlayer = nil
    end
end

refreshPlayerDropdown()
Players.PlayerAdded:Connect(refreshPlayerDropdown)
Players.PlayerRemoving:Connect(refreshPlayerDropdown)

MainTab:AddButton({
    Name = "Teleport a jugador",
    Callback = function()
        if not SelectedPlayer then return end
        local targetChar = SelectedPlayer.Character
        local hrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local myHrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHrp then
            myHrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 3)
        end
    end
})

MainTab:AddButton({
    Name = "Espectar jugador (toggle)",
    Callback = function()
        if State.Spectating then
            workspace.CurrentCamera.CameraSubject = Humanoid
            State.Spectating = nil
            return
        end
        if not SelectedPlayer then return end
        local targetHum = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHum then
            workspace.CurrentCamera.CameraSubject = targetHum
            State.Spectating = SelectedPlayer
        end
    end
})

MainTab:AddButton({
    Name = "Copiar nombre seleccionado",
    Callback = function()
        if SelectedPlayer then
            if setclipboard then setclipboard(SelectedPlayer.Name) end
            StarterGui:SetCore("SendNotification", {
                Title = "KS HUB",
                Text = "Nombre copiado: " .. SelectedPlayer.Name,
                Duration = 2
            })
        end
    end
})

-- Lista de jugadores con scroll
MainTab:AddButton({
    Name = "Lista de jugadores (scroll)",
    Callback = function()
        local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("KS_PlayerList")
        if existing then existing:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "KS_PlayerList"
        gui.ResetOnSpawn = false
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 240, 0, 320)
        frame.Position = UDim2.new(0, 20, 0, 80)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 30)
        title.Position = UDim2.new(0, 5, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "Jugadores"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.Parent = frame

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -50)
        scroll.Position = UDim2.new(0, 5, 0, 40)
        scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Parent = frame

        local layout = Instance.new("UIListLayout")
        layout.Parent = scroll
        layout.Padding = UDim.new(0, 4)
        layout.SortOrder = Enum.SortOrder.Name

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
        end)

        local function addButton(plr)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = plr.Name
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = plr
                StarterGui:SetCore("SendNotification", {
                    Title = "KS HUB",
                    Text = "Seleccionado: " .. plr.Name,
                    Duration = 2
                })
            end)
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            addButton(plr)
        end
        Players.PlayerAdded:Connect(addButton)
        Players.PlayerRemoving:Connect(function(plr)
            for _, child in ipairs(scroll:GetChildren()) do
                if child:IsA("TextButton") and child.Text == plr.Name then
                    child:Destroy()
                end
            end
        end)
    end
})

----------------------------------------------------------
-- Sección: Juego
----------------------------------------------------------
MainTab:AddSection({ Name = "Juego" })

MainTab:AddSlider({
    Name = "Velocidad",
    Min = 16, Max = 200, Default = 16,
    Callback = function(val)
        if Humanoid then Humanoid.WalkSpeed = val end
    end
})

MainTab:AddSlider({
    Name = "Salto",
    Min = 50, Max = 500, Default = 50,
    Callback = function(val)
        if Humanoid then Humanoid.JumpPower = val end
    end
})

-- Botón maestro: AUTOMATIZACIÓN
MainTab:AddToggle({
    Name = "AUTOMATIZACIÓN",
    Default = false,
    Callback = function(state)
        State.Automatizacion = state
        if state then
            StarterGui:SetCore("SendNotification", {
                Title = "KS HUB",
                Text = "Automatización activada",
                Duration = 2
            })
            task.spawn(function()
                while State.Automatizacion do
                    task.wait(State.AutoDelay)

                    -- 1) ClickDetector
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("ClickDetector") then
                            pcall(function() fireclickdetector(obj) end)
                        end
                    end

                    -- 2) ProximityPrompt
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            -- Acercarse si es necesario
                            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
                            local parent = prompt.Parent
                            if hrp and parent and parent:IsA("BasePart") then
                                if (hrp.Position - parent.Position).Magnitude > prompt.MaxActivationDistance - 1 then
                                    hrp.CFrame = parent.CFrame + Vector3.new(0, 2, 0)
                                end
                            end
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end

                    -- 3) TouchInterest (monedas/drops/orbes)
                    for _, part in ipairs(workspace:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChild("TouchInterest") then
                            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end)
        else
            StarterGui:SetCore("SendNotification", {
                Title = "KS HUB",
                Text = "Automatización desactivada",
                Duration = 2
            })
        end
    end
})

MainTab:AddDropdown({
    Name = "Modo de Farm",
    Options = {"Rápido", "Seguro", "Por Zona"},
    Default = "Rápido",
    Callback = function(mode)
        State.FarmMode = mode
    end
})

MainTab:AddToggle({
    Name = "Auto-Farm (básico)",
    Default = false,
    Callback = function(state)
        State.FarmEnabled = state
    end
})

MainTab:AddButton({
    Name = "Farmear Recompensas",
    Callback = function()
        print("[KS HUB] Farmear Recompensas - modo:", State.FarmMode)
        -- Inserta tu lógica específica de juego aquí
    end
})

MainTab:AddButton({
    Name = "Farmear Monedas",
    Callback = function()
        print("[KS HUB] Farmear Monedas - modo:", State.FarmMode)
        -- Inserta tu lógica específica de juego aquí
    end
})

----------------------------------------------------------
-- Sección: Utilidades
----------------------------------------------------------
MainTab:AddSection({ Name = "Utilidades" })

MainTab:AddButton({
    Name = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

MainTab:AddButton({
    Name = "Resetear personaje",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
})

MainTab:AddButton({
    Name = "Abrir consola",
    Callback = function()
        StarterGui:SetCore("DevConsoleVisible", true)
    end
})

MainTab:AddButton({
    Name = "Refrescar HUB",
    Callback = function()
        Rayfield:Destroy()
        task.wait(0.2)
        StarterGui:SetCore("SendNotification", {
            Title = "KS HUB",
            Text = "HUB refrescado (re-ejecuta el loader)",
            Duration = 2
        })
    end
})

MainTab:AddButton({
    Name = "Copiar Discord",
    Callback = function()
        local invite = "discord.gg/ks-hub" -- Actualiza con tu enlace real
        if setclipboard then setclipboard(invite) end
        StarterGui:SetCore("SendNotification", {
            Title = "KS HUB",
            Text = "Discord copiado al portapapeles",
            Duration = 2
        })
    end
})

MainTab:AddButton({
    Name = "Guardar configuración",
    Callback = function()
        Rayfield:SaveConfiguration()
        StarterGui:SetCore("SendNotification", {
            Title = "KS HUB",
            Text = "Configuración guardada",
            Duration = 2
        })
    end
})

MainTab:AddButton({
    Name = "Cargar configuración",
    Callback = function()
        Rayfield:LoadConfiguration()
        StarterGui:SetCore("SendNotification", {
            Title = "KS HUB",
            Text = "Configuración cargada",
            Duration = 2
        })
    end
})

----------------------------------------------------------
-- Sección: Visual
----------------------------------------------------------
MainTab:AddSection({ Name = "Visual" })

local Highlights = {}

local function applyHighlight(plr, enabled)
    local char = plr.Character
    if not char then return end
    if enabled then
        if not Highlights[plr] then
            local h = Instance.new("Highlight")
            h.FillTransparency = 0.7
            h.FillColor = Color3.fromRGB(0, 170, 255)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.Parent = char
            Highlights[plr] = h
        end
    else
        if Highlights[plr] then
            Highlights[plr]:Destroy()
            Highlights[plr] = nil
        end
    end
end

MainTab:AddToggle({
    Name = "ESP Jugadores",
    Default = false,
    Callback = function(state)
        State.ESPEnabled = state
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                applyHighlight(plr, state)
            end
        end
    end
})

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if State.ESPEnabled and plr ~= LocalPlayer then
            task.wait(0.2)
            applyHighlight(plr, true)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if Highlights[plr] then
        Highlights[plr]:Destroy()
        Highlights[plr] = nil
    end
end)

MainTab:AddToggle({
    Name = "Mostrar Hitbox",
    Default = false,
    Callback = function(state)
        State.HitboxEnabled = state
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then
                    hrp.Transparency = 0.6
                    hrp.Color = Color3.fromRGB(255, 170, 0)
                else
                    hrp.Transparency = 1
                    hrp.Color = Color3.fromRGB(163, 162, 165)
                end
            end
        end
    end
})

MainTab:AddToggle({
    Name = "Night Mode",
    Default = false,
    Callback = function(state)
        State.NightEnabled = state
        if state then
            Lighting.ClockTime = 0
            Lighting.Brightness = 1
        else
            Lighting.ClockTime = 14
            Lighting.Brightness = 2
        end
    end
})

MainTab:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(state)
        State.ChamsEnabled = state
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = state and Enum.Material.ForceField or Enum.Material.Plastic
                    end
                end
            end
        end
    end
})

MainTab:AddToggle({
    Name = "Tracer Lines",
    Default = false,
    Callback = function(state)
        State.TracersEnabled = state
        -- Placeholder: implementa con Drawing API si tu ejecutor lo permite
        print("[KS HUB] Tracers:", state)
    end
})

----------------------------------------------------------
-- Sección: Scripts Extras
----------------------------------------------------------
MainTab:AddSection({ Name = "Scripts Extras" })

-- Fly suave
local flyConn
MainTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(state)
        State.FlyEnabled = state
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if state then
            if Humanoid then Humanoid.PlatformStand = true end
            flyConn = RunService.RenderStepped:Connect(function()
                if not hrp then return end
                local cam = workspace.CurrentCamera
                hrp.Velocity = cam.CFrame.LookVector * 50
            end)
        else
            if Humanoid then Humanoid.PlatformStand = false end
            if flyConn then flyConn:Disconnect() flyConn = nil end
            if hrp then hrp.Velocity = Vector3.zero end
        end
    end
})

-- Noclip simple
local noclipConn
MainTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        State.NoclipEnabled = state
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

-- Aim assist (orienta cámara a Head del seleccionado)
MainTab:AddToggle({
    Name = "Aimbot (asistencia cámara)",
    Default = false,
    Callback = function(state)
        if state then
            RunService:BindToRenderStep("KS_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
                if SelectedPlayer and SelectedPlayer.Character then
                    local head = SelectedPlayer.Character:FindFirstChild("Head")
                    if head then
                        local cam = workspace.CurrentCamera
                        cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position)
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("KS_Aimbot")
        end
    end
})

----------------------------------------------------------
-- Créditos
----------------------------------------------------------
MainTab:AddSection({ Name = "Créditos" })
MainTab:AddLabel("KS HUB - KennyKressinR")

--========================================================
-- QoL: re-sincronización
--========================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
end)

-- Opcional: ajuste de delay para la automatización
MainTab:AddSlider({
    Name = "Delay de automatización (segundos)",
    Min = 0.1, Max = 2, Default = State.AutoDelay,
    Callback = function(val)
        State.AutoDelay = math.max(0.1, val)
    end
})
