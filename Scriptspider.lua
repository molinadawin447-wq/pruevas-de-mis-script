-- LocalScript
-- Distribución: nuevo botón + 2 / 4 / 4
-- 11 botones en total
-- Botón nuevo a la izquierda de la primera fila
--
-- 1_1 = blanco 30 minutos (BAT BYPASS)
-- 1_2 = blanco 1 segundo (RESET)
-- 2_1 = blanco 30 minutos (ANTI DESYNC)
-- 2_2, 2_3, 2_4 = destello blanco (DROP BR, AUTO LEFT, BAT AIMBOT)
-- 3_1 = blanco 30 minutos (TP DOWN)
-- 3_2 = destello blanco (CARRY SPD)
-- 3_3, 3_4 = blanco 30 minutos (LAGGER 1, LAGGER 2)
-- NuevoButton = blanco 30 minutos (toggle) - AUTO RIGHT

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

Main.Size = UDim2.fromOffset(268, 245)
Main.Position = UDim2.new(1, -7, 0, 12)
Main.AnchorPoint = Vector2.new(1, 0)
Main.BackgroundTransparency = 1
Main.Parent = ScreenGui

local ButtonSize = 60
local GapX = 7
local GapY = 6

-- Estilo de texto unificado
local TEXT_FONT = Enum.Font.GothamBold
local TEXT_SIZE = 13
local TEXT_STROKE_THICKNESS = 2

-- Columnas originales
local ColumnData = {
	{Amount = 2, X = 67},
	{Amount = 4, X = 134},
	{Amount = 4, X = 201},
}

local WHITE_TIME = 1800
local SHORT_WHITE_TIME = 1

-- Texto que llevará cada botón (dos líneas)
local ButtonLabels = {
	["1_1"] = {"BAT", "BYPASS"},
	["1_2"] = {"RESET", ""},
	["2_1"] = {"ANTI", "DESYNC"},
	["2_2"] = {"DROP", "BR"},
	["2_3"] = {"AUTO", "LEFT"},
	["2_4"] = {"BAT", "AIMBOT"},
	["3_1"] = {"TP", "DOWN"},
	["3_2"] = {"CARRY", "SPD"},
	["3_3"] = {"LAGGER", "1"},
	["3_4"] = {"LAGGER", "2"},
}

local LongWhiteButtons = {
	["1_1"] = true,
	["2_1"] = true,
	["3_1"] = true,
	["3_3"] = true,
	["3_4"] = true,
}

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

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(120, 50, 180)
	Stroke.Thickness = 2
	Stroke.Transparency = 0
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = Button
end

-- FUNCIÓN PARA APLICAR TEXTO (dos líneas, blanco, contorno negro)
local function ApplyTwoLineText(Button, Line1, Line2)

	if Line2 == nil or Line2 == "" then
		Button.Text = Line1
	else
		Button.Text = Line1 .. "\n" .. Line2
	end

	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.Font = TEXT_FONT
	Button.TextSize = TEXT_SIZE
	Button.TextWrapped = true
	Button.TextXAlignment = Enum.TextXAlignment.Center
	Button.TextYAlignment = Enum.TextYAlignment.Center
	Button.TextScaled = false

	local TextStroke = Instance.new("UIStroke")
	TextStroke.Color = Color3.fromRGB(0, 0, 0)
	TextStroke.Thickness = TEXT_STROKE_THICKNESS
	TextStroke.Transparency = 0
	TextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	TextStroke.Parent = Button

	local TextPadding = Instance.new("UIPadding")
	TextPadding.PaddingLeft = UDim.new(0, 4)
	TextPadding.PaddingRight = UDim.new(0, 4)
	TextPadding.PaddingTop = UDim.new(0, 4)
	TextPadding.PaddingBottom = UDim.new(0, 4)
	TextPadding.Parent = Button
end

-- =========================================
-- NUEVO BOTÓN A LA IZQUIERDA (AUTO RIGHT)
-- =========================================

local NewButton = Instance.new("TextButton")
NewButton.Name = "NewButton"
NewButton.Size = UDim2.fromOffset(ButtonSize, ButtonSize)
NewButton.Position = UDim2.fromOffset(0, 0)

ApplyButtonStyle(NewButton)
ApplyTwoLineText(NewButton, "AUTO", "RIGHT")

NewButton.Parent = Main

local NewActive = false
local NewActivationId = 0

NewButton.Activated:Connect(function()

	if NewActive then
		NewActive = false
		NewActivationId += 1
		NewButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		return
	end

	NewActive = true
	NewActivationId += 1
	local ThisActivation = NewActivationId

	NewButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	task.delay(WHITE_TIME, function()
		if NewActive and NewActivationId == ThisActivation then
			NewActive = false
			NewButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end
	end)

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
		Button.Position = UDim2.fromOffset(Data.X, (Number - 1) * (ButtonSize + GapY))

		ApplyButtonStyle(Button)
		Button.Parent = Main

		local Key = Column .. "_" .. Number

		-- Aplicar el texto correspondiente según la imagen
		local Label = ButtonLabels[Key]
		if Label then
			ApplyTwoLineText(Button, Label[1], Label[2])
		end

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