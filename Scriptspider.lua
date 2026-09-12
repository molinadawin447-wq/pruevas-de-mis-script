-- LocalScript
-- Distribución: 1 + 2 + 3 + 4 = 10 botones en total

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local LP = Player

-- ============================================================
-- MÓDULO M (contenedor de funciones del BAT AIMBOT)
-- ============================================================
local M = {}
M.mobBtnRefs = {}
M.autoBatEnabled = false
M.autoSwingEnabled = true
M.aimbotSpeed = 58

-- ============================================================
-- INSTANT RESET
-- ============================================================

local cursedResetRemote = nil
local resetCooldown = false
local CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"

local function findResetRemote()
	for _, desc in ipairs(game:GetDescendants()) do
		if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then
			cursedResetRemote = desc
			return true
		end
	end
	return false
end

local function performInstantReset()
	if resetCooldown then return end
	resetCooldown = true

	if not cursedResetRemote then
		findResetRemote()
	end

	if not cursedResetRemote then
		for _, desc in ipairs(game:GetDescendants()) do
			if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then
				cursedResetRemote = desc
				break
			end
		end
	end

	if cursedResetRemote then
		local character = LP.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health <= 0 then
			pcall(function()
				cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon")
			end)
			task.delay(0.3, function()
				resetCooldown = false
			end)
			return
		end

		local resetDetected = false
		local conns = {}

		if humanoid then
			table.insert(conns, humanoid.Died:Connect(function()
				resetDetected = true
			end))
			table.insert(conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then
					resetDetected = true
				end
			end))
		end

		if character then
			table.insert(conns, character.AncestryChanged:Connect(function(_, parent)
				if not parent then
					resetDetected = true
				end
			end))
		end

		task.spawn(function()
			for i = 1, 50 do
				if resetDetected then break end
				pcall(function()
					cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon")
				end)
				task.wait()
			end

			for _, conn in ipairs(conns) do
				pcall(function()
					conn:Disconnect()
				end)
			end

			task.delay(0.3, function()
				resetCooldown = false
			end)
		end)

	else
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = 0
		end
		task.delay(0.3, function()
			resetCooldown = false
		end)
	end
end

-- ============================================================
-- BAT AIMBOT
-- ============================================================

function M.findBatForAimbot()
	local char = player.Character
	if not char then return nil end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
			return tool
		end
	end
	local bp = player:FindFirstChild("Backpack")
	if bp then
		for _, tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
				return tool
			end
		end
	end
	return nil
end

function M.getClosestTargetAimbot()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local closest, minDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and hum and hum.Health > 0 then
				local dist = (tRoot.Position - root.Position).Magnitude
				if dist < minDist then
					minDist = dist
					closest = tRoot
				end
			end
		end
	end
	return closest
end

function M.swingCurrentBatAimbot(char)
	if not M.autoSwingEnabled then return end
	local bat = M.findBatForAimbot()
	if bat and bat.Parent == char then
		pcall(function() bat:Activate() end)
	end
end

function M.startBatAimbot()
	if M.aimbotConn then M.aimbotConn:Disconnect() end

	if M.autoLeftEnabled then
		M.autoLeftEnabled = false
		if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end
		M.stopAutoLeft()
	end
	if M.autoRightEnabled then
		M.autoRightEnabled = false
		if M.autoRightSetVisual then M.autoRightSetVisual(false) end
		M.stopAutoRight()
	end

	M.autoBatEnabled = true

	local hum0 = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum0 then hum0.AutoRotate = false end

	M.aimbotConn = RunService.RenderStepped:Connect(function()
		if not M.autoBatEnabled then return end

		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if not char:FindFirstChildOfClass("Tool") then
			local bat = M.findBatForAimbot()
			if bat then pcall(function() hum:EquipTool(bat) end) end
		end

		local target = M.getClosestTargetAimbot()
		if not target then
			M._aimbotTarget = nil
			M.swingCurrentBatAimbot(char)
			return
		end
		M._aimbotTarget = target

		local targetVel = target.AssemblyLinearVelocity
		local myPos = root.Position
		local targetPos = target.Position

		local predictPos = targetPos + targetVel * 0.14 + target.CFrame.LookVector * 0.3
		local direction = predictPos - myPos
		local flatDir = Vector3.new(direction.X, 0, direction.Z).Unit

		local chaseSpeed = M.aimbotSpeed or 58
		local desiredHeight = targetPos.Y + 3.7
		local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8

		if hum.FloorMaterial ~= Enum.Material.Air then
			yVel = math.max(yVel, 13)
		end
		yVel = math.clamp(yVel, -70, 110)

		local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
		root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)

		local speed3 = targetVel.Magnitude
		local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
		local predictedPos = targetPos + targetVel * predictTime

		local toPredict = predictedPos - myPos
		if toPredict.Magnitude > 0.1 then
			local goalCF = CFrame.lookAt(myPos, predictedPos)
			local diffCF = root.CFrame:Inverse() * goalCF
			local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
			rx = math.clamp(rx, -2.5, 2.5)
			ry = math.clamp(ry, -2.5, 2.5)
			rz = math.clamp(rz, -2.5, 2.5)
			root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx*42, ry*42, rz*42))
		end

		M.swingCurrentBatAimbot(char)
	end)
