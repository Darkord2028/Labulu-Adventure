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

	local Money = Instance.new("IntValue")
	Money.Name = "Money"
	Money.Value = 0
	Money.Parent = leaderstats

	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Humanoid") -- Ensure character is fully loaded
		WeaponManager:EquipWeapon(player, "TreeBranch")
		equipEvent:FireClient(player, "rbxthumb://type=Asset&id=74079277949819&w=420&h=420")
	end)
end)

attackEvent.OnServerEvent:Connect(function(player)
	WeaponManager:Attack(player)
end)

equipEvent.OnServerEvent:Connect(function(player, weaponName)
	WeaponManager:EquipWeapon(player, weaponName)
	equipEvent:FireClient(player, weaponName)
end)
