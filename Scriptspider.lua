local Players = game:GetService("Players")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotonesGui"
screenGui.Parent = player.PlayerGui

-- Configuración visual
local buttonSize = 63
local spacingH = 15   -- separación horizontal entre columnas
local spacingV = 10   -- separación vertical entre botones de una misma columna
local columnCounts = {1, 2, 4, 4}  -- número de botones por columna

-- Calcular alturas
local columnHeights = {}
local maxHeight = 0
for _, count in ipairs(columnCounts) do
    local h = count * buttonSize + (count - 1) * spacingV
    table.insert(columnHeights, h)
    if h > maxHeight then maxHeight = h end
end

local totalWidth = #columnCounts * buttonSize + (#columnCounts - 1) * spacingH
local totalHeight = maxHeight

-- Contenedor principal (centrado)
local container = Instance.new("Frame")
container.Name = "Container"
container.BackgroundTransparency = 1
container.Size = UDim2.new(0, totalWidth, 0, totalHeight)
container.Position = UDim2.new(0.5, -totalWidth/2, 0.5, -totalHeight/2)
container.Parent = screenGui

-- Función que se ejecuta al hacer clic en un botón
local function onButtonClick(buttonNumber)
    -- Aquí pones lo que quieras que haga cada botón
    print("Botón " .. buttonNumber .. " pulsado")
    -- Por ejemplo, mostrar un mensaje en la pantalla (opcional)
    -- (necesitarías un TextLabel creado previamente)
end

-- Crear las columnas
local buttonCounter = 1
for colIndex, count in ipairs(columnCounts) do
    local colHeight = columnHeights[colIndex]
    local colFrame = Instance.new("Frame")
    colFrame.Name = "Columna" .. colIndex
    colFrame.BackgroundTransparency = 1
    colFrame.Size = UDim2.new(0, buttonSize, 0, colHeight)
    colFrame.Position = UDim2.new(0, (colIndex-1)*(buttonSize + spacingH), 0.5, -colHeight/2)
    colFrame.Parent = container
    
    for i = 1, count do
        -- Botón
        local button = Instance.new("ImageButton")
        button.Name = "Boton" .. buttonCounter
        button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
        
        local yOffset = (colHeight - (count * buttonSize + (count-1)*spacingV)) / 2
        local yPos = yOffset + (i-1) * (buttonSize + spacingV)
        button.Position = UDim2.new(0, 0, 0, yPos)
        
        -- Color NEGRO
        button.BackgroundColor3 = Color3.new(0, 0, 0)
        button.BackgroundTransparency = 0
        button.BorderSizePixel = 0   -- sin borde
        button.AutoButtonColor = true
        button.Text = ""   -- sin texto, o puedes poner el número si quieres
        button.Image = ""
        button.Parent = colFrame
        
        -- Hacerlo circular
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = button
        
        -- Asignar evento click con el número correspondiente
        local num = buttonCounter
        button.MouseButton1Click:Connect(function()
            onButtonClick(num)
        end)
        
        buttonCounter = buttonCounter + 1
    end
end

-- (Opcional) Reposicionar si cambia el tamaño de la pantalla
container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    container.Position = UDim2.new(0.5, -container.Size.X.Offset / 2, 0.5, -container.Size.Y.Offset / 2)
end)