-- LocalScript
-- 4 columnas / 11 botones
-- Parte superior derecha

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

-- Tamaño del conjunto
Main.Size = UDim2.fromOffset(355, 275)

-- Un poquito más hacia la derecha
Main.Position = UDim2.new(1, -15, 0, 25)
Main.AnchorPoint = Vector2.new(1, 0)

Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

-- Botones más grandes
local ButtonSize = 68
local GapX = 9
local GapY = 7

-- Distribución:
-- ■■■■
--    ■■■
--       ■■
--       ■■

local ColumnData = {
	{Amount = 1, X = 0,   Y = 0},
	{Amount = 2, X = 77,  Y = 0},
	{Amount = 4, X = 154, Y = 0},
	{Amount = 4, X = 231, Y = 0},
}

for Column = 1, 4 do

	local Data = ColumnData[Column]

	for Number = 1, Data.Amount do

		local Button = Instance.new("TextButton")
		Button.Name = "Button" .. Column .. "_" .. Number

		Button.Size = UDim2.fromOffset(
			ButtonSize,
			ButtonSize
		)

		Button.Position = UDim2.fromOffset(
			Data.X,
			Data.Y + (Number - 1) * (ButtonSize + GapY)
		)

		Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Text = ""
		Button.AutoButtonColor = true

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(1, 0)
		Corner.Parent = Button

		Button.Parent = Main
	end
end