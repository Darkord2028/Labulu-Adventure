-- Game Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Local Player Variables
local player = Players.LocalPlayer

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequest")
local equipEvent = Events:WaitForChild("EquipWeaponRequest")

local WeaponManager = require(ReplicatedStorage.Managers.WeaponManager)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E then
		attackEvent:FireServer()
	end
end)
