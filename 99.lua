-- HUB_99Nights - Paquete completo -- Incluye 3 archivos: 1) HubSetup (ServerScriptService) --                        2) HubServerHandler (ServerScriptService) --                        3) HubLocal (StarterGui -> LocalScript) -- Pega cada bloque en su ubicación indicada en el header de cada archivo.

-- ================================================================== -- File: ServerScriptService/HubSetup.lua -- Ejecuta una sola vez en el servidor (o manténlo en ServerScriptService). -- Crea RemoteEvents necesarios si no existen. -- ================================================================== local ReplicatedStorage = game:GetService("ReplicatedStorage") local function ensureRemote(name) local r = ReplicatedStorage:FindFirstChild(name) if not r then r = Instance.new("RemoteEvent") r.Name = name r.Parent = ReplicatedStorage print("[HubSetup] Created RemoteEvent:", name) end return r end

ensureRemote("HubAction")                 -- Principal: { action = "Name", params = {} } ensureRemote("BringItemRequest")          -- Peticiones para mover/traer items: { filter = "All" / "Log" / "Coal" } ensureRemote("RequestStartDraggingItem")  -- Usado por algunos handlers (nombres tomados de tu script) ensureRemote("StopDraggingItem") print("[HubSetup] Setup complete")

-- ================================================================== -- File: ServerScriptService/HubServerHandler.lua -- Maneja acciones solicitadas por el cliente. Todas las decisiones importantes -- y cambios se hacen aquí (servidor) para evitar exploits. -- ================================================================== local ReplicatedStorage = game:GetService("ReplicatedStorage") local Players = game:GetService("Players") local ServerStorage = game:GetService("ServerStorage") local RunService = game:GetService("RunService")

local HUB_REMOTE = ReplicatedStorage:WaitForChild("HubAction") local BRING_REMOTE = ReplicatedStorage:WaitForChild("BringItemRequest") local START_DRAG_REMOTE = ReplicatedStorage:WaitForChild("RequestStartDraggingItem") local STOP_DRAG_REMOTE = ReplicatedStorage:WaitForChild("StopDraggingItem")

-- CONFIG local ADMIN_USERIDS = { -- Pon tus UserIds aquí para acciones administrativas -- Ej: 12345678, } local ACTION_COOLDOWN = 0.8 -- segundos por jugador local BRING_LIMIT_PER_CALL = 50 -- máximo de items a mover por petición

-- Estado simple local lastActionAt = {} -- [player.UserId] = timestamp

local function isAdmin(player) for _, id in ipairs(ADMIN_USERIDS) do if player.UserId == id then return true end end return false end

local function canPerform(player) local t = tick() local last = lastActionAt[player.UserId] or 0 if t - last < ACTION_COOLDOWN then return false end lastActionAt[player.UserId] = t return true end

-- Acción: Saltar noche (ejemplo - adapta a tu NightController si lo tienes) local function handleSkipNight(player, params) if not isAdmin(player) then return false, "Necesitas permisos de admin" end -- Busca un objeto NightController en ServerScriptService o Workspace local nc = game:GetService("ServerScriptService"):FindFirstChild("NightController") or workspace:FindFirstChild("NightController") if nc and nc:IsA("ModuleScript") then -- si usas un ModuleScript, require y llama función si existe (personaliza) local ok, m = pcall(function() return require(nc) end) if ok and type(m.SkipNight) == "function" then pcall(m.SkipNight) return true, "Noche saltada" end elseif nc and type(nc.Skip) == "function" then pcall(function() nc:Skip() end) return true, "Noche saltada" end -- Fallback: mandar evento a ServerStorage o avisar return false, "NightController no encontrado o no compatible" end

-- Acción: Dar item (servidor clona desde ServerStorage.Items) local function handleGiveItem(player, params) if type(params) ~= "table" or type(params.itemName) ~= "string" then return false, "params inválidos" end local itemName = params.itemName local itemsFolder = ServerStorage:FindFirstChild("Items") if not itemsFolder then return false, "ServerStorage.Items no existe" end local template = itemsFolder:FindFirstChild(itemName) if not template then return false, "Item no encontrado" end

-- Lista blanca (solo permite clones de templates existentes)
local clone = template:Clone()
clone.Parent = player:WaitForChild("Backpack")
return true, "Item entregado: "..itemName

end

