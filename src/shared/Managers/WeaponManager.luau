local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponModule"))
local WeaponModels = ReplicatedStorage:WaitForChild("Weapons")

local Events = ReplicatedStorage:WaitForChild("Events")
local finishedAttackEvent = Events:WaitForChild("FinishedAttackEvent")
local DisplayDamagePopUpEvent = Events:WaitForChild("DisplayDamagePopUpEvent")

local WeaponManager = {}
WeaponManager.PlayerWeapons = {}

local function makeStorageFolder(player: Player): Folder
	local folder = Instance.new("Folder")
	folder.Name = "WeaponStorage"
	folder.Parent = player
	return folder
end

local function getOrCreateWeapon(player: Player, weaponName: string)
	local pdata = WeaponManager.PlayerWeapons[player.UserId]
	if not pdata then
		pdata = {
			storage = makeStorageFolder(player),
			current = nil,
			weapons = {},
		}
		WeaponManager.PlayerWeapons[player.UserId] = pdata
	end

	if pdata.weapons[weaponName] then
		return pdata.weapons[weaponName]
	end

	local wDef = WeaponModule[weaponName]
	if not wDef then
		return nil
	end

	local modelSrc = WeaponModels:FindFirstChild(wDef.ModelName)
	if not modelSrc then
		warn("Missing model:", wDef.ModelName)
		return nil
	end

	local model = modelSrc:Clone()
	model.Parent = pdata.storage
	model.PrimaryPart = model:FindFirstChild("Handle") or model.PrimaryPart

	local animObj = Instance.new("Animation")
	animObj.Name = weaponName .. "_AttackAnim"
	animObj.AnimationId = wDef.AttackAnimation

	pdata.weapons[weaponName] = {
		model = model,
		animObj = animObj,
		def = wDef,
	}

	return pdata.weapons[weaponName]
end

local function clearOldMotor(model: Model)
	if not model.PrimaryPart then
		return
	end
	for _, weld in ipairs(model.PrimaryPart:GetChildren()) do
		if weld:IsA("Motor6D") and weld.Part1 == model.PrimaryPart then
			weld:Destroy()
		end
	end
end

function WeaponManager:EquipWeapon(player: Player, weaponName: string)
	local weaponData = getOrCreateWeapon(player, weaponName)
	if not weaponData then
		return
	end

	local char = player.Character
	if not char then
		return
	end

	local pdata = self.PlayerWeapons[player.UserId]
	if not pdata then
		return
	end

	if pdata.current then
		local oldData = pdata.weapons[pdata.current]
		if oldData and oldData.model and oldData.model.Parent == char then
			clearOldMotor(oldData.model)
			oldData.model.Parent = pdata.storage
		end
	end

	local weaponModel = weaponData.model
	if not weaponModel.PrimaryPart then
		warn("Weapon has no PrimaryPart:", weaponName)
		return
	end

	local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	if not rightHand then
		warn("Missing right hand")
		return
	end

	weaponModel.Parent = char
	weaponModel:SetPrimaryPartCFrame(rightHand.CFrame)

	local motor = Instance.new("Motor6D")
	motor.Part0 = rightHand
	motor.Part1 = weaponModel.PrimaryPart
	motor.Parent = rightHand

	pdata.current = weaponName
end

function WeaponManager:Attack(player: Player)
	local pdata = self.PlayerWeapons[player.UserId]
	if not pdata or not pdata.current then
		return
	end

	local weaponData = pdata.weapons[pdata.current]
	if not weaponData then
		return
	end

	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	local track = animator:LoadAnimation(weaponData.animObj)
	track.Priority = Enum.AnimationPriority.Action

	track:GetMarkerReachedSignal("EnableHitbox"):Connect(function()
		local rootPart = char:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			return
		end

		local rayOrigin = rootPart.Position
		local rayDirection = rootPart.CFrame.LookVector * 6

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { char }

		local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		if result then
			local enemy = result.Instance:FindFirstAncestorOfClass("Model")
			local enemyHumanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
			local enemyHead = enemy and (enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart"))

			if enemy and enemyHumanoid and enemyHumanoid.Health > 0 then
				local damage = weaponData.def.Damage or 10
				enemyHumanoid:TakeDamage(damage)
				if enemyHead then
					DisplayDamagePopUpEvent:FireClient(player, enemyHead, damage)
				end
			end
		end
	end)

	track:Play()
	track.Stopped:Connect(function()
		finishedAttackEvent:FireClient(player)
	end)
end

return WeaponManager
