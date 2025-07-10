-- Game Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Players
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local head = character:FindFirstChild("Head")

-- Camera
local cam = Workspace.CurrentCamera

-- Leaderboard
local leaderboard = LocalPlayer:WaitForChild("leaderstats")
local Money = leaderboard:WaitForChild("Money")

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequestEvent")
local equipEvent = Events:WaitForChild("EquipWeaponEvent")
local finishedAttackEvent = Events:WaitForChild("FinishedAttackEvent")
local DisplayDamagePopUpEvent = Events:WaitForChild("DisplayDamagePopUpEvent")
local EnemyDiedEvent = Events:WaitForChild("EnemyDiedEvent")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local DamagePopUpPoolModule = require(Modules:WaitForChild("DamagePopUpPoolModule"))
local DamagePopUpPool = DamagePopUpPoolModule.new(5)

local MoneyPoolModule = require(Modules:WaitForChild("MoneyPoolModule"))
MoneyPool = MoneyPoolModule.new(5)

-- GUI
local PlayerGui = LocalPlayer.PlayerGui
local InventoryGUI = PlayerGui:WaitForChild("InventoryGUI")
local MoneyTextLabel = InventoryGUI.MoneyFrame.Money

-- Audio
local Audio = ReplicatedStorage:WaitForChild("Audio")
local DamageAudio = Audio:WaitForChild("Damage")
DamageAudio.Volume = 0.5
local EquipAudio = Audio:WaitForChild("Equip")
EquipAudio.Volume = 0.5
local CashCollect = Audio:WaitForChild("CashCollect")
CashCollect.Volume = 0.5

-- Local Player Flags
local isWeaponEquipped = false
local isAttacking = false

local function screenShake(duration, magnitude)
	local startTime = tick()

	RunService:BindToRenderStep("ScreenShake", Enum.RenderPriority.Camera.Value + 1, function()
		local elapsed = tick() - startTime
		if elapsed > duration then
			RunService:UnbindFromRenderStep("ScreenShake")
			cam.CFrame = cam.CFrame -- reset
			return
		end

		local offset = Vector3.new(
			math.random(-100, 100) / 100 * magnitude,
			math.random(-100, 100) / 100 * magnitude,
			math.random(-100, 100) / 100 * magnitude
		)

		cam.CFrame = cam.CFrame * CFrame.new(offset)
	end)
end

finishedAttackEvent.OnClientEvent:Connect(function()
	isAttacking = false
end)

equipEvent.OnClientEvent:Connect(function(weapon)
	isWeaponEquipped = true
	EquipAudio:Play()
	print("Weapon Name = " .. weapon)
end)

DisplayDamagePopUpEvent.OnClientEvent:Connect(function(position, damage)
	DamagePopUpPool:Display(position, damage)
	DamageAudio:Play()
	screenShake(0.1, 0.1)
end)

EnemyDiedEvent.OnClientEvent:Connect(function(xpReward)
	Money.Value = Money.Value + xpReward
	MoneyTextLabel.Text = Money.Value
	MoneyPool:Display(head, xpReward / 10)
	CashCollect:Play()
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