end

function M.stopBatAimbot()
	if M.aimbotConn then
		M.aimbotConn:Disconnect()
		M.aimbotConn = nil
	end
	M._aimbotTarget = nil
	M.autoBatEnabled = false

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
	local hum2 = char and char:FindFirstChildOfClass("Humanoid")
	if hum2 then hum2.AutoRotate = true end
end

function M.queueAutoBatStart()
	if M.autoLeftEnabled then M.autoLeftEnabled=false; M.stopAutoLeft() end
	if M.autoRightEnabled then M.autoRightEnabled=false; M.stopAutoRight() end
	M.startBatAimbot()
end

-- ============================================================
-- AUTO LEFT & AUTO RIGHT
-- ============================================================

local AP = {
	L1 = Vector3.new(-476.48, -6.28, 92.73),
	L2 = Vector3.new(-483.12, -4.95, 94.80),
	L_FACE = Vector3.new(-482.25, -4.96, 92.09),
	R1 = Vector3.new(-476.16, -6.52, 25.62),
	R2 = Vector3.new(-483.06, -5.03, 25.48),
	R_FACE = Vector3.new(-482.06, -6.93, 35.47),
}

local autoLeftEnabled = false
local autoRightEnabled = false
local alPhase = 1
local arPhase = 1
local alConn = nil
local arConn = nil

local normalSpeed = 60

function startAutoLeft(speed)
	if alConn then stopAutoLeft() end
	autoLeftEnabled = true
	alPhase = 1
	local spd = speed or normalSpeed

	alConn = RunService.Heartbeat:Connect(function()
		if not autoLeftEnabled then return end
		local char = LP.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		if alPhase == 1 then
			local target = Vector3.new(AP.L1.X, hrp.Position.Y, AP.L1.Z)
			local dist = (target - hrp.Position).Magnitude
			if dist < 1 then
				alPhase = 2
			end
			local dir = (AP.L1 - hrp.Position)
			local move = Vector3.new(dir.X, 0, dir.Z).Unit
			hum:Move(move, false)
			hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)

		elseif alPhase == 2 then
			local target = Vector3.new(AP.L2.X, hrp.Position.Y, AP.L2.Z)
			local dist = (target - hrp.Position).Magnitude
			if dist < 1 then
				hum:Move(Vector3.zero, false)
				hrp.AssemblyLinearVelocity = Vector3.zero
				autoLeftEnabled = false
				if alConn then alConn:Disconnect(); alConn = nil end
				alPhase = 1
				return
			end
			local dir = (AP.L2 - hrp.Position)
			local move = Vector3.new(dir.X, 0, dir.Z).Unit
			hum:Move(move, false)
			hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)
		end
	end)
end

function stopAutoLeft()
	if alConn then alConn:Disconnect(); alConn = nil end
	autoLeftEnabled = false
	alPhase = 1
	local char = LP.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum:Move(Vector3.zero, false) end
	end
end

