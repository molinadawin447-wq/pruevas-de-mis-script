-- LocalScript
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ElevenButtonsUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Contenedor principal
local container = Instance.new("Frame")
container.Name = "ButtonsContainer"
container.Size = UDim2.fromOffset(300, 150)
container.Position = UDim2.fromScale(0.5, 0.5)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BackgroundTransparency = 1
container.Parent = screenGui

-- Configuración
local buttonSize = 58
local gapX = 8
local gapY = 8

-- Cantidad de botones por columna
local columns = {
    1,
    2,
    4,
    4
}

-- Crear botones
for column = 1, 4 do

    local amount = columns[column]

    local columnFrame = Instance.new("Frame")
    columnFrame.Name = "Column" .. column
    columnFrame.Size = UDim2.fromOffset(buttonSize, amount * buttonSize + (amount - 1) * gapY)

    -- Centrar verticalmente cada columna
    columnFrame.Position = UDim2.fromOffset(
        (column - 1) * (buttonSize + gapX),
        (150 - columnFrame.Size.Y.Offset) / 2
    )

    columnFrame.BackgroundTransparency = 1
    columnFrame.Parent = container

    for i = 1, amount do

        local button = Instance.new("TextButton")
        button.Name = "Button_" .. column .. "_" .. i
        button.Size = UDim2.fromOffset(buttonSize, buttonSize)

        button.Position = UDim2.fromOffset(
            0,
            (i - 1) * (buttonSize + gapY)
        )

        -- Apariencia
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        button.BackgroundTransparency = 0
        button.BorderSizePixel = 0

        -- Forma circular
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button

        -- Texto
        button.Text = ""
        button.AutoButtonColor = true

        button.Parent = columnFrame
    end
end