-- Acción: Teleport a Lobby (usa workspace.LobbySpawn o un SpawnLocation llamado "LobbySpawn") local function handleTeleportToLobby(player, params) local char = player.Character if not char or not char.PrimaryPart then return false, "No hay personaje activo" end local spawn = workspace:FindFirstChild("LobbySpawn") or workspace:FindFirstChildWhichIsA("SpawnLocation") if not spawn then return false, "LobbySpawn no encontrado" end local ok, err = pcall(function() char:SetPrimaryPartCFrame(CFrame.new(spawn.Position + Vector3.new(0,3,0))) end) if not ok then return false, (err or "Teleport falló") end return true, "Teleport OK" end

-- Acción: Traer items (mueve modelos de workspace.Items al jugador) - controlado por servidor local function handleBringItems(player, params) -- params.filter: "All" | "Log" | "Coal" if type(params) ~= "table" then params = {} end local filter = params.filter or "All" local itemsRoot = workspace:FindFirstChild("Items") if not itemsRoot then return false, "Workspace.Items no existe" end

local moved = 0
for _, obj in ipairs(itemsRoot:GetChildren()) do
    if moved >= BRING_LIMIT_PER_CALL then break end
    if obj:IsA("Model") and obj.PrimaryPart then
        local name = obj.Name
        local allowed = false
        if filter == "All" then allowed = true
        elseif filter == "Log" and name == "Log" then allowed = true
        elseif filter == "Coal" and name == "Coal" then allowed = true
        end
        if allowed then
            -- Mueve el objeto de forma segura
            local ok, err = pcall(function()
                obj:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame + Vector3.new(0,0.5 + moved))
            end)
            if ok then moved = moved + 1 end
        end
    end
end
return true, ("Movidos: "..tostring(moved))

end

-- Dispatcher principal para "HubAction" local ActionHandlers = { SkipNight = handleSkipNight, GiveItem = handleGiveItem, TeleportToLobby = handleTeleportToLobby, -- otros handlers si es necesario }

HUB_REMOTE.OnServerEvent:Connect(function(player, data) if type(data) ~= "table" or type(data.action) ~= "string" then return end if not canPerform(player) then return end local handler = ActionHandlers[data.action] if not handler then warn("[Hub] Acción no encontrada:", data.action) return end local success, res, msg = pcall(function() return handler(player, data.params or {}) end) if not success then warn("[Hub] Error ejecutando acción:", res) else -- si quieres, podrías usar otro RemoteEvent para responder al cliente print("[Hub] Acción ", data.action, "->", res) end end)

-- Handler para BringItemRequest (se usa por separado porque es más pesado) BRING_REMOTE.OnServerEvent:Connect(function(player, params) if not canPerform(player) then return end local ok, msg = pcall(function() return handleBringItems(player, params) end) if not ok then warn("[Hub] BringItems error: ", msg) end end)

-- Reexporta los requests de arrastre (compatibilidad con tu script) START_DRAG_REMOTE.OnServerEvent:Connect(function(player, item) -- Reenvía (si necesitas validar aquí, hazlo) -- Este RemoteEvent existe porque tu script lo usa: RequestStartDraggingItem -- Por defecto lo dejamos pasar para compatibilidad, pero podrías validar ownership. -- No hacemos nada extra en este handler por seguridad. end) STOP_DRAG_REMOTE.OnServerEvent:Connect(function(player, item) -- Igual que arriba end)

print("[HubServerHandler] Listo")

-- ================================================================== -- File: StarterGui/HubLocal.lua (LocalScript) -- GUI limpio, simétrico y sin superposiciones. Usa un Grid para botones y -- separa la sección de ESP, Items y Jugador. -- ================================================================== local Players = game:GetService("Players") local ReplicatedStorage = game:GetService("ReplicatedStorage") local RunService = game:GetService("RunService") local TweenService = game:GetService("TweenService") local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer local HUB_REMOTE = ReplicatedStorage:WaitForChild("HubAction") local BRING_REMOTE = ReplicatedStorage:WaitForChild("BringItemRequest")

-- Helper: Create UI elements quickly local function make(class, props) local o = Instance.new(class) if props then for k,v in pairs(props) do o[k] = v end end return o end

-- ScreenGui local screenGui = make("ScreenGui", {Name = "ProHub99N", ResetOnSpawn = false}) screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main container (centered) local main = make("Frame", { Name = "Main", Size = UDim2.fromOffset(520, 360), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(20,20,22), BorderSizePixel = 0, }) main.Parent = screenGui

-- Rounded corners local uic = make("UICorner", {Parent = main, CornerRadius = UDim.new(0, 12)})