function startAutoRight(speed)
	if arConn then stopAutoRight() end
	autoRightEnabled = true
	arPhase = 1
	local spd = speed or normalSpeed

	arConn = RunService.Heartbeat:Connect(function()
		if not autoRightEnabled then return end
		local char = LP.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		if arPhase == 1 then
			local target = Vector3.new(AP.R1.X, hrp.Position.Y, AP.R1.Z)
			local dist = (target - hrp.Position).Magnitude
			if dist < 1 then
				arPhase = 2
			end
			local dir = (AP.R1 - hrp.Position)
			local move = Vector3.new(dir.X, 0, dir.Z).Unit
			hum:Move(move, false)
			hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)

		elseif arPhase == 2 then
			local target = Vector3.new(AP.R2.X, hrp.Position.Y, AP.R2.Z)
			local dist = (target - hrp.Position).Magnitude
			if dist < 1 then
				hum:Move(Vector3.zero, false)
				hrp.AssemblyLinearVelocity = Vector3.zero
				autoRightEnabled = false
				if arConn then arConn:Disconnect(); arConn = nil end
				arPhase = 1
				return
			end
			local dir = (AP.R2 - hrp.Position)
			local move = Vector3.new(dir.X, 0, dir.Z).Unit
			hum:Move(move, false)
			hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)
		end
	end)
end

function stopAutoRight()
	if arConn then arConn:Disconnect(); arConn = nil end
	autoRightEnabled = false
	arPhase = 1
	local char = LP.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum:Move(Vector3.zero, false) end
	end
end

-- ============================================================
-- TP BAT
-- ============================================================

local tpBatEnabled = false
local tpBatHittingCooldown = false
local tpBatHRP = nil
local tpBatH = nil
local heartbeatConn = nil
local renderConn = nil
local charAddedConn = nil

local function getBatTool()
	local char = LP.Character
	if not char then return nil end
	local bat = char:FindFirstChild("Bat")
	if bat then return bat end
	local backpack = LP:FindFirstChild("Backpack")
	if backpack then
		bat = backpack:FindFirstChild("Bat")
		if bat then
			bat.Parent = char
			return bat
		end
	end
	return nil
end

local function tryHit()
	if tpBatHittingCooldown then return end
	tpBatHittingCooldown = true
	pcall(function()
		local bat = getBatTool()
		if bat then
			bat:Activate()
			local remoteEvent = bat:FindFirstChildWhichIsA("RemoteEvent")
			if remoteEvent then remoteEvent:FireServer() end
		end
	end)
	task.delay(0.08, function()
		tpBatHittingCooldown = false
	end)
end

