-- LocalScript
-- Distribución: 1 + 2 + 3 + 4 = 10 botones en total
--
-- Columna 1 (X=0)   : BAT BYPASS
-- Columna 2 (X=67)  : ANTI DESYNC / RESET
-- Columna 3 (X=134) : DROP BR / BAT AIMBOT / TP DOWN
-- Columna 4 (X=201) : AUTO LEFT / AUTO RIGHT / CARRY SPD / LAGGER OFF-ON

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
-- INSTANT RESET (AXONIC HUB v2.0)
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
-- BAT AIMBOT (funciones del módulo M)
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
	if M.autoTPEnabled then
		if M.autoTPConn then task.cancel(M.autoTPConn); M.autoTPConn = nil end
		if M.setAutoTPVisual then M.setAutoTPVisual(true) end
	end

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

	if M.autoBatSetVisual then M.autoBatSetVisual(true) end
	if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(true) end
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

	if M.autoTPEnabled then M.startAutoTP() end
	if M.autoBatSetVisual then M.autoBatSetVisual(false) end
	if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(false) end
end

function M.queueAutoBatStart()
	if M.antiKickEnabled and M.brainrotDetected then return end
	if M.autoLeftEnabled then M.autoLeftEnabled=false; if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end; M.stopAutoLeft() end
	if M.autoRightEnabled then M.autoRightEnabled=false; if M.autoRightSetVisual then M.autoRightSetVisual(false) end; M.stopAutoRight() end
	M.startBatAimbot()
end

-- ============================================================
-- AUTO LEFT & AUTO RIGHT (CRYON BLUE EDITION)
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

function setNormalSpeed(speed)
	if type(speed) == "number" and speed > 0 then
		normalSpeed = speed
	end
end

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
				local dir = (AP.L2 - hrp.Position)
				local move = Vector3.new(dir.X, 0, dir.Z).Unit
				hum:Move(move, false)
				hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)
				return
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
				if (AP.L_FACE - hrp.Position).Magnitude > 0.01 then
					hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(AP.L_FACE.X, hrp.Position.Y, AP.L_FACE.Z))
				end
				return
			end
			local dir = (AP.L2 - hrp.Position)
			local move = Vector3.new(dir.X, 0, dir.Z).Unit
			hum:Move(move, false)
			hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)
		end
	end)
	print("Auto Left activado")
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
	print("Auto Left desactivado")
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
				local dir = (AP.R2 - hrp.Position)
				local move = Vector3.new(dir.X, 0, dir.Z).Unit
				hum:Move(move, false)
				hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)
				return
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
				if (AP.R_FACE - hrp.Position).Magnitude > 0.01 then
					hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(AP.R_FACE.X, hrp.Position.Y, AP.R_FACE.Z))
				end
				return
			end
			local dir = (AP.R2 - hrp.Position)
			local move = Vector3.new(dir.X, 0, dir.Z).Unit
			hum:Move(move, false)
			hrp.AssemblyLinearVelocity = Vector3.new(move.X * spd, hrp.AssemblyLinearVelocity.Y, move.Z * spd)
		end
	end)
	print("Auto Right activado")
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
	print("Auto Right desactivado")
end

-- ============================================================
-- TP BAT FUNCTION (CRYON BLUE EDITION)
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
			if remoteEvent then
				remoteEvent:FireServer()
			end
			local remoteFunction = bat:FindFirstChildWhichIsA("RemoteFunction")
			if remoteFunction then
				pcall(function()
					remoteFunction:InvokeServer()
				end)
			end
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

	local target, dist = getClosestPlayer()
	if target and target.Character then
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			if sethiddenproperty then
				pcall(function()
					sethiddenproperty(tpBatHRP, "PhysicsRepRootPart", targetRoot)
				end)
			end

			local targetPosition = targetRoot.Position + Vector3.new(0, 0.9, 0)
			if (tpBatHRP.Position - targetPosition).Magnitude > 5 then
				tpBatHRP.CFrame = CFrame.new(targetPosition)
			end

			local camera = workspace.CurrentCamera
			if camera then
				camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
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

	local target, dist = getClosestPlayer()
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

	print("TP Bat activado")
end

function disableTPBat()
	if not tpBatEnabled then return end
	tpBatEnabled = false

	if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	if charAddedConn then charAddedConn:Disconnect(); charAddedConn = nil end

	pcall(function()
		local camera = workspace.CurrentCamera
		if camera then
			camera.CFrame = CFrame.new(camera.CFrame.Position, Vector3.zero)
		end
	end)

	print("TP Bat desactivado")
end

-- ============================================================
-- FIN TP BAT
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
local SHORT_WHITE_TIME = 1
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
				if Key == "2_2" then
					performInstantReset()
				end
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

					if Key == "4_4" then
						Button.Text = "LAGGER\nOFF"
					end

					if Key == "4_1" then
						stopAutoLeft()
					elseif Key == "4_2" then
						stopAutoRight()
					elseif Key == "2_1" then
						disableTPBat()
					elseif Key == "3_2" then
						M.stopBatAimbot()
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

				if Key == "4_1" then
					startAutoLeft()
				elseif Key == "4_2" then
					startAutoRight()
				elseif Key == "2_1" then
					enableTPBat()
				elseif Key == "3_2" then
					M.queueAutoBatStart()
				end

				task.delay(WHITE_TIME, function()
					if Active and ActivationId == ThisActivation then
						Active = false
						Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

						if Key == "4_4" then
							Button.Text = "LAGGER\nOFF"
						end

						if Key == "4_1" then
							stopAutoLeft()
						elseif Key == "4_2" then
							stopAutoRight()
						elseif Key == "2_1" then
							disableTPBat()
						elseif Key == "3_2" then
							M.stopBatAimbot()
						end
					end
				end)
			end)
		end
	end
end

-- ============================================================
-- BOTÓN ENANO IZQUIERDO (independiente)
-- ============================================================

local BotonEnano = Instance.new("TextButton")
BotonEnano.Name = "BotonEnano"
BotonEnano.Size = UDim2.fromOffset(45, 22)
BotonEnano.Position = UDim2.new(0, 8, 0.5, -60)
BotonEnano.AnchorPoint = Vector2.new(0, 0.5)
BotonEnano.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotonEnano.BorderSizePixel = 0
BotonEnano.Text = ""
BotonEnano.AutoButtonColor = true
BotonEnano.Parent = ScreenGui

local CornerEnano = Instance.new("UICorner")
CornerEnano.CornerRadius = UDim.new(1, 0)
CornerEnano.Parent = BotonEnano

BotonEnano.Text = "MENU"
BotonEnano.TextColor3 = Color3.fromRGB(255, 255, 255)
BotonEnano.Font = Enum.Font.GothamBold
BotonEnano.TextSize = 11
BotonEnano.TextWrapped = true
BotonEnano.TextXAlignment = Enum.TextXAlignment.Center
BotonEnano.TextYAlignment = Enum.TextYAlignment.Center

local TextStrokeEnano = Instance.new("UIStroke")
TextStrokeEnano.Color = Color3.fromRGB(0, 0, 0)
TextStrokeEnano.Thickness = 1
TextStrokeEnano.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
TextStrokeEnano.Parent = BotonEnano

BotonEnano.Activated:Connect(function()
	if Main.Visible then
		Main.Visible = false
	else
		Main.Visible = true
	end
end)