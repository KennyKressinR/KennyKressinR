
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local selectedTheme = "Default"
local Window = Rayfield:CreateWindow({
   Name = "Doors - Script By Iliankytb",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Doors",
   LoadingSubtitle = "Script By Iliankytb",
   Theme = selectedTheme, -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SaverDoors", -- Create a custom folder for your hub/game
      FileName = "K"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
local InfoTab = Window:CreateTab("Info")
local UpdateTab = Window:CreateTab("Update")
local PlayerTab = Window:CreateTab("Player")
local GameTab = Window:CreateTab("Game")
local EspTab = Window:CreateTab("Esp")
local MonstersTab = Window:CreateTab("Monsters")
local DiscordTab = Window:CreateTab("Discord")
local SettingsTab = Window:CreateTab("Settings")
local ActiveEspDoor,ActiveSpeedBoost,ActiveEspHidingSpots,ActiveEspItems,ActiveEspCoins,ActiveMonsterSpawnAlert,ActiveNoCooldownPrompt,ActiveFullBright,ActiveModifiedFieldOfView,ActiveEspChest,ActiveEspBooks,ActiveEspMonster,ActiveEspTimerLever,ActiveEspGen,DisableLimitRangerEsp,ActiveAutoInteract,ActiveCanJump,ActiveInfOxygen,ActiveHMOxygen,ActiveSpeedBypassing,ActiveEspPlayers,ActiveDistanceEsp,ActiveBigPrompt = false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false
local LimitRangerEsp = 100
local ParagraphInfoServer = InfoTab:CreateParagraph({Title = "Info", Content = "Loading"})
Rayfield:Notify({
   Title = "Cheat Version",
   Content = "V.0.58",
   Duration = 2.5,
   Image = "rewind",
})

local Paragraph1 = UpdateTab:CreateParagraph({Title = "Released(V.0.8)", Content = "The Script Is Released It Has Only Some Esp And Speed Boost,I Will Add More Things In The Future!"})
local Paragraph2 = UpdateTab:CreateParagraph({Title = "Notify Monster Spawning(V.0.21)", Content = "New Things Added Monsters Esp(Uncompleted!) and Notify Monster Spawning is Uncompleted Too I Will Try To get monster from floor 2 and ambush & halt!"})
local Paragraph3 = UpdateTab:CreateParagraph({Title = "Theme Changer In Settings(V.0.22)", Content = "Added Themes Changer In Settings"})
local Paragraph4 = UpdateTab:CreateParagraph({Title = "Theme Changer In Settings(V.0.25)", Content = "Fixed Themes Changer In Settings,Now It Work Enjoy With My Script!"})
local Paragraph5 = UpdateTab:CreateParagraph({Title = "Upgraded And Added Things(V.0.26)", Content = "Added Section And Game Button,Upgrade Esp Monster And Monster Spawning Alert,Added Esp Timer Lever"})
local Paragraph6 = UpdateTab:CreateParagraph({Title = "Upgraded Limit Ranger Esp(V.0.30)", Content = "Added  A Slider To Change The Limit Ranger Esp Or A Toggle To Disable A Limit Ranger Esp In Settings!"})
local Paragraph7 = UpdateTab:CreateParagraph({Title = "Fixed Esp Door For Mines(V.0.31)", Content = "Just Try it! normally it work"})
local Paragraph8 = UpdateTab:CreateParagraph({Title = "Auto Interact(V.0.32)", Content = "Working Good But I Will Work On The Auto Interact Settings! btw its in Game tab."})
local Paragraph9 = UpdateTab:CreateParagraph({Title = "Fixed Full Bright(V.0.33)", Content = "Normally Full Bright Is Fixed Try It!"})
local Paragraph10 = UpdateTab:CreateParagraph({Title = "Fixed And Added(V.0.35)", Content = "Normally Full Bright Is Fixed Again,fixed Esp Hidding Spots And Esp Door Sometimes It Disapear and added Can Jump And Inf Oxygen!"})
local Paragraph11 = UpdateTab:CreateParagraph({Title = "Lag(V.0.36)", Content = "Normally there no lag for esp or etc i will upgrade again the full bright and somethings!"})
local Paragraph12 = UpdateTab:CreateParagraph({Title = "Highlight(V.0.39)", Content = "Just Upgraded Highlight!"})
local Paragraph13 = UpdateTab:CreateParagraph({Title = "Lag(V.0.42)", Content = "Using Heartbeat methode instead of renderstepped!"})
local Paragraph14 = UpdateTab:CreateParagraph({Title = "Esp(V.0.43)", Content = "Fixed Esp now!"})
local Paragraph15 = UpdateTab:CreateParagraph({Title = "Esp(V.0.47)", Content = "Fixed Esp again, it use the cframe of the camera instead of the rootpart cframe,bcause with the spectate it don't work!"})
local Paragraph16 = UpdateTab:CreateParagraph({Title = "Added More Monsters(V.0.48)", Content = "Added A60 and A120 in Esp Monsters and Monster spawn alert."})
local Paragraph17 = UpdateTab:CreateParagraph({Title = "Added things(V.0.50-51)", Content = "Added A button to see distance for esp in settings,fixed auto interact,Added big distance prompt,Added textlabel like evade script.(coming soon esp players and custom esp color & highlight!"})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function NotifMonsterSpawned(NameMonster,Time)
Rayfield:Notify({
   Title = "Monster Spawned!",
   Content = NameMonster.." Has Spawned!",
   Duration = Time,
   Image = "rewind",
})
end
local OptionNotif = {}
local function CreateEsp(Char, Color, Text,Parent)
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
highlight.Enabled = false
	highlight.Parent = Char

	
	local billboard = Char:FindFirstChild("ESP") or Instance.new("BillboardGui")
	billboard.Name = "ESP"
	billboard.Size = UDim2.new(0, 50, 0, 25)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, -2, 0)
	billboard.Adornee = Parent
	billboard.Enabled = false
	billboard.Parent = Parent

	
	local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = Text
	label.TextColor3 = Color
	label.TextScaled = true
	label.Parent = billboard

	task.spawn(function()
		local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

while highlight and billboard and Parent and Parent.Parent do
	local cameraPosition = Camera and Camera.CFrame.Position
	if cameraPosition and Parent and Parent:IsA("BasePart") then
	local distance = (cameraPosition - Parent.Position).Magnitude
				task.spawn(function()
if ActiveDistanceEsp then
label.Text = Text.." ("..math.floor(distance + 0.5).." m)"
else
label.Text = Text
end
end)
if not DisableLimitRangerEsp then
			local withinRange = distance <= LimitRangerEsp

			highlight.Enabled = withinRange
			billboard.Enabled = withinRange
		else
			billboard.Enabled = true
			highlight.Enabled = true
		end
	end

	RunService.Heartbeat:Wait()
end

	end)
end

local function KeepEsp(Char,Parent)
	if Char and Char:FindFirstChildOfClass("Highlight") and Parent:FindFirstChildOfClass("BillboardGui") then
		Char:FindFirstChildOfClass("Highlight"):Destroy()
		Parent:FindFirstChildOfClass("BillboardGui"):Destroy()
	end
end
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    else
        warn("setclipboard is not supported in this environment.")
    end
end
local DiscordLink = DiscordTab:CreateButton({
   Name = "Discord Link",
   Callback = function()
copyToClipboard("https://discord.gg/E2TqYRsRP4")
end,
}) local function onPromptShown(prompt)
    if prompt and prompt.MaxActivationDistance > 0 then
            prompt:InputHoldBegin() 
            task.wait(prompt.HoldDuration or 0)
            prompt:InputHoldEnd() 
        
    end
end

local Section1 = GameTab:CreateSection("General")
local Section2 = EspTab:CreateSection("General")
local DropdownMonsterSpawnAlert = GameTab:CreateDropdown({
    Name = "Monster Spawn Alert Dropdown",
    Options = {"Rush","Seek","Figure","Sally","Eyes","LookMan","BackdoorRush","Giggle","GloombatSwarm","Ambush","A-60","A-120"},
    CurrentOption = {""},
    MultipleOptions = true,
    Flag = "MonsterSpawnAlertDropdown",
    Callback = function(Options)
       
        if table.find(Options, "Rush") and not table.find(OptionNotif, "RushMoving") then
            table.insert(OptionNotif, "RushMoving")
        elseif not table.find(Options, "Rush") then
            local index = table.find(OptionNotif, "RushMoving")
            if index then
                table.remove(OptionNotif, index)
            end
        end

        if table.find(Options, "Seek") and not table.find(OptionNotif, "SeekMovingNewClone") then
            table.insert(OptionNotif, "SeekMovingNewClone")
        elseif not table.find(Options, "Seek") then
            local index = table.find(OptionNotif, "SeekMovingNewClone")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "Sally") and not table.find(OptionNotif, "SallyMoving") then
            table.insert(OptionNotif, "SallyMoving")
        elseif not table.find(Options, "Sally") then
            local index = table.find(OptionNotif, "SallyMoving")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "Figure") and not table.find(OptionNotif, "FigureRig") then
            table.insert(OptionNotif, "FigureRig")
        elseif not table.find(Options, "Figure") then
            local index = table.find(OptionNotif, "FigureRig")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "Eyes") and not table.find(OptionNotif, "Eyes") then
            table.insert(OptionNotif, "Eyes")
        elseif not table.find(Options, "Eyes") then
            local index = table.find(OptionNotif, "Eyes")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "LookMan") and not table.find(OptionNotif, "BackdoorLookman") then
            table.insert(OptionNotif, "BackdoorLookman")
        elseif not table.find(Options, "LookMan") then
            local index = table.find(OptionNotif, "BackdoorLookman")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "BackdoorRush") and not table.find(OptionNotif, "BackdoorRush") then
            table.insert(OptionNotif, "BackdoorRush")
        elseif not table.find(Options, "BackdoorRush") then
            local index = table.find(OptionNotif, "BackdoorRush")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "Giggle") and not table.find(OptionNotif, "GiggleCeiling") then
            table.insert(OptionNotif, "GiggleCeiling")
        elseif not table.find(Options, "Giggle") then
            local index = table.find(OptionNotif, "GiggleCeiling")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "GloombatSwarm") and not table.find(OptionNotif, "GloombatSwarm") then
            table.insert(OptionNotif, "GloombatSwarm")
        elseif not table.find(Options, "GloombatSwarm") then
            local index = table.find(OptionNotif, "GloombatSwarm")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "Ambush") and not table.find(OptionNotif, "AmbushMoving") then
            table.insert(OptionNotif, "AmbushMoving")
        elseif not table.find(Options, "Ambush") then
            local index = table.find(OptionNotif, "AmbushMoving")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "A-60") and not table.find(OptionNotif, "A60") then
            table.insert(OptionNotif, "A60")
        elseif not table.find(Options, "A-60") then
            local index = table.find(OptionNotif, "A60")
            if index then
                table.remove(OptionNotif, index)
            end
        end
