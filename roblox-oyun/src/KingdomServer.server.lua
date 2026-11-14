-- KRALLIK SAVUNMASI | ServerScriptService > KingdomServer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local remote = ReplicatedStorage:FindFirstChild("KingdomEvent") or Instance.new("RemoteEvent")
remote.Name = "KingdomEvent"
remote.Parent = ReplicatedStorage

local old = workspace:FindFirstChild("KingdomMap")
if old then old:Destroy() end
local map = Instance.new("Folder")
map.Name = "KingdomMap"
map.Parent = workspace

local enemies, defenses = {}, {}
local playerActionTimes, playerAttackTimes = {}, {}
local wave = 0
local coreHealth, coreMaxHealth = 1000, 1000
local arenaCenter = Vector3.new(0, 0, 0)

local function part(name, size, cf, color, material, parent)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent or map
	return p
end

-- Arena and castle. The castle remains visible but does not block enemy pathing.
part("Grass Arena", Vector3.new(190, 2, 190), CFrame.new(0, -1, 0), Color3.fromRGB(83, 145, 70), Enum.Material.Grass)
local keep = part("Castle Keep", Vector3.new(22, 20, 22), CFrame.new(0, 10, 0), Color3.fromRGB(130, 132, 143), Enum.Material.Slate)
keep.CanCollide = false
local roof = part("Castle Roof", Vector3.new(25, 3, 25), CFrame.new(0, 21, 0), Color3.fromRGB(157, 54, 47), Enum.Material.Slate)
roof.CanCollide = false
local core = part("Kingdom Crystal", Vector3.new(6, 6, 6), CFrame.new(0, 26, 0), Color3.fromRGB(65, 220, 255), Enum.Material.Neon)
core.Shape = Enum.PartType.Ball
core.CanCollide = false

local spawnPositions = {
	Vector3.new(-75, 2, -75),
	Vector3.new(75, 2, -75),
	Vector3.new(-75, 2, 75),
	Vector3.new(75, 2, 75)
}
for _, pos in ipairs(spawnPositions) do
	part("Path Marker", Vector3.new(13, 0.3, 13), CFrame.new(pos.X, 0.2, pos.Z), Color3.fromRGB(150, 124, 85), Enum.Material.Cobblestone)
end
for i = 1, 12 do
	local angle = math.rad(i * 30)
	local x, z = math.cos(angle) * 88, math.sin(angle) * 88
	part("Boundary", Vector3.new(7, 10, 2), CFrame.new(x, 4, z) * CFrame.Angles(0, -angle, 0), Color3.fromRGB(89, 64, 42), Enum.Material.Wood)
end

local function makeStat(parent, name, value)
	local v = Instance.new("IntValue")
	v.Name, v.Value, v.Parent = name, value, parent
	return v
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name, leaderstats.Parent = "leaderstats", player
	makeStat(leaderstats, "Altin", 250)
	makeStat(leaderstats, "Dalga", 0)
	makeStat(leaderstats, "KuleSeviyesi", 1)

	player.CharacterAdded:Connect(function(char)
		task.wait(0.25)
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = CFrame.new(0, 5, 38) end
	end)

	task.delay(2, function()
		if player.Parent then
			remote:FireClient(player, "Status", {wave = wave, core = coreHealth, maxCore = coreMaxHealth})
		end
	end)
end)

local function announce(kind, data)
	for _, player in ipairs(Players:GetPlayers()) do
		remote:FireClient(player, kind, data)
	end
end

local function getGold(player)
	local ls = player:FindFirstChild("leaderstats")
	return ls and ls:FindFirstChild("Altin")
end

