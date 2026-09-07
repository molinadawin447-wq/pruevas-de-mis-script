-- LocalScript
-- 4 columnas / 11 botones
-- Parte superior derecha
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

-- Tamaño del conjunto
Main.Size = UDim2.fromOffset(330, 250)

-- Arriba a la derecha, con espacio
Main.Position = UDim2.new(1, -25, 0, 25)
Main.AnchorPoint = Vector2.new(1, 0)

Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

-- Botones un poquito más grandes
local ButtonSize = 62
local GapX = 9
local GapY = 7

-- Posiciones de las columnas
local ColumnData = {
	-- Columna 1
	{Amount = 1, X = 0, Y = 0},

	-- Columna 2
	{Amount = 2, X = 71, Y = 0},

	-- Columna 3
	{Amount = 4, X = 142, Y = 0},

	-- Columna 4
	{Amount = 4, X = 213, Y = 0},
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

		-- Redondos
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(1, 0)
		Corner.Parent = Button

		Button.Parent = Main
	end
end