-- Header local header = make("Frame", {Parent = main, Size = UDim2.new(1,0,0,56), BackgroundTransparency = 1}) local title = make("TextLabel", { Parent = header, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = "HUB — 99 Nights in the Forest", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left, }) local closeBtn = make("TextButton", {Parent = header, Size = UDim2.new(0, 54, 0, 36), Position = UDim2.new(1, -70, 0, 10), BackgroundColor3 = Color3.fromRGB(44,44,46), Text = "Cerrar", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.new(1,1,1)}) make("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,6)})

-- Left: Info / HUD preview local left = make("Frame", {Parent = main, Size = UDim2.new(0.46, -12, 1, -66), Position = UDim2.new(0, 12, 0, 56), BackgroundColor3 = Color3.fromRGB(24,24,26), BorderSizePixel = 0}) make("UICorner", {Parent = left, CornerRadius = UDim.new(0,10)})

local leftTitle = make("TextLabel", {Parent = left, Size = UDim2.new(1, -12, 0, 30), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1, Text = "Información", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1,1,1), TextXAlignment = Enum.TextXAlignment.Left})

local infoBox = make("TextLabel", {Parent = left, Size = UDim2.new(1, -12, 1, -48), Position = UDim2.new(0,6,0,42), BackgroundTransparency = 1, Text = "Cargando...", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(200,200,200), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})

-- Right: Grid de botones (simétrico, sin overlap) local right = make("Frame", {Parent = main, Size = UDim2.new(0.5, -12, 1, -66), Position = UDim2.new(1, -12 - (0.5*main.Size.X.Offset), 0, 56), BackgroundTransparency = 1})

-- Grid container local gridContainer = make("Frame", {Parent = right, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(28,28,30)}) make("UICorner", {Parent = gridContainer, CornerRadius = UDim.new(0,10)})

local grid = make("UIGridLayout", {Parent = gridContainer, CellSize = UDim2.new(0, 240, 0, 56), CellPadding = UDim2.new(0, 12, 0, 12), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top})

-- Button factory (clean, consistent) local function createButton(text) local btn = make("TextButton", {Parent = gridContainer, Size = UDim2.fromOffset(240,56), BackgroundColor3 = Color3.fromRGB(44,44,46), Text = text, Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = Color3.fromRGB(255,255,255)}) make("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)}) return btn end

-- Buttons (acciones) local btnSkipNight = createButton("Saltar noche") local btnGiveCake = createButton("Dar pastel") local btnTeleportLobby = createButton("Ir al Lobby") local btnBringAll = createButton("Traer todos los items") local btnBringLogs = createButton("Traer Logs") local btnBringCoal = createButton("Traer Coal") local btnToggleESPItems = createButton("ESP: Items (OFF)") local btnToggleESPEnemies = createButton("ESP: Enemigos (OFF)") local btnToggleESPChildren = createButton("ESP: Niños (OFF)")

-- Compact footer with small controls local footer = make("Frame", {Parent = main, Size = UDim2.new(1, -24, 0, 50), Position = UDim2.new(0, 12, 1, -58), BackgroundTransparency = 1}) local hint = make("TextLabel", {Parent = footer, Size = UDim2.new(1, -160, 1, 0), BackgroundTransparency = 1, Text = "Tecla rápida: RightShift para ocultar/mostrar HUB", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(180,180,180), TextXAlignment = Enum.TextXAlignment.Left})

-- Toggle HUD visibility local function toggleVisibility() screenGui.Enabled = not screenGui.Enabled end

-- Keybind RightShift UserInputService.InputBegan:Connect(function(inp, gpe) if gpe then return end if inp.KeyCode == Enum.KeyCode.RightShift then toggleVisibility() end end)

closeBtn.MouseButton1Click:Connect(function() toggleVisibility() end)

-- Función para enviar acciones al servidor de forma estructurada local function sendAction(name, params) local payload = { action = name, params = params or {} } HUB_REMOTE:FireServer(payload) end

-- Botones: conexiones btnSkipNight.MouseButton1Click:Connect(function() sendAction("SkipNight", {}) end) btnGiveCake.MouseButton1Click:Connect(function() sendAction("GiveItem", { itemName = "Cake" }) end) btnTeleportLobby.MouseButton1Click:Connect(function() sendAction("TeleportToLobby", {}) end) btnBringAll.MouseButton1Click:Connect(function() BRING_REMOTE:FireServer({ filter = "All" }) end) btnBringLogs.MouseButton1Click:Connect(function() BRING_REMOTE:FireServer({ filter = "Log" }) end) btnBringCoal.MouseButton1Click:Connect(function() BRING_REMOTE:FireServer({ filter = "Coal" }) end)

-- ===================== ESP IMPLEMENTATION (clean & efficient) ===================== local EspState = { items = false, enemies = false, children = false, }

local function makeHighlightFor(model, color) if not model or not model.PrimaryPart then return end -- Prevent duplicates if model:FindFirstChild("ESP_Highlight") or model.PrimaryPart:FindFirstChild("ESP_Billboard") then return end local h = Instance.new("Highlight") h.Name = "ESP_Highlight" h.Adornee = model h.FillColor = color h.FillTransparency = 1 h.OutlineColor = color h.OutlineTransparency = 0 h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop h.Parent = model

local billboard = Instance.new("BillboardGui")
billboard.Name = "ESP_Billboard"
billboard.Adornee = model.PrimaryPart
billboard.Size = UDim2.new(0,120,0,24)
billboard.StudsOffset = Vector3.new(0, 2.6, 0)
billboard.AlwaysOnTop = true
billboard.Parent = model.PrimaryPart

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,1,0)
label.BackgroundTransparency = 1
label.Text = model.Name
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.TextColor3 = color
label.TextScaled = false
label.Parent = billboard

