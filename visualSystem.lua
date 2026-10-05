local rS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local runService = game:GetService("RunService")

local templates = rS.Templates
local VFXFolder = templates.VFXAssets
local players = game:GetService("Players")
local toolFolder = game.ServerStorage.Tools

-- Remotes
local requireStats = rS.remoteFunctions.requireStats
local textBubbleEvent = rS.Events.TextBubbleEvent

-- Systems
local statsSystem = require(rS.Systems.StatsSystem)

--Data
local armorData = require(rS.Data.ArmorData)
local weaponData = require(rS.Data.WeaponData)

-- APPEARANCE CONFIGURATION
local AppearanceTemplates = rS:WaitForChild("AppearanceTemplates")
local SkinToneFolder = AppearanceTemplates:WaitForChild("Skin")
local MaleHairFolder = AppearanceTemplates:WaitForChild("MaleHair")
local FemaleHairFolder = AppearanceTemplates:WaitForChild("FemaleHair")
local HairColorFolder = AppearanceTemplates:WaitForChild("HairColors")
local EyesFolder = AppearanceTemplates:WaitForChild("Eyes")
local EyeColors = AppearanceTemplates:WaitForChild("EyeColors")
local MouthFolder = AppearanceTemplates:WaitForChild("Mouths")
local NoseFolder = AppearanceTemplates:WaitForChild("Noses")
local ShirtFolder = AppearanceTemplates:WaitForChild("Shirts")
local PantsFolder = AppearanceTemplates:WaitForChild("Pants")
local HelmetFolder = AppearanceTemplates:WaitForChild("Helmets")
local WeaponsFolder = AppearanceTemplates:WaitForChild("Weapons")
local AccessoriesFolder = AppearanceTemplates:WaitForChild("Accessories")
local ExtraDecalsFolder = AppearanceTemplates:WaitForChild("ExtraDecals")

-- i hate math
local function calculateBezier(p0, p1, p2, t)
	local term1 = (1 - t)^2 * p0
	local term2 = 2 * (1 - t) * t * p1
	local term3 = t^2 * p2
	return term1 + term2 + term3
end

local effectsSystem = require(rS.Systems.EffectsSystem)

local toolPassives = {}
for i, v in pairs(game:GetService("ServerStorage").Tools:GetChildren()) do
	toolPassives[v.Name] = true
end

-- Map races to lists of possible rig names
local HairColorMapping = {
	["Mekolkal"] = {"Color1", "Color4", "Color5","Color12"}, 
	["Gemling"]  = {"Color14", "Color15", "Color8"}, 
	["Fireborn"] = {"Color2", "Color3", "Color9"}, 
	["Pazaron"]  = {"Color11", "Color5", "Color13"},
	["Ichthus"]  = {"Color6", "Color7", "Color10"},
	["Regan"]    = {"Color11", "Color4", "Color5"}
}

local weaponFlavors = { -- for classes that have weapons that can talk i guess? just so its not a one time thing and we can reuse maybe
	["Barbarian"] = {Text = {"CUT THEM TO PIECES", "DODGE THIS", "RAHHHHHHHHHHHHHH", "I WILL CUT YOU DOWN", "What are we doing after this?", "HAHAHA! FIGHT BACK!"}, Rng = 15},
}

local extraDecalsTable = { -- for both classes and races, maybe make it specify body part later
	["Barbarian"] = {"BarbarianTatoo1", "BarbarianTatoo2"},
	["Pazaron"] = {"Wings"} -- not yet added in the folder
}

local damageTextTemplate = templates.DamageText
local moveInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local visualSystem = {}

local function makeTextBubble(rig, message)
	if not message then return end
	if not rig then return end
	if not message then message = "It's me, flowery" end
	textBubbleEvent:FireAllClients(rig, message)
end