local function getClosestPlayer()
	if not tpBatHRP then return nil, math.huge end
	local closest, closestDist = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LP and player.Character then
			local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local dist = (tpBatHRP.Position - targetRoot.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = player
				end
			end
		end
	end
	return closest, closestDist
end

local function updateCharacterReferences()
	local char = LP.Character
	if char then
		tpBatH = char:FindFirstChildOfClass("Humanoid")
		tpBatHRP = char:FindFirstChild("HumanoidRootPart")
	end
end

local function heartbeatLoop()
	if not tpBatEnabled then return end
	if not tpBatH or not tpBatHRP or not tpBatH.Parent or not tpBatHRP.Parent then
		updateCharacterReferences()
		if not tpBatH or not tpBatHRP then return end
	end
	local target = getClosestPlayer()
	if target and target.Character then
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local targetPosition = targetRoot.Position + Vector3.new(0, 0.9, 0)
			if (tpBatHRP.Position - targetPosition).Magnitude > 5 then
				tpBatHRP.CFrame = CFrame.new(targetPosition)
			end
			tryHit()
		end
	end
end

local function renderLoop()
	if not tpBatEnabled then return end
	if not tpBatH or not tpBatHRP or not tpBatH.Parent or not tpBatHRP.Parent then
		updateCharacterReferences()
		if not tpBatH or not tpBatHRP then return end
	end
	local target = getClosestPlayer()
	if target and target.Character then
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local camera = workspace.CurrentCamera
			if camera then
				camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
			end
			tryHit()
		end
	end
end

function enableTPBat()
	if tpBatEnabled then return end
	tpBatEnabled = true
	updateCharacterReferences()
	if heartbeatConn then heartbeatConn:Disconnect() end
	if renderConn then renderConn:Disconnect() end
	heartbeatConn = RunService.Heartbeat:Connect(heartbeatLoop)
	renderConn = RunService.RenderStepped:Connect(renderLoop)
	if charAddedConn then charAddedConn:Disconnect() end
	charAddedConn = LP.CharacterAdded:Connect(function()
		task.wait(0.2)
		updateCharacterReferences()
	end)
end

function disableTPBat()
	if not tpBatEnabled then return end
	tpBatEnabled = false
	if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	if charAddedConn then charAddedConn:Disconnect(); charAddedConn = nil end
end

-- ============================================================
-- UI PRINCIPAL
-- ============================================================

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

local TEXT_FONT = Enum.Font.GothamBold
local TEXT_SIZE = 13
local TEXT_STROKE_THICKNESS = 2
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_STROKE_COLOR = Color3.fromRGB(0, 0, 0)

local ColumnData = {
	{Amount = 1, X = 0},
	{Amount = 2, X = 67},
	{Amount = 3, X = 134},
	{Amount = 4, X = 201},
}

local WHITE_TIME = 1800
local FLASH_010_TIME = 0.10

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

local LongWhiteButtons = {
	["1_1"] = true,
	["2_1"] = true,
	["3_2"] = true,
	["4_1"] = true,
	["4_2"] = true,
	["4_3"] = true,
	["4_4"] = true,
}

local Flash010Buttons = {
	["2_2"] = true,
	["3_1"] = true,
	["3_3"] = true,
}

local function ApplyButtonStyle(Button)
	Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.AutoButtonColor = true
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Button
end

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
	TextStroke.Color = TEXT_STROKE_COLOR
	TextStroke.Thickness = TEXT_STROKE_THICKNESS
	TextStroke.Parent = Button
	local TextPadding = Instance.new("UIPadding")
	TextPadding.PaddingLeft = UDim.new(0, 4)
	TextPadding.PaddingRight = UDim.new(0, 4)
	TextPadding.PaddingTop = UDim.new(0, 4)
	TextPadding.PaddingBottom = UDim.new(0, 4)
	TextPadding.Parent = Button
end

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

		if Flash010Buttons[Key] then
			Button.Activated:Connect(function()
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				if Key == "2_2" then performInstantReset() end
				task.wait(FLASH_010_TIME)
				Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end)
		elseif LongWhiteButtons[Key] then
			local Active = false
			local ActivationId = 0
			Button.Activated:Connect(function()
				if Active then
					Active = false
					ActivationId += 1
					Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					if Key == "4_4" then Button.Text = "LAGGER\nOFF" end
					if Key == "4_1" then stopAutoLeft()
					elseif Key == "4_2" then stopAutoRight()
					elseif Key == "2_1" then disableTPBat()
					elseif Key == "3_2" then M.stopBatAimbot() end
					return
				end
				Active = true
				ActivationId += 1
				local ThisActivation = ActivationId
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				if Key == "4_4" then Button.Text = "LAGGER\nON" end
				if Key == "4_1" then startAutoLeft()
				elseif Key == "4_2" then startAutoRight()
				elseif Key == "2_1" then enableTPBat()
				elseif Key == "3_2" then M.queueAutoBatStart() end
				task.delay(WHITE_TIME, function()
					if Active and ActivationId == ThisActivation then
						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
						if Key == "4_4" then Button.Text = "LAGGER\nOFF" end
						if Key == "4_1" then stopAutoLeft()
						elseif Key == "4_2" then stopAutoRight()
						elseif Key == "2_1" then disableTPBat()
						elseif Key == "3_2" then M.stopBatAimbot() end
					end
				end)
			end)
		end
	end
end

-- ============================================================
-- BOTÓN DECORATIVO (estilo VANTA VS) - ABRE EL PANEL
-- ============================================================

local BotonDecorativo = Instance.new("TextButton")
BotonDecorativo.Name = "BotonDecorativo"
BotonDecorativo.Size = UDim2.fromOffset(120, 45)
BotonDecorativo.Position = UDim2.new(0, 12, 0.5, -60)
BotonDecorativo.AnchorPoint = Vector2.new(0, 0.5)
BotonDecorativo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotonDecorativo.BackgroundTransparency = 0
BotonDecorativo.BorderSizePixel = 0
BotonDecorativo.Text = ""
BotonDecorativo.AutoButtonColor = true
BotonDecorativo.Parent = ScreenGui

local CornerBotonDecorativo = Instance.new("UICorner")
CornerBotonDecorativo.CornerRadius = UDim.new(0, 10)
CornerBotonDecorativo.Parent = BotonDecorativo

-- ============================================================
-- PANEL BRAXIL HUB (estilo ACE DUELS)
-- ============================================================

local PanelAdapt = Instance.new("Frame")
PanelAdapt.Name = "PanelAdapt"
PanelAdapt.Size = UDim2.new(0, 300, 1, -40)
PanelAdapt.AnchorPoint = Vector2.new(0.5, 0.5)
PanelAdapt.Position = UDim2.new(1.5, 0, 0.5, 0)
PanelAdapt.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PanelAdapt.BorderSizePixel = 0
PanelAdapt.Visible = true
PanelAdapt.Parent = ScreenGui

local CornerPanelAdapt = Instance.new("UICorner")
CornerPanelAdapt.CornerRadius = UDim.new(0, 14)
CornerPanelAdapt.Parent = PanelAdapt

local StrokePanelAdapt = Instance.new("UIStroke")
StrokePanelAdapt.Color = Color3.fromRGB(60, 60, 60)
StrokePanelAdapt.Thickness = 1.5
StrokePanelAdapt.Parent = PanelAdapt

-- ============================================================
-- HEADER DEL PANEL (logo + título + subtítulo + LOCK + X)
-- ============================================================

-- Logo (círculo con símbolo)
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.fromOffset(44, 44)
LogoFrame.Position = UDim2.new(0, 12, 0, 14)
LogoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogoFrame.BorderSizePixel = 0
LogoFrame.Parent = PanelAdapt

local CornerLogo = Instance.new("UICorner")
CornerLogo.CornerRadius = UDim.new(0, 10)
CornerLogo.Parent = LogoFrame

local StrokeLogo = Instance.new("UIStroke")
StrokeLogo.Color = Color3.fromRGB(80, 80, 80)
StrokeLogo.Thickness = 1
StrokeLogo.Parent = LogoFrame

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "♠"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 26
LogoText.Parent = LogoFrame

-- Título "BRAXIL HUB"
local TituloPanel = Instance.new("TextLabel")
TituloPanel.Name = "TituloPanel"
TituloPanel.Size = UDim2.new(0, 140, 0, 24)
TituloPanel.Position = UDim2.new(0, 64, 0, 16)
TituloPanel.BackgroundTransparency = 1
TituloPanel.Text = "BRAXIL HUB"
TituloPanel.TextColor3 = Color3.fromRGB(255, 255, 255)
TituloPanel.Font = Enum.Font.GothamBold
TituloPanel.TextSize = 17
TituloPanel.TextXAlignment = Enum.TextXAlignment.Left
TituloPanel.Parent = PanelAdapt

-- Subtítulo
local SubtituloPanel = Instance.new("TextLabel")
SubtituloPanel.Name = "SubtituloPanel"
SubtituloPanel.Size = UDim2.new(0, 140, 0, 14)
SubtituloPanel.Position = UDim2.new(0, 64, 0, 40)
SubtituloPanel.BackgroundTransparency = 1
SubtituloPanel.Text = "t.me/kurtis_scripts"
SubtituloPanel.TextColor3 = Color3.fromRGB(140, 140, 140)
SubtituloPanel.Font = Enum.Font.Gotham
SubtituloPanel.TextSize = 10
SubtituloPanel.TextXAlignment = Enum.TextXAlignment.Left
SubtituloPanel.Parent = PanelAdapt

-- Botón LOCK
local LockBtn = Instance.new("TextButton")
LockBtn.Name = "LockBtn"
LockBtn.Size = UDim2.fromOffset(42, 22)
LockBtn.Position = UDim2.new(1, -60, 0, 16)
LockBtn.AnchorPoint = Vector2.new(1, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LockBtn.BorderSizePixel = 0
LockBtn.Text = "LOCK"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 10
LockBtn.Parent = PanelAdapt

local CornerLock = Instance.new("UICorner")
CornerLock.CornerRadius = UDim.new(0, 6)
CornerLock.Parent = LockBtn

local StrokeLock = Instance.new("UIStroke")
StrokeLock.Color = Color3.fromRGB(60, 60, 60)
StrokeLock.Thickness = 1
StrokeLock.Parent = LockBtn

-- Botón X (cerrar)
local BotonCerrarX = Instance.new("TextButton")
BotonCerrarX.Name = "BotonCerrarX"
BotonCerrarX.Size = UDim2.fromOffset(22, 22)
BotonCerrarX.Position = UDim2.new(1, -12, 0, 16)
BotonCerrarX.AnchorPoint = Vector2.new(1, 0)
BotonCerrarX.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
BotonCerrarX.BorderSizePixel = 0
BotonCerrarX.Text = "X"
BotonCerrarX.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonCerrarX.Font = Enum.Font.GothamBold
BotonCerrarX.TextSize = 13
BotonCerrarX.Parent = PanelAdapt

local CornerX = Instance.new("UICorner")
CornerX.CornerRadius = UDim.new(0, 6)
CornerX.Parent = BotonCerrarX

local StrokeX = Instance.new("UIStroke")
StrokeX.Color = Color3.fromRGB(60, 60, 60)
StrokeX.Thickness = 1
StrokeX.Parent = BotonCerrarX

-- ============================================================
-- PESTAÑAS: MOVEMENT, COMBAT, KEYBINDS, VISUALS, SETTINGS
-- ============================================================

local COLOR_ACTIVO_TEXTO = Color3.fromRGB(255, 255, 255)
local COLOR_ACTIVO_BORDE = Color3.fromRGB(255, 255, 255)
local COLOR_INACTIVO_TEXTO = Color3.fromRGB(130, 130, 130)
local COLOR_INACTIVO_BORDE = Color3.fromRGB(50, 50, 50)

local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -20, 0, 28)
TabsContainer.Position = UDim2.new(0, 10, 0, 70)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = PanelAdapt

local TabNames = {"MOVEMENT", "COMBAT", "KEYBINDS", "VISUALS", "SETTINGS"}
local Tabs = {}
local TabStrokes = {}
local tabW = 1 / #TabNames

for i, name in ipairs(TabNames) do
	local tab = Instance.new("TextButton")
	tab.Name = "Tab_" .. name
	tab.Size = UDim2.new(tabW, -3, 1, 0)
	tab.Position = UDim2.new((i-1) * tabW, 1.5, 0, 0)
	tab.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	tab.BorderSizePixel = 0
	tab.Text = name
	tab.TextColor3 = (i == 1) and COLOR_ACTIVO_TEXTO or COLOR_INACTIVO_TEXTO
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 8
	tab.AutoButtonColor = false
	tab.Parent = TabsContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = tab

	local stroke = Instance.new("UIStroke")
	stroke.Color = (i == 1) and COLOR_ACTIVO_BORDE or COLOR_INACTIVO_BORDE
	stroke.Thickness = 1
	stroke.Parent = tab

	Tabs[i] = tab
	TabStrokes[i] = stroke
end

local function setTabActiva(index)
	for i, tab in ipairs(Tabs) do
		if i == index then
			tab.TextColor3 = COLOR_ACTIVO_TEXTO
			TabStrokes[i].Color = COLOR_ACTIVO_BORDE
		else
			tab.TextColor3 = COLOR_INACTIVO_TEXTO
			TabStrokes[i].Color = COLOR_INACTIVO_BORDE
		end
	end
end

for i, tab in ipairs(Tabs) do
	tab.Activated:Connect(function()
		setTabActiva(i)
	end)
end

-- ============================================================
-- CONTENIDO DE LA PESTAÑA MOVEMENT
-- ============================================================

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -115)
ContentFrame.Position = UDim2.new(0, 0, 0, 108)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = PanelAdapt

