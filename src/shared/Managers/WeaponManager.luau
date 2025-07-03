local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WeaponModule"))
local WeaponModels = ReplicatedStorage:WaitForChild("Weapons")
local Animations = ReplicatedStorage:WaitForChild("Animations")

local WeaponManager = {}
WeaponManager.PlayerWeapons = {}

function WeaponManager:EquipWeapon(player, weaponName)
	local weaponData = WeaponModule[weaponName]
	print(weaponData["Pick Axe"])
	if not weaponData then
		warn("Weapon not found:", weaponName)
		return
	end

	local character = player.Character
	if not character then
		warn("Character not found for", player.Name)
		return
	end

	-- Cleanup previous weapon
	local playerData = self.PlayerWeapons[player.UserId]
	if playerData and playerData.weapon and playerData.weapon:IsDescendantOf(game) then
		playerData.weapon:Destroy()
	end

	-- Clone and attach weapon
	local model = WeaponModels:FindFirstChild(weaponData.ModelName)
	if not model then
		warn("Weapon model missing:", weaponData.ModelName)
		return
	end

	local weapon = model:Clone()
	weapon.Parent = character

	local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChild("BasePart")
	local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if handle and rightHand then
		local motor = Instance.new("Motor6D")
		motor.Part0 = rightHand
		motor.Part1 = handle
		motor.Parent = rightHand
	end

	weapon:SetAttribute("Damage", weaponData.Damage)

	local animId = weaponData.AttackAnimation
	local animObj = Animations:FindFirstChild("Attack")
	animObj.AnimationId = animId

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local dummyTrack = humanoid:LoadAnimation(animObj)
		dummyTrack:Stop()
		dummyTrack:Destroy()
	end

	self.PlayerWeapons[player.UserId] = {
		weapon = weapon,
		hitbox = weapon:FindFirstChild("Hitbox"),
		anim = animId,
		animObj = animObj,
	}

	-- Inside EquipWeapon
	local hitbox = weapon:FindFirstChild("Hitbox")
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
end

function WeaponManager:Attack(player)
	local data = self.PlayerWeapons[player.UserId]
	if not data then
		warn("No weapon equipped for", player.Name)
		return
	end

	local character = player.Character
	if not character then
		warn("Character not found for", player.Name)
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		warn("Animator missing for", player.Name)
		return
	end

	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0

	local track = animator:LoadAnimation(data.animObj)
	track.Priority = Enum.AnimationPriority.Action

	local hitbox = data.hitbox
	track:GetMarkerReachedSignal("EnableHitbox"):Connect(function()
		if hitbox then
			hitbox.BrickColor = BrickColor.new("Bright red")
			hitbox.CanTouch = true
		end
	end)

	track:GetMarkerReachedSignal("DisableHitbox"):Connect(function()
		if hitbox then
			hitbox.BrickColor = BrickColor.new("Bright blue")
			hitbox.CanTouch = false
		end
	end)

	track:Play()

	track.stopped:Connect(function()
		humanoid.WalkSpeed = originalSpeed
	end)
end

return WeaponManager
