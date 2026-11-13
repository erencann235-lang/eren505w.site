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

local enemies, towers = {}, {}
local playerActionTimes = {}
local wave = 0
local coreHealth = 1000
local coreMaxHealth = 1000
local arenaCenter = Vector3.new(0, 0, 0)

local function part(name, size, cf, color, material, parent)
 local p = Instance.new("Part")
 p.Name, p.Size, p.CFrame, p.Color, p.Material = name, size, cf, color, material or Enum.Material.SmoothPlastic
 p.Anchored = true
 p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
 p.Parent = parent or map
 return p
end

-- Arena and castle
part("Grass Arena", Vector3.new(190, 2, 190), CFrame.new(0, -1, 0), Color3.fromRGB(83, 145, 70), Enum.Material.Grass)
part("Castle Keep", Vector3.new(22, 20, 22), CFrame.new(0, 10, 0), Color3.fromRGB(130, 132, 143), Enum.Material.Slate)
part("Castle Roof", Vector3.new(25, 3, 25), CFrame.new(0, 21, 0), Color3.fromRGB(157, 54, 47), Enum.Material.Slate)
local core = part("Kingdom Crystal", Vector3.new(5, 8, 5), CFrame.new(0, 26, 0), Color3.fromRGB(65, 220, 255), Enum.Material.Neon)
core.Shape = Enum.PartType.Ball
core.Size = Vector3.new(6, 6, 6)
local spawnPositions = {Vector3.new(-75, 2, -75), Vector3.new(75, 2, -75), Vector3.new(-75, 2, 75), Vector3.new(75, 2, 75)}
for _, pos in ipairs(spawnPositions) do
 part("Path Marker", Vector3.new(13, .3, 13), CFrame.new(pos.X, .2, pos.Z), Color3.fromRGB(150, 124, 85), Enum.Material.Cobblestone)
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
  task.wait(.25)
  local root = char:FindFirstChild("HumanoidRootPart")
  if root then root.CFrame = CFrame.new(0, 5, 38) end
 end)
 task.delay(2, function()
  if player.Parent then remote:FireClient(player, "Status", {wave = wave, core = coreHealth, maxCore = coreMaxHealth}) end
 end)
end)

local function announce(kind, data)
 for _, player in ipairs(Players:GetPlayers()) do remote:FireClient(player, kind, data) end
end

local function getGold(player)
 local ls = player:FindFirstChild("leaderstats")
 return ls and ls:FindFirstChild("Altin")
end

