local TweenService = game:GetService("TweenService")

local MoneyPopUpPool = {}
MoneyPopUpPool.__index = MoneyPopUpPool

-- Configurable
local COIN_IMAGE_ID = "rbxassetid://8150337440"
local TWEEN_TIME = 3
local END_SCALE = 0.2
local VERTICAL_OFFSET = Vector3.new(0, 2, 0)
local SPACING = 20
local COIN_SIZE = UDim2.new(0, 24, 0, 24)

function MoneyPopUpPool.new(size)
	local self = setmetatable({}, MoneyPopUpPool)
	self.pool = {}

	for _ = 1, size do
		local popup = Instance.new("BillboardGui")
		popup.Name = "MoneyPopUp"
		popup.Size = UDim2.new(0, 100, 0, 50)
		popup.StudsOffset = VERTICAL_OFFSET
		popup.AlwaysOnTop = true
		popup.Enabled = false

		-- Create internal coin image pool
		local coinPool = {}
		for _ = 1, 10 do
			local coin = Instance.new("ImageLabel")
			coin.Name = "CoinImage"
			coin.Image = COIN_IMAGE_ID
			coin.Size = COIN_SIZE
			coin.BackgroundTransparency = 1
			coin.AnchorPoint = Vector2.new(0.5, 0.5)
			coin.Visible = false
			coin.Position = UDim2.new(0.5, 0, 0.5, 0)
			coin.Parent = popup
			table.insert(coinPool, coin)
		end

		table.insert(self.pool, {
			gui = popup,
			coins = coinPool,
			inUse = false,
		})
	end

	return self
end

function MoneyPopUpPool:Get()
	for _, entry in ipairs(self.pool) do
		if not entry.inUse then
			entry.inUse = true
			return entry
		end
	end

	-- Optional: Clone fallback
	local fallback = self.pool[1]
	local newPopup = fallback.gui:Clone()
	local newCoinPool = {}

	for _, child in ipairs(newPopup:GetChildren()) do
		if child:IsA("ImageLabel") then
			table.insert(newCoinPool, child)
		end
	end

	local entry = {
		gui = newPopup,
		coins = newCoinPool,
		inUse = true,
	}
	table.insert(self.pool, entry)
	return entry
end

function MoneyPopUpPool:Return(entry)
	entry.inUse = false
	local popup = entry.gui
	popup.Enabled = false
	popup.Parent = nil
	popup.Adornee = nil

	for _, coin in ipairs(entry.coins) do
		coin.Visible = false
		coin.ImageTransparency = 0
		coin.Size = COIN_SIZE
		coin.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
end

function MoneyPopUpPool:Display(head, amount)
	local entry = self:Get()
	if not entry then
		return
	end

	local popup = entry.gui
	local coinPool = entry.coins

	local coinsToUse = math.min(amount, #coinPool)
	for i = 1, coinsToUse do
		local coin = coinPool[i]

		local baseX = (i - (coinsToUse / 2)) * SPACING

		-- 🔁 Random rotation and offset
		local randomOffsetX = math.random(-5, 5)
		local randomOffsetY = math.random(-5, 5)
		local randomRotation = math.random(-30, 30)

		coin.Position = UDim2.new(0.5, baseX + randomOffsetX, 0.5, randomOffsetY)
		coin.Rotation = randomRotation
		coin.Visible = true

		local tween = TweenService:Create(coin, TweenInfo.new(TWEEN_TIME), {
			ImageTransparency = 1,
			Size = UDim2.new(0, COIN_SIZE.X.Offset * END_SCALE, 0, COIN_SIZE.Y.Offset * END_SCALE),
			Position = UDim2.new(0.5, baseX + randomOffsetX, 0.5, randomOffsetY + 12),
			Rotation = randomRotation + math.random(-20, 20),
		})

		tween:Play()
	end

	popup.Adornee = head
	popup.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	popup.Enabled = true

	task.delay(TWEEN_TIME, function()
		self:Return(entry)
	end)
end

return MoneyPopUpPool
