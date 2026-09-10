-- LocalScript
-- Distribución: 1 / 2 / 4 / 4
-- 11 botones
-- Botones cuadrados con esquinas redondeadas
-- Bordes morados oscuros
-- Textos blancos, centrados y ajustados

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

-- 4 columnas x 60 + espacios
Main.Size = UDim2.fromOffset(261, 245)

-- Pegado a la derecha con 7 px de separación
Main.Position = UDim2.new(1, -7, 0, 12)
Main.AnchorPoint = Vector2.new(1, 0)

Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

local ButtonSize = 60
local GapX = 7
local GapY = 6

-- 1 / 2 / 4 / 4
local ColumnData = {
	{Amount = 1, X = 0},
	{Amount = 2, X = 67},
	{Amount = 4, X = 134},
	{Amount = 4, X = 201},
}

-- Textos de los botones
local ButtonTexts = {
	["1_1"] = "BAT\nV2",

	["2_1"] = "BYPASS\nAIMBOT",
	["2_2"] = "INSTA\nRESET",
}

-- Botones que permanecen blancos 30 minutos
local LongWhiteButtons = {
	["1_1"] = true,

	["2_1"] = true,

	["3_1"] = true,
	["3_3"] = true,
	["3_4"] = true,
}

-- Botones que hacen un destello blanco
local FlashButtons = {
	["2_2"] = true,

	["3_2"] = true,
	["3_3"] = false,
	["3_4"] = false,
}

local WHITE_TIME = 1800
local FLASH_TIME = 0.15

for Column = 1, 4 do

	local Data = ColumnData[Column]

	for Number = 1, Data.Amount do

		local Button = Instance.new("TextButton")

		Button.Name = "Button" .. Column .. "_" .. Number
		Button.Size = UDim2.fromOffset(ButtonSize, ButtonSize)

		Button.Position = UDim2.fromOffset(
			Data.X,
			(Number - 1) * (ButtonSize + GapY)
		)

		Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Text = ButtonTexts[Column .. "_" .. Number] or ""
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextSize = 13
		Button.Font = Enum.Font.GothamBold
		Button.TextWrapped = true
		Button.TextScaled = false
		Button.TextXAlignment = Enum.TextXAlignment.Center
		Button.TextYAlignment = Enum.TextYAlignment.Center
		Button.AutoButtonColor = true

		-- Margen para que el texto nunca toque los bordes
		Button.TextBounds = Vector2.new(50, 50)

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

		-- =========================
		-- BOTONES DE 30 MINUTOS
		-- =========================

		if LongWhiteButtons[Key] then

			local Active = false
			local ActivationId = 0

			Button.Activated:Connect(function()

				-- Si está blanco, vuelve a negro
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

		-- =========================
		-- BOTONES DE DESTELLO
		-- =========================

		elseif FlashButtons[Key] then

			Button.Activated:Connect(function()

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				task.delay(FLASH_TIME, function()

					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

				end)
			end)
		end
	end
end