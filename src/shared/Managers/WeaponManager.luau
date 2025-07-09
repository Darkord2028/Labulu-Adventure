local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponModule"))
local WeaponModels = ReplicatedStorage:WaitForChild("Weapons")

local Events = ReplicatedStorage:WaitForChild("Events")
local finishedAttackEvent = Events:WaitForChild("FinishedAttackEvent")
local DisplayDamagePopUpEvent = Events:WaitForChild("DisplayDamagePopUpEvent")

-- Raycast Variables
local rayCount = 5
local damageArcAngle = math.rad(90)
local rayLength = 6

local WeaponManager = {}
WeaponManager.PlayerWeapons = {}

local function makeStorageFolder(player: Player): Folder
	local folder = Instance.new("Folder")
	folder.Name = "WeaponStorage"
	folder.Parent = player
	return folder
end

local function drawRay(origin: Vector3, direction: Vector3, color: Color3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.1, 0.1, direction.Magnitude)
	part.CFrame = CFrame.new(origin + direction / 2, origin + direction)
	part.Color = color or Color3.new(1, 0, 0)
	part.Material = Enum.Material.Neon
	part.Parent = workspace

	game:GetService("Debris"):AddItem(part, 0.3)
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
		local rootCFrame = rootPart.CFrame

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { char }

		local hitEnemies = {}

		for i = 0, rayCount - 1 do
			local t = (i / (rayCount - 1)) * 2 - 1
			local angle = t * (damageArcAngle / 2)
			local rotatedDirection = (rootCFrame * CFrame.Angles(0, angle, 0)).LookVector

			--drawRay(rayOrigin, rotatedDirection * rayLength, Color3.fromRGB(255, 255, 0)) -- Debug line

			local result = workspace:Raycast(rayOrigin, rotatedDirection * rayLength, raycastParams)
			if result then
				local enemy = result.Instance:FindFirstAncestorOfClass("Model")
				local enemyHumanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
				local enemyHead = enemy and (enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart"))

				if enemy and enemyHumanoid and enemyHumanoid.Health > 0 and not hitEnemies[enemy] then
					hitEnemies[enemy] = true
					local damage = weaponData.def.Damage or 10
					enemyHumanoid:TakeDamage(damage)
					if enemyHead then
						DisplayDamagePopUpEvent:FireClient(player, enemyHead, damage)
					end
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