end

local function removeEspFrom(model) if model:FindFirstChild("ESP_Highlight") then model:FindFirstChild("ESP_Highlight"):Destroy() end if model.PrimaryPart and model.PrimaryPart:FindFirstChild("ESP_Billboard") then model.PrimaryPart:FindFirstChild("ESP_Billboard"):Destroy() end end

-- Toggling buttons update text and flip state local function updateButtonText(btn, base, state) btn.Text = base .. (state and " (ON)" or " (OFF)") end

btnToggleESPItems.MouseButton1Click:Connect(function() EspState.items = not EspState.items updateButtonText(btnToggleESPItems, "ESP: Items", EspState.items) end) btnToggleESPEnemies.MouseButton1Click:Connect(function() EspState.enemies = not EspState.enemies updateButtonText(btnToggleESPEnemies, "ESP: Enemigos", EspState.enemies) end) btnToggleESPChildren.MouseButton1Click:Connect(function() EspState.children = not EspState.children updateButtonText(btnToggleESPChildren, "ESP: Niños", EspState.children) end)

-- Loop de ESP (optimizado: un solo RenderStepped) RunService.Heartbeat:Connect(function() -- Items if EspState.items then local itemsRoot = workspace:FindFirstChild("Items") if itemsRoot then for _,obj in pairs(itemsRoot:GetChildren()) do if obj:IsA("Model") and obj.PrimaryPart and not obj:FindFirstChild("ESP_Highlight") then makeHighlightFor(obj, Color3.fromRGB(255,215,0)) end end end else -- cleanup items local itemsRoot = workspace:FindFirstChild("Items") if itemsRoot then for _,obj in pairs(itemsRoot:GetChildren()) do if obj:IsA("Model") then removeEspFrom(obj) end end end end

-- Enemies
if EspState.enemies or EspState.children then
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _,m in pairs(chars:GetChildren()) do
            if m:IsA("Model") and m.PrimaryPart then
                local nm = m.Name
                if EspState.enemies and not (nm == "Lost Child" or nm:match("Lost Child")) and not (nm == "Pelt Trader") then
                    if not m:FindFirstChild("ESP_Highlight") then makeHighlightFor(m, Color3.fromRGB(255,0,0)) end
                elseif EspState.children and (nm == "Lost Child" or nm:match("Lost Child")) then
                    if not m:FindFirstChild("ESP_Highlight") then makeHighlightFor(m, Color3.fromRGB(0,255,0)) end
                else
                    -- no match: remove if exists
                    removeEspFrom(m)
                end
            end
        end
    end
else
    -- cleanup enemies/children
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _,m in pairs(chars:GetChildren()) do
            if m:IsA("Model") then removeEspFrom(m) end
        end
    end
end

end)

-- Llenar InfoBox con datos básicos del server (user-friendly) local function updateInfo() local PlayersService = game:GetService("Players") local playerCount = #PlayersService:GetPlayers() local maxPlayers = PlayersService.MaxPlayers or 16 local placeId = game.PlaceId infoBox.Text = string.format("Jugadores: %d/%d\nPlaceId: %d\nJobId: %s\nLocalPlayer: %s", playerCount, maxPlayers, placeId, tostring(game.JobId), player.Name) end

updateInfo()

-- Pequeña animación de entrada main.Size = UDim2.fromOffset(0,0) TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(520,360)}):Play()

print("[HubLocal] GUI listo")

-- FIN DEL ARCHIVO

