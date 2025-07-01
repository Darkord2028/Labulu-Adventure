local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local weaponManager = require(character:WaitForChild("Managers"):WaitForChild("WeaponManager"))

		-- Equip a weapon when the character is added
		weaponManager:EquipWeapon(player, "Pick Axe")
	end)
end)