local function spawnEnemy()
 local pos = spawnPositions[math.random(1, #spawnPositions)]
 local kind = "Goblin"
 local roll = math.random()
 if wave >= 5 and roll < .18 then
  kind = "Ork"
 elseif wave >= 3 and roll < .42 then
  kind = "Tank Goblin"
 end
 local configs = {
  ["Goblin"] = {health = 60, speed = 12, damage = 8, reward = 18, color = Color3.fromRGB(88, 170, 65), size = Vector3.new(3,4,2), label = "GOBLİN"},
  ["Tank Goblin"] = {health = 150, speed = 7, damage = 18, reward = 34, color = Color3.fromRGB(65, 115, 55), size = Vector3.new(4,5,3), label = "ZIRHLI"},
  ["Ork"] = {health = 240, speed = 9, damage = 28, reward = 55, color = Color3.fromRGB(160, 75, 55), size = Vector3.new(5,6,4), label = "ORK"}
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
 head.Name, head.Shape, head.Size = "Head", Enum.PartType.Ball, Vector3.new(2.2, 2.2, 2.2)
 head.Position, head.Color, head.Parent = body.Position + Vector3.new(0, cfg.size.Y / 2 + .2, 0), Color3.fromRGB(115, 190, 75), model
 local weld = Instance.new("WeldConstraint")
 weld.Part0, weld.Part1, weld.Parent = body, head, body
 local hum = Instance.new("Humanoid")
 hum.MaxHealth = cfg.health + wave * 14
 hum.Health = hum.MaxHealth
 hum.WalkSpeed = math.min(cfg.speed + wave * .15, 18)
 hum.Parent = model
 model.PrimaryPart = body
 local tag = Instance.new("BillboardGui")
 tag.Size, tag.StudsOffset, tag.AlwaysOnTop = UDim2.fromOffset(110, 22), Vector3.new(0, cfg.size.Y + 2, 0), true
 tag.Parent = head
 local label = Instance.new("TextLabel")
 label.Size, label.BackgroundTransparency, label.TextScaled = UDim2.fromScale(1, 1), 1, true
 label.TextColor3, label.TextStrokeTransparency, label.Text = Color3.new(1,1,1), .15, cfg.label
 label.Parent = tag
 enemies[model] = hum
 hum.Died:Connect(function()
  enemies[model] = nil
  for _, player in ipairs(Players:GetPlayers()) do
   local gold = getGold(player)
   if gold then gold.Value += cfg.reward + wave * 2 end
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
    task.wait(.6)
   end
  end
 end)
end

local function placeTower(player, kind, position)
 if kind ~= "Wall" and kind ~= "Tower" then return end
 if typeof(position) ~= "Vector3" then return end
 if (position - arenaCenter).Magnitude > 78 or position.Y < -2 or position.Y > 8 then return end
 local char = player.Character
 local playerRoot = char and char:FindFirstChild("HumanoidRootPart")
 if not playerRoot or (playerRoot.Position - position).Magnitude > 110 then return end
 local gold = getGold(player)
 local cost = kind == "Wall" and 70 or 130
 if not gold or gold.Value < cost then
  remote:FireClient(player, "Message", "Yeterli altının yok!")
  return
 end
 local flat = Vector3.new(position.X, 0, position.Z)
 for _, tower in ipairs(towers) do
  if tower.part and (Vector3.new(tower.part.Position.X,0,tower.part.Position.Z) - flat).Magnitude < 9 then
   remote:FireClient(player, "Message", "Buraya çok yakın başka bir bina var.")
   return
  end
 end
 gold.Value -= cost
 if kind == "Wall" then
  local p = part("Castle Wall", Vector3.new(9, 7, 3), CFrame.new(position.X, 3.5, position.Z), Color3.fromRGB(130, 132, 143), Enum.Material.Slate)
  table.insert(towers, {part = p, kind = "Wall", level = 1})
 else
  local base = part("Archer Tower", Vector3.new(6, 9, 6), CFrame.new(position.X, 4.5, position.Z), Color3.fromRGB(120, 80, 49), Enum.Material.Wood)
  local top = part("Tower Roof", Vector3.new(8, 2, 8), CFrame.new(position.X, 10, position.Z), Color3.fromRGB(155, 48, 43), Enum.Material.Slate)
  local flag = part("Tower Flag", Vector3.new(.4, 5, .4), CFrame.new(position.X, 13, position.Z), Color3.fromRGB(240, 210, 80), Enum.Material.Neon)
  table.insert(towers, {part = base, kind = "Tower", top = top, flag = flag, lastShot = 0, level = 1})
 end
 remote:FireClient(player, "Message", kind == "Wall" and "Duvar inşa edildi!" or "Okçu kulesi kuruldu!")
end

local function upgradeNearestTower(player)
 local char = player.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 local gold = getGold(player)
 if not root or not gold then return end
 local chosen, best = nil, 35
 for _, tower in ipairs(towers) do
  if tower.kind == "Tower" and tower.part and tower.part.Parent then
   local distance = (tower.part.Position - root.Position).Magnitude
   if distance < best then chosen, best = tower, distance end
  end
 end
 if not chosen then
  remote:FireClient(player, "Message", "Yükseltmek için bir kuleye yaklaş!")
  return
 end
 if chosen.level >= 5 then
  remote:FireClient(player, "Message", "Bu kule en yüksek seviyede!")
  return
 end
 local cost = 150 * chosen.level
 if gold.Value < cost then
  remote:FireClient(player, "Message", "Kule yükseltmek için " .. cost .. " altın gerekli.")
  return
 end
 gold.Value -= cost
 chosen.level += 1
 chosen.part.Size = chosen.part.Size + Vector3.new(.5, 1, .5)
 chosen.part.Color = Color3.fromRGB(115 + chosen.level * 12, 80, 49)
 chosen.top.Size = chosen.top.Size + Vector3.new(.5, 0, .5)
 remote:FireClient(player, "Message", "Kule seviye " .. chosen.level .. " oldu! Hasarı ve menzili arttı.")
end

remote.OnServerEvent:Connect(function(player, action, data)
 if typeof(action) ~= "string" then return end
 local now = os.clock()
 local previous = playerActionTimes[player] or 0
 if now - previous < .18 then return end
 playerActionTimes[player] = now
 if action == "Place" and typeof(data) == "table" then
  placeTower(player, data.kind, data.position)
 elseif action == "UpgradeTower" then
  upgradeNearestTower(player)
 elseif action == "Attack" then
  local char = player.Character
  local root = char and char:FindFirstChild("HumanoidRootPart")
  if not root then return end
  local target, best = nil, 12
  for model, hum in pairs(enemies) do
   local enemyRoot = model:FindFirstChild("HumanoidRootPart")
   if enemyRoot and hum.Health > 0 then
    local d = (enemyRoot.Position - root.Position).Magnitude
    if d < best then target, best = hum, d end
   end
  end
  if target then target:TakeDamage(35) end
 end
end)

Players.PlayerRemoving:Connect(function(player)
 playerActionTimes[player] = nil
end)

-- Tower auto-fire
RunService.Heartbeat:Connect(function()
 for _, tower in ipairs(towers) do
  if tower.kind == "Tower" and tower.part and os.clock() - tower.lastShot > 1.1 then
   local nearest, nearestDist
   for model, hum in pairs(enemies) do
    local root = model:FindFirstChild("HumanoidRootPart")
    if root and hum.Health > 0 then
     local d = (root.Position - tower.part.Position).Magnitude
     if d < (48 + ((tower.level or 1) - 1) * 6) and (not nearestDist or d < nearestDist) then nearest, nearestDist = hum, d end
    end
   end
   if nearest then
    tower.lastShot = os.clock()
    nearest:TakeDamage(16 + ((tower.level or 1) - 1) * 10)
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
   spawnEnemy()
   task.wait(math.max(.35, 1.5 - wave * .04))
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
