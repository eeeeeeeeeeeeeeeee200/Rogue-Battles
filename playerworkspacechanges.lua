local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local map = workspace:WaitForChild("GameMap")
local strangeplace = map:WaitForChild("StrangePlace")
local sigilfolder = strangeplace:WaitForChild("Sigil")
local sigil = sigilfolder:WaitForChild("MotherTree")
local eye = sigil:WaitForChild("Eye")
local detectionDistance = 30

local rS = game:GetService("ReplicatedStorage")

local neoning = false
local isNearby = false

local tutorial = workspace.GameMap.Tutorial
local beamTemplate = tutorial:WaitForChild("Beam")
local dialogueRemote = rS:WaitForChild("Events"):WaitForChild("DialogueRemote")

local TweenService = game:GetService("TweenService")
local changesEvent = rS:WaitForChild("Events"):WaitForChild("WorkspaceChangesEvent")
local remoteChanges = rS:WaitForChild("Events"):WaitForChild("WorkspaceChangesRemote")

local camera = workspace.CurrentCamera
local cameraPart = tutorial.CutscenePart
local cameraPart2 = tutorial.CutscenePart2

local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://75235325521182" 

local track = nil

local playerScripts = player:WaitForChild("PlayerScripts")
local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
local controls = playerModule:GetControls()

local pulseDuration = 3
local tweenInfo = TweenInfo.new(
	pulseDuration, 
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out
)

local function turnneon()
	neoning = true

	task.spawn(function()
		task.wait(0.1)
		eye.Transparency = 0.8
		task.wait(0.1)
		eye.Transparency = 0.6
		task.wait(0.1)
		eye.Transparency = 0.4
		task.wait(0.1)
		eye.Transparency = 0.2
		task.wait(0.1)
		eye.Transparency = 0
	end)
	for _, par in ipairs(sigil:GetDescendants()) do
		if par:IsA("BasePart") and par.Material == Enum.Material.Wood then
			par.Material = Enum.Material.Neon
			par.Color = Color3.fromRGB(49, 148, 0)
			task.wait(0.02)
			par.Color = Color3.fromRGB(106, 255, 0)

		end
	end
	task.wait(2)
	neoning = false
end


local function unturnneon()
	neoning = true

	task.spawn(function()
		task.wait(0.1)
		eye.Transparency = 0.2
		task.wait(0.1)
		eye.Transparency = 0.4
		task.wait(0.1)
		eye.Transparency = 0.6
		task.wait(0.1)
		eye.Transparency = 0.8
		task.wait(0.1)
		eye.Transparency = 1
	end)
	for _, par in ipairs(sigil:GetDescendants()) do
		if par:IsA("BasePart") and par.Material == Enum.Material.Neon then
			par.Color = Color3.fromRGB(106, 255, 0)
			task.wait(0.05)
			par.Color = Color3.fromRGB(49, 148, 0)
			par.Material = Enum.Material.Wood
			par.Color = Color3.fromRGB(0, 125, 0)

		end
	end
	task.wait(0.5)
	neoning = false
end




RunService.Heartbeat:Connect(function()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local distance = (character.HumanoidRootPart.Position - eye.Position).Magnitude

		if distance <= detectionDistance then
			if not isNearby then
				if neoning == false then
					turnneon()
				end
				isNearby = true
			end
		else
			if isNearby then
				if neoning == false then
					unturnneon()
				end
				isNearby = false
			end
		end
	end
end)

local stageToCFrame = {
	-- i dont got all pos yet holdup guys brb
	-- aint no one reading anyways
	[1] = CFrame.new(9997, 1006, 9959),
	[2] = CFrame.new(10017, 1006, 9917.5),
	[3] = CFrame.new(10002.5, 1012.5, 9810.5),
	[4] = CFrame.new(0, 0, 0),
	[5] = CFrame.new(10014.478, 1012.5, 9623.085),
	[6] = CFrame.new(0, 0, 0),
}

