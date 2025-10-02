-- KS HUB v0.2.x - Actualizado
-- Pegar como LocalScript en StarterPlayerScripts

-- ===== Servicios =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Estado =====
local hub = {
    noclip = false,
    antiVoid = false,
    highlights = false,
    fullbright = false,
    instantInteract = false,
    savedWaypoints = {},
    highlightObjects = {},
    toolHighlights = {},
    origCanCollide = {},
    origLighting = {},
    origPromptDurations = {},
    rtxEnabled = false,
    rtxObjects = {}
}

-- ===== Refs personaje =====
local character, humanoid, hrp
local function setCharRefs()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
    hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
    hub.baseWalkSpeed = humanoid and humanoid.WalkSpeed or 16
    hub.baseJumpPower = humanoid and humanoid.JumpPower or 50
end
setCharRefs()
player.CharacterAdded:Connect(function() wait(0.1) setCharRefs() end)

-- ===== Helpers =====
local function new(class, props)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k] = v end end
    return o
end

local function safePcall(fn,...)
    local ok, a = pcall(fn, ...)
    return ok, a
end

-- ===== UI - tamaño mayor y transparencia por defecto 75% =====
local MAIN_COLOR = Color3.fromRGB(0,102,204)
local BTN_COLOR = Color3.fromRGB(102,204,255)

local screenGui = new("ScreenGui",{Name="KSHub",ResetOnSpawn=false,Parent=playerGui})
local main = new("Frame",{
    Name="Main",
    Size=UDim2.new(0,340,0,620),            -- MÁS ALTO para más contenido
    Position=UDim2.new(0.5,0,0.5,0),
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=MAIN_COLOR,
    BorderSizePixel=0,
    BackgroundTransparency = 0.75,          -- Transparencia por defecto 75%
    Parent=screenGui
})

-- Header + drag + close/toggle
local header = new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(0,76,153),Parent=main})
local title = new("TextLabel",{Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text="KS HUB v0.2.x",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.SourceSansBold,TextSize=18,Parent=header})
local closeBtn = new("TextButton",{Size=UDim2.new(0,54,1,0),Position=UDim2.new(1,-54,0,0),BackgroundColor3=BTN_COLOR,Text="X",Font=Enum.Font.SourceSansBold,TextSize=16,Parent=header})
local toggleBtn = new("TextButton",{Name="ToggleOpen",Size=UDim2.new(0,64,0,30),Position=UDim2.new(0,8,0,8),BackgroundColor3=BTN_COLOR,Text="KS",Font=Enum.Font.SourceSansBold,TextSize=16,Parent=screenGui,Visible=false})

-- Tabs y scrolls (ajustados al nuevo tamaño)
local tabBar = new("Frame",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,38),BackgroundTransparency=1,Parent=main})
local tabs = {"Principal","Visuales","Ajustes"}
local tabButtons = {}
local scrolls = {}
local contents = {}
for i,name in ipairs(tabs) do
    local btn = new("TextButton",{Size=UDim2.new(1/#tabs,-4,1,0),Position=UDim2.new((i-1)/#tabs,2,0,0),BackgroundColor3=BTN_COLOR,Text=name,Font=Enum.Font.SourceSansBold,TextSize=14,Parent=tabBar})
    tabButtons[i] = btn

    local scroll = new("ScrollingFrame",{Name=name.."Scroll",Size=UDim2.new(1,-12,1,-120),Position=UDim2.new(0,6,0,78),BackgroundTransparency=1,ScrollBarThickness=8,Parent=main,Visible=(i==1)})
    local content = new("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,Parent=scroll})
    local layout = new("UIListLayout",{Parent=content,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
    local pad = new("UIPadding",{Parent=content,PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
    end)
    scrolls[i] = scroll
    contents[i] = content
end
for i,btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for j,s in ipairs(scrolls) do s.Visible = (i==j) end
    end)
end

-- Drag header
do
    local dragging, dragStart, startPos = false, Vector2.new(), main.Position
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Close / toggle
closeBtn.MouseButton1Click:Connect(function() main.Visible = false toggleBtn.Visible = true end)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = true toggleBtn.Visible = false end)

-- Pequeños creadores (botones compactos)
local function addLabel(parent, txt)
    return new("TextLabel",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=txt,TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.SourceSansBold,TextSize=14,Parent=parent})
end
local function addBtn(parent, txt)
    return new("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=BTN_COLOR,Text=txt,Font=Enum.Font.SourceSansBold,TextSize=14,Parent=parent})
end
local function addBox(parent, placeholder)
    return new("TextBox",{Size=UDim2.new(1,0,0,26),BackgroundColor3=Color3.fromRGB(245,245,245),Text="",PlaceholderText=placeholder,Font=Enum.Font.SourceSans,TextSize=14,TextColor3=Color3.new(0,0,0),Parent=parent})
end

-- ===== Contenido: Principal (TP arriba para accesibilidad) =====
local principal = contents[1]
addLabel(principal,"Principal - Funciones")

-- Teleport a jugador (arriba)
addLabel(principal,"Teleport a jugador (nombre parcial)")
local tpBox = addBox(principal,"Nombre parcial")
local tpBtn = addBtn(principal,"TP")
tpBtn.MouseButton1Click:Connect(function()
    local q = (tpBox.Text or ""):lower():gsub("%s+","")
    if q == "" then return end
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Name:lower():gsub("%s+",""):find(q,1,true) and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() if hrp then hrp.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0) end end)
            break
        end
    end
end)

-- Noclip
local noclipBtn = addBtn(principal,"Activar Noclip")
noclipBtn.MouseButton1Click:Connect(function()
    hub.noclip = not hub.noclip
    noclipBtn.Text = hub.noclip and "Desactivar Noclip" or "Activar Noclip"
    if hub.noclip then
        hub.origCanCollide = {}
        if character then
            for _,p in pairs(character:GetDescendants()) do
                if p:IsA("BasePart") then hub.origCanCollide[p] = p.CanCollide p.CanCollide = false end
            end
        end
    else
        for part,val in pairs(hub.origCanCollide) do if part and part.Parent then pcall(function() part.CanCollide = val end) end end
        hub.origCanCollide = {}
    end
end)

-- InstantInteract (convierte HoldDuration a 0 para ProximityPrompt)
local instantBtn = addBtn(principal,"InstantInteract: OFF")
local function applyInstantToPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if hub.instantInteract then
        if hub.origPromptDurations[prompt] == nil then hub.origPromptDurations[prompt] = prompt.HoldDuration end
        pcall(function() prompt.HoldDuration = 0 end)
    else
        if hub.origPromptDurations[prompt] ~= nil then
            pcall(function() prompt.HoldDuration = hub.origPromptDurations[prompt] end)
            hub.origPromptDurations[prompt] = nil
        end
    end
end
instantBtn.MouseButton1Click:Connect(function()
    hub.instantInteract = not hub.instantInteract
    instantBtn.Text = hub.instantInteract and "InstantInteract: ON" or "InstantInteract: OFF"
    for _,p in ipairs(Workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then applyInstantToPrompt(p) end end
end)
Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then wait(0.05) applyInstantToPrompt(desc) end
end)

-- AntiVoid
local antiVoidBtn = addBtn(principal,"Activar AntiVoid")
antiVoidBtn.MouseButton1Click:Connect(function()
    hub.antiVoid = not hub.antiVoid
    antiVoidBtn.Text = hub.antiVoid and "Desactivar AntiVoid" or "Activar AntiVoid"
end)

-- Waypoints (2)
addLabel(principal,"Waypoints (2)")
local wpSave1 = addBtn(principal,"Save 1")
local wpLoad1 = addBtn(principal,"Load 1")
local wpSave2 = addBtn(principal,"Save 2")
local wpLoad2 = addBtn(principal,"Load 2")
wpSave1.MouseButton1Click:Connect(function() if hrp then hub.savedWaypoints[1] = hrp.CFrame end end)
wpLoad1.MouseButton1Click:Connect(function() if hub.savedWaypoints[1] and hrp then pcall(function() hrp.CFrame = hub.savedWaypoints[1] end) end end)
wpSave2.MouseButton1Click:Connect(function() if hrp then hub.savedWaypoints[2] = hrp.CFrame end end)
wpLoad2.MouseButton1Click:Connect(function() if hub.savedWaypoints[2] and hrp then pcall(function() hrp.CFrame = hub.savedWaypoints[2] end) end end)

-- WalkSpeed (orden mayor->menor)
addLabel(principal,"WalkSpeed Presets")
local wsVals = {200,150,75,50,30}
for _,v in ipairs(wsVals) do
    local b = addBtn(principal,tostring(v))
    b.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.WalkSpeed = v end) end end)
end
local bNormal = addBtn(principal,"Normal")
bNormal.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.WalkSpeed = hub.baseWalkSpeed end) end end)

