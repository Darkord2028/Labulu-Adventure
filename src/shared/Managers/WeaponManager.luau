local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponModule"))
local WeaponModels = ReplicatedStorage:WaitForChild("Weapons")
local Animations = ReplicatedStorage:WaitForChild("Animations")

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local finishedAttackEvent = Events:WaitForChild("FinishedAttackEvent")

local WeaponManager = {}
WeaponManager.PlayerWeapons = {}

local function makeStorageFolder(player: Player): Folder
	local folder = Instance.new("Folder")
	folder.Name = "WeaponStorage"
	folder.Parent = player
	return folder
end

-- Create (or fetch) cached weapon data for this player
local function getOrCreateWeapon(player: Player, weaponName: string)
	local pdata = WeaponManager.PlayerWeapons[player.UserId]
	if not pdata then
		-- first time for this player
		pdata = {
			storage = makeStorageFolder(player),
			current = nil,
			weapons = {},
		}
		WeaponManager.PlayerWeapons[player.UserId] = pdata
	end

	-- already cached?
	if pdata.weapons[weaponName] then
		return pdata.weapons[weaponName]
	end

	-- otherwise build it once
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
	model.Parent = pdata.storage -- keep out of sight until equipped
	model.PrimaryPart = model:FindFirstChild("Handle") or model.PrimaryPart

	-- prepare animation asset
	local baseAnim = Animations:FindFirstChild("Attack")
	local animObj = baseAnim:Clone()
	animObj.AnimationId = wDef.AttackAnimation

	local hitbox = model:FindFirstChild("Hitbox")
	local debounce = {}

	if hitbox then
		hitbox.Touched:Connect(function(other)
			local enemy = other.Parent
			if not enemy then
				return
			end

			if debounce[enemy] then
				return
			end
			debounce[enemy] = true

			local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
			if enemyHumanoid then
				enemyHumanoid:TakeDamage(hitbox:GetAttribute("Damage") or 10)
				print("Enemy hit:", enemy.Name)
			end

			task.delay(0.3, function()
				debounce[enemy] = nil
			end)
		end)
	end

	-- cache
	pdata.weapons[weaponName] = {
		model = model,
		hitbox = model:FindFirstChild("Hitbox"),
		animObj = animObj,
	}
	return pdata.weapons[weaponName]
end

-- Detach any existing Motor6D we added
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

	-- Unequip current
	if pdata.current then
		local oldData = pdata.weapons[pdata.current]
		if oldData and oldData.model and oldData.model.Parent == char then
			clearOldMotor(oldData.model)
			oldData.model.Parent = pdata.storage
		end
	end

	-- Equip requested weapon
	local weaponModel = weaponData.model
	if not weaponModel.PrimaryPart then
		warn("Weapon has no PrimaryPart:", weaponName)
		return
	end

	local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	if not rightHand then
		warn("Character missing right hand")
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

	local hitbox = weaponData.hitbox
	if hitbox then
		track:GetMarkerReachedSignal("EnableHitbox"):Connect(function()
			hitbox.CanTouch = true
			hitbox.BrickColor = BrickColor.new("Bright red")
		end)
		track:GetMarkerReachedSignal("DisableHitbox"):Connect(function()
			hitbox.CanTouch = false
			hitbox.BrickColor = BrickColor.new("Bright blue")
		end)
	end

	track:Play()
	track.Stopped:Connect(function()
		finishedAttackEvent:FireClient(player)
	end)
end

return WeaponManager
