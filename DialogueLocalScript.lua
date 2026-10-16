local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DialogueEvent")
local DialogueModule = require(ReplicatedStorage.Data.DialogueData)
local DialogueEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DialogueRemote")
local RunService = game:GetService("RunService")
local shopEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShopEvent")
local changesEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WorkspaceChangesEvent")

-- UI variables
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local dialogueGui = playerGui:WaitForChild("DialogueGui")
local textLabel = dialogueGui.DialogueText 
local buttonContainer = dialogueGui.DialogueFrame.Container
local currentNPCModel = nil 

-- Variables to track state

local distanceConnection = nil

local currentNPCData = nil
local currentDialogueId = ""

local updatingText = false
local viewingDialogue = false

local speedUpDialogue = false
local skipDialogue = false



local default_text_speed = 0.02
local fast_text_speed = 0.01

-- NOTE: the keys should be edited 
local dialogue_skip_key = Enum.KeyCode.Space
local dialogue_speed_up_key = Enum.KeyCode.Z
local dialoge_speed_up_mouse = Enum.UserInputType.MouseButton1


local function closeDialogue()
	dialogueGui.Enabled = false
	currentNPCData = nil 
	currentDialogueId = "" 
	updatingText = false
	viewingDialogue = false

	if distanceConnection then
		distanceConnection:Disconnect()
		distanceConnection = nil
	end
end

