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

-- Columnas (columna 3 ahora tiene 3 botones)
local ColumnData = {
	{Amount = 1, X = 0},
	{Amount = 2, X = 67},
	{Amount = 3, X = 134},
	{Amount = 4, X = 201},
}

-- Tiempos
local WHITE_TIME = 1800          -- 30 minutos
local SHORT_WHITE_TIME = 1       -- 1 segundo
local FLASH_010_TIME = 0.10      -- 0,10 segundos

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
	["4_4"] = {"LAGGER", "OFF"},   -- cambia a ON cuando se activa
}

-- =========================================
-- COMPORTAMIENTOS
-- =========================================

-- Toggle 30 minutos
local LongWhiteButtons = {
	["1_1"] = true,   -- BAT BYPASS
	["2_1"] = true,   -- ANTI DESYNC
	["3_2"] = true,   -- BAT AIMBOT
	["4_1"] = true,   -- AUTO LEFT
	["4_2"] = true,   -- AUTO RIGHT
	["4_3"] = true,   -- CARRY SPD
	["4_4"] = true,   -- LAGGER OFF/ON
}

-- Destello blanco de 0,10 segundos
local Flash010Buttons = {
	["2_2"] = true,   -- RESET
	["3_1"] = true,   -- DROP BR
	["3_3"] = true,   -- TP DOWN
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

-- FUNCIÓN PARA APLICAR TEXTO (mismo grueso siempre)
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

	-- Solo crear el contorno si no existe ya
	if not Button:FindFirstChildOfClass("UIStroke") or not Button:FindFirstChild("TextStroke") then
		-- (el UIStroke del borde ya existe; este es para las letras)
	end

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

		-- Texto del botón
		local Label = ButtonLabels[Key]
		if Label then
			ApplyTwoLineText(Button, Label[1], Label[2])
		end

		-- DESTELLO BLANCO 0,10 s (RESET, DROP BR, TP DOWN)
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
					-- Segundo toque antes de los 30 min → vuelve a negro
					Active = false
					ActivationId += 1
					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

					-- Si es el botón LAGGER, volver a "OFF"
					if Key == "4_4" then
						Button.Text = "LAGGER\nOFF"
					end

					return
				end

				-- Primer toque → blanco 30 min
				Active = true
				ActivationId += 1
				local ThisActivation = ActivationId

				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				-- Si es el botón LAGGER, cambiar a "ON"
				if Key == "4_4" then
					Button.Text = "LAGGER\nON"
				end

				task.delay(WHITE_TIME, function()
					if Active and ActivationId == ThisActivation then
						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

						-- Si es el botón LAGGER, volver a "OFF"
						if Key == "4_4" then
							Button.Text = "LAGGER\nOFF"
						end
					end
				end)

			end)
		end
	end
end