local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponModule"))

local WeaponModels = ReplicatedStorage:WaitForChild("Weapons")

local WeaponManager = {}
WeaponManager.CurrentWeapon = {}

function WeaponManager:EquipWeapon(player, weaponName)
	local weaponData = WeaponModule[weaponName]
	if not weaponData then
		warn("Weapon not found: " .. weaponName)
		return
	end

	local character = player.Character
	if not character then
		warn("Player character not found for player: " .. player.Name)
		return
	end

	if self.CurrentWeapon and typeof(self.CurrentWeapon) == "Instance" then
		self.CurrentWeapon:Destroy()
		self.CurrentWeapon = nil
	end

	local weaponModel = WeaponModels:FindFirstChild(weaponData.ModelName)
	if weaponModel then
		local cloneModel = weaponModel:Clone()
		cloneModel.Parent = character

		local handle = cloneModel:FindFirstChild("Handle") or cloneModel:FindFirstChild("BasePart")
		local RightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")

		if handle and RightHand then
			if cloneModel.PrimaryPart then
				cloneModel:SetPrimaryPartCFrame(RightHand.CFrame)
			end

			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = RightHand
			motor6D.Part1 = handle
			motor6D.Parent = handle
		end

		cloneModel:SetAttribute("Damage", weaponData.Damage)
		self.CurrentWeapon = cloneModel
	end
end

return WeaponManager