local function setupLocalInteraction(npc)
	local function bindClick(targetPart)

		local cd = targetPart:FindFirstChildOfClass("ClickDetector") or Instance.new("ClickDetector")
		cd.MaxActivationDistance = 15
		cd.Parent = targetPart

		cd.MouseClick:Connect(function()
			local dialogueId = npc:GetAttribute("DialogueId") or "Gabriel1"
			dialogueRemote:FireServer("InteractLocalNPC", dialogueId)
		end)
	end

	if npc:IsA("BasePart") then
		bindClick(npc)
	end
	for _, child in ipairs(npc:GetDescendants()) do
		if child:IsA("BasePart") then
			bindClick(child)
		end
	end
end

local function spawnPulse(positionCFrame)
	local temporaryclone = beamTemplate:Clone()
	temporaryclone.CFrame = positionCFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(90))
	temporaryclone.Transparency = 0
	temporaryclone.Anchored = true 
	temporaryclone.Parent = tutorial

	local targetProperties = {
		Size = Vector3.new(50, 15, 15),
		Transparency = 1 
	}

	local tween = TweenService:Create(temporaryclone, tweenInfo, targetProperties)
	tween:Play()

	tween.Completed:Connect(function()
		temporaryclone:Destroy()
	end)
end

-- add tween for purest lightbeam
local function gabrielLightBeam(gabriel)
	local gabe = tutorial:FindFirstChild("Gabriel")
	local gabeStage = tonumber(string.match(gabriel, "%d+"))
	local gabePos = nil
	if gabe then
		local pos = gabe:GetPivot()
		gabe:PivotTo(CFrame.new(0,0,0))
		spawnPulse(pos)
	end
	local y = math.rad(180)
	if gabeStage == 5 then y = math.rad(-90) end
	local targetCFrame = stageToCFrame[gabeStage] * CFrame.fromEulerAnglesXYZ(0, y, 0)
	local invisWall = tutorial:FindFirstChild("wall" .. gabeStage)
	gabe:PivotTo(targetCFrame)
	gabe:SetAttribute("DialogueId", "Gabriel" .. gabeStage + 1)
	setupLocalInteraction(gabe)
	spawnPulse(targetCFrame)
	if invisWall then invisWall.CanCollide = false end
end
-- incase titlescreen i guess
local function restartTutorial()
	local walls = 1
	for i, v in pairs(tutorial:GetChildren()) do 
		if v.Name == "wall" .. walls then
			walls += 1
			v.CanCollide = true
		end
	end
	for i, v in pairs (tutorial:GetChildren()) do 
		if v.Name == "Gabriel" then
			v:Destroy()
		end
	end
	local newGabe = game.ReplicatedStorage.Templates.Gabriel:Clone()
	local targetCFrame = CFrame.new(9997, 1005.5, 10019) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)
	newGabe:PivotTo(targetCFrame)
	newGabe:SetAttribute("DialogueId", "Gabriel1")
	setupLocalInteraction(newGabe)
	newGabe.Parent = tutorial
	tutorial.GateOther.Transparency = 1
	remoteChanges:FireServer("RestartTutorial")
end


-- i wonder if this will work
-- it did not
-- it works now
local function hideGuis(time)
	local disabledGuis = {}
	for i, v in pairs (player.PlayerGui:GetChildren()) do 
		if v:IsA("ScreenGui") then
			if v.Enabled == true then
				v.Enabled = false
				table.insert(disabledGuis, v)
			end
		end
	end
	task.spawn(function()
		task.wait(time)
		for i, v in pairs (disabledGuis) do 
			v.Enabled = true
		end
	end)
end

local function aretimHelper(model, doOrUndo)
	if doOrUndo then
		for i, v in pairs(model:GetChildren()) do
			if v.Color == Color3.fromRGB(72, 14, 10) then
				task.wait(0.00001)
				local tweenGoaler = {Color = Color3.fromRGB(240,0,0)}
				local tweeniestInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				local twin = TweenService:Create(v, tweeniestInfo, tweenGoaler)
				twin:Play() -- twin 
				v.Material = Enum.Material.Neon
				if v:IsA("UnionOperation") then
					local otherGoal = {Size = v.Size + Vector3.new(100,0,0), Transparency = 0.9}
					local twins = TweenService:Create(v, tweeniestInfo, otherGoal)
					twins:Play()
				end   
			end
		end
		local middle = model:FindFirstChild("trueMiddle")
		if middle then
		local attachment = middle.Attachment
		local particle = attachment.Particle
		particle:Emit(500)
		end
	else
		for i, v in pairs(model:GetChildren()) do
			task.wait(0.00001)
			v.Color = Color3.fromRGB(72, 14, 10)
			v.Material = Enum.Material.Slate
			if v:IsA("UnionOperation") then 
				local info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				local otherGoal = {Size = v.Size - Vector3.new(100,50,50), Transparency = 0.5}
				local twins = TweenService:Create(v, info, otherGoal)
				twins:Play()
				task.spawn(function()
					task.wait(0.5)
					v.Transparency = 0
				end)
			end
		end
	end
