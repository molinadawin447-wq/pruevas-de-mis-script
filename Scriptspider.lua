-- LocalScript
-- 4 columnas / 11 botones
-- Arriba a la derecha

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
Main.Size = UDim2.fromOffset(330, 255)

-- Más arriba y más pegado a la derecha
Main.Position = UDim2.new(1, -12, 0, 18)
Main.AnchorPoint = Vector2.new(1, 0)

Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

-- Un poquito más pequeños
local ButtonSize = 63
local GapX = 8
local GapY = 6

-- Distribución:
-- ■■■■
--    ■■■
--       ■■
--       ■■

local ColumnData = {
	{Amount = 1, X = 0,   Y = 0},
	{Amount = 2, X = 71,  Y = 0},
	{Amount = 4, X = 142, Y = 0},
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

		-- Botón redondo
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(1, 0)
		Corner.Parent = Button

		Button.Parent = Main

		-- Primer botón de columna 3 y 4:
		-- negro <-> blanco al tocar
		if (Column == 3 or Column == 4) and Number == 1 then

			local Active = false

			Button.Activated:Connect(function()
				Active = not Active

				if Active then
					Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				else
					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				end
			end)
		end
	end
end