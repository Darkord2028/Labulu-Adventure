local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponManager = require(ReplicatedStorage:WaitForChild("Managers"):WaitForChild("WeaponManager"))

-- Remote Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequestEvent")
local equipEvent = Events:WaitForChild("EquipWeaponEvent")

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = 0
	xp.Parent = leaderstats
end)

attackEvent.OnServerEvent:Connect(function(player)
	WeaponManager:Attack(player)
end)

equipEvent.OnServerEvent:Connect(function(player, weaponName)
	WeaponManager:EquipWeapon(player, weaponName)
end)