end 
local function AretimSummon()
	local circleModel = map.VinesBiome.RitualCircle
	if not circleModel then return end
	local outerCorners = circleModel.OuterCorners
	local middle = circleModel.Middle
	local innerEye = circleModel.InnerEye

	if not outerCorners or not middle or not innerEye then return end

	task.wait(0.05)
	aretimHelper(outerCorners, true)
	aretimHelper(middle, true)
	aretimHelper(innerEye, true)

	for i, v in pairs(middle:GetChildren()) do
		if v:IsA("UnionOperation") then
			local info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local otherGoal = {Size = v.Size + Vector3.new(0,50,50), Transparency = 1}
			local twins = TweenService:Create(v, info, otherGoal)
			twins:Play()
		end
	end
end

local function AretimSummonUndo()
	local circleModel = map.VinesBiome.RitualCircle
	if not circleModel then return end
	local outerCorners = circleModel.OuterCorners
	local middle = circleModel.Middle
	local innerEye = circleModel.InnerEye

	if not outerCorners or not middle or not innerEye then return end

	task.wait(0.05)
	aretimHelper(innerEye)
	aretimHelper(middle)
	aretimHelper(outerCorners)
end

local function playGabsCutscene()
	local gate = tutorial.Gate
	gate.Size = Vector3.new(0, 10, 0)
	gate.Transparency = 0
	hideGuis(19)
	player.Character:PivotTo(CFrame.new(0, 5, 0))
	controls:Disable()
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cameraPart.CFrame

	local tweenerInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	gate.Size = Vector3.new(0, 10, 0)
	task.wait(1)

	local tween = TweenService:Create(gate, tweenerInfo, {Size = Vector3.new(10, 13, 2)})
	tween:Play()
	tween.Completed:Wait()
	tutorial.GateOther.Transparency = 0
	task.wait(3)
	player.Character:PivotTo(CFrame.new(10006.152, 1009.5, 9625.485))
	camera.CFrame = cameraPart2.CFrame

	track = player.Character.Humanoid:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action2
	track.Looped = true
	track:Play()
	player.Character.Humanoid:MoveTo(Vector3.new(10017.5, 1011.5, 9623.5))
	task.wait(2)
	player.Character.Humanoid:MoveTo(Vector3.new(10035.5, 1012.5, 9623.5))
	task.wait(3)
	player.Character:PivotTo(CFrame.new(12977.04, 1581.297, 167.481))

	camera.CFrame = cameraPart.CFrame
	local tween = TweenService:Create(gate, tweenerInfo, {Size = Vector3.new(0, 10, 0)})
	tutorial.GateOther.Transparency = 1
	tween:Play()
	tween.Completed:Wait()
	gabrielLightBeam("Gabriel5")
	task.wait(6)
	gabrielLightBeam("Gabriel6")
	task.wait(3)

	controls:Enable()
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
	remoteChanges:FireServer("FinishedTutorial")
end

changesEvent.Event:Connect(function(action)
	if typeof(action) == "string" and string.find(action, "Gabriel") then
		gabrielLightBeam(action)
	elseif action == "RestartTutorial" then
		restartTutorial()
	end
end)

-- the server one, remoteEvent
remoteChanges.OnClientEvent:Connect(function(action, arg2, arg3)
	if action == "GabCutscene" then
		playGabsCutscene()

	elseif action == "BattleCutscene" then
		local part = arg2
		local timer = arg3
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = part.CFrame
		task.spawn(function()
			task.wait(timer)
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
		end)
	elseif action == "AretimSummoning" and not arg2 then
		AretimSummon()
	elseif action == "AretimSummoning" and arg2 then
		AretimSummonUndo()
	end
end)

setupLocalInteraction(tutorial.Gabriel)