local function spawnEnemy(isBoss)
	local pos = spawnPositions[math.random(1, #spawnPositions)]
	local kind = "Goblin"
	local roll = math.random()

	if isBoss then
		kind = "Ork Chief"
	elseif wave >= 5 and roll < 0.18 then
		kind = "Ork"
	elseif wave >= 3 and roll < 0.42 then
		kind = "Tank Goblin"
	end

	local configs = {
		["Goblin"] = {
			health = 60, speed = 12, damage = 8, reward = 18,
			color = Color3.fromRGB(88, 170, 65), size = Vector3.new(3, 4, 2), label = "GOBLİN"
		},
		["Tank Goblin"] = {
			health = 150, speed = 7, damage = 18, reward = 34,
			color = Color3.fromRGB(65, 115, 55), size = Vector3.new(4, 5, 3), label = "ZIRHLI"
		},
		["Ork"] = {
			health = 240, speed = 9, damage = 28, reward = 55,
			color = Color3.fromRGB(160, 75, 55), size = Vector3.new(5, 6, 4), label = "ORK"
		},
		["Ork Chief"] = {
			health = 650, speed = 7, damage = 45, reward = 160,
			color = Color3.fromRGB(115, 35, 35), size = Vector3.new(7, 8, 6), label = "ORK ŞEFİ"
		}
	}
	local cfg = configs[kind]

	local model = Instance.new("Model")
	model.Name = kind
	model:SetAttribute("EnemyType", kind)
	model.Parent = map

	local body = Instance.new("Part")
	body.Name, body.Size = "HumanoidRootPart", cfg.size
	body.Position = Vector3.new(pos.X, cfg.size.Y / 2 + 1, pos.Z)
	body.Color, body.Material, body.Anchored = cfg.color, Enum.Material.SmoothPlastic, false
	body.Parent = model
	body:SetNetworkOwner(nil)

	local head = Instance.new("Part")
	head.Name, head.Shape = "Head", Enum.PartType.Ball
	head.Size = kind == "Ork Chief" and Vector3.new(3.2, 3.2, 3.2) or Vector3.new(2.2, 2.2, 2.2)
	head.Position = body.Position + Vector3.new(0, cfg.size.Y / 2 + 0.2, 0)
	head.Color, head.Parent = Color3.fromRGB(115, 190, 75), model

	local weld = Instance.new("WeldConstraint")
	weld.Part0, weld.Part1, weld.Parent = body, head, body

	local hum = Instance.new("Humanoid")
	hum.MaxHealth = cfg.health + wave * (isBoss and 40 or 14)
	hum.Health = hum.MaxHealth
	hum.WalkSpeed = math.min(cfg.speed + wave * 0.15, isBoss and 12 or 18)
	hum.Parent = model
	model.PrimaryPart = body

	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.fromOffset(120, 24)
	tag.StudsOffset = Vector3.new(0, cfg.size.Y + 2, 0)
	tag.AlwaysOnTop = true
	tag.Parent = head

	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency, label.TextScaled = UDim2.fromScale(1, 1), 1, true
	label.TextColor3, label.TextStrokeTransparency, label.Text = Color3.new(1, 1, 1), 0.15, cfg.label
	label.Font = Enum.Font.GothamBold
	label.Parent = tag

	enemies[model] = hum
	if isBoss then announce("Message", "ORK ŞEFİ geldi! Kristali koru!") end

	hum.Died:Connect(function()
		enemies[model] = nil
		for _, player in ipairs(Players:GetPlayers()) do
			local gold = getGold(player)
			if gold then gold.Value += cfg.reward + wave * (isBoss and 10 or 2) end
		end
		announce("Message", cfg.label .. " yenildi! Takım altın kazandı.")
		Debris:AddItem(model, 2)
	end)

	task.spawn(function()
		while model.Parent and hum.Health > 0 and coreHealth > 0 do
			local target = Vector3.new(0, 2, 0)
			local distance = (body.Position - target).Magnitude
			if distance < 9 then
				coreHealth = math.max(0, coreHealth - (cfg.damage + wave))
				announce("Status", {wave = wave, core = coreHealth, maxCore = coreMaxHealth})
				task.wait(1.2)
			else
				hum:MoveTo(target)
				task.wait(0.6)
			end
		end
	end)
end

local function createGuard(position)
	local model = Instance.new("Model")
	model.Name = "Castle Guard"
	model.Parent = map

	local body = part(
		"Guard Body", Vector3.new(2, 4, 1.5),
		CFrame.new(position.X, 2.5, position.Z),
		Color3.fromRGB(55, 85, 145), Enum.Material.Metal, model
	)
	local head = part(
		"Guard Head", Vector3.new(1.8, 1.8, 1.8),
		CFrame.new(position.X, 5.4, position.Z),
		Color3.fromRGB(220, 180, 135), Enum.Material.SmoothPlastic, model
	)
	head.Shape = Enum.PartType.Ball
	part(
		"Guard Sword", Vector3.new(0.35, 3, 0.35),
		CFrame.new(position.X + 1.25, 2.7, position.Z) * CFrame.Angles(0, 0, math.rad(-18)),
		Color3.fromRGB(210, 215, 225), Enum.Material.Metal, model
	)
	return model, body
end

local function placeDefense(player, kind, position)
	if kind ~= "Wall" and kind ~= "Tower" and kind ~= "Guard" then return end
	if typeof(position) ~= "Vector3" then return end
	if position.X ~= position.X or position.Y ~= position.Y or position.Z ~= position.Z then return end
	if math.abs(position.X) > 90 or math.abs(position.Z) > 90 then return end
	if (position - arenaCenter).Magnitude > 78 or position.Y < -2 or position.Y > 4 then return end
	if Vector3.new(position.X, 0, position.Z).Magnitude < 17 then
		remote:FireClient(player, "Message", "Kale çevresine bina yerleştiremezsin.")
		return
	end

	local char = player.Character
	local playerRoot = char and char:FindFirstChild("HumanoidRootPart")
	if not playerRoot or (playerRoot.Position - position).Magnitude > 110 then return end

	local gold = getGold(player)
	local costs = {Wall = 70, Tower = 130, Guard = 180}
	local cost = costs[kind]
	if not gold or gold.Value < cost then
		remote:FireClient(player, "Message", "Yeterli altının yok!")
		return
	end

	local flat = Vector3.new(position.X, 0, position.Z)
	for _, defense in ipairs(defenses) do
		if defense.part and defense.part.Parent then
			local other = Vector3.new(defense.part.Position.X, 0, defense.part.Position.Z)
			if (other - flat).Magnitude < 9 then
				remote:FireClient(player, "Message", "Buraya çok yakın başka bir savunma var.")
				return
			end
		end
	end

	gold.Value -= cost
	if kind == "Wall" then
		local p = part(
			"Castle Wall", Vector3.new(9, 7, 3),
			CFrame.new(position.X, 3.5, position.Z),
			Color3.fromRGB(130, 132, 143), Enum.Material.Slate
		)
		table.insert(defenses, {part = p, kind = "Wall", level = 1})
	elseif kind == "Tower" then
		local base = part(
			"Archer Tower", Vector3.new(6, 9, 6),
			CFrame.new(position.X, 4.5, position.Z),
			Color3.fromRGB(120, 80, 49), Enum.Material.Wood
		)
		local top = part(
			"Tower Roof", Vector3.new(8, 2, 8),
			CFrame.new(position.X, 10, position.Z),
			Color3.fromRGB(155, 48, 43), Enum.Material.Slate
		)
		part(
			"Tower Flag", Vector3.new(0.4, 5, 0.4),
			CFrame.new(position.X, 13, position.Z),
			Color3.fromRGB(240, 210, 80), Enum.Material.Neon
		)
		table.insert(defenses, {part = base, top = top, kind = "Tower", lastShot = 0, level = 1})
	else
		local model, body = createGuard(position)
		table.insert(defenses, {part = body, model = model, kind = "Guard", lastShot = 0, level = 1})
	end

	local names = {Wall = "Duvar inşa edildi!", Tower = "Okçu kulesi kuruldu!", Guard = "Muhafız göreve başladı!"}
	remote:FireClient(player, "Message", names[kind])
end

local function upgradeNearestDefense(player)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local gold = getGold(player)
	if not root or not gold then return end

	local chosen, best = nil, 35
	for _, defense in ipairs(defenses) do
		if (defense.kind == "Tower" or defense.kind == "Guard") and defense.part and defense.part.Parent then
			local distance = (defense.part.Position - root.Position).Magnitude
			if distance < best then chosen, best = defense, distance end
		end
	end

	if not chosen then
		remote:FireClient(player, "Message", "Geliştirmek için kuleye veya muhafıza yaklaş!")
		return
	end
	if chosen.level >= 5 then
		remote:FireClient(player, "Message", "Bu savunma en yüksek seviyede!")
		return
	end

	local cost = 150 * chosen.level
	if gold.Value < cost then
		remote:FireClient(player, "Message", "Geliştirme için " .. cost .. " altın gerekli.")
		return
	end

	gold.Value -= cost
	chosen.level += 1
	if chosen.kind == "Tower" then
		chosen.part.Size += Vector3.new(0.5, 1, 0.5)
		chosen.part.Color = Color3.fromRGB(115 + chosen.level * 12, 80, 49)
		if chosen.top then chosen.top.Size += Vector3.new(0.5, 0, 0.5) end
	else
		chosen.part.Size += Vector3.new(0.2, 0.5, 0.2)
		chosen.part.Color = Color3.fromRGB(55 + chosen.level * 12, 85, 145)
	end
	remote:FireClient(player, "Message", "Savunma seviye " .. chosen.level .. " oldu! Hasarı ve menzili arttı.")
end

remote.OnServerEvent:Connect(function(player, action, data)
	if typeof(action) ~= "string" then return end

	local now = os.clock()
	local previous = playerActionTimes[player] or 0
	if now - previous < 0.15 then return end
	playerActionTimes[player] = now

	if action == "Place" and typeof(data) == "table" then
		placeDefense(player, data.kind, data.position)
	elseif action == "UpgradeDefense" or action == "UpgradeTower" then
		upgradeNearestDefense(player)
	elseif action == "Attack" then
		local lastAttack = playerAttackTimes[player] or 0
		if now - lastAttack < 0.55 then return end
		playerAttackTimes[player] = now

		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local target, best = nil, 12
		for model, hum in pairs(enemies) do
			local enemyRoot = model:FindFirstChild("HumanoidRootPart")
			if enemyRoot and hum.Health > 0 then
				local distance = (enemyRoot.Position - root.Position).Magnitude
				if distance < best then target, best = hum, distance end
			end
		end
		if target then target:TakeDamage(35) end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	playerActionTimes[player] = nil
	playerAttackTimes[player] = nil
end)

-- Towers and guards automatically attack the nearest enemy in range.
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, defense in ipairs(defenses) do
		if (defense.kind == "Tower" or defense.kind == "Guard") and defense.part and defense.part.Parent then
			local level = defense.level or 1
			local cooldown = defense.kind == "Tower" and 1.1 or 1.4
			if now - (defense.lastShot or 0) >= cooldown then
				defense.lastShot = now
				local range = defense.kind == "Tower" and (48 + (level - 1) * 6) or (30 + (level - 1) * 4)
				local nearest, nearestDistance
				for model, hum in pairs(enemies) do
					local enemyRoot = model:FindFirstChild("HumanoidRootPart")
					if enemyRoot and hum.Health > 0 then
						local distance = (enemyRoot.Position - defense.part.Position).Magnitude
						if distance < range and (not nearestDistance or distance < nearestDistance) then
							nearest, nearestDistance = hum, distance
						end
					end
				end
				if nearest then
					local damage = defense.kind == "Tower" and (16 + (level - 1) * 10) or (12 + (level - 1) * 8)
					nearest:TakeDamage(damage)
				end
			end
		end
	end
end)

task.spawn(function()
	task.wait(8)
	while true do
		wave += 1
		for _, player in ipairs(Players:GetPlayers()) do
			local ls = player:FindFirstChild("leaderstats")
			if ls and ls:FindFirstChild("Dalga") then ls.Dalga.Value = wave end
		end

		announce("Wave", {wave = wave, core = coreHealth, maxCore = coreMaxHealth})
		local count = math.min(3 + wave * 2, 24)
		for i = 1, count do
			if coreHealth <= 0 then break end
			local bossWave = wave % 5 == 0 and i == count
			spawnEnemy(bossWave)
			task.wait(math.max(0.35, 1.5 - wave * 0.04))
		end

		repeat task.wait(1) until next(enemies) == nil or coreHealth <= 0
		if coreHealth <= 0 then
			announce("GameOver", {wave = wave})
			break
		end

		for _, player in ipairs(Players:GetPlayers()) do
			local gold = getGold(player)
			if gold then gold.Value += 60 + wave * 5 end
		end
		task.wait(8)
	end
end)
