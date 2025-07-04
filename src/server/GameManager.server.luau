local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponManager = require(ReplicatedStorage:WaitForChild("Managers"):WaitForChild("WeaponManager"))

-- Remote Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequestEvent")
local equipEvent = Events:WaitForChild("EquipWeaponEvent")
--local addItemEvent = Events:WaitForChild("AddItemEvent")

attackEvent.OnServerEvent:Connect(function(player)
	WeaponManager:Attack(player)
end)

equipEvent.OnServerEvent:Connect(function(player, weaponName)
	WeaponManager:EquipWeapon(player, weaponName)
end)