local Y = 0

-- Helper: etiqueta de sección
local function makeSectionLabel(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 16)
	label.Position = UDim2.new(0, 10, 0, Y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = ContentFrame
	Y = Y + 20
end

-- Helper: fila con texto izquierdo y caja de valor derecha
local function makeRow(textoIzq, valorDer)
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, -20, 0, 36)
	fila.Position = UDim2.new(0, 10, 0, Y)
	fila.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	fila.BorderSizePixel = 0
	fila.Parent = ContentFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = fila

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 45)
	stroke.Thickness = 1
	stroke.Parent = fila

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = textoIzq
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = fila

	local cajaValor = Instance.new("Frame")
	cajaValor.Size = UDim2.fromOffset(48, 22)
	cajaValor.Position = UDim2.new(1, -10, 0.5, 0)
	cajaValor.AnchorPoint = Vector2.new(1, 0.5)
	cajaValor.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	cajaValor.BorderSizePixel = 0
	cajaValor.Parent = fila

	local cornerCaja = Instance.new("UICorner")
	cornerCaja.CornerRadius = UDim.new(0, 6)
	cornerCaja.Parent = cajaValor

	local strokeCaja = Instance.new("UIStroke")
	strokeCaja.Color = Color3.fromRGB(50, 50, 50)
	strokeCaja.Thickness = 1
	strokeCaja.Parent = cajaValor

	local valorLabel = Instance.new("TextLabel")
	valorLabel.Size = UDim2.new(1, 0, 1, 0)
	valorLabel.BackgroundTransparency = 1
	valorLabel.Text = valorDer
	valorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valorLabel.Font = Enum.Font.GothamBold
	valorLabel.TextSize = 12
	valorLabel.Parent = cajaValor

	Y = Y + 42
	return fila
