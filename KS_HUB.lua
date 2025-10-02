-- KS HUB v0.2.2 -- Script unificado con Teleport manual y lista dinámica de jugadores

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players") local TeleportService = game:GetService("TeleportService") local pl = Players.LocalPlayer local chr, hrp

pl.CharacterAdded:Connect(function(c) chr = c hrp = c:WaitForChild("HumanoidRootPart") end) if pl.Character then chr = pl.Character hrp = chr:WaitForChild("HumanoidRootPart") end

local function tpTo(name) for _,p in pairs(Players:GetPlayers()) do if p.Name:lower():sub(1,#name:lower())==name:lower() or p.DisplayName:lower():sub(1,#name:lower())==name:lower() then if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp then hrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0) end end end end

-- GUI local scr = Instance.new("ScreenGui", pl:WaitForChild("PlayerGui")) scr.Name = "KSHub"

local main = Instance.new("Frame", scr) main.Size = UDim2.new(0,350,0,400) main.Position = UDim2.new(0.5,-175,0.5,-200) main.BackgroundColor3 = Color3.fromRGB(30,30,30)

local uic = Instance.new("UICorner", main) uic.CornerRadius = UDim.new(0,12)

local tabs = Instance.new("Frame", main) tabs.Size = UDim2.new(1,0,0,30) tabs.BackgroundColor3 = Color3.fromRGB(40,40,40)

local content = Instance.new("Frame", main) content.Size = UDim2.new(1,0,1,-30) content.Position = UDim2.new(0,0,0,30) content.BackgroundTransparency = 1

local function makeBtn(txt, pos) local b = Instance.new("TextButton", tabs) b.Size = UDim2.new(0.5,0,1,0) b.Position = pos b.Text = txt b.BackgroundColor3 = Color3.fromRGB(60,60,60) b.TextColor3 = Color3.fromRGB(255,255,255) return b end

local btnMain = makeBtn("Principal", UDim2.new(0,0,0,0)) local btnMisc = makeBtn("Extra", UDim2.new(0.5,0,0,0))

local pageMain = Instance.new("Frame", content) pageMain.Size = UDim2.new(1,0,1,0) pageMain.BackgroundTransparency = 1

local pageMisc = Instance.new("Frame", content) pageMisc.Size = UDim2.new(1,0,1,0) pageMisc.BackgroundTransparency = 1 pageMisc.Visible = false

btnMain.MouseButton1Click:Connect(function() pageMain.Visible = true pageMisc.Visible = false end)

btnMisc.MouseButton1Click:Connect(function() pageMain.Visible = false pageMisc.Visible = true end)

-- Sección Teleport Manual local tb = Instance.new("TextBox", pageMain) tb.Size = UDim2.new(0.7,-5,0,30) tb.Position = UDim2.new(0,5,0,10) tb.PlaceholderText = "Nombre jugador" tb.Text = ""

tb.BackgroundColor3 = Color3.fromRGB(50,50,50) tb.TextColor3 = Color3.fromRGB(255,255,255)

local tpBtn = Instance.new("TextButton", pageMain) tpBtn.Size = UDim2.new(0.25,-5,0,30) tpBtn.Position = UDim2.new(0.7,0,0,10) tpBtn.Text = "TP" tpBtn.BackgroundColor3 = Color3.fromRGB(0,200,100) tpBtn.TextColor3 = Color3.fromRGB(0,0,0)

tpBtn.MouseButton1Click:Connect(function() tpTo(tb.Text) end)

-- Lista dinámica de jugadores local playersFrame = Instance.new("Frame", pageMain) playersFrame.Size = UDim2.new(1,-10,0,300) playersFrame.Position = UDim2.new(0,5,0,50) playersFrame.BackgroundTransparency = 1

local playersScroll = Instance.new("ScrollingFrame", playersFrame) playersScroll.Size = UDim2.new(1,0,1,0) playersScroll.BackgroundTransparency = 1 playersScroll.ScrollBarThickness = 6 playersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y playersScroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

local listLayout = Instance.new("UIListLayout", playersScroll) listLayout.SortOrder = Enum.SortOrder.LayoutOrder listLayout.Padding = UDim.new(0,4)

local function addPlayerButton(player) if player == pl then return end local btn = Instance.new("TextButton", playersScroll) btn.Size = UDim2.new(1,-4,0,30) btn.BackgroundColor3 = Color3.fromRGB(0,200,255) btn.Font = Enum.Font.GothamBold btn.TextSize = 15 btn.TextColor3 = Color3.fromRGB(0,0,80) btn.Text = player.DisplayName .. " (@" .. player.Name .. ")" btn.AutoButtonColor = true btn.MouseButton1Click:Connect(function() tpTo(player.Name) end) btn.Name = "btn_"..player.Name end

local function removePlayerButton(player) local b = playersScroll:FindFirstChild("btn_"..player.Name) if b then b:Destroy() end end

for _,player in pairs(Players:GetPlayers()) do addPlayerButton(player) end

Players.PlayerAdded:Connect(addPlayerButton) Players.PlayerRemoving:Connect(removePlayerButton)

-- Ejemplo de extra local labelExtra = Instance.new("TextLabel", pageMisc) labelExtra.Size = UDim2.new(1,0,0,30) labelExtra.Text = "Sección Extra (en desarrollo)" labelExtra.TextColor3 = Color3.fromRGB(255,255,255) labelExtra.BackgroundTransparency = 1

