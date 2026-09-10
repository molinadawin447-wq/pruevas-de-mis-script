-- LocalScript
-- 4 columnas / 11 botones
-- Arriba a la derecha
-- Botones 3_1 y 4_1: blanco durante 2 minutos

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
Main.Position = UDim2.new(1, -12, 0, 18)
Main.AnchorPoint = Vector2.new(1, 0)
Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

local ButtonSize = 63
local GapX = 8
local GapY = 6

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

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(1, 0)
		Corner.Parent = Button

		Button.Parent = Main

		-- Primer botón de las columnas 3 y 4
		if (Column == 3 or Column == 4) and Number == 1 then

			local Active = false
			local ActivationId = 0

			Button.Activated:Connect(function()

				-- Si ya está activo, lo apaga
				if Active then
					Active = false
					ActivationId += 1
					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					return
				end

				-- Lo activa
				Active = true
				ActivationId += 1

				local ThisActivation = ActivationId

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				-- Después de 2 minutos vuelve a normal
				task.delay(120, function()

					-- Solo cambia si sigue siendo la misma activación
					if Active and ActivationId == ThisActivation then
						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					end

				end)
			end)
		end
	end
end