end

-- Helper: fila con switch (Auto Carry Speed)
local function makeRowSwitch()
	local fila = Instance.new("Frame")
	fila.Size = UDim2.new(1, -20, 0, 42)
	fila.Position = UDim2.new(0, 10, 0, Y)
	fila.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	fila.BorderSizePixel = 0
	fila.Parent = ContentFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = fila

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 45)
	stroke.Thickness = 1
	stroke.Parent = fila

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "Auto Carry Speed"
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = fila

	local Switch = Instance.new("TextButton")
	Switch.Name = "SwitchAutoCarry"
	Switch.Size = UDim2.fromOffset(50, 26)
	Switch.Position = UDim2.new(1, -10, 0.5, 0)
	Switch.AnchorPoint = Vector2.new(1, 0.5)
	Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Switch.BorderSizePixel = 0
	Switch.Text = ""
	Switch.AutoButtonColor = false
	Switch.Parent = fila

	local cornerSwitch = Instance.new("UICorner")
	cornerSwitch.CornerRadius = UDim.new(0.5, 0)
	cornerSwitch.Parent = Switch

	local Bolita = Instance.new("Frame")
	Bolita.Name = "BolitaSwitch"
	Bolita.Size = UDim2.fromOffset(20, 20)
	Bolita.Position = UDim2.new(0, 3, 0.5, 0)
	Bolita.AnchorPoint = Vector2.new(0, 0.5)
	Bolita.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Bolita.BorderSizePixel = 0
	Bolita.Parent = Switch

	local cornerBolita = Instance.new("UICorner")
	cornerBolita.CornerRadius = UDim.new(0.5, 0)
	cornerBolita.Parent = Bolita

	local activo = false
	Switch.Activated:Connect(function()
		activo = not activo
		if activo then
			TweenService:Create(Bolita, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, 0)}):Play()
			TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(Bolita, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		else
			TweenService:Create(Bolita, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, 0)}):Play()
			TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			TweenService:Create(Bolita, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		end
	end)

	Y = Y + 48
	return fila
