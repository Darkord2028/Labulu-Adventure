-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequestEvent")
local equipEvent = Events:WaitForChild("EquipWeaponEvent")
local addItemEvent = Events:WaitForChild("AddItemEvent")

-- Local Player Flags
local isWeaponEquipped = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if
		input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Enum.KeyCode.E
		and not isWeaponEquipped
	then
		isWeaponEquipped = true
		equipEvent:FireServer("TreeBranch")
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and isWeaponEquipped then
		attackEvent:FireServer()
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		addItemEvent:FireServer("TreeBranch", 1)
	end
end)