function visualSystem.rerollSkin(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	local race = instanceData.Race
	local raceSkinsFolder = SkinToneFolder:FindFirstChild(race)
	if not raceSkinsFolder then return end

	local currentSkin = instanceData.Skin
	local availableSkins = {}
	for _, skinName in ipairs(raceSkinsFolder:GetChildren()) do
		if skinName ~= currentSkin then
			table.insert(availableSkins, skinName)
		end
	end

	instanceData.Skin = availableSkins[math.random(1, #availableSkins)].Name
	visualSystem.ApplyAppearance(instanceModel, instanceData)
end

function visualSystem.rerollHair(instanceModel, action)
	local instanceData = require(instanceModel.InstanceData)
	local curentHair = instanceData.Hair
	local curentHairColor = instanceData.HairColor
	local gender = instanceData.Gender
	local hairFolder = nil

	if action == "Hair" then

		if gender == "Male" then
			hairFolder = AppearanceTemplates.MaleHair
		else
			hairFolder = AppearanceTemplates.FemaleHair
		end

		local hairList = hairFolder:GetChildren()
		local availableHair = {}

		for _, hair in ipairs(hairList) do
			if hair.Name ~= curentHair then
				table.insert(availableHair, hair)
			end
		end

		local newHair = availableHair[math.random(1, #availableHair)]
		instanceData.Hair = newHair.Name
	elseif action == "Color" then
		local race = instanceData.Race

		local haircolorList = HairColorMapping[race]
		local availableColors = {}

		for _, haircolor in ipairs(haircolorList) do
			if haircolor ~= curentHairColor then
				table.insert(availableColors, haircolor)
			end
		end
		local newHair = availableColors[math.random(1, #availableColors)]
		instanceData.HairColor = newHair
	end
	visualSystem.ApplyAppearance(instanceModel, instanceData)
end

function visualSystem.rerollFace(instanceModel, action)
	local instanceData = require(instanceModel.InstanceData)

	local available = {}
	local curent = nil
	local list = nil
	local data = nil

	if action == "Eyes" then
		list = AppearanceTemplates.Eyes:GetChildren()
		curent = instanceData.Eyes
		data = "Eyes"
	elseif action == "Mouth" then
		list = AppearanceTemplates.Mouths:GetChildren()
		curent = instanceData.Mouth
		data = "Mouth"
	elseif action == "Nose" then
		list = AppearanceTemplates.Noses:GetChildren()
		curent = instanceData.Nose
		data = "Nose"
	elseif action == "EyeColor" then
		list = AppearanceTemplates.EyeColors:GetChildren()
		curent = instanceData.EyeColor
		data = "EyeColor"
	end
	for _, variable in ipairs(list) do
		if variable.Name ~= curent then
			table.insert(available, variable)
		end
	end
	local new = available[math.random(1, #available)]
	instanceData[data] = new.Name
	visualSystem.ApplyAppearance(instanceModel, instanceData)
end

function visualSystem.GetRandomSkinForRace(slotData, race)
	local skinsForRaceFolder = SkinToneFolder:FindFirstChild(race)
	if skinsForRaceFolder then
		local skinsForRace = skinsForRaceFolder:GetChildren()
		slotData.Skin = skinsForRace[math.random(1, #skinsForRace)].Name
	else
		slotData.Skin = "WhiteRig"
	end

	local eyesList = EyesFolder:GetChildren()
	slotData.Eyes = #eyesList > 0 and eyesList[math.random(1, #eyesList)].Name or "None"

	local eyecolorList = EyeColors:GetChildren()
	slotData.EyeColor = #eyecolorList > 0 and eyecolorList[math.random(1, #eyecolorList)].Name or "None"

	local mouthsList = MouthFolder:GetChildren()
	slotData.Mouth = #mouthsList > 0 and mouthsList[math.random(1, #mouthsList)].Name or "None"

	local nosesList = NoseFolder:GetChildren()
	slotData.Nose = #nosesList > 0 and nosesList[math.random(1, #nosesList)].Name or "None"

	slotData.Gender = (math.random(1, 2) == 1) and "Male" or "Female"

	local hairList = (slotData.Gender == "Male") and MaleHairFolder:GetChildren() or FemaleHairFolder:GetChildren()
	slotData.Hair = #hairList > 0 and hairList[math.random(1, #hairList)].Name or "None" 

	local colorOptions = HairColorMapping[race] or {"Color8"}
	slotData.HairColor = colorOptions[math.random(1, #colorOptions)]
end

function visualSystem.EquipAccessories(character, slotData)
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local accessories = slotData.Accessories or {}
	for _, accessoryName in ipairs(accessories) do
		local accessory = AccessoriesFolder:FindFirstChild(accessoryName)
		if accessory then
			local clone = accessory:Clone()
			humanoid:AddAccessory(clone)
		end
	end
end

function visualSystem.ApplyAppearance(character, slotData)
	if not character then return end

	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Accessory") or item:IsA("Clothing") then item:Destroy() end
	end
	if head and head:FindFirstChild("face") then head.face:Destroy() end
	
	humanoid.RequiresNeck = false

	local sourceRigFolder = SkinToneFolder:FindFirstChild(slotData.Race) or SkinToneFolder
	local sourceRig = sourceRigFolder and sourceRigFolder:FindFirstChild(slotData.Skin)
	if sourceRig and sourceRig:FindFirstChildOfClass("BodyColors") then
		if character:FindFirstChildOfClass("BodyColors") then character:FindFirstChildOfClass("BodyColors"):Destroy() end
		sourceRig:FindFirstChildOfClass("BodyColors"):Clone().Parent = character
	else
		local bc = character:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", character)
		local white = Color3.new(1, 1, 1)
		bc.HeadColor3 = white bc.TorsoColor3 = white bc.LeftArmColor3 = white 
		bc.RightArmColor3 = white bc.LeftLegColor3 = white bc.RightLegColor3 = white
	end

	if head then
		local existingFake = character:FindFirstChild("FakeHead")
		if existingFake then existingFake:Destroy() end

		local fakeHead = head:Clone()
		fakeHead.Name = "FakeHead"

		for _, child in ipairs(fakeHead:GetChildren()) do
			if child:IsA("LuaSourceContainer") or child:IsA("Decal") then
				child:Destroy()
			end
		end

		fakeHead.Transparency = 0
		fakeHead.CanCollide = false
		fakeHead.CanTouch = false
		fakeHead.CanQuery = false
		fakeHead.Massless = true
		fakeHead.CFrame = head.CFrame
		fakeHead.Parent = character

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = fakeHead
		weld.Part1 = head
		weld.Parent = fakeHead

		local function addLayer(folder, name, layerName)
			if name and name ~= "None" then
				local template = folder:FindFirstChild(name)
				if template then
					local decal = template:Clone()
					decal.Name = layerName
					decal.Face = Enum.NormalId.Front
					decal.Parent = fakeHead
				end
			end
		end

		addLayer(EyesFolder, slotData.Eyes, "Eyes")
		addLayer(EyeColors, slotData.EyeColor, "EyeColor")
		addLayer(MouthFolder, slotData.Mouth, "Mouth")
		addLayer(NoseFolder, slotData.Nose, "Nose")
	end

	local armorName = slotData.Armor
	if armorName then
		if armorData.Modified[armorName] then
			local clonedShirt = ShirtFolder.Undershirt:Clone()
			clonedShirt.Parent = character
		end

		local ShirtTemplate = ShirtFolder:FindFirstChild(armorName)
		local PantsTemplate = PantsFolder:FindFirstChild(armorName)

		if ShirtTemplate then
			local clonedShirt = ShirtTemplate:Clone()
			clonedShirt.Parent = character
		end

		if PantsTemplate then
			local clonedPants = PantsTemplate:Clone()
			clonedPants.Parent = character
		end
	end

	local hair = true
	if slotData.Helmet and slotData.Helmet ~= "None" then
		local HelmetTemplate = HelmetFolder:FindFirstChild(slotData.Helmet)
		if armorData.Modified[slotData.Helmet] then
			hair = false
		end
		if HelmetTemplate then
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Accessory") and item:GetAttribute("IsHelmet") then
					item:Destroy()
				end
			end

			local clonedHelmet = HelmetTemplate:Clone()
			clonedHelmet:SetAttribute("IsHelmet", true) 
			humanoid:AddAccessory(clonedHelmet)
		end
	end

	if slotData.Hair and slotData.Hair ~= "None" and hair then
		local hairTemplate = nil

		if slotData.Gender == "Male" then
			hairTemplate = MaleHairFolder:FindFirstChild(slotData.Hair)
		else
			hairTemplate = FemaleHairFolder:FindFirstChild(slotData.Hair)
		end

		if hairTemplate then
			local clonedHair = hairTemplate:Clone()

			if slotData.HairColor and slotData.HairColor ~= "None" then
				local colorTemplate = HairColorFolder:FindFirstChild(slotData.HairColor)
				if colorTemplate then
					local targetColor = colorTemplate:IsA("Color3Value") and colorTemplate.Value or colorTemplate.Color
					local handle = clonedHair:FindFirstChild("Handle")

					if handle then
						handle.Color = targetColor
						if handle:IsA("MeshPart") then
							handle.UsePartColor = true
							handle.TextureID = "" 
						end
						local mesh = handle:FindFirstChildWhichIsA("SpecialMesh")
						if mesh then
							mesh.TextureId = "" 
							mesh.VertexColor = Vector3.new(targetColor.R, targetColor.G, targetColor.B)
						end
					end
				end
			end
			humanoid:AddAccessory(clonedHair)
		end
	end

	local weaponsFolderChar = character:FindFirstChild("Weapons")
	if not weaponsFolderChar then
		weaponsFolderChar = Instance.new("Folder")
		weaponsFolderChar.Name = "Weapons"
		weaponsFolderChar.Parent = character
	end
	for _, model in ipairs(weaponsFolderChar:GetChildren()) do
		model:Destroy()
	end
	for _, weapon in ipairs(slotData.Weapons) do
		if weapon ~= "None" then
			local cleanWeaponName = string.gsub(weapon, " ", "")
			if character:FindFirstChild(cleanWeaponName) then return end
			local weaponTemplate = WeaponsFolder:FindFirstChild(cleanWeaponName)
			if weaponTemplate then
				local clonedWeapon = weaponTemplate:Clone()
				clonedWeapon.Parent = weaponsFolderChar

				local motor6d = clonedWeapon:FindFirstChildOfClass("Motor6D")
				if motor6d then
					local partToAttach = clonedWeapon:FindFirstChildOfClass("StringValue").Value
					motor6d.Part0 = partToAttach ~= nil and character:FindFirstChild(partToAttach) or nil
				end
			end
		end
	end
	visualSystem.EquipAccessories(character, slotData)

	-- gises tool code
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		for i, v in pairs(player.Backpack:GetChildren()) do
			if v:IsA("Tool") then
				v:Destroy()
			end
		end
		for i, v in pairs(slotData.SkillsLearned) do
			if toolPassives[i] then
				local templateTool = toolFolder:FindFirstChild(i)
				if templateTool then
					local tool = toolFolder[i]:Clone()
					tool.Parent = player.Backpack
				end
			end
		end
	end

	-- extra decals
	if extraDecalsTable[slotData.T2Class] or extraDecalsTable[slotData.T3Class] or extraDecalsTable[slotData.Race] then
		-- gtg finsih later
	end
	-- gemling gems 
	if slotData.Gems and slotData.Race == "Gemling" then

		local torso = character:FindFirstChild("Torso")
		if not torso then return end

		local gemsFolder = character:FindFirstChild("equippedGems")

		if gemsFolder then for i, v in pairs(gemsFolder:GetChildren()) do v:Destroy() end end

		if not gemsFolder then
			gemsFolder = Instance.new("Folder")
			gemsFolder.Name = "equippedGems"
			gemsFolder.Parent = character
		end

		local placements = {
			[1] = {Weld = character:FindFirstChild("Right Arm"), Pivot = character:FindFirstChild("Right Arm").RightGripAttachment.WorldCFrame + Vector3.new(0, 0.1,0)},
			[2] = {Weld = character:FindFirstChild("Left Arm"), Pivot = character:FindFirstChild("Left Arm").LeftGripAttachment.WorldCFrame + Vector3.new(0, 0.1,0)},
			[3] = {Weld = character:FindFirstChild("Torso"), Pivot = character:FindFirstChild("Torso").BodyBackAttachment.WorldCFrame},
			[4] = {Weld = character:FindFirstChild("Torso"), Pivot = character:FindFirstChild("Torso").BodyFrontAttachment.WorldCFrame},
		}


		for i, v in pairs(slotData.Gems) do
			if v.gem ~= "None" then

				local slotNum = tonumber(string.match(i, "%d+")) or 1
				local gemClone = templates:FindFirstChild(string.lower(v.gem)):Clone()
				local mainPart = gemClone:IsA("BasePart") and gemClone or gemClone.PrimaryPart
				if not mainPart then continue end



				for _, part in ipairs(gemClone:IsA("BasePart") and {gemClone} or gemClone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						part.CanTouch = false
						part.CanQuery = false
						part.Massless = true
						part.Anchored = false
					end
				end

				gemClone.Parent = gemsFolder
				mainPart.CFrame = torso.CFrame

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = mainPart
				weld.Part1 = placements[slotNum].Weld
				gemClone:PivotTo(placements[slotNum].Pivot)
				weld.Parent = mainPart
			end
		end
	end
end

function visualSystem.clearAnimations(animator)
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Looped then continue end
		track:Stop()
	end
end

function visualSystem.clearAllAnimations(animator)
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:Stop()
	end
end

function visualSystem.getPosInFrontOfModel(entity, destModel)
	if entity == destModel then return end

	local enemyPrimary = destModel.PrimaryPart
		or destModel:FindFirstChild("HumanoidRootPart") 
		or destModel:FindFirstChild("Torso")

	local entityPrimary = entity.PrimaryPart
		or entity:FindFirstChild("HumanoidRootPart") 

	if enemyPrimary and entityPrimary then
		local targetPos = enemyPrimary.Position
		local offset = Vector3.new(0, 0, 0)

		local finalPos = targetPos + enemyPrimary.CFrame.LookVector * 2.5 + offset

		return finalPos
	end
end

function visualSystem.rotateEntity(entity, destModel)
	if entity == destModel then return end

	local enemyPrimary = destModel.PrimaryPart
		or destModel:FindFirstChild("HumanoidRootPart") 
		or destModel:FindFirstChild("Torso")

	local entityPrimary = entity.PrimaryPart
		or entity:FindFirstChild("HumanoidRootPart") 

	if enemyPrimary and entityPrimary then
		local targetPos = Vector3.new(enemyPrimary.Position.X, entityPrimary.Position.Y, enemyPrimary.Position.Z)
		local playerPos = entityPrimary.Position

		local newCFrame = CFrame.lookAt(playerPos, targetPos)

		entity:SetPrimaryPartCFrame(newCFrame)
	end
end

function visualSystem.tpEntity(entity, destination)
	entity:SetPrimaryPartCFrame(destination)
end

function visualSystem.setupClickDetector(model)
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Parent = model

	clickDetector.CursorIcon = "rbxassetid://"

	clickDetector.MouseHoverEnter:Connect(function(plr)
		local instStats = require(model.InstanceData)
		if instStats and instStats["Health"] > 0 then
			statsSystem.ShowStats(plr, model, instStats)
		end
	end)

	clickDetector.MouseHoverLeave:Connect(function(plr)
		task.wait(0.05)
		local mouseTarget = requireStats:InvokeClient(plr, "getMouseTarget")
		if mouseTarget and mouseTarget ~= model and mouseTarget.Parent ~= model then
			statsSystem.showingStats[plr] = nil
			statsSystem.UpdateStats(plr)
		end
	end)
end

function visualSystem.showDamageText(partToGive, damage)
	local newGui = damageTextTemplate:Clone()

	local color = Color3.fromRGB(65, 190, 0)
	if damage >= 0 then
		color = Color3.fromRGB(math.min(damage * 3, 255), 0, 0)
	end

	newGui.TextLabel.Text = damage
	newGui.TextLabel.TextColor3 = color
	newGui.Parent = partToGive
	newGui.Adornee = partToGive
	newGui.Enabled = true

	local moveGoal = {StudsOffset = Vector3.new(math.random(-10, 10)/10, math.random(-10, 10)/10, 0)}
	local fadeGoal = {TextTransparency = 0.85}
	local moveTween = TweenService:Create(newGui, moveInfo, moveGoal)
	local fadeTween = TweenService:Create(newGui.TextLabel, fadeInfo, fadeGoal)

	moveTween:Play()
	fadeTween:Play()

	fadeTween.Completed:Connect(function()
		newGui:Destroy()
	end)
end

function visualSystem.putWeaponInHand(model, weapon)
	local slotData = require(model.InstanceData)
	local weaponsFolder = model:FindFirstChild("Weapons")
	if not weaponsFolder then return end

	local weaponModel = weaponsFolder and weaponsFolder:FindFirstChild(weapon)
	if not weaponModel then return end

	local weaponMotor6D = weaponModel:FindFirstChildOfClass("Motor6D")
	local combatCFrame = weaponModel:FindFirstChild("CombatPos")
	if weaponMotor6D and combatCFrame then
		weaponMotor6D.Part0 = model["Right Arm"] or model["RightArm"]
		weaponMotor6D.C1 = combatCFrame.Value
	end
	local talkingWeaponClass = weaponFlavors[slotData.T2Class] or weaponFlavors[slotData.T3Class]
	if talkingWeaponClass then
		local rng = math.random(1,100)
		if rng <= talkingWeaponClass.Rng then
			makeTextBubble(weaponModel, talkingWeaponClass.Text[math.random(1, #talkingWeaponClass.Text)])
		end
	end
end

function visualSystem.withdrawWeapons(model)
	local weaponsFolder = model:FindFirstChild("Weapons")
	if not weaponsFolder then return end

	for _, weapon in ipairs(weaponsFolder:GetChildren()) do
		local weaponMotor6D = weapon:FindFirstChildOfClass("Motor6D")
		if weaponMotor6D then
			local basePos = weapon:FindFirstChild("BasePos")
			local partToAttach = weapon:FindFirstChildOfClass("StringValue").Value

			if basePos then
				weaponMotor6D.Part0 = model:FindFirstChild(partToAttach)
				weaponMotor6D.C1 = basePos.Value
			end
		end
	end
end

function visualSystem.destroyNPCModel(npcModel, npcName) 
	local hum = npcModel:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end
	local hmrp = npcModel:FindFirstChild("HumanoidRootPart")
	if not hmrp then return end

	local fakeHead = npcModel:FindFirstChild("FakeHead")
	if fakeHead then fakeHead:Destroy() end

	hmrp.Anchored = false
	local names = {"Left Arm", "Right Arm", "Right Leg", "Left Leg", "Head"}

	for _, name in ipairs(names) do
		local part = npcModel:FindFirstChild(name)
		if part then
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("Attachment") then child:Destroy() end
			end
		end
	end

	Debris:AddItem(npcModel, 2)
end

visualSystem.activeEffects = {}

function visualSystem.applyEffectVFX(participantInstance, effect)
	local effectName = effect.name

	local handlerFunction = visualSystem.EffectsVFX[effectName]
	if handlerFunction then
		handlerFunction(participantInstance, effect)
		return
	end

	local effectTemplate = VFXFolder:FindFirstChild(effectName)
	if not effectTemplate then return end

	if not visualSystem.activeEffects[participantInstance] then
		visualSystem.activeEffects[participantInstance] = {}
	end

	local effectClone = effectTemplate:Clone()
	if effectClone:IsA("ParticleEmitter") then 
		effectClone.Parent = participantInstance:FindFirstChild("HumanoidRootPart")
	elseif effectClone:IsA("BillboardGui") then
		effectClone.Parent = participantInstance.PrimaryPart
		effectClone.Adornee = participantInstance.PrimaryPart
	else
		effectClone.Parent = participantInstance
	end
	table.insert(visualSystem.activeEffects[participantInstance], effectClone)
end

function visualSystem.removeEffectVFX(participantInstance, effectName)
	local handlerFunction = visualSystem.EffectsVFX[effectName .. "Remove"]
	if handlerFunction then
		handlerFunction(participantInstance, effectName)
		return
	end

	if not visualSystem.activeEffects[participantInstance] then return end

	local list = visualSystem.activeEffects[participantInstance]
	for i = #list, 1, -1 do
		local fx = list[i]
		if fx.Name == effectName then
			fx:Destroy()
			table.remove(list, i)
		end
	end
end

function visualSystem.clearAllEffects(participantInstance)
	if visualSystem.activeEffects[participantInstance] then
		for _, fx in ipairs(visualSystem.activeEffects[participantInstance]) do
			if fx then fx:Destroy() end
		end
		visualSystem.activeEffects[participantInstance] = nil
	end
end

function visualSystem.shadowDodgeAnim(dodgerInstance)
	local partsToTween = {}
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for i, v in pairs(dodgerInstance:GetChildren()) do
		if v.Name ~= "HumanoidRootPart" and v:IsA("BasePart") and v.Name ~= "FakeHead" and v.Name ~= "Head" then
			for i = 1, 4 do
				task.wait(0.01)
			local spawnedPart = Instance.new("Part")
			spawnedPart.Color = Color3.fromRGB(30,0,20)
			spawnedPart.Size = v.Size + Vector3.new(1,1,1)
			spawnedPart.Material = Enum.Material.Neon
			spawnedPart.CanCollide = false
			spawnedPart.Anchored = true
			spawnedPart.CFrame = v.CFrame
			spawnedPart.Position = spawnedPart.Position + Vector3.new(math.random(1,20) / 10, math.random(1,20) / 10, math.random(1,20) / 10)
			spawnedPart.Parent = workspace
			table.insert(partsToTween, spawnedPart)
			end
		end
	end
	for i, v in ipairs(partsToTween) do
		local tweenGoal = {Size = Vector3.new(0.1,0.1,0.1), Transparency = 1}
		local tween = TweenService:Create(v, tweenInfo, tweenGoal)
		tween:Play()
		Debris:AddItem(v, 0.65)
	end

end

visualSystem.AttacksVFX = {
	["LightSpark"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.CFrame * CFrame.new(0, 0, 5)).Position

		task.wait(0.1)
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Position = targetPos, Size = Vector3.new(15, 15, 15)}

		local templatePart = VFXFolder.LightSparkBall

		for i = 1, 5 do
			local newPart = templatePart:Clone()
			newPart.Parent = workspace
			newPart.CFrame = attackerRoot.CFrame * CFrame.new(0, 0, -2)

			local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
			tween:Play()

			tween.Completed:Connect(function()
				Debris:AddItem(newPart, 0)
			end)

			task.wait(0.1)
		end
	end,

	["WaterPistol"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart

		local startPos = (attackerRoot.CFrame * CFrame.new(0, 0, -2)).Position
		local targetPos = (targetRoot.CFrame * CFrame.new(0, 0, 5)).Position

		local distance = (targetPos - startPos).Magnitude


		local lookDir = CFrame.lookAt(startPos, targetPos)


		local cylinderCFrame = lookDir * CFrame.Angles(0, math.pi / 2, 0)

		local templatePart = VFXFolder.WaterPistol
		local newPart = templatePart:Clone()


		local startLength = 0.05
		local thicknessY = newPart.Size.Y
		local thicknessZ = newPart.Size.Z

		newPart.Size = Vector3.new(startLength, thicknessY, thicknessZ)


		newPart.CFrame = cylinderCFrame * CFrame.new(startLength / 2, 0, 0)
		newPart.Parent = workspace

		local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)


		local tweenGoal = {
			Size = Vector3.new(distance, thicknessY, thicknessZ),
			CFrame = cylinderCFrame * CFrame.new(distance / 2, 0, 0)
		}

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		tween:Play()

		tween.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,

	["DarknessBeams"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart
		local magicCircle = VFXFolder.Dark

		local targetPos = (targetRoot.CFrame * CFrame.new(0, 0, 5)).Position

		local endParticle = VFXFolder.DarkParticles

		local function createMagicCircle()
			local circle = magicCircle:Clone()
			local randomOffset = Vector3.new(math.random(-5, 5), math.random(0, 5), math.random(-5, 5))
			local spawnCFrame = attackerRoot.CFrame * CFrame.new(randomOffset)
			circle:PivotTo(CFrame.lookAt(spawnCFrame.Position, targetPos))
			task.spawn(function()
				while circle and circle.Parent do
					circle.Decal.Rotation = (circle.Decal.Rotation + 1) % 361 -- we actually dont need the modulo i realized because the circles despawn too quickly but its like pretty cool, jjk modulo	
					task.wait()
				end
			end)
			circle.Parent = workspace

			local startPos = circle.CFrame.Position
			local endPos = targetRoot.Position
			local midpoint = (startPos + endPos) / 2
			local controlPoint = midpoint + Vector3.new(math.random(-5,5), 0, math.random(-5, 5))

			local cframeValue = Instance.new("CFrameValue")

			local attachment = Instance.new("Attachment")
			attachment.Parent = circle
			local attachment2 = Instance.new("Attachment")
			attachment2.Parent = workspace.Terrain
			attachment.WorldCFrame = circle.CFrame

			local duration = 0.3
			local timePassed = 0

			cframeValue.Value = attachment2.WorldCFrame


			local beam = VFXFolder.darkBeam:Clone()
			beam.Parent = circle
			beam.Attachment0 = attachment
			beam.Attachment1 = attachment2

			local connection
			connection = runService.Heartbeat:Connect(function(dt)
				timePassed = timePassed + dt
				local t = math.clamp(timePassed / duration, 0, 1)

				local currentPos = calculateBezier(startPos, controlPoint, endPos, t)
				attachment2.WorldCFrame = CFrame.new(currentPos)

				if t >= 1 then
					connection:Disconnect()
					local clone = endParticle:Clone()
					clone.Parent = attachment2
					clone:Emit(1)
					Debris:AddItem(circle, 0.7)
				end
			end)
		end

		for i = 1, 10 do
			createMagicCircle()
			task.wait(0.2)
		end

	end,

	["SandThrow"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local attackerRightArm = attackerModel:FindFirstChild("RightArm") or attackerModel:FindFirstChild("Right Arm")
		if not attackerRightArm then return end
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.Position)

		task.wait(0.15)
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Position = targetPos}

		local templatePart = VFXFolder.SandThrow
		local newPart = templatePart:Clone()
		newPart.Parent = workspace
		newPart.CFrame = attackerRightArm.CFrame * CFrame.new(0, -1.5, 0)

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		tween:Play()

		tween.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,

	["Raincast"] = function(attacker, target)
		local targetModel = target.Instance

		local targetRoot = targetModel.PrimaryPart

		local target = Vector3.new(13.763, 9.095, 24.667) / Vector3.new(2,2,2)

		local tweenInfo = TweenInfo.new(1.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		local tweenGoal = {Size = target}

		local templatePart = VFXFolder.Raincast
		local newPart = templatePart:Clone()
		newPart.Size = Vector3.new(1.763,1.095,1.667)
		newPart.Parent = workspace
		newPart.Position = targetRoot.Position + Vector3.new(0,10,0)

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		tween:Play()

		tween.Completed:Connect(function()
			Debris:AddItem(newPart, 2)
		end)
	end,

	["Lightningcast"] = function(attacker, target)
		local targetModel = target.Instance

		local targetRoot = targetModel.PrimaryPart

		local target = Vector3.new(13.763, 9.095, 24.667) / Vector3.new(2,2,2)
		local targetColor = Color3.fromRGB(111,111,111)

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		local tweenGoal = {Size = target}
		local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal2 = {Color = targetColor}


		local templatePart = VFXFolder.Lightningcast
		local templatePart2 = VFXFolder.LightningcastBolt
		local newPart = templatePart:Clone()
		newPart.Parent = workspace
		newPart.Position = targetRoot.Position + Vector3.new(0,10,0)

		local lightningClone = templatePart2:Clone()

		local size = Vector3.new(3.229, 0.2, 1.965)

		local tweenGoal3 = {Size = Vector3.new(16, 0.2, 1.965), Position = targetRoot.Position + Vector3.new(size.X / 2, 0, 0)}
		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		local tween2 = TweenService:Create(newPart, tweenInfo2, tweenGoal2)
		local tween3 = TweenService:Create(lightningClone, tweenInfo2, tweenGoal3)
		tween:Play()
		tween.Completed:Wait()
		tween2:Play()
		tween2.Completed:Wait()
		lightningClone.Position = targetRoot.Position + Vector3.new(0,11,0)
		lightningClone.Parent = workspace
		tween3:Play()
		tween3.Completed:Connect(function()
			Debris:AddItem(newPart, 2)
			Debris:AddItem(lightningClone, 0)
		end)
	end,

	["PiercingShadow"] = function(attacker, target)
		local darkDuration = 1
		local template = VFXFolder.PiercingShadow
		local targetRoot = target.Instance.PrimaryPart
		-- two FANG FROM GRIM PLATFORM BATTLES per darkness stack
		local moved = false
		task.spawn(function()
			task.wait(0.27)
			-- move the enemy up during anim
			target.Instance:PivotTo(targetRoot.CFrame * CFrame.new(0,1,0))
			moved = true
		end)

		local targetEffects = target.InBattleData.Effects
		local darkness = effectsSystem.findEffect("Darkness", targetEffects, "onTurn")
		if darkness then darkDuration = darkness.duration * 2 end
		for i = 1, darkDuration do
			local randomOffset = Vector3.new(math.random(-7, 7), math.random(-1, 5), math.random(-7, 7))
			local spawnCFrame = targetRoot.CFrame * CFrame.new(randomOffset)
			task.wait(0.1)
			local fangClone = template:Clone()
			fangClone.CFrame = CFrame.lookAt(spawnCFrame.Position, target.Instance.PrimaryPart.Position) * CFrame.Angles(math.rad(-90),0,0)
			fangClone.Parent = workspace

			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local direction = (targetRoot.Position - fangClone.Position).Unit
			local finalPosition = fangClone.Position + ((direction * 12))
			local tweenGoal = {Position = finalPosition}
			local tween = TweenService:Create(fangClone, tweenInfo, tweenGoal)
			tween:Play()
			tween.Completed:Connect(function()
				Debris:AddItem(fangClone, 0.2)
			end)
		end
		while moved == false do
			task.wait(0.1)
		end
		moved = false
		target.Instance:PivotTo(targetRoot.CFrame * CFrame.new(0,-1,0))
	end, 

	["FirePunch"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local attackerRightArm = attackerModel:FindFirstChild("RightArm") or attackerModel:FindFirstChild("Right Arm")
		if not attackerRightArm then return end

		local particleEmiter = VFXFolder.FirePunch

		local newemiter = particleEmiter:Clone()
		newemiter.Parent = attackerRightArm.RightGripAttachment
		task.wait(1)
		Debris:AddItem(newemiter, 0)

	end,


	["PoisonSpit"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local attackerHead = attackerModel:FindFirstChild("Head") or attackerModel:FindFirstChild("Fake Head")
		if not attackerHead then return end
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.Position)

		task.wait(0.15)
		local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Position = targetPos}

		local templatePart = VFXFolder.PoisonSpit
		local templatePart2 = VFXFolder.PoisonSpit2
		local newPart = templatePart:Clone()
		local newPart2 = templatePart2:Clone()
		newPart2.Transparency = 1
		newPart2.Parent = workspace
		newPart2.CFrame = attackerHead.CFrame * CFrame.new(0, 0, -2)
		newPart.Parent = workspace
		newPart.CFrame = attackerHead.CFrame * CFrame.new(0, 0, 0)

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		tween:Play()

		task.spawn(function()
			task.wait(0.5)
			newPart2.ParticleEmitter.Rate = 0
			task.wait(3)
			Debris:AddItem(newPart2, 0)
		end)

		tween.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,

	["WindSlash"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.Position)

		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Position = targetPos,}

		local templatePart = VFXFolder.WindSlash
		local newPart = templatePart:Clone()
		newPart.CFrame = attackerRoot.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(90), math.rad(35), math.rad(180))

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		task.wait(0.45)
		newPart.Parent = workspace
		tween:Play()

		tween.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,

	["RockBendingKick"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.Position)

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {CFrame = attackerRoot.CFrame * CFrame.new(0, 1, -2)}
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal2 = {Position = targetPos,}

		local templatePart = VFXFolder.RockFragment2
		local newPart = templatePart:Clone()
		newPart.Parent = workspace
		newPart.CFrame = attackerRoot.CFrame * CFrame.new(0, -5, -2)

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		local tween2 = TweenService:Create(newPart, tweenInfo2, tweenGoal2)

		tween:Play()
		tween.Completed:Wait()
		tween2:Play()

		tween2.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,



	["Cataclysm"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.Position)
		local templatePart = VFXFolder.Cataclysm
		local newPart = templatePart:Clone()
		newPart.Parent = workspace
		newPart.CFrame = attackerRoot.CFrame * CFrame.new(0, 10, 0)

		local size = Vector3.new(100, 100, 100)
		local heightOffset = (size.Y - newPart.Size.Y) / 2

		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Size = size, Position = newPart.Position + Vector3.new(0, heightOffset, 0)}
		local tweenGoal2 = {Position = targetPos,}



		local tween = TweenService:Create(newPart, tweenInfo2, tweenGoal)
		local tween2 = TweenService:Create(newPart, tweenInfo, tweenGoal2)
		tween:Play()
		tween.Completed:Wait()
		tween2:Play()

		tween2.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,

	["MagicMissile"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerRoot = attackerModel.PrimaryPart
		local targetRoot = targetModel.PrimaryPart

		local targetPos = (targetRoot.Position)
		local templatePart = VFXFolder.MagicMissile
		local newPart = templatePart:Clone()
		newPart.CFrame = attackerRoot.CFrame * CFrame.new(0, 2, 0)
		newPart.Parent = workspace

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Position = targetPos,}

		local tween = TweenService:Create(newPart, tweenInfo, tweenGoal)
		tween:Play()

		tween.Completed:Connect(function()
			Debris:AddItem(newPart, 0)
		end)
	end,

	["SpearThrowATTEMPT"] = function(attacker, target)
		local attackerModel = attacker.Instance
		local targetModel = target.Instance

		local attackerData = require(attackerModel.InstanceData)
		local spearName = weaponData:GetWeaponOfType(attackerData.Weapons, "spear")
		if not spearName then return end

		local spear = attackerModel.Weapons[spearName]
		if not spear then return end

		local originalPos = spear.PrimaryPart.CFrame

		local targetRoot = targetModel.PrimaryPart
		local targetPos = (targetRoot.Position)

		local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenGoal = {Position = targetPos,}

		local tween = TweenService:Create(spear.Handle, tweenInfo, tweenGoal)
		task.wait(0.5)
		tween:Play()

		tween.Completed:Connect(function()
			spear:PivotTo(originalPos)
			visualSystem.withdrawWeapons(attackerModel)
		end)
	end,
}

visualSystem.EffectsVFX = {}

return visualSystem