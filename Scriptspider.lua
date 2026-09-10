-- LocalScript
-- Distribución: 1 + 2 + 4 + 4 = 11 botones en total
--
-- Columna 1 (X=0)   : BAT BYPASS
-- Columna 2 (X=67)  : ANTI DESYNC / RESET
-- Columna 3 (X=134) : DROP BR / BAT AIMBOT / TP DOWN / LAGGER 1
-- Columna 4 (X=201) : AUTO LEFT / AUTO RIGHT / CARRY SPD / LAGGER 2

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

-- =========================================
-- ESTILO DE TEXTO ÚNICO (mismo grueso para TODOS)
-- =========================================
local TEXT_FONT = Enum.Font.GothamBold     -- misma fuente
local TEXT_SIZE = 13                       -- mismo tamaño/grueso
local TEXT_STROKE_THICKNESS = 2            -- mismo contorno
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0)

-- Columnas
local ColumnData = {
	{Amount = 1, X = 0},
	{Amount = 2, X = 67},
	{Amount = 4, X = 134},
	{Amount = 4, X = 201},
}

local WHITE_TIME = 1800
local SHORT_WHITE_TIME = 1

-- Texto de cada botón (dos líneas)
local ButtonLabels = {
	["1_1"] = {"BAT", "BYPASS"},

	["2_1"] = {"ANTI", "DESYNC"},
	["2_2"] = {"RESET", ""},

	["3_1"] = {"DROP", "BR"},
	["3_2"] = {"BAT", "AIMBOT"},
	["3_3"] = {"TP", "DOWN"},
	["3_4"] = {"LAGGER", "1"},

	["4_1"] = {"AUTO", "LEFT"},
	["4_2"] = {"AUTO", "RIGHT"},
	["4_3"] = {"CARRY", "SPD"},
	["4_4"] = {"LAGGER", "2"},
}

-- Botones que permanecen blancos 30 minutos
local LongWhiteButtons = {
	["1_1"] = true,
	["2_1"] = true,
	["3_1"] = true,
	["3_4"] = true,
	["4_4"] = true,
}

-- Botones que hacen destello blanco (0,15 s)
local FlashButtons = {
	["2_2"] = true,
	["3_2"] = true,
	["3_3"] = true,
	["4_1"] = true,
	["4_2"] = true,
	["4_3"] = true,
}

-- FUNCIÓN PARA CREAR EL MISMO ESTILO DEL BOTÓN
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

-- FUNCIÓN PARA APLICAR TEXTO (siempre con el MISMO grueso)
local function ApplyTwoLineText(Button, Line1, Line2)

	if Line2 == nil or Line2 == "" then
		Button.Text = Line1
	else
		Button.Text = Line1 .. "\n" .. Line2
	end

	-- Propiedades fijas tomadas de las constantes de arriba
	Button.TextColor3 = TEXT_COLOR
	Button.Font = TEXT_FONT
	Button.TextSize = TEXT_SIZE
	Button.TextWrapped = true
	Button.TextXAlignment = Enum.TextXAlignment.Center
	Button.TextYAlignment = Enum.TextYAlignment.Center
	Button.TextScaled = false

	-- Contorno negro del mismo grosor en todos
	local TextStroke = Instance.new("UIStroke")
	TextStroke.Color = TEXT_STROKE_COLOR
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
-- CREAR TODOS LOS BOTONES
-- =========================================

for Column = 1, 4 do

	local Data = ColumnData[Column]

	for Number = 1, Data.Amount do

		local Button = Instance.new("TextButton")

		Button.Name = "Button" .. Column .. "_" .. Number
		Button.Size = UDim2.fromOffset(ButtonSize, ButtonSize)
		Button.Position = UDim2.fromOffset(Data.X, (Number - 1) * (ButtonSize + GapY))

		ApplyButtonStyle(Button)
		Button.Parent = Main

		local Key = Column .. "_" .. Number

		-- Aplicar el texto que corresponde
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
		end
	end
end