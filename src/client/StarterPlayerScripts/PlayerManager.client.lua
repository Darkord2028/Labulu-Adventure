-- Game Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Players
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Camera
local cam = Workspace.CurrentCamera

-- Leaderboard
local leaderboard = LocalPlayer:WaitForChild("leaderstats")
local XP = leaderboard:WaitForChild("XP")

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local attackEvent = Events:WaitForChild("AttackRequestEvent")
local equipEvent = Events:WaitForChild("EquipWeaponEvent")
local finishedAttackEvent = Events:WaitForChild("FinishedAttackEvent")
local DisplayDamagePopUpEvent = Events:WaitForChild("DisplayDamagePopUpEvent")
local EnemyDiedEvent = Events:WaitForChild("EnemyDiedEvent")

local DamagePopUpPoolModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DamagePopUpPoolModule"))
local DamagePopUpPool = DamagePopUpPoolModule.new(20)

-- GUI
local PlayerGui = LocalPlayer.PlayerGui
local InventoryGUI = PlayerGui:WaitForChild("InventoryGUI")
local PlayerName = InventoryGUI.PlayerNameFrame.NameTextLabel
PlayerName.Text = LocalPlayer.Name
local CurrentWeaponImage = InventoryGUI.CurrentWeapon
local XPTextLabel = InventoryGUI.XPFrame.XP

-- Audio
local Audio = ReplicatedStorage:WaitForChild("Audio")
local DamageAudio = Audio:WaitForChild("Damage")
DamageAudio.Volume = 0.5
local EquipAudio = Audio:WaitForChild("Equip")
EquipAudio.Volume = 0.5

-- Weapons
local itemsData = require(ReplicatedStorage.Modules.WeaponModule)

-- XP
local CurrentXP = 0
local XPForNextLevel = 0

-- Local Player Flags
local isWeaponEquipped = false
local isAttacking = false

local function UpdateXP(XPReward)
	for _, data in pairs(itemsData) do
		if data.Enabled then
			if data.Cost >= XPReward then
				CurrentXP = XPReward
				XPForNextLevel = data.Cost
				print(CurrentXP .. " " .. XPForNextLevel)
			end
		else
			print("Weapon Ended")
		end
	end
end

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

equipEvent.OnClientEvent:Connect(function(weaponImage)
	isWeaponEquipped = true
	EquipAudio:Play()
	CurrentWeaponImage.Image = weaponImage
end)

DisplayDamagePopUpEvent.OnClientEvent:Connect(function(position, damage)
	DamagePopUpPool:Display(position, damage)
	DamageAudio:Play()
	screenShake(0.1, 0.1)
end)

EnemyDiedEvent.OnClientEvent:Connect(function(xpReward)
	XP.Value = XP.Value + xpReward
	XPTextLabel.Text = XP.Value
	UpdateXP(xpReward)
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
