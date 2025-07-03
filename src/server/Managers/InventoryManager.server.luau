local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetInventory = ReplicatedStorage.RemoteFunctions.GetInventory

local PlayerInventoryData = {

	XRCentral = {
		Branch = { uses = 2 },
		Sword = { uses = 5 },
		Shield = { uses = 1 },
	},
}

GetInventory.OnServerInvoke = function(player: Player)
	local inventoryData = PlayerInventoryData[player.Name]
	return inventoryData
end
