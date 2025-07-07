-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Players
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequestEvent")
local equipEvent = Events:WaitForChild("EquipWeaponEvent")
local finishedAttackEvent = Events:WaitForChild("FinishedAttackEvent")
local DisplayDamagePopUpEvent = Events:WaitForChild("DisplayDamagePopUpEvent")

local DamagePopUpPoolModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DamagePopUpPoolModule"))
local DamagePopUpPool = DamagePopUpPoolModule.new(20)

-- GUI
local PlayerGui = LocalPlayer.PlayerGui
local InventoryGUI = PlayerGui:WaitForChild("InventoryGUI")
local CurrentWeapon = InventoryGUI.CurrentWeapon

-- Local Player Flags
local isWeaponEquipped = false
local isAttacking = false

finishedAttackEvent.OnClientEvent:Connect(function()
	isAttacking = false
end)

equipEvent.OnClientEvent:Connect(function(weaponImage)
	isWeaponEquipped = true
	CurrentWeapon.Image = weaponImage
end)

DisplayDamagePopUpEvent.OnClientEvent:Connect(function(position, damage)
	DamagePopUpPool:Display(position, damage)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and isWeaponEquipped and not isAttacking then
		attackEvent:FireServer()
		isAttacking = true
	end
end)
