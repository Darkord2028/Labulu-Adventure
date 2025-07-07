local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer.PlayerGui
local InventoryGUI = playerGui:WaitForChild("InventoryGUI")

local inventoryTemplate = playerGui.Template:WaitForChild("InventoryTemplate")
local inventoryScroll = InventoryGUI.Inventory.Scroll

local itemsData = require(ReplicatedStorage.Modules.WeaponModule)

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local EquipEvent = Events:WaitForChild("EquipWeaponEvent")

-- Data
local playerXP = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("XP")
local currentXP = playerXP.Value

local cache = {}

local sortedWeapons = {}
for name, data in pairs(itemsData) do
	if data.Enabled then
		table.insert(sortedWeapons, { Name = name, Data = data })
	end
end

table.sort(sortedWeapons, function(a, b)
	return (a.Data.Order or 0) < (b.Data.Order or 0)
end)

for _, weapon in ipairs(sortedWeapons) do
	local name = weapon.Name
	local data = weapon.Data

	local entry = inventoryTemplate:Clone()
	entry.Name = name
	entry.ImageButton.Image = data.Image
	entry.ImageButton.WeaponName.Text = data.Name
	entry.Parent = inventoryScroll

	entry.LockOverlay.Visible = true

	entry.ImageButton.Activated:Connect(function()
		if not entry.LockOverlay.Visible then
			EquipEvent:FireServer(name)
		end
	end)

	cache[name] = entry
end

local function refreshLocks()
	for name, entry in pairs(cache) do
		local cost = itemsData[name].Cost or 0
		entry.LockOverlay.Visible = currentXP < cost
	end
end

playerXP:GetPropertyChangedSignal("Value"):Connect(function()
	currentXP = playerXP.Value
	refreshLocks()
end)

local ToggleInventoryButton = InventoryGUI.ToggleInventoryButton

ToggleInventoryButton.MouseButton1Click:Connect(function()
	InventoryGUI.Inventory.Visible = not InventoryGUI.Inventory.Visible
end)

refreshLocks()
