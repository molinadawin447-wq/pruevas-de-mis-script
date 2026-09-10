-- LocalScript
-- Distribución: nuevo botón + 2 / 4 / 4
-- 11 botones en total
-- Botón nuevo a la izquierda de la primera fila
--
-- 1_1 = blanco 30 minutos
-- 1_2 = blanco 1 segundo
-- 2_1 = blanco 30 minutos
-- 2_2, 2_3, 2_4 = destello blanco
-- 3_1 = blanco 30 minutos
-- 3_2 = destello blanco
-- 3_3, 3_4 = blanco 30 minutos
-- NuevoButton = destello blanco 0,15 segundos

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

-- Espacio para el nuevo botón de la izquierda
Main.Size = UDim2.fromOffset(268, 245)

-- Pegado a la derecha
Main.Position = UDim2.new(1, -7, 0, 12)
Main.AnchorPoint = Vector2.new(1, 0)

Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

local ButtonSize = 60
local GapX = 7
local GapY = 6

-- Columnas originales
local ColumnData = {
	{Amount = 2, X = 67},
	{Amount = 4, X = 134},
	{Amount = 4, X = 201},
}

-- 30 minutos
local WHITE_TIME = 1800

-- 1 segundo
local SHORT_WHITE_TIME = 1

-- Botones que permanecen blancos
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
	["2_3"] = true,
	["2_4"] = true,
	["3_2"] = true,
}

-- FUNCIÓN PARA CREAR EL MISMO ESTILO
local function ApplyButtonStyle(Button)

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
end

-- =========================================
-- NUEVO BOTÓN A LA IZQUIERDA
-- =========================================

local NewButton = Instance.new("TextButton")

NewButton.Name = "NewButton"
NewButton.Size = UDim2.fromOffset(ButtonSize, ButtonSize)
NewButton.Position = UDim2.fromOffset(0, 0)

ApplyButtonStyle(NewButton)

NewButton.Parent = Main

-- Al tocarlo se pone blanco durante 0,15 segundos
NewButton.Activated:Connect(function()

	NewButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	task.wait(0.15)

	NewButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

end)

-- =========================================
-- COLUMNAS ORIGINALES
-- =========================================

for Column = 1, 3 do

	local Data = ColumnData[Column]

	for Number = 1, Data.Amount do

		local Button = Instance.new("TextButton")

		Button.Name = "Button" .. Column .. "_" .. Number
		Button.Size = UDim2.fromOffset(ButtonSize, ButtonSize)

		Button.Position = UDim2.fromOffset(
			Data.X,
			(Number - 1) * (ButtonSize + GapY)
		)

		ApplyButtonStyle(Button)

		Button.Parent = Main

		local Key = Column .. "_" .. Number

		-- BOTONES DE DESTELLO
		if FlashButtons[Key] then

			Button.Activated:Connect(function()

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				task.wait(0.15)

				Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

			end)

		-- BOTONES DE 30 MINUTOS
		elseif LongWhiteButtons[Key] then

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

		-- BOTÓN 1_2: 1 SEGUNDO
		elseif Key == "1_2" then

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

				task.delay(SHORT_WHITE_TIME, function()

					if Active and ActivationId == ThisActivation then

						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

					end

				end)

			end)
		end
	end
end