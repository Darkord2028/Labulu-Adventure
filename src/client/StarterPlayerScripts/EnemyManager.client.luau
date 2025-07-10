local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Enemies = ReplicatedStorage:WaitForChild("Enemies")
local Events = ReplicatedStorage:WaitForChild("Events")
local EnemyDiedEvent = Events:WaitForChild("EnemyDiedEvent")

local baseHealth = 100
local spawnCount = 0
local healthIncrease = 50
local xpReward = 50

local spawnPoints = CollectionService:GetTagged("EnemySpawner")
if #spawnPoints == 0 then
	warn("No spawn points tagged as 'EnemySpawner' in the workspace.")
end

local usedPoints = {} -- Track which spawn points are in use

local function getAvailableSpawnPoint()
	local available = {}
	for _, point in ipairs(spawnPoints) do
		if not usedPoints[point] then
			table.insert(available, point)
		end
	end
	if #available > 0 then
		return available[math.random(1, #available)]
	else
		return nil
	end
end

local function spawnEnemyAt(spawnPart)
	local enemyTemplates = Enemies:GetChildren()
	if #enemyTemplates == 0 then
		warn("No enemy templates found in ReplicatedStorage.Enemies")
		return
	end

	local enemyModel = enemyTemplates[math.random(1, #enemyTemplates)]:Clone()
	enemyModel.Parent = workspace
	enemyModel:SetAttribute("EnemyId", HttpService:GenerateGUID(false))
	enemyModel:SetPrimaryPartCFrame(spawnPart.CFrame + Vector3.new(0, 6, 0))

	usedPoints[spawnPart] = true

	local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.MaxHealth = baseHealth + (math.floor(spawnCount / 3) * healthIncrease)
		humanoid.Health = humanoid.MaxHealth

		humanoid.Died:Connect(function()
			EnemyDiedEvent:FireAllClients(50)
			enemyModel:Destroy()
			usedPoints[spawnPart] = nil -- Mark spawn point as available
			spawnCount += 1
			task.wait(1)

			local nextSpawn = getAvailableSpawnPoint()
			if nextSpawn then
				spawnEnemyAt(nextSpawn)
			end
		end)
	end

	return enemyModel
end

-- Initial spawn: up to available spawn point count
for i = 1, math.min(10, #spawnPoints) do
	local point = getAvailableSpawnPoint()
	if point then
		spawnEnemyAt(point)
	end
end
