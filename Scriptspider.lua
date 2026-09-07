-- LocalScript
-- 4 columnas / 11 botones
-- Columna 1 = 1 | Columna 2 = 2 | Columna 3 = 4 | Columna 4 = 4

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(290, 150)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

local ButtonSize = 55
local GapX = 9
local GapY = 7

local ColumnButtons = {
	1,
	2,
	4,
	4
}

for Column = 1, 4 do

	local Amount = ColumnButtons[Column]

	local ColumnFrame = Instance.new("Frame")
	ColumnFrame.Name = "Column" .. Column
	ColumnFrame.Size = UDim2.fromOffset(
		ButtonSize,
		Amount * ButtonSize + (Amount - 1) * GapY
	)

	ColumnFrame.Position = UDim2.fromOffset(
		(Column - 1) * (ButtonSize + GapX),
		(150 - ColumnFrame.Size.Y.Offset) / 2
	)

	ColumnFrame.BackgroundTransparency = 1
	ColumnFrame.Parent = Main

	for Number = 1, Amount do

		local Button = Instance.new("TextButton")
		Button.Name = "Button" .. Column .. "_" .. Number
		Button.Size = UDim2.fromOffset(ButtonSize, ButtonSize)

		Button.Position = UDim2.fromOffset(
			0,
			(Number - 1) * (ButtonSize + GapY)
		)

		Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Text = ""
		Button.AutoButtonColor = true

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(1, 0)
		Corner.Parent = Button

		Button.Parent = ColumnFrame
	end
end