-- LocalScript
-- Distribución: 1 + 2 + 3 + 4 = 10 botones en total
--
-- Columna 1 (X=0)   : BAT BYPASS
-- Columna 2 (X=67)  : ANTI DESYNC / RESET
-- Columna 3 (X=134) : DROP BR / BAT AIMBOT / TP DOWN
-- Columna 4 (X=201) : AUTO LEFT / AUTO RIGHT / CARRY SPD / LAGGER OFF-ON

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
local TEXT_FONT = Enum.Font.GothamBold
local TEXT_SIZE = 13
local TEXT_STROKE_THICKNESS = 2
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0)

-- =========================================
-- ESTILO DEL BORDE TIPO "LUZ ROJA" ❗️
-- 3 capas superpuestas: núcleo rojo vivo → halo rojo brillante → borde rosado claro
-- =========================================

-- Capa 1: núcleo rojo intenso (pegado al botón)
local CORE_COLOR = Color3.fromRGB(230, 20, 20)
local CORE_THICKNESS = 3
local CORE_TRANSPARENCY = 0

-- Capa 2: halo rojo brillante
local MID_COLOR = Color3.fromRGB(255, 60, 60)
local MID_THICKNESS = 6
local MID_TRANSPARENCY = 0.2

-- Capa 3: borde exterior rosado claro (brillo tipo neón)
local OUTER_COLOR = Color3.fromRGB(255, 180, 180)
local OUTER_THICKNESS = 8
local OUTER_TRANSPARENCY = 0.3

-- Columnas
local ColumnData = {
	{Amount = 1, X = 0},
	{Amount = 2, X = 67},
	{Amount = 3, X = 134},
	{Amount = 4, X = 201},
}

-- Tiempos
local WHITE_TIME = 1800
local SHORT_WHITE_TIME = 1
local FLASH_010_TIME = 0.10

-- Texto de cada botón
local ButtonLabels = {
	["1_1"] = {"BAT", "BYPASS"},

	["2_1"] = {"ANTI", "DESYNC"},
	["2_2"] = {"RESET", ""},

	["3_1"] = {"DROP", "BR"},
	["3_2"] = {"BAT", "AIMBOT"},
	["3_3"] = {"TP", "DOWN"},

	["4_1"] = {"AUTO", "LEFT"},
	["4_2"] = {"AUTO", "RIGHT"},
	["4_3"] = {"CARRY", "SPD"},
	["4_4"] = {"LAGGER", "OFF"},
}

-- Toggle 30 minutos
local LongWhiteButtons = {
	["1_1"] = true,
	["2_1"] = true,
	["3_2"] = true,
	["4_1"] = true,
	["4_2"] = true,
	["4_3"] = true,
	["4_4"] = true,
}

-- Destello 0,10 s
local Flash010Buttons = {
	["2_2"] = true,
	["3_1"] = true,
	["3_3"] = true,
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

	-- Capa 1: núcleo rojo vivo
	local Core = Instance.new("UIStroke")
	Core.Name = "CoreStroke"
	Core.Color = CORE_COLOR
	Core.Thickness = CORE_THICKNESS
	Core.Transparency = CORE_TRANSPARENCY
	Core.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Core.Parent = Button

	-- Capa 2: halo rojo brillante
	local Mid = Instance.new("UIStroke")
	Mid.Name = "MidGlow"
	Mid.Color = MID_COLOR
	Mid.Thickness = MID_THICKNESS
	Mid.Transparency = MID_TRANSPARENCY
	Mid.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Mid.Parent = Button

	-- Capa 3: borde exterior rosado claro (brillo neón)
	local Outer = Instance.new("UIStroke")
	Outer.Name = "OuterGlow"
	Outer.Color = OUTER_COLOR
	Outer.Thickness = OUTER_THICKNESS
	Outer.Transparency = OUTER_TRANSPARENCY
	Outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Outer.Parent = Button
end

-- FUNCIÓN PARA APLICAR TEXTO
local function ApplyTwoLineText(Button, Line1, Line2)

	if Line2 == nil or Line2 == "" then
		Button.Text = Line1
	else
		Button.Text = Line1 .. "\n" .. Line2
	end

	Button.TextColor3 = TEXT_COLOR
	Button.Font = TEXT_FONT
	Button.TextSize = TEXT_SIZE
	Button.TextWrapped = true
	Button.TextXAlignment = Enum.TextXAlignment.Center
	Button.TextYAlignment = Enum.TextYAlignment.Center
	Button.TextScaled = false

	local TextStroke = Instance.new("UIStroke")
	TextStroke.Name = "TextStroke"
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

		local Label = ButtonLabels[Key]
		if Label then
			ApplyTwoLineText(Button, Label[1], Label[2])
		end

		-- DESTELLO BLANCO 0,10 s
		if Flash010Buttons[Key] then

			Button.Activated:Connect(function()
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				task.wait(FLASH_010_TIME)
				Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end)

		-- TOGGLE 30 MINUTOS
		elseif LongWhiteButtons[Key] then

			local Active = false
			local ActivationId = 0

			Button.Activated:Connect(function()

				if Active then
					Active = false
					ActivationId += 1
					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

					if Key == "4_4" then
						Button.Text = "LAGGER\nOFF"
					end

					return
				end

				Active = true
				ActivationId += 1
				local ThisActivation = ActivationId

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				if Key == "4_4" then
					Button.Text = "LAGGER\nON"
				end

				task.delay(WHITE_TIME, function()
					if Active and ActivationId == ThisActivation then
						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

						if Key == "4_4" then
							Button.Text = "LAGGER\nOFF"
						end
					end
				end)

			end)
		end
	end
end