-- Jump presets
addLabel(principal,"JumpPower Presets")
local jpReset = addBtn(principal,"Reset Jump")
local jp25 = addBtn(principal,"+25%")
local jp50 = addBtn(principal,"+50%")
local jp100 = addBtn(principal,"+100%")
jpReset.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = hub.baseJumpPower end) end end)
jp25.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 1.25) end) end end)
jp50.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 1.50) end) end end)
jp100.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 2.0) end) end end)

-- ===== Contenido: Visuales =====
local visuals = contents[2]
addLabel(visuals,"Visuales - Lo que puedes ver")

-- Highlights jugadores (existente)
local highlightsBtn = addBtn(visuals,"Toggle Highlights Jugadores")
highlightsBtn.MouseButton1Click:Connect(function()
    hub.highlights = not hub.highlights
    highlightsBtn.Text = hub.highlights and "Highlights: ON" or "Highlights: OFF"
    if hub.highlights then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= player and pl.Character and not hub.highlightObjects[pl.UserId] then
                pcall(function()
                    local h = Instance.new("Highlight", pl.Character)
                    h.Adornee = pl.Character
                    h.FillTransparency = 0.6
                    h.OutlineTransparency = 0.8
                    hub.highlightObjects[pl.UserId] = h
                end)
            end
        end
    else
        for id,h in pairs(hub.highlightObjects) do if h and h.Parent then pcall(function() h:Destroy() end) end hub.highlightObjects[id] = nil end
    end
end)

-- Ver Items/Tools (através de paredes)
local toolsBtn = addBtn(visuals,"Toggle Ver Items/Tools")
local function applyToolHighlights(enable)
    if enable then
        -- scan workspace for Tools or Models with Handle
        for _,inst in ipairs(Workspace:GetDescendants()) do
            if inst:IsA("Tool") or (inst:IsA("Model") and inst:FindFirstChild("Handle")) then
                local key = inst
                if not hub.toolHighlights[key] then
                    pcall(function()
                        local adornee = inst:IsA("Tool") and (inst:FindFirstChild("Handle") or inst) or inst:FindFirstChild("Handle")
                        if adornee then
                            local h = Instance.new("Highlight")
                            h.Parent = workspace
                            h.Adornee = adornee
                            h.FillTransparency = 0.7
                            h.OutlineTransparency = 0.6
                            hub.toolHighlights[key] = h
                        end
                    end)
                end
            end
        end
    else
        for k,h in pairs(hub.toolHighlights) do
            if h and h.Parent then pcall(function() h:Destroy() end) end
            hub.toolHighlights[k] = nil
        end
    end
end

toolsBtn.MouseButton1Click:Connect(function()
    hub.toolsVisible = not hub.toolsVisible
    toolsBtn.Text = hub.toolsVisible and "Ver Items: ON" or "Ver Items: OFF"
    applyToolHighlights(hub.toolsVisible)
end)

-- Auto-apply for tools added later
Workspace.DescendantAdded:Connect(function(desc)
    if hub.toolsVisible then
        wait(0.05)
        if desc:IsA("Tool") or (desc:IsA("Model") and desc:FindFirstChild("Handle")) then
            applyToolHighlights(true)
        end
    end
end)

-- FullBright (existente)
local fbBtn = addBtn(visuals,"Toggle FullBright")
fbBtn.MouseButton1Click:Connect(function()
    hub.fullbright = not hub.fullbright
    fbBtn.Text = hub.fullbright and "FullBright: ON" or "FullBright: OFF"
    if hub.fullbright then
        hub.origLighting.Ambient = Lighting.Ambient
        hub.origLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        hub.origLighting.GlobalShadows = Lighting.GlobalShadows
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.GlobalShadows = false
        end)
    else
        pcall(function()
            if hub.origLighting.Ambient then Lighting.Ambient = hub.origLighting.Ambient end
            if hub.origLighting.OutdoorAmbient then Lighting.OutdoorAmbient = hub.origLighting.OutdoorAmbient end
            if hub.origLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = hub.origLighting.GlobalShadows end
        end)
        hub.origLighting = {}
    end
end)

