-- LocalScript
-- Distribución: 1 / 2 / 4 / 4
-- Botones cuadrados con esquinas redondeadas
-- Bordes morados oscuros

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
Main.Size = UDim2.fromOffset(315, 245)

Main.Position = UDim2.new(1, -7, 0, 12)
Main.AnchorPoint = Vector2.new(1, 0)

Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

local ButtonSize = 60
local GapX = 7
local GapY = 6

local ColumnData = {
	{Amount = 1, X = 0,   Y = 0},
	{Amount = 2, X = 67,  Y = 0},
	{Amount = 4, X = 134, Y = 0},
	{Amount = 4, X = 201, Y = 0},
}

local WHITE_TIME = 1800

local SpecialButtons = {
	["1_1"] = true,
	["2_1"] = true,
	["2_2"] = true,
	["3_1"] = true,
	["4_1"] = true,
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

		-- Esquinas redondeadas
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 10)
		Corner.Parent = Button

		-- Borde morado oscuro
		local Stroke = Instance.new("UIStroke")
		Stroke.Color = Color3.fromRGB(120, 50, 180)
		Stroke.Thickness = 2
		Stroke.Transparency = 0
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.Parent = Button

		Button.Parent = Main

		local Key = Column .. "_" .. Number

		if SpecialButtons[Key] then

			local Active = false
			local ActivationId = 0

			Button.Activated:Connect(function()

				if Active then
					Active = false
					ActivationId += 1
					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					return
				end

				Active = true
				ActivationId += 1

				local ThisActivation = ActivationId

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				task.delay(WHITE_TIME, function()

					if Active and ActivationId == ThisActivation then
						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					end

				end)
			end)
		end
	end
end