end

-- ============ CONSTRUIR CONTENIDO MOVEMENT ============

-- AUTO SPEED
makeSectionLabel("AUTO SPEED")
makeRowSwitch()

Y = Y + 4

-- NORMAL SPEED
makeSectionLabel("NORMAL SPEED")
makeRow("Normal Speed", "63")
makeRow("Carry Speed", "30")
makeRow("Mode", "Normal")

Y = Y + 4

-- LAGGER SPEED
makeSectionLabel("LAGGER SPEED")
makeRow("Lagger Speed", "35")
makeRow("Lagger Carry Speed", "20")
makeRow("Mode", "Lagger")

Y = Y + 4

-- TELEPORT
makeSectionLabel("TELEPORT")

-- ============================================================
-- ANIMACIÓN DEL PANEL
-- ============================================================

local POS_OCULTO = UDim2.new(1.5, 0, 0.5, 0)
local POS_CENTRO = UDim2.new(0.5, 0, 0.5, 0)

local panelVisible = false
local animando = false

local function abrirPanel()
	if animando or panelVisible then return end
	animando = true
	PanelAdapt.Position = POS_OCULTO
	local tweenIn = TweenService:Create(
		PanelAdapt,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = POS_CENTRO}
	)
	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		panelVisible = true
		animando = false
	end)
end

local function cerrarPanel()
	if animando or not panelVisible then return end
	animando = true
	local tweenOut = TweenService:Create(
		PanelAdapt,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Position = POS_OCULTO}
	)
	tweenOut:Play()
	tweenOut.Completed:Connect(function()
		panelVisible = false
		animando = false
	end)
end

BotonDecorativo.Activated:Connect(function()
	abrirPanel()
end)

BotonCerrarX.Activated:Connect(function()
	cerrarPanel()
end)