local function dialogueTextHandler(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
	if actionName == "dialogueSkip" then
		skipDialogue = (inputState == Enum.UserInputState.Begin)
	end
	if actionName == "dialogueSpeed" then
		speedUpDialogue = (inputState == Enum.UserInputState.Begin)
	end
end

local function updateText(text,skip)
	updatingText = true
	textLabel.Text = ""

	skipDialogue = false
	speedUpDialogue = false

	for i = 1, #text do
		if skipDialogue then
			-- you wont believe me what we do if skipDialogue == true
			textLabel.Text = text
			updatingText = false
		end
		if not updatingText then break end
		-- set the text speed
		local textSpeed = default_text_speed
		if speedUpDialogue then
			textSpeed = fast_text_speed 
		end
		-- update the text
		textLabel.Text = string.sub(text, 1, i)
		task.wait(textSpeed)
	end

	updatingText = false
	return true
end

local function displayStep(stepNumber)
	local step = currentNPCData[stepNumber]
	if not step or updatingText then return end
	
	--1. Clear all existing buttons
	for _, child in ipairs(buttonContainer:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	-- 2. Update the NPC's main text
	ContextActionService:BindAction("dialogueSkip",dialogueTextHandler,true,dialogue_skip_key)
	ContextActionService:BindAction("dialogueSpeed",dialogueTextHandler,true,dialoge_speed_up_mouse,dialogue_speed_up_key)
	-- design CAS buttons for mobile
	local skipBtn = ContextActionService:SetTitle("dialogueSkip","Skip")
	local speedBtn = ContextActionService:SetTitle("dialogueSpeed","Accelerate")
	
	updateText(step.Text)
	
	ContextActionService:UnbindAction("dialogueSkip")
	ContextActionService:UnbindAction("dialogueSpeed")

	-- 3. Create new buttons for Replies
	if step.Replies then
		for _, reply in ipairs(step.Replies) do
			local btn = ReplicatedStorage.Templates.AnswerTemplate:Clone()
			btn.Text = reply.Text
			btn.Parent = buttonContainer

			btn.MouseButton1Click:Connect(function()
				displayStep(reply.Next)
			end)
		end
	else

		task.wait(1) 

		if currentDialogueId == "Aretim_Alive" then
			if stepNumber == 4 then
				DialogueEvent:FireServer("Reset")
			elseif stepNumber == 3 then
				DialogueEvent:FireServer("TeleportOnly")
			end
		elseif currentDialogueId and string.find(currentDialogueId, "Aretim") then
			DialogueEvent:FireServer("Reset")
		end

		
		if currentDialogueId == "Robbie" and stepNumber == 5 then
			DialogueEvent:FireServer("Train_Robbie")
		
		elseif currentDialogueId == "RobbieLearning" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Robbie")
		
		elseif currentDialogueId == "Noelle" and stepNumber == 4 then
			DialogueEvent:FireServer("Train_Noelle")
		
		elseif currentDialogueId == "NoelleLearning" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Noelle")
			
		elseif currentDialogueId == "Faye" and stepNumber == 4 then
			DialogueEvent:FireServer("Train_Faye")
			
		elseif currentDialogueId == "FayeLearning" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Faye")

		elseif currentDialogueId == "Zylies" and stepNumber == 4 then
			DialogueEvent:FireServer("Train_Zylies")
		
		elseif currentDialogueId == "Zylies" and stepNumber == 8 then
			shopEvent:Fire("Zylies", currentNPCModel)
		
		elseif currentDialogueId == "ZyliesWrongClass" and stepNumber == 8 then
			shopEvent:Fire("Zylies", currentNPCModel)

		elseif currentDialogueId == "ZyliesLearning" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Zylies")

		elseif currentDialogueId == "Keo_ShieldEquipped" and stepNumber == 4 then
				DialogueEvent:FireServer("Train_Keo")
				
		elseif currentDialogueId == "KeoLearning" and stepNumber == 3 then
			DialogueEvent:FireServer("Train_Keo")
			
		elseif currentDialogueId == "Teks_Permit" and stepNumber == 4 then
			DialogueEvent:FireServer("Permit_Teks")
		elseif currentDialogueId == "Teks_QuestCompleted" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Teks")
		elseif currentDialogueId == "Teks_Training" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Teks")
			
		elseif currentDialogueId == "Kaint_Recruit" or currentDialogueId == "Kaint_Learning" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Kaint")
			
		elseif currentDialogueId == "MotherTreeTraining" or currentDialogueId == "MotherTreeMekolkalTraining" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_MotherTree")
			
		elseif currentDialogueId == "Edgar" and stepNumber == 4 then
			DialogueEvent:FireServer("Train_Edgar")

		elseif currentDialogueId == "EdgarLearning" and stepNumber == 2 then
			DialogueEvent:FireServer("Train_Edgar")
		
		elseif currentDialogueId == "BarbarianSwordPedestal" and stepNumber == 3 then
			playerGui:FindFirstChild("BarbarianGui").Frame.Visible = true
			
		elseif currentDialogueId == "JinRecruit" and stepNumber == 4 then
			DialogueEvent:FireServer("Train_Jin")
			
		elseif currentDialogueId == "Rin" and stepNumber == 4 then
			DialogueEvent:FireServer("StartLabRun")
			
		elseif currentDialogueId == "LabExitDoor" and stepNumber == 3 then
			DialogueEvent:FireServer("LabExitDoor")
		elseif currentDialogueId == "ElesigDoor" and stepNumber == 2 then
			-- 2 is door
			DialogueEvent:FireServer("ElesigDoor")
			
		elseif currentDialogueId == "ElesigExitDoor" and stepNumber == 2 then
			-- 2 is door
			DialogueEvent:FireServer("ElesigExitDoor")
		elseif currentDialogueId == "TestDungeonNpc" and stepNumber == 2 then
			DialogueEvent:FireServer("DungeonStart")
		elseif currentDialogueId == "KipDoorPassword" and stepNumber == 4 then
			-- 4 open
			DialogueEvent:FireServer("KipDoorOpen")
			
		elseif currentDialogueId == "Kip" and stepNumber == 2 then
			-- 2 open
			DialogueEvent:FireServer("KipDoorOpen")
			
		elseif currentDialogueId and string.find(currentDialogueId, "Gabriel") and stepNumber == 2 and currentDialogueId ~= "Gabriel3" then
			changesEvent:Fire(currentDialogueId)
		
		elseif currentDialogueId == "Gabriel3" and stepNumber == 2 then
			DialogueEvent:FireServer("GabbieSword")
			changesEvent:Fire(currentDialogueId)
			
		elseif currentDialogueId == "Hugo" and stepNumber == 4 then
			DialogueEvent:FireServer("Hugo_Buy")
			
		elseif currentDialogueId == "Kab" and stepNumber == 4 then
			DialogueEvent:FireServer("Kab_Buy")
		
		elseif currentDialogueId == "Ben" and stepNumber == 2 then
			local sellitems = playerGui:WaitForChild("SellItemsGui")
			sellitems.Enabled = true

		elseif currentDialogueId == "Duster" and stepNumber == 2 then
			DialogueEvent:FireServer("Duster_Battle")
		elseif currentDialogueId == "Duster" and stepNumber == 3 then
			DialogueEvent:FireServer("Duster_PartyBattle")
			
		elseif currentDialogueId == "Anneliese" and stepNumber == 5 then
			DialogueEvent:FireServer("Anneliese_Battle")
			
		elseif currentDialogueId == "Dummy" and stepNumber == 2 then
			DialogueEvent:FireServer("Dummy_Battle")
		
		elseif currentDialogueId == "DummyGab" and stepNumber == 2 then
			DialogueEvent:FireServer("Dummy_BattleGab")

		elseif currentDialogueId == "MotherTreeWizard" and stepNumber == 12 then
			DialogueEvent:FireServer("MotherTree_Battle")
	
		elseif currentDialogueId == "MotherTreeWizardMekolkal" and stepNumber == 16 then
			DialogueEvent:FireServer("MotherTree_Battle")
			
		elseif currentDialogueId == "MotherTreeWizardMekolkal" and stepNumber == 17 then
			DialogueEvent:FireServer("Mekolkal_Purify")
			
			
		elseif currentDialogueId == "MotherTreeMekolkal" and stepNumber == 15 then
			DialogueEvent:FireServer("Mekolkal_Purify")
			
		elseif currentDialogueId == "MotherTreeMekolkalTraining" and stepNumber == 6 then
		    DialogueEvent:FireServer("Mekolkal_Purify")

        elseif currentDialogueId == "RitualCircle" and stepNumber == 4 then
            DialogueEvent:FireServer("RitualCircle")
		

		-- Mendi n spirit LOGIC
		elseif currentDialogueId == "Mendi" and stepNumber == 2 then
			-- Node 2 is the Healing!!!!!!!!!!!
			DialogueEvent:FireServer("Mendi_Heal")
			
			-- Sean LOGIC
		elseif currentDialogueId == "Sean" and stepNumber == 4 then
			-- Boat trip
			DialogueEvent:FireServer("SeanToIsland")	
		elseif currentDialogueId == "SeanIsland" and stepNumber == 3 then
			-- Boat trip
			DialogueEvent:FireServer("SeanIsland")
			
		-- nate start	
		elseif currentDialogueId == "Nate" and stepNumber == 5 then
			DialogueEvent:FireServer("NateQuest1")
		elseif currentDialogueId == "KateQuest" and stepNumber == 5 then
			DialogueEvent:FireServer("NateQuest2")
		elseif currentDialogueId == "NateUndoneQuest" and stepNumber == 2 then
			DialogueEvent:FireServer("NateQuest3")
		-- end of nate
		
		elseif currentDialogueId == "Clein" and stepNumber == 2 then
			DialogueEvent:FireServer("CleinQuest")
			
		
			
		-- rex quest start
		elseif currentDialogueId == "RexQuest" and stepNumber == 2 then
			DialogueEvent:FireServer("Rex", currentNPCModel)
			shopEvent:Fire("Rex", currentNPCModel)
		elseif currentDialogueId == "RexQuestDone" and stepNumber == 2 then
			DialogueEvent:FireServer("Rex", currentNPCModel)
			shopEvent:Fire("Rex", currentNPCModel)
		elseif currentDialogueId == "Rex" and stepNumber == 6 then
			DialogueEvent:FireServer("RexQuest1")
		elseif currentDialogueId == "DenisQuest" and stepNumber == 5 then
			DialogueEvent:FireServer("RexQuest2")
		elseif currentDialogueId == "RexIngredients" and stepNumber == 4 then
			DialogueEvent:FireServer("RexQuest3")
		-- rex end
		
		elseif currentDialogueId == "Sergi" and stepNumber == 6 then
			DialogueEvent:FireServer("SergiQuest1")
		elseif currentDialogueId == "SergiQuest" and stepNumber == 2 then
			DialogueEvent:FireServer("SergiQuest2")
		
		elseif currentDialogueId == "Elesig" and stepNumber == 6 then
			DialogueEvent:FireServer("Elesig")
			
		elseif currentDialogueId == "Elesig2" and stepNumber == 3 then
			DialogueEvent:FireServer("Elesig2")
			
		elseif currentDialogueId == "ElesigCombat" and stepNumber == 3 then
			DialogueEvent:FireServer("ElesigCombat")


		
		-- fast travel ORB
		elseif currentDialogueId == "Orb" and stepNumber == 2 then
			DialogueEvent:FireServer("Orb")
		elseif currentDialogueId == "BeachOrb" and stepNumber == 2 then
			DialogueEvent:FireServer("BeachOrb")	
		elseif currentDialogueId == "LuneOrb" and stepNumber == 2 then
			DialogueEvent:FireServer("LuneOrb")	
		elseif currentDialogueId == "VolcanoOrb" and stepNumber == 2 then
			DialogueEvent:FireServer("VolcanoOrb")	
		elseif currentDialogueId == "IslandOrb" and stepNumber == 2 then
			DialogueEvent:FireServer("IslandOrb")
	
	
	-- These devs label NOTHING!!! Here, this is the Armor Section
	-- THESE DEVS LABEL TOO MUCH!!! STOP LABLEING THE ARMOR SECTION
		elseif currentDialogueId == "ClunkyArmor" and stepNumber == 2 then
			DialogueEvent:FireServer("ClunkyArmor_Buy")
			
		elseif currentDialogueId == "ClunkyHelmet" and stepNumber == 2 then
			DialogueEvent:FireServer("ClunkyHelmet_Buy")
		
		elseif currentDialogueId == "SunHelmet" and stepNumber == 2 then
			DialogueEvent:FireServer("SunHelmet_Buy")
			
		elseif currentDialogueId == "SpartanHelmet" and stepNumber == 2 then
			DialogueEvent:FireServer("SpartanHelmet_Buy")
		
		elseif currentDialogueId == "TravelerHood" and stepNumber == 2 then
			DialogueEvent:FireServer("TravelerHood_Buy")
			
		elseif currentDialogueId == "VolcanicHelmet" and stepNumber == 2 then
			DialogueEvent:FireServer("VolcanicHelmet_Buy")
		
		elseif currentDialogueId == "BlueMageArmor" and stepNumber == 2 then
			DialogueEvent:FireServer("BlueMageArmor_Buy")
			
		elseif currentDialogueId == "WarriorArmor" and stepNumber == 2 then
			DialogueEvent:FireServer("WarriorArmor_Buy")
			
		elseif currentDialogueId == "SpearfighterArmor" and stepNumber == 2 then
			DialogueEvent:FireServer("SpearfighterArmor_Buy")
			
		elseif currentDialogueId == "DefenderArmor" and stepNumber == 2 then
			DialogueEvent:FireServer("DefenderArmor_Buy")
			
		elseif currentDialogueId == "VolcanicArmor" and stepNumber == 2 then
			DialogueEvent:FireServer("VolcanicArmor_Buy")
		
		elseif currentDialogueId == "LeafCrown" and stepNumber == 2 then
			DialogueEvent:FireServer("LeafCrown_Buy")
			
		elseif currentDialogueId == "GothicSpec" and stepNumber == 2 then
			DialogueEvent:FireServer("GothicSpec_Buy")
			
			
		-- Weapon DialogueIDS	
		elseif currentDialogueId == "BasicSpear" and stepNumber == 2 then
			DialogueEvent:FireServer("BasicSpear_Buy")
			
		elseif currentDialogueId == "BasicSword" and stepNumber == 2 then
			DialogueEvent:FireServer("BasicSword_Buy")
		
		elseif currentDialogueId == "BasicShield" and stepNumber == 2 then
			DialogueEvent:FireServer("BasicShield_Buy")
			
		elseif currentDialogueId == "BasicFlintlock" and stepNumber == 2 then
			DialogueEvent:FireServer("BasicFlintlock_Buy")
			
		elseif currentDialogueId == "Agres" or currentDialogueId == "Agres_Fight" and stepNumber == 2 then
			playerGui.AgresSoulGiving.Enabled = true
		elseif currentDialogueId == "Agres_Fight" and stepNumber == 5 then
			DialogueEvent:FireServer("Agres_Battle")
		elseif currentDialogueId == "Agres_Reward" and stepNumber == 3 then
			DialogueEvent:FireServer("Agres_Genesis")
			
		elseif currentDialogueId == "Grim" and stepNumber == 2 then
			shopEvent:Fire("Grim", currentNPCModel)
			
		elseif currentDialogueId == "Rex" and stepNumber == 2 then
			shopEvent:Fire("Rex", currentNPCModel)
			
		end
		closeDialogue()
	end
end

-- Start the dialogue when the RemoteEvent is received from the Server
event.OnClientEvent:Connect(function(dialogueId, npcModel) 
	if viewingDialogue then return end
	
	currentDialogueId = dialogueId
	currentNPCModel = npcModel

	
	if string.find(dialogueId, "Gabriel") then
		local localGabe = workspace.GameMap:FindFirstChild("Tutorial") and workspace.GameMap.Tutorial:FindFirstChild("Gabriel")
		if localGabe then
			currentNPCModel = localGabe
		end
	end
	
	currentNPCData = DialogueModule.Dialogues[dialogueId]
	
	if currentNPCData then
		dialogueGui.Enabled = true
		
		if distanceConnection then distanceConnection:Disconnect() end

		distanceConnection = RunService.Heartbeat:Connect(function()
			local character = game.Players.LocalPlayer.Character
			if not character or not character:FindFirstChild("HumanoidRootPart") or not currentNPCModel then
				closeDialogue()
				return
			end
			local npcPart = nil
			if npcModel:IsA("BasePart") then 
				npcPart = currentNPCModel
			else
			npcPart = currentNPCModel.PrimaryPart or currentNPCModel:FindFirstChild("HumanoidRootPart") or currentNPCModel:FindFirstChildWhichIsA("BasePart")
			end
			
			if npcPart then
				local playerPos = character.HumanoidRootPart.Position
				local distance = (playerPos - npcPart.Position).Magnitude

				if distance > 15 then
					closeDialogue()
				end
			end
		end)
		
		viewingDialogue = true
		displayStep(1)
	else
		warn("No dialogue data found for ID: " .. tostring(dialogueId))
	end
end)

dialogueGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not dialogueGui.Enabled then
		closeDialogue()
	end
end)