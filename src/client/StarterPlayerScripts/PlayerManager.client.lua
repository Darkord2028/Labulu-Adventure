local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local WeaponManager = require(character:WaitForChild("Managers"):WaitForChild("WeaponManager"))

WeaponManager:EquipWeapon(localPlayer, "Tree Branch")
