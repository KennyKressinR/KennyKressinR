-- KS HUB v0.2.x - Versión corregida: UI compacta, scroll arreglado, botones más pequeños, TP accesible, Delay funcional
-- Pegar como LocalScript en StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local hub = {
    noclip = false,
    antiVoid = false,
    highlights = false,
    fullbright = false,
    instantInteract = false, -- "delay" invertido: true = interactuar instantáneamente
    savedWaypoints = {},
    highlightObjects = {},
    origCanCollide = {},
    origLighting = {},
    origPromptDurations = {}, -- store original HoldDuration for ProximityPrompt
}

-- Character refs
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

-- UI creators (compact)
local MAIN_COLOR = Color3.fromRGB(0,102,204)
local BTN_COLOR = Color3.fromRGB(102,204,255)

local function new(class, props)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k] = v end end
    return o
end

-- ScreenGui & main (menos ancho)
local screenGui = new("ScreenGui",{Name="KSHub",ResetOnSpawn=false,Parent=playerGui})
local main = new("Frame",{
    Name="Main",
    Size=UDim2.new(0,320,0,460), -- menos ancho que antes
    Position=UDim2.new(0.5,0,0.5,0),
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=MAIN_COLOR,
    BorderSizePixel=0,
    Parent=screenGui
})

-- Header y drag
local header = new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(0,76,153),Parent=main})
local title = new("TextLabel",{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text="KS HUB v0.2.x",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.SourceSansBold,TextSize=18,Parent=header})
local closeBtn = new("TextButton",{Size=UDim2.new(0,48,1,0),Position=UDim2.new(1,-48,0,0),BackgroundColor3=BTN_COLOR,Text="X",Font=Enum.Font.SourceSansBold,TextSize=18,Parent=header})
local toggleBtn = new("TextButton",{Name="ToggleOpen",Size=UDim2.new(0,56,0,26),Position=UDim2.new(0,8,0,8),BackgroundColor3=BTN_COLOR,Text="KS",Font=Enum.Font.SourceSansBold,TextSize=16,Parent=screenGui,Visible=false})

-- Tabs + ScrollingFrames con UIListLayout y ajuste dinámico del CanvasSize (FIX SCROLL)
local tabBar = new("Frame",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1,Parent=main})
local tabs = {"Principal","Visuales","Ajustes"}
local tabButtons = {}
local scrolls = {}
local contents = {}

for i,name in ipairs(tabs) do
    local btn = new("TextButton",{Size=UDim2.new(1/#tabs,-4,1,0),Position=UDim2.new((i-1)/#tabs,2,0,0),BackgroundColor3=BTN_COLOR,Text=name,Font=Enum.Font.SourceSansBold,TextSize=14,Parent=tabBar})
    tabButtons[i] = btn

    local scroll = new("ScrollingFrame",{
        Name=name.."Scroll",
        Size=UDim2.new(1,-12,1,-64), -- menos alto para ajustarse al header y tabBar
        Position=UDim2.new(0,6,0,64),
        BackgroundTransparency=1,
        ScrollBarThickness=6,
        Parent=main,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y
    })

    local content = new("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,Parent=scroll})
    local layout = new("UIListLayout",{Parent=content,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    local pad = new("UIPadding",{Parent=content,PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y)
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
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

-- Small button creator (50% smaller look)
local function addLabel(parent, txt)
    local l = new("TextLabel",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=txt,TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.SourceSansBold,TextSize=14,Parent=parent})
    return l
end
local function addBtn(parent, txt)
    local b = new("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=BTN_COLOR,Text=txt,Font=Enum.Font.SourceSansBold,TextSize=14,Parent=parent})
    return b
end
local function addBox(parent, placeholder)
    local tb = new("TextBox",{Size=UDim2.new(1,0,0,24),BackgroundColor3=Color3.fromRGB(245,245,245),Text="",PlaceholderText=placeholder,Font=Enum.Font.SourceSans,TextSize=14,TextColor3=Color3.new(0,0,0),Parent=parent})
    return tb
end

-- -------- Principal tab content (ordenado y TP arriba para ser accesible) --------
local principal = contents[1]
addLabel(principal,"Principal - Funciones")

-- Noclip
local noclipBtn = addBtn(principal,"Activar Noclip")
noclipBtn.MouseButton1Click:Connect(function()
    hub.noclip = not hub.noclip
    noclipBtn.Text = hub.noclip and "Desactivar Noclip" or "Activar Noclip"
    if hub.noclip then
        hub.origCanCollide = {}
        if character then
            for _,p in pairs(character:GetDescendants()) do
                if p:IsA("BasePart") then
                    hub.origCanCollide[p] = p.CanCollide
                    p.CanCollide = false
                end
            end
        end
    else
        for part,val in pairs(hub.origCanCollide) do
            if part and part.Parent then pcall(function() part.CanCollide = val end) end
        end
        hub.origCanCollide = {}
    end
end)

-- Delay / InstantInteract toggle (funciona con ProximityPrompt HoldDuration)
local delayBtn = addBtn(principal,"InstantInteract: OFF")
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
delayBtn.MouseButton1Click:Connect(function()
    hub.instantInteract = not hub.instantInteract
    delayBtn.Text = hub.instantInteract and "InstantInteract: ON" or "InstantInteract: OFF"
    -- apply to existing prompts in workspace
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then applyInstantToPrompt(p) end
    end
end)
-- auto-apply for prompts spawned later
Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        -- short wait to let creator finish initializing
        wait(0.05)
        applyInstantToPrompt(desc)
    end
end)

-- AntiVoid toggle
local antiVoidBtn = addBtn(principal,"Activar AntiVoid")
antiVoidBtn.MouseButton1Click:Connect(function()
    hub.antiVoid = not hub.antiVoid
    antiVoidBtn.Text = hub.antiVoid and "Desactivar AntiVoid" or "Activar AntiVoid"
end)

-- Waypoints (2) - arriba para accesibilidad
addLabel(principal,"Waypoints (2)")
local wpSave1 = addBtn(principal,"Save 1")
local wpLoad1 = addBtn(principal,"Load 1")
local wpSave2 = addBtn(principal,"Save 2")
local wpLoad2 = addBtn(principal,"Load 2")
wpSave1.MouseButton1Click:Connect(function() if hrp then hub.savedWaypoints[1] = hrp.CFrame end end)
wpLoad1.MouseButton1Click:Connect(function() if hub.savedWaypoints[1] and hrp then pcall(function() hrp.CFrame = hub.savedWaypoints[1] end) end end)
wpSave2.MouseButton1Click:Connect(function() if hrp then hub.savedWaypoints[2] = hrp.CFrame end end)
wpLoad2.MouseButton1Click:Connect(function() if hub.savedWaypoints[2] and hrp then pcall(function() hrp.CFrame = hub.savedWaypoints[2] end) end end)

-- Teleport a jugador (colocado arriba para que el scroll alcance)
addLabel(principal,"Teleport a jugador (nombre parcial)")
local tpBox = addBox(principal,"Nombre parcial")
local tpBtn = addBtn(principal,"TP")
tpBtn.MouseButton1Click:Connect(function()
    local q = (tpBox.Text or ""):lower():gsub("%s+","")
    if q == "" then return end
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Name:lower():gsub("%s+",""):find(q,1,true) and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() hrp.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0) end)
            break
        end
    end
end)

-- WalkSpeed presets (ordenadas mayor a menor)
addLabel(principal,"WalkSpeed Presets")
local wsVals = {200,150,75,50,30}
for _,v in ipairs(wsVals) do
    local b = addBtn(principal,tostring(v))
    b.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.WalkSpeed = v end) end end)
end
local bNormal = addBtn(principal,"Normal")
bNormal.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.WalkSpeed = hub.baseWalkSpeed end) end end)

