-- KRALLIK SAVUNMASI | StarterPlayer > StarterPlayerScripts > KingdomClient
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("KingdomEvent")
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "KingdomHUD", false, player:WaitForChild("PlayerGui")
local function label(text, size, pos, color)
 local l = Instance.new("TextLabel")
 l.Size, l.Position = size, pos
 l.BackgroundColor3, l.BackgroundTransparency = Color3.fromRGB(31, 43, 32), .12
 l.TextColor3, l.Text, l.TextScaled = Color3.new(1,1,1), text, true
 l.Font, l.Parent = Enum.Font.GothamBold, gui
 local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = l
 return l
end
local function button(text, size, pos, color)
 local b = Instance.new("TextButton")
 b.Size, b.Position = size, pos
 b.BackgroundColor3, b.TextColor3 = color or Color3.fromRGB(190, 133, 54), Color3.new(1,1,1)
 b.Text, b.TextScaled, b.Font = text, true, Enum.Font.GothamBold
 b.Parent = gui
 local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = b
 return b
end

local title = label("🏰 KRALLIK SAVUNMASI", UDim2.fromOffset(280, 42), UDim2.fromOffset(14, 14))
title.TextSize = 20
local stats = label("💎 Kale Kristali: 1000 / 1000", UDim2.fromOffset(260, 36), UDim2.fromOffset(14, 62))
local waveLabel = label("⚔️ Dalga: Hazırlan", UDim2.fromOffset(180, 36), UDim2.fromOffset(14, 104))
local message = label("Düşmanlara karşı kaleni koru!", UDim2.new(0.55, 0, 0, 38), UDim2.new(.225, 0, 0, 14))
message.TextSize = 16
local tower = button("🏹 OKÇU KULESİ 130 ALTIN", UDim2.fromOffset(220, 46), UDim2.new(1, -234, 1, -116))
local wall = button("🧱 DUVAR 70 ALTIN", UDim2.fromOffset(220, 46), UDim2.new(1, -234, 1, -62), Color3.fromRGB(90, 115, 145))
local attack = button("⚔️ VUR", UDim2.fromOffset(130, 62), UDim2.new(1, -150, .5, -31), Color3.fromRGB(170, 55, 48))
local mode = nil
tower.MouseButton1Click:Connect(function() mode = "Tower"; message.Text = "Kuleyi yerleştirmek için zeminde bir yere tıkla." end)
wall.MouseButton1Click:Connect(function() mode = "Wall"; message.Text = "Duvarı yerleştirmek için zeminde bir yere tıkla." end)
attack.MouseButton1Click:Connect(function() remote:FireServer("Attack") end)
mouse.Button1Down:Connect(function()
 if mode then
  local hit = mouse.Hit
  if hit then remote:FireServer("Place", {kind = mode, position = hit.Position}) end
  mode = nil
 end
end)
UserInputService.InputBegan:Connect(function(input, processed)
 if processed then return end
 if input.KeyCode == Enum.KeyCode.E then remote:FireServer("Attack") end
end)
remote.OnClientEvent:Connect(function(kind, data)
 if kind == "Status" or kind == "Wave" then
  stats.Text = "💎 Kale Kristali: " .. tostring(data.core) .. " / " .. tostring(data.maxCore)
  if kind == "Wave" then waveLabel.Text = "⚔️ DALGA " .. tostring(data.wave) end
 elseif kind == "Message" then
  message.Text = tostring(data)
 elseif kind == "GameOver" then
  message.Text = "💀 KALE DÜŞTÜ! Son dalga: " .. tostring(data.wave)
  message.BackgroundColor3 = Color3.fromRGB(130, 35, 35)
 end
end)
