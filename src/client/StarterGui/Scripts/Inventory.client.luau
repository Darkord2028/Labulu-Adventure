local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer.PlayerGui
local InventoryGUI = playerGui:WaitForChild("InventoryGUI")

local inventoryTemplate = playerGui.Template:WaitForChild("InventoryTemplate")
local inventoryScroll = InventoryGUI.Inventory.Scroll

local itemsData = require(ReplicatedStorage.Modules.ItemData)

local GetInventory = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetInventory")
local playerItems = GetInventory:InvokeServer()

-- Initialize the inventory
for itemName, itemData in pairs(itemsData) do
	if itemData.Enabled == true then
		local newItem = inventoryTemplate:Clone()
		print("Item cloned")
		newItem.Visible = false
		newItem.Parent = inventoryScroll
		newItem.Name = itemName
		newItem.ImageButton.Image = itemData.Image
		newItem.ImageButton.ImageColor3 = itemData.Color
		newItem:AddTag(itemData.ItemType)
		newItem.ImageButton:AddTag("InventoryItem")
	end
end

-- Load Player Items
if playerItems ~= nil then
	for itemName, itemData in pairs(playerItems) do
		if itemsData[itemName].Enabled == true then
			if itemData.uses > 0 then
				local item = inventoryScroll:FindFirstChild(itemName)
				item.Visible = true
				item.ImageButton.usesLabel.Text = "x" .. itemData.uses
				item.ItemOwn.Value = true
			end
		end
	end
end

local ToggleInventoryButton = InventoryGUI.ToggleInventoryButton

ToggleInventoryButton.MouseButton1Click:Connect(function()
	print("ToggleInventoryButton clicked")
	InventoryGUI.Inventory.Visible = not InventoryGUI.Inventory.Visible
end)
