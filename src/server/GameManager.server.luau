local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponManager = require(ReplicatedStorage.Managers.WeaponManager)

local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequest")

Players.PlayerAdded:Connect(function(player)
	WeaponManager.EquipWeapon(player, "Tree Branch")
end)

attackEvent.OnServerEvent:Connect(function(player)
	WeaponManager.Attack(player)
end)