if table.find(Options, "A-120") and not table.find(OptionNotif, "A120") then
            table.insert(OptionNotif, "A120")
        elseif not table.find(Options, "A-120") then
            local index = table.find(OptionNotif, "A120")
            if index then
                table.remove(OptionNotif, index)
            end
        end
    end,
})

local EspDoorToggle = EspTab:CreateToggle({
   Name = "Door Esp",
   CurrentValue = false,
   Flag = "EspDoor", 
   Callback = function(Value)
ActiveEspDoor = Value 
task.spawn(function() 
while ActiveEspDoor do
if Game.Workspace:FindFirstChild("CurrentRooms") then 
for _,Rooms in pairs(Game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do 
if Rooms:isA("Model") then task.spawn(function()
if Rooms:FindFirstChild("Door") and not Rooms:FindFirstChild("Door"):FindFirstChildOfClass("Highlight") and not Rooms:FindFirstChild("Door").PrimaryPart:FindFirstChildOfClass("BillboardGui") and not Rooms:FindFirstChild("Assets"):FindFirstChild("KeyObtain") then 
local signText = (Rooms:FindFirstChild("Door") and Rooms.Door:FindFirstChild("Sign") and 
                 ((Rooms.Door.Sign:FindFirstChild("Stinker") and Rooms.Door.Sign.Stinker.Text ~= "" and Rooms.Door.Sign.Stinker.Text)
               or (Rooms.Door.Sign:FindFirstChild("SignText") and Rooms.Door.Sign.SignText.Text)))
               or "Unknown"
CreateEsp(Rooms.Door, Color3.fromRGB(0,255,0), "Doors " .. signText,Rooms.Door.PrimaryPart) 
elseif Rooms:FindFirstChild("Door") and not Rooms:FindFirstChild("Door"):FindFirstChildOfClass("Highlight") and not Rooms:FindFirstChild("Door").PrimaryPart:FindFirstChildOfClass("BillboardGui") and  Rooms:FindFirstChild("Assets"):FindFirstChild("KeyObtain") then 
local signText = (Rooms:FindFirstChild("Door") and Rooms.Door:FindFirstChild("Sign") and 
                 ((Rooms.Door.Sign:FindFirstChild("Stinker") and Rooms.Door.Sign.Stinker.Text ~= "" and Rooms.Door.Sign.Stinker.Text)
               or (Rooms.Door.Sign:FindFirstChild("SignText") and Rooms.Door.Sign.SignText.Text)))
               or "Unknown"

CreateEsp(Rooms.Door, Color3.fromRGB(0,255,0), "Doors " .. signText.."(Lock)",Rooms.Door.PrimaryPart)
end end)
end 
end 
end
wait(0.1) end 
if Game.Workspace:FindFirstChild("CurrentRooms") then
for _,Rooms in pairs(Game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do
if Rooms:isA("Model") then
if Rooms:FindFirstChild("Door") and Rooms:FindFirstChild("Door"):FindFirstChildOfClass("Highlight") and  Rooms:FindFirstChild("Door").PrimaryPart:FindFirstChildOfClass("BillboardGui") then 
KeepEsp(Rooms:FindFirstChild("Door"),Rooms:FindFirstChild("Door").PrimaryPart) 
end 
end 
end
end 
end)
end,
}) local EspHidingSpotsToggle = EspTab:CreateToggle({
   Name = "Hiding Spots Esp",
   CurrentValue = false,
   Flag = "EspHidingSpots", 
   Callback = function(Value)
ActiveEspHidingSpots = Value 
task.spawn(function() 
while ActiveEspHidingSpots do
if Game.Workspace:FindFirstChild("CurrentRooms") then 
for _,Rooms in pairs(Game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do 
if Rooms:isA("Model") then
if Rooms:FindFirstChild("Assets") then  
for _,Assets in pairs(Rooms:FindFirstChild("Assets"):GetChildren()) do
task.spawn(function() 
if Assets:isA("Model") and (Assets.Name == "Bed" or Assets.Name == "Wardrobe" or Assets.Name == "Backdoor_Wardrobe" or Assets.Name == "Locker_Large" or Assets.Name == "Rooms_Locker")  and  not Assets:FindFirstChildOfClass("Highlight") and not Assets.PrimaryPart:FindFirstChildOfClass("BillboardGui")  then 
CreateEsp(Assets,Color3.fromRGB(0,255,255),Assets.Name,Assets.PrimaryPart) 
end end)
end 
end 
end end end
wait(0.1) end
if Game.Workspace:FindFirstChild("CurrentRooms") then 
for _,Rooms in pairs(Game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do 
if Rooms:isA("Model") then
if Rooms:FindFirstChild("Assets") then 
for _,Assets in pairs(Rooms:FindFirstChild("Assets"):GetChildren()) do  
if Assets:isA("Model")  and (Assets.Name == "Bed" or Assets.Name == "Wardrobe" or Assets.Name == "Backdoor_Wardrobe" or Assets.Name == "Locker_Large" or Assets.Name == "Rooms_Locker") and   Assets:FindFirstChildOfClass("Highlight") and Assets.PrimaryPart:FindFirstChildOfClass("BillboardGui") then 
KeepEsp(Assets,Assets.PrimaryPart) 
end 
end 
end 
end end end 
end)
end,
})
local ActiveMonsterSpawnAlertToggle = GameTab:CreateToggle({
   Name = "Active Monster Spawn Alert(Its uncompleted!)",
   CurrentValue = false,
   Flag = "ActiveMonsterSpawnAlert1", 
   Callback = function(Value)
ActiveMonsterSpawnAlert = Value 
end,
})
local NoCooldownpromptToggle = GameTab:CreateToggle({
   Name = "Instant Prompt",
   CurrentValue = false,
   Flag = "NoCooldownPrompt1", 
   Callback = function(Value)
ActiveNoCooldownPrompt = Value 
task.spawn(function()  
while ActiveNoCooldownPrompt do
for _,Assets in pairs(Game.Workspace:GetDescendants()) do  
if Assets:isA("ProximityPrompt") then 
task.spawn(function()
if Assets.HoldDuration ~= 0 then
Assets:SetAttribute("HoldDurationOld",Assets.HoldDuration)
Assets.HoldDuration = 0
end
end)
end 
end  
wait(0.1) end 
for _,Assets in pairs(Game.Workspace:GetDescendants()) do  
if Assets:isA("ProximityPrompt") then 
task.spawn(function()
if Assets:GetAttribute("HoldDurationOld") and Assets:GetAttribute("HoldDurationOld") ~= 0 then
Assets.HoldDuration = Assets:GetAttribute("HoldDurationOld")
end
end)
end 
end   
end)
end,
})
local EspItemsToggle = EspTab:CreateToggle({
   Name = "Items Esp",
   CurrentValue = false,
   Flag = "EspItems", 
   Callback = function(Value)
ActiveEspItems = Value 
task.spawn(function() 
while ActiveEspItems do
  for _,Assets in pairs(Game.Workspace:GetDescendants()) do  
task.spawn(function()
if Assets:isA("Model") and (Assets.Name == "KeyObtain" or Assets.Name == "LeverForGate" or Assets.Name == "Battery" or Assets.Name == "Flashlight" or Assets.Name == "Lighter" or Assets.Name == "Bandage" or Assets.Name == "Crucifix" or Assets.Name == "Vitamins" or Assets.Name == "Lockpick" or Assets.Name == "Candle" or Assets.Name == "AlarmClock" or Assets.Name == "LibraryHintPaper" or Assets.Name == "Smoothie" or Assets.Name == "FuseObtain" or Assets.Name == "BatteryPack" or Assets.Name == "Glowsticks" or Assets.Name == "StarVial" or Assets.Name == "Shakelight" or Ass