-- RTX toggle (local visual effects)
local rtxBtn = addBtn(visuals,"Toggle RTX")
rtxBtn.MouseButton1Click:Connect(function()
    hub.rtxEnabled = not hub.rtxEnabled
    rtxBtn.Text = hub.rtxEnabled and "RTX: ON" or "RTX: OFF"
    if hub.rtxEnabled then
        -- create local effects
        local bloom = new("BloomEffect",{Parent = Lighting,Intensity = 1,Size = 24})
        local cc = new("ColorCorrection",{Parent = Lighting,Contrast = 0.05, Saturation = 0.1, Brightness = 0})
        local sun = new("SunRays",{Parent = Lighting,Intensity = 0.2,Spread = 0.5})
        hub.rtxObjects = {bloom,cc,sun}
    else
        for _,inst in ipairs(hub.rtxObjects or {}) do if inst and inst.Parent then pcall(function() inst:Destroy() end) end end
        hub.rtxObjects = {}
    end
end)

-- ===== Ajustes =====
local ajustes = contents[3]
addLabel(ajustes,"Ajustes")
addLabel(ajustes,"Transparencia GUI")
local t75 = addBtn(ajustes,"75%")
local t50 = addBtn(ajustes,"50%")
local t25 = addBtn(ajustes,"25%")
t75.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.75 end)
t50.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.5 end)
t25.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.25 end)
local changelog = new("TextLabel",{Size=UDim2.new(1,0,0,120),BackgroundTransparency=0.2,BackgroundColor3=Color3.fromRGB(10,40,80),TextColor3=Color3.fromRGB(255,255,255),Text="Changelog v0.2.x:\n- Transparencia por defecto 75%\n- Tools visible (Highlight)\n- RTX local (Bloom/CC/SunRays)\n- Scroll y ventana más grandes",Font=Enum.Font.SourceSans,TextWrapped=true,TextSize=14,Parent=ajustes})

-- ===== Core loops =====
RunService.RenderStepped:Connect(function()
    -- noclip
    if hub.noclip and character then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then
                if hub.origCanCollide[p] == nil then hub.origCanCollide[p] = p.CanCollide end
                if p.CanCollide then pcall(function() p.CanCollide = false end) end
            end
        end
    end
    -- antiVoid
    if hub.antiVoid and hrp and hrp.Position.Y < -50 then
        if hub.savedWaypoints[1] then
            pcall(function() hrp.CFrame = hub.savedWaypoints[1] + Vector3.new(0,5,0) end)
        else
            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then pcall(function() hrp.CFrame = spawn.CFrame + Vector3.new(0,5,0) end)
            else pcall(function() hrp.CFrame = CFrame.new(0,50,0) end) end
        end
    end
end)

-- Restore prompts on leave
local function restoreAllPrompts()
    for prompt,orig in pairs(hub.origPromptDurations) do
        if prompt and prompt.Parent then pcall(function() prompt.HoldDuration = orig end) end
    end
    hub.origPromptDurations = {}
end

-- Cleanup on exit
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        for part,val in pairs(hub.origCanCollide) do if part and part.Parent then pcall(function() part.CanCollide = val end) end end
        for id,h in pairs(hub.highlightObjects) do if h and h.Parent then pcall(function() h:Destroy() end) end end
        for k,h in pairs(hub.toolHighlights) do if h and h.Parent then pcall(function() h:Destroy() end) end end
        for _,inst in ipairs(hub.rtxObjects or {}) do if inst and inst.Parent then pcall(function() inst:Destroy() end) end end
        restoreAllPrompts()
    end
end)

-- Auto-apply highlights for players and tools if toggled
Players.PlayerAdded:Connect(function(pl)
    if hub.highlights and pl.Character then
        wait(0.1)
        pcall(function()
            local h = Instance.new("Highlight", pl.Character)
            h.Adornee = pl.Character
            h.FillTransparency = 0.6
            h.OutlineTransparency = 0.8
            hub.highlightObjects[pl.UserId] = h
        end)
    end
end)
Workspace.DescendantAdded:Connect(function(desc)
    if hub.toolsVisible and (desc:IsA("Tool") or (desc:IsA("Model") and desc:FindFirstChild("Handle"))) then
        wait(0.05)
        applyToolHighlights(true)
    end
end)

print("[KS HUB] Actualización aplicada: transparencia 75%, Tools-visible y RTX añadidos.")

-- ===== FIN =====