-- JumpPower presets (compactos)
addLabel(principal,"JumpPower Presets")
local jpReset = addBtn(principal,"Reset Jump")
local jp25 = addBtn(principal,"+25%")
local jp50 = addBtn(principal,"+50%")
local jp100 = addBtn(principal,"+100%")
jpReset.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = hub.baseJumpPower end) end end)
jp25.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 1.25) end) end end)
jp50.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 1.50) end) end end)
jp100.MouseButton1Click:Connect(function() if humanoid then pcall(function() humanoid.JumpPower = math.floor(hub.baseJumpPower * 2.0) end) end end)

-- -------- Visuales tab --------
local visuals = contents[2]
addLabel(visuals,"Visuales")

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

Players.PlayerAdded:Connect(function(pl)
    if hub.highlights then
        wait(0.1)
        if pl.Character then
            pcall(function()
                local h = Instance.new("Highlight", pl.Character)
                h.Adornee = pl.Character
                h.FillTransparency = 0.6
                h.OutlineTransparency = 0.8
                hub.highlightObjects[pl.UserId] = h
            end)
        end
    end
end)
Players.PlayerRemoving:Connect(function(pl) hub.highlightObjects[pl.UserId] = nil end)

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

-- -------- Ajustes tab --------
local ajustes = contents[3]
addLabel(ajustes,"Ajustes")
addLabel(ajustes,"Transparencia GUI")
local t75 = addBtn(ajustes,"75%")
local t50 = addBtn(ajustes,"50%")
local t25 = addBtn(ajustes,"25%")
t75.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.75 end)
t50.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.5 end)
t25.MouseButton1Click:Connect(function() main.BackgroundTransparency = 0.25 end)

local changelog = new("TextLabel",{Size=UDim2.new(1,0,0,110),BackgroundTransparency=0.2,BackgroundColor3=Color3.fromRGB(10,40,80),TextColor3=Color3.fromRGB(255,255,255),Text="Changelog v0.2.x:\n- UI compacta y centrada\n- Botones 50% más pequeños\n- TP y Waypoints accesibles\n- WalkSpeed ordenadas (mayor->menor)\n- InstantInteract funcional (convierte HoldDuration a 0)",Font=Enum.Font.SourceSans,TextWrapped=true,TextSize=14,Parent=ajustes})

-- -------- Core loops: noclip y antiVoid --------
RunService.RenderStepped:Connect(function()
    if hub.noclip and character then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then
                if hub.origCanCollide[p] == nil then hub.origCanCollide[p] = p.CanCollide end
                if p.CanCollide then pcall(function() p.CanCollide = false end) end
            end
        end
    end

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

-- Restore prompts on script end / player leave
local function restoreAllPrompts()
    for prompt,orig in pairs(hub.origPromptDurations) do
        if prompt and prompt.Parent then
            pcall(function() prompt.HoldDuration = orig end)
        end
    end
    hub.origPromptDurations = {}
end

player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        -- restore collisions
        for part,val in pairs(hub.origCanCollide) do if part and part.Parent then pcall(function() part.CanCollide = val end) end end
        -- destroy highlights
        for id,h in pairs(hub.highlightObjects) do if h and h.Parent then pcall(function() h:Destroy() end) end end
        restoreAllPrompts()
    end
end)

-- Feedback
print("[KS HUB] UI ajustada. TP accesible, botones más pequeños, InstantInteract funcionando.")
