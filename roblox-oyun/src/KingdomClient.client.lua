-- KRALLIK SAVUNMASI | StarterPlayer > StarterPlayerScripts > KingdomClient
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("KingdomEvent")
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Name = "KingdomHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Name = "HUDRoot"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1, 1)
root.Parent = gui

local scale = Instance.new("UIScale")
scale.Parent = root

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then return end
	scale.Scale = math.clamp(camera.ViewportSize.X / 900, 0.68, 1)
end
updateScale()
task.spawn(function()
	while not workspace.CurrentCamera do task.wait() end
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end)

local function label(text, size, pos)
	local item = Instance.new("TextLabel")
	item.Size, item.Position = size, pos
	item.BackgroundColor3 = Color3.fromRGB(31, 43, 32)
	item.BackgroundTransparency = 0.12
	item.TextColor3, item.Text = Color3.new(1, 1, 1), text
	item.TextScaled = true
	item.Font = Enum.Font.GothamBold
	item.Parent = root
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = item
	return item
end

local function button(text, size, pos, color)
	local item = Instance.new("TextButton")
	item.Size, item.Position = size, pos
	item.BackgroundColor3 = color or Color3.fromRGB(190, 133, 54)
	item.TextColor3 = Color3.new(1, 1, 1)
	item.Text, item.TextScaled = text, true
	item.Font = Enum.Font.GothamBold
	item.AutoButtonColor = true
	item.Parent = root
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = item
	return item
end

local title = label("KRALLIK SAVUNMASI", UDim2.fromOffset(260, 40), UDim2.fromOffset(14, 14))
local stats = label("Kristal: 1000 / 1000", UDim2.fromOffset(240, 34), UDim2.fromOffset(14, 60))
local waveLabel = label("Dalga: Hazırlan", UDim2.fromOffset(170, 34), UDim2.fromOffset(14, 100))
local goldLabel = label("Altın: 250", UDim2.fromOffset(170, 34), UDim2.fromOffset(14, 140))
local message = label("Kaleni koru; savunma kur ve geliştir!", UDim2.new(0.52, 0, 0, 38), UDim2.new(0.24, 0, 0, 14))

local tower = button("KULE  •  130", UDim2.fromOffset(172, 38), UDim2.new(1, -186, 1, -204))
local wall = button("DUVAR  •  70", UDim2.fromOffset(172, 38), UDim2.new(1, -186, 1, -160), Color3.fromRGB(90, 115, 145))
local guard = button("MUHAFIZ  •  180", UDim2.fromOffset(172, 38), UDim2.new(1, -186, 1, -116), Color3.fromRGB(65, 95, 145))
local upgrade = button("SAVUNMAYI GELİŞTİR", UDim2.fromOffset(172, 38), UDim2.new(1, -186, 1, -72), Color3.fromRGB(70, 145, 90))
local attack = button("VUR", UDim2.fromOffset(92, 56), UDim2.new(1, -106, 0.5, -28), Color3.fromRGB(170, 55, 48))

local mode = nil
local function selectBuild(kind, description)
	mode = kind
	message.Text = description .. " Yerleştirmek için zemine dokun veya tıkla."
end

tower.Activated:Connect(function()
	selectBuild("Tower", "Okçu kulesi seçildi.")
end)
wall.Activated:Connect(function()
	selectBuild("Wall", "Duvar seçildi.")
end)
guard.Activated:Connect(function()
	selectBuild("Guard", "Muhafız seçildi.")
end)
attack.Activated:Connect(function()
	remote:FireServer("Attack")
end)
upgrade.Activated:Connect(function()
	remote:FireServer("UpgradeDefense")
end)

local function getPlacementPosition(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local hit = mouse.Hit
		return hit and hit.Position or nil
	end

	local camera = workspace.CurrentCamera
	if not camera then return nil end
	local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	return result and result.Position or nil
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not mode then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local position = getPlacementPosition(input)
	if position then
		remote:FireServer("Place", {kind = mode, position = position})
	end
	mode = nil
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E then
		remote:FireServer("Attack")
	end
end)

local function watchGold()
	local statsFolder = player:WaitForChild("leaderstats", 15)
	if not statsFolder then return end
	local gold = statsFolder:WaitForChild("Altin", 15)
	if not gold then return end

	local function update()
		goldLabel.Text = "Altın: " .. tostring(gold.Value)
	end
	update()
	gold:GetPropertyChangedSignal("Value"):Connect(update)
end
task.spawn(watchGold)

remote.OnClientEvent:Connect(function(kind, data)
	if kind == "Status" or kind == "Wave" then
		stats.Text = "Kristal: " .. tostring(data.core) .. " / " .. tostring(data.maxCore)
		if kind == "Wave" then
			waveLabel.Text = "Dalga: " .. tostring(data.wave)
		end
	elseif kind == "Message" then
		message.Text = tostring(data)
	elseif kind == "GameOver" then
		message.Text = "KALE DÜŞTÜ! Son dalga: " .. tostring(data.wave)
		message.BackgroundColor3 = Color3.fromRGB(130, 35, 35)
	end
end)
