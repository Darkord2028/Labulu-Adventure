local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer.PlayerGui
local InventoryGUI = playerGui:WaitForChild("InventoryGUI")
InventoryGUI.IgnoreGuiInset = true

local inventoryTemplate = playerGui.Template:WaitForChild("InventoryTemplate")
local inventoryScroll = InventoryGUI.Inventory.Scroll

local itemsData = require(ReplicatedStorage.Modules.WeaponModule)

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")
local EquipEvent = Events:WaitForChild("EquipWeaponEvent")

-- Data
local playerMoney = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Money")
local currentMoney = playerMoney.Value

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
	entry.ImageButton.XPCost.Text = "XP -" .. tostring(data.Cost or 0)
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
		entry.LockOverlay.Visible = currentMoney < cost
	end
end

playerMoney:GetPropertyChangedSignal("Value"):Connect(function()
	currentMoney = playerMoney.Value
	refreshLocks()
end)

local ToggleInventoryButton = InventoryGUI.ToggleInventoryButton

ToggleInventoryButton.MouseButton1Click:Connect(function()
	InventoryGUI.Inventory.Visible = not InventoryGUI.Inventory.Visible
end)

refreshLocks()
