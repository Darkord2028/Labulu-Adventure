local Players = game:GetService("Players")

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events
local Events = ReplicatedStorage:WaitForChild("Events")
local AddItemEvent = Events:WaitForChild("AddItemEvent")

local WeaponModule = require(ReplicatedStorage.Modules.WeaponModule)

local GetInventory = ReplicatedStorage.RemoteFunctions.GetInventory

local PlayerInventoryData = {}

Players.PlayerAdded:Connect(function(player)
	if not PlayerInventoryData[player.Name] then
		PlayerInventoryData[player.Name] = {}
	end
end)

GetInventory.OnServerInvoke = function(player: Player)
	local inventoryData = PlayerInventoryData[player.Name]
	return inventoryData
end

local function AddItem(player, itemName, amount)
	amount = tonumber(amount) or 1
	if amount <= 0 then
		return
	end

	-- validate item name
	if not WeaponModule[itemName] then
		warn("Invalid item:", itemName)
		return
	end

	local data = PlayerInventoryData[player.Name] or {}
	PlayerInventoryData[player.Name] = data

	local slot = data[itemName] or { uses = 0 }
	slot.uses += amount
	data[itemName] = slot

	print(player.Name, "now has", slot.uses, "uses of", itemName)
end

AddItemEvent.OnServerEvent:Connect(AddItem)
