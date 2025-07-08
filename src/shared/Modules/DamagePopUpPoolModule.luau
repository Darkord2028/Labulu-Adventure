local TweenService = game:GetService("TweenService")

local DamagePopUpPool = {}
DamagePopUpPool.__index = DamagePopUpPool

function DamagePopUpPool.new(size)
	local self = setmetatable({}, DamagePopUpPool)
	self.pool = {}

	for _ = 1, size do
		local popup = Instance.new("BillboardGui")
		popup.Name = "DamagePopUp"
		popup.Size = UDim2.new(0, 100, 0, 50)
		popup.StudsOffset = Vector3.new(0, 2, 0)
		popup.AlwaysOnTop = true

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Text"
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.new(1, 0, 0)
		textLabel.TextScaled = false
		textLabel.TextSize = 53
		textLabel.Font = Enum.Font.Bangers
		textLabel.Parent = popup

		popup.Enabled = false
		table.insert(self.pool, popup)
	end

	return self
end

function DamagePopUpPool:Get()
	for _, popup in ipairs(self.pool) do
		if not popup.Parent then
			return popup
		end
	end
	-- No free popup found, clone a new one
	local newPopup = self.pool[1]:Clone()
	table.insert(self.pool, newPopup)
	return newPopup
end

function DamagePopUpPool:Display(head, damage)
	local popup = self:Get()
	popup.Text.Text = tostring(damage)

	-- Add random horizontal offset (left/right and forward/back)
	local randomOffset = Vector3.new(
		math.random(-2, 2),
		2 + math.random(), -- keep Y a bit elevated
		math.random(-2, 2)
	)
	popup.StudsOffset = randomOffset

	popup.Parent = head
	popup.Enabled = true

	local tween = TweenService:Create(popup.Text, TweenInfo.new(0.7), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, 0.2, 0),
	})
	tween:Play()

	tween.Completed:Connect(function()
		popup.Text.TextTransparency = 0
		popup.Text.Position = UDim2.new(0, 0, 0, 0)
		popup.Parent = nil
	end)
end

return DamagePopUpPool
