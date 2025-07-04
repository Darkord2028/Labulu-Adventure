local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponModule = require(ReplicatedStorage.Modules.WeaponModule)

local GetInventory = ReplicatedStorage.RemoteFunctions.GetInventory

local PlayerInventoryData = {

	XRCentral = {
		TreeBranch = {
			uses = 2,
		},
		PickAxe = {
			uses = 5,
		},
	},
}

GetInventory.OnServerInvoke = function(player: Player)
	local inventoryData = PlayerInventoryData[player.Name]
	return inventoryData
end
