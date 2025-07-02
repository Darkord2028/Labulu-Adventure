local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Disable Jumping
Humanoid.JumpPower = 0
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

-- === Animation Setup ===
local Animations = ReplicatedStorage:WaitForChild("Animations")

local idleAnim = Animations:WaitForChild("Idle")
idleAnim.AnimationId = "rbxassetid://87581514090884"

local walkAnim = Animations:WaitForChild("Walk")
walkAnim.AnimationId = "rbxassetid://70386778159907"

local runAnim = Animations:WaitForChild("Run")
runAnim.AnimationId = "rbxassetid://107702858255480"

local attackAnim = Animations:WaitForChild("Attack")
attackAnim.AnimationId = "rbxassetid://106695665803705"

-- === Tracks ===
local idleTrack = Animator:LoadAnimation(idleAnim)
idleTrack.Looped = true
idleTrack:Play()

local walkTrack
local runTrack

-- === Constants ===
local WALK_THRESHOLD = 4
local RUN_THRESHOLD = 8

-- === Movement Logic ===
Humanoid.Running:Connect(function(speed)
	if speed > RUN_THRESHOLD then
		-- Run
		if not runTrack or not runTrack.IsPlaying then
			if walkTrack then
				walkTrack:Stop()
				walkTrack:Destroy()
				walkTrack = nil
			end
			if runTrack then
				runTrack:Destroy()
			end
			runTrack = Animator:LoadAnimation(runAnim)
			runTrack.Looped = true
			runTrack.Priority = Enum.AnimationPriority.Movement
			runTrack:Play()
		end
		if idleTrack.IsPlaying then
			idleTrack:Stop()
		end
	elseif speed > 0 and speed <= WALK_THRESHOLD then
		-- Walk
		if not walkTrack or not walkTrack.IsPlaying then
			if runTrack then
				runTrack:Stop()
				runTrack:Destroy()
				runTrack = nil
			end
			if walkTrack then
				walkTrack:Destroy()
			end
			walkTrack = Animator:LoadAnimation(walkAnim)
			walkTrack.Looped = true
			walkTrack.Priority = Enum.AnimationPriority.Movement
			walkTrack:Play()
		end
		if idleTrack.IsPlaying then
			idleTrack:Stop()
		end
	else
		-- Idle
		if runTrack then
			runTrack:Stop()
			runTrack:Destroy()
			runTrack = nil
		end
		if walkTrack then
			walkTrack:Stop()
			walkTrack:Destroy()
			walkTrack = nil
		end
		if not idleTrack.IsPlaying then
			idleTrack:Play()
		end
	end
end)
