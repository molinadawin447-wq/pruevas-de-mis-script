-- LocalScript
-- 4 columnas / 11 botones
-- Distribución:
-- ■■■■
--    ■■■
--       ■■
--       ■■

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
Main.Size = UDim2.fromOffset(330, 250)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

-- Botones un poquito más grandes
local ButtonSize = 62
local GapX = 9
local GapY = 7

-- Posiciones exactas de las columnas
local ColumnData = {
	-- Columna 1: 1 botón
	{Amount = 1, X = 0, Y = 0},

	-- Columna 2: 2 botones
	{Amount = 2, X = 71, Y = 0},

	-- Columna 3: 4 botones
	{Amount = 4, X = 142, Y = 0},

	-- Columna 4: 4 botones
	{Amount = 4, X = 213, Y = 0},
}

for Column = 1, 4 do

	local Data = ColumnData[Column]

	for Number = 1, Data.Amount do

		local Button = Instance.new("TextButton")
		Button.Name = "Button" .. Column .. "_" .. Number
		Button.Size = UDim2.fromOffset(ButtonSize, ButtonSize)

		Button.Position = UDim2.fromOffset(
			Data.X,
			Data.Y + (Number - 1) * (ButtonSize + GapY)
		)

		Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Text = ""
		Button.AutoButtonColor = true

		-- Botones completamente redondos
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(1, 0)
		Corner.Parent = Button

		Button.Parent = Main
	end
end