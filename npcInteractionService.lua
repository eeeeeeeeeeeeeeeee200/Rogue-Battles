local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- 1. Setup Modules
local battleSystem = require(ReplicatedStorage.Systems.BattleSystem)
local dataSystem = require(ReplicatedStorage.Systems.DataSystem)
local NPCLogic = require(ServerScriptService:WaitForChild("NPCLogic"))
local invSystem = require(ReplicatedStorage.Systems.InvSystem)
local AttacksModule = require(ReplicatedStorage:WaitForChild("AttacksModule"))

local TrainingData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("TrainingData"))
local weaponData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("WeaponData"))
local armorData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("ArmorData"))
local passivesData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("PassivesData"))
local racesData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("RacesData"))

local soundeffects = game:GetService("SoundService"):WaitForChild("SoundEffects")

local visualSystem = require(ReplicatedStorage.Systems:WaitForChild("VisualSystem"))
local equipmentSystem = require(ReplicatedStorage.Systems:WaitForChild("EquipmentSystem"))
local passivesSystem = require(ReplicatedStorage.Systems:WaitForChild("PassivesSystem"))
local subraceSystem = require(ReplicatedStorage.Systems:WaitForChild("SubraceSystem"))

-- 2. Setup Events
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local dialogueEvent = EventsFolder:WaitForChild("DialogueEvent")
local dialogueRemote = EventsFolder:WaitForChild("DialogueRemote")
local updateUIEvent = EventsFolder:WaitForChild("UpdateUI")
local resetEvent = EventsFolder:WaitForChild("ResetEvent")
local soundEvent = EventsFolder:WaitForChild("SoundEffectsEvent")
local messageEvent = EventsFolder:WaitForChild("LittleMessagesEvent")
local orbEvent = EventsFolder:WaitForChild("OrbEvent")
local bindableOrb = EventsFolder:WaitForChild("BindableOrb")
local startBattleEvent = EventsFolder.startBattleServer
local bossMusicEvent = EventsFolder:WaitForChild("BossMusicEvent")
local dungeonEvent = EventsFolder:WaitForChild("DungeonSpawnerEvent")

local dialogueDatas = {}

-- 3. Settings
local TweenService = game:GetService("TweenService")
local teleportDestination = CFrame.new(-825.5, 22.5, -345.5)
local islanddestination = CFrame.new(-719.235, 25.2, -2491.8)
local backfromisland = CFrame.new(-629, 15.5, -270.45)
local elesigisland = CFrame.new(-1433.601, 28.001, -2903.049)
local elesigexit = CFrame.new(-1049.334, 24.427, -3267.264)
local elesigaretim = CFrame.new(12977.04, 1581.297, 167.481)

local possibleRaces = racesData.Races

local resettingPlayers = {}
local function resetSlot(player, slotData, currentSlotName, sessionData)
	if resettingPlayers[player] then return end
	resettingPlayers[player] = true

	local race = slotData.Race
	if race == "None" or race == "" or slotData.Lives == -1 then
		race = possibleRaces[math.random(1, #possibleRaces)]
	end

	local newSlotData = table.clone(require(ReplicatedStorage.ProfilesTemplate.SlotDataTemplate))
	
	newSlotData.Lives = 3
	newSlotData.Race = race
	local raceData = racesData[race]
	if not raceData then raceData = racesData.Default end
	
	local currentRaceStats = raceData.Stats or {Defence = 0, Damage = 1, Speed = 1}
	for statName, raceStat in pairs(currentRaceStats) do
		newSlotData[statName] = raceStat
	end
	
	local starterAttacksList = raceData.Attacks or {"Punch"}
	local formattedAttacks = {}
	for index, attackName in ipairs(starterAttacksList) do
		formattedAttacks[attackName] = {
			position = index,
			equipped = true,
			useable = true
		}
	end
	newSlotData.Attacks = formattedAttacks

	local starterPassivesList = raceData.Passives or {}

	newSlotData.CombatPassives = {}
	for passiveName, passiveData in pairs(starterPassivesList) do
		passivesSystem.learnPassive(newSlotData, passiveName, passiveData)
	end

	visualSystem.GetRandomSkinForRace(newSlotData, race)
	
	local raceAccessories = raceData.Accessories or {}
	for _, accessoryName in ipairs(raceAccessories) do
		table.insert(newSlotData.Accessories, accessoryName)
	end

	sessionData.Slots[currentSlotName] = newSlotData

	if player.Character then
		player:LoadCharacterAsync()

		player.Character:PivotTo(teleportDestination)
		visualSystem.ApplyAppearance(player.Character, newSlotData)
	end
	resettingPlayers[player] = false
end

local function playSoundEffect(player, soundName)
	soundEvent:FireClient(player, soundName)
end

local function sendMessage(player, message)
	messageEvent:FireClient(player, message)
end

local function buyItem(cost, player, slotData, itemName, itemType)
	if itemType == "Armor" or itemType == "Helmet" then
		if slotData[itemType] == itemName then
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You already have this!")
			return
		end
	end
	
	if slotData.EmberShards >= cost then
		if equipmentSystem.equipItem(slotData, itemName, player, itemType) then
			slotData.EmberShards -= cost
		end
		visualSystem.ApplyAppearance(player.Character, slotData)
		playSoundEffect(player, "Success")
		return true
	else
		sendMessage(player, "You can't afford that!")
		playSoundEffect(player, "Brokie")
		return false
	end
end

local function learnClass(player, slotData, className, progression, cost, classTier, currency)
	local currency = currency or "Ember Shards"
	local currencyName = string.gsub(currency, " ", "")
	
	local freeSlot = slotData[classTier] == "None"
		or slotData[classTier] == className 
		or (type(slotData[classTier]) == "table" and (TrainingData.GetCompatibility(className, slotData[classTier])) 
		or table.find(slotData[classTier], className))
	
	if not freeSlot then return end
	
	local skillToLearn = nil
	for _, skillName in ipairs(progression) do
		if not slotData.SkillsLearned[skillName] then skillToLearn = skillName break end
	end
	
	if skillToLearn and slotData[currencyName] >= cost then
		slotData[currencyName] -= cost
		if type(slotData[classTier]) == "table" then slotData[classTier][freeSlot] = className else slotData[classTier] = className end
		TrainingData.LearnSkill(player, skillToLearn)
		playSoundEffect(player, "Learn")
		visualSystem.ApplyAppearance(player.Character, slotData)
		return true
	else
		sendMessage(player, "You don't have enough " .. currency .. ".")
		playSoundEffect(player, "Brokie")
		
		return false
	end
end

-- 4. Central Event Handler
dialogueRemote.OnServerEvent:Connect(function(player, requestType, extraArg)
	local sessionData = dataSystem.getData(player)
	if not sessionData then return end

	local currentSlotName = sessionData.LastSlot
	local slotData = sessionData.Slots[currentSlotName]
	if not slotData then return end

	if requestType == "Reset" then
		resetSlot(player, slotData, currentSlotName, sessionData)

	elseif requestType == "TeleportOnly" then
		if player.Character then
			player.Character:PivotTo(teleportDestination) 
			player.Character.Humanoid.Health = slotData.Health
		end

	elseif requestType == "Train_Robbie" or requestType == "RobbieLearning" then
		if not weaponData:GetWeaponOfType(slotData.Weapons, "sword") then print("WTF") return end
		learnClass(player, slotData, "Swordsman", TrainingData.RobbieProgression, 20, "T1Classes")

	elseif requestType == "Train_Noelle" or requestType == "NoelleLearning" then
		learnClass(player, slotData, "Spearfighter", TrainingData.NoelleProgression, 60, "T1Classes")
		
	elseif requestType == "Train_Faye" or requestType == "FayeLearning" then
		if slotData.MaxHealth < 35 then return end
		learnClass(player, slotData, "Martial Artist", TrainingData.FayeProgression, 20, "T1Classes")

	elseif requestType == "Train_Zylies" then
		learnClass(player, slotData, "Wizard", TrainingData.ZyliesProgression, 40, "T1Classes")

	elseif requestType == "Train_Keo" or requestType == "KeoLearning" then
		if not weaponData:GetWeaponOfType(slotData.Weapons, "shield") then return end
		learnClass(player, slotData, "Defender", TrainingData.KeoProgression, 40, "T1Classes")
	elseif requestType == "Train_Barbarian" then
		if not table.find(slotData.T1Classes, "Swordsman") or slotData.QuestProgress.Barbarian then return end
	learnClass(player, slotData, "Barbarian", TrainingData.ZanshiProgression, 0, "T2Class")
		slotData.QuestProgress["Barbarian"] = 0
		
	elseif requestType == "Permit_Teks" then
		if slotData.EmberShards < 100 then return end 
		slotData.EmberShards -= 100
		slotData.SkillsLearned["FlintlockPermit"] = true
		slotData.QuestProgress["Teks"] = 1
		playSoundEffect(player, "Success")
	elseif requestType == "Train_Teks" then
		learnClass(player, slotData, "Buccaneer", TrainingData.TeksProgression, 70, "T1Classes")
		
	elseif requestType == "Train_Kaint" or requestType == "KaintLearning" then
		if not weaponData:GetWeaponOfType(slotData.Weapons, "shield") or not weaponData:GetWeaponOfType(slotData.Weapons, "sword") then return end
		learnClass(player, slotData, "Guardian", TrainingData.KaintProgression, 0, "T2Class")
		
	elseif requestType == "Train_MotherTree" or requestType == "MotherTreeLearning" then
		learnClass(player, slotData, "Druid", TrainingData.MotherTreeProgression, 10, "T2Class", "Souls")
		
	elseif requestType == "Train_Edgar" then
		learnClass(player, slotData, "Maniacal Fighter", TrainingData.EdgarProgression, 120, "T2Class")

	elseif requestType == "Train_Jin" then
		learnClass(player, slotData, "Soul-Flux Barbarian", TrainingData.JinProgression, 100, "T2Class")

	elseif requestType == "Hugo_Buy" then
		local cost = 20
		if slotData.EmberShards >= cost then
			local success = invSystem.AddItem(player, "Coconut Water", 1)
			if success then slotData.EmberShards -= cost end
			playSoundEffect(player, "Success")
		else
			sendMessage(player, "You can't afford that!")
			playSoundEffect(player, "Brokie")
		end
	
	elseif requestType == "Kab_Buy" then
		local cost = 30
		if slotData.EmberShards >= cost then
			local success = invSystem.AddItem(player, "Corn", 1)
			if success then slotData.EmberShards -= cost end
			playSoundEffect(player, "Success")
		else
			sendMessage(player, "You can't afford that!")
			playSoundEffect(player, "Brokie")
		end
		
	-- Nate
	elseif requestType == "NateQuest1" then
		slotData.QuestProgress["Nate"] = 1
	elseif requestType == "NateQuest2" then
		slotData.QuestProgress["Nate"] = 2
	elseif requestType == "NateQuest3" then
		slotData.QuestProgress["Nate"] = 3
		slotData.EmberShards = slotData.EmberShards + 60
		
	elseif requestType == "CleinQuest" then
		if slotData.EmberShards >= 50 then
			slotData.EmberShards -= 50
			slotData.QuestProgress["Clein"] = 1
			playSoundEffect(player, "Success")
		end
		
	--Rex
	elseif requestType == "RexQuest1" then
		slotData.QuestProgress["Rex"] = 1
	elseif requestType == "RexQuest2" then
		slotData.QuestProgress["Rex"] = 2
	elseif requestType == "RexQuest3" then
		slotData.QuestProgress["Rex"] = 3
		slotData.EmberShards += 130
		
	elseif requestType == "SergiQuest1" then
		slotData.QuestProgress["Sergi"] = 0
	elseif requestType == "SergiQuest2" then
		if invSystem.RemoveItem(player, "Black Rock", 3) then
			playSoundEffect(player, "Success")
			slotData.QuestProgress["Sergi"] = 1
		end
		
	elseif requestType == "InteractLocalNPC" then
		local dialogueId = extraArg
		local finalId = dialogueId
		local logicFunc = NPCLogic.Rules[dialogueId]

		if logicFunc and slotData then 
			finalId = logicFunc(slotData) 
		end

		local proxyModel = ReplicatedStorage.Templates:FindFirstChild("Gabriel")
		dialogueEvent:FireClient(player, finalId, proxyModel)
	
	-- gabe
	elseif requestType == "GabbieSword" then
		if buyItem(0, player, slotData, "Basic Sword", "Weapon") then
			AttacksModule:LearnAttack(player, "Sword Strike")
		end

	--Orbs
	elseif requestType == "Orb" then
		orbEvent:FireClient(player, slotData.UnlockedFastTravels, "Open")
		bindableOrb:Fire(player, slotData.UnlockedFastTravels)
	
	elseif requestType == "BeachOrb" then
		slotData.UnlockedFastTravels["Beach"] = true
		playSoundEffect(player, "Learn")
	elseif requestType == "LuneOrb" then
		slotData.UnlockedFastTravels["Lune"] = true
		playSoundEffect(player, "Learn")
	elseif requestType == "VolcanoOrb" then
		slotData.UnlockedFastTravels["Volcano"] = true
		playSoundEffect(player, "Learn")
	elseif requestType == "IslandOrb" then
		slotData.UnlockedFastTravels["Island"] = true
		playSoundEffect(player, "Learn")
	
	
	--kib
	elseif requestType == "KipDoorOpen" then
		local door = workspace.Interactable.Door
		local otherdoor = workspace.Interactable.Part

		local info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweengoal = {Position = Vector3.new(-550.787, 39.422, 533.143)}
		local tweengoal2 = {Position =  Vector3.new(-544.787, 39.422, 533.143)}
		local tweengoal3 = {Position = Vector3.new(-551.64, 39.04, 533.5)}
		local tweengoal4 = {Position = Vector3.new(-544.64, 39.04, 533.5)}
		
		local open = TweenService:Create(door, info, tweengoal)
		local close = TweenService:Create(door, info, tweengoal2)
		local open2 = TweenService:Create(otherdoor, info, tweengoal3)
		local close2 = TweenService:Create(otherdoor, info, tweengoal4)
	
		-- playSoundEffect(player, "Waves")
		task.spawn(function()
		open:Play()
		open2:Play()
		end)
		open.Completed:Wait()

		task.wait(3)
		task.spawn(function()
			close:Play()
			close2:Play()
		end)
		close.Completed:Wait()

	elseif requestType == "SeanToIsland" then
		local seangui = player.PlayerGui:WaitForChild("SeanTeleportGui")
		local frame = seangui:WaitForChild("Frame")

		local info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local fadeIn = TweenService:Create(frame, info, {BackgroundTransparency = 0})
		local fadeOut = TweenService:Create(frame, info, {BackgroundTransparency = 1})
		
		seangui.Enabled = true
		playSoundEffect(player, "Waves")
		fadeIn:Play()
		fadeIn.Completed:Wait()

		if player.Character then
			print("teleporting")
			player.Character:PivotTo(islanddestination) 
		end
		
		task.wait(0.5)

		fadeOut:Play()
		fadeOut.Completed:Wait()
		seangui.Enabled = false
		
	elseif requestType == "SeanIsland" then
		local seangui = player.PlayerGui:WaitForChild("SeanTeleportGui")
		local frame = seangui:WaitForChild("Frame")

		local info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local fadeIn = TweenService:Create(frame, info, {BackgroundTransparency = 0})
		local fadeOut = TweenService:Create(frame, info, {BackgroundTransparency = 1})

		seangui.Enabled = true
		playSoundEffect(player, "Waves")
		fadeIn:Play()
		fadeIn.Completed:Wait()

		if player.Character then
			print("teleporting")
			player.Character:PivotTo(backfromisland) 
		end

		task.wait(0.5)

		fadeOut:Play()
		fadeOut.Completed:Wait()
		seangui.Enabled = false
	
	elseif requestType == "ClunkyArmor_Buy" then
		buyItem(75, player, slotData, "ClunkyArmor", "Armor")
	elseif requestType == "ClunkyHelmet_Buy" then
		buyItem(50, player, slotData, "ClunkyHelmet", "Helmet")
	elseif requestType == "SunHelmet_Buy" then
		if not slotData.SkillsLearned["Pure Heart"] then
			sendMessage(player, "You don't meet the requirements for this!")
			return
		end
		buyItem(100, player, slotData, "SunHelmet", "Helmet")
	elseif requestType == "SpartanHelmet_Buy" then
		if not table.find(slotData.T1Classes, "Spearfighter") then
			sendMessage(player, "You don't meet the requirements for this!")
			return
		end
		buyItem(90, player, slotData, "SpartanHelmet", "Helmet")
	elseif requestType == "TravelerHood_Buy" then
		buyItem(40, player, slotData, "TravelerHood", "Helmet")
	elseif requestType == "LeafCrown_Buy" then
		buyItem(30, player, slotData, "LeafCrown", "Helmet")
	elseif requestType == "VolcanicHelmet_Buy" then
		if not slotData.QuestProgress["Sergi"] or slotData.QuestProgress["Sergi"] ~= 1 then
			sendMessage(player, "The shop owner doesn't want to sell this to you.")
			return
		end
		buyItem(120, player, slotData, "VolcanicHelmet", "Helmet")
	elseif requestType == "BlueMageArmor_Buy"  then
		buyItem(100, player, slotData, "BlueMageArmor", "Armor")
	elseif requestType == "WarriorArmor_Buy"  then
		buyItem(120, player, slotData, "WarriorArmor", "Armor")
	elseif requestType == "GothicSpec_Buy"  then
		if player.Name ~= "gothickitty08" then return end
		buyItem(0, player, slotData, "GothicSpec", "Armor")
	elseif requestType == "TackySuit_Buy"  then
		buyItem(120, player, slotData, "TackySuit", "Armor")
	elseif requestType == "SpearfighterArmor_Buy" then
		if table.find(slotData.T1Classes, "Spearfighter") then
			buyItem(140, player, slotData, "SpearfighterArmor", "Armor")
		else
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You don't meet the requirements for this!")
		end
	elseif requestType == "DefenderArmor_Buy" then
		if table.find(slotData.T1Classes, "Defender") then
			buyItem(80, player, slotData, "DefenderArmor", "Armor")
		else
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You don't meet the requirements for this!")
		end
	elseif requestType == "VolcanicArmor_Buy" then
		if not slotData.QuestProgress["Sergi"] or slotData.QuestProgress["Sergi"] ~= 1 then
			sendMessage(player, "The shop owner doesn't want to sell this to you.")
			return
		end
		buyItem(150, player, slotData, "VolcanicArmor", "Armor")
	elseif requestType == "BasicSpear_Buy" then
		if weaponData:GetWeaponOfType(slotData.Weapons, "spear") or not table.find(slotData.Weapons, "None") then
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You already have too many weapons!")
			return
		end
		if not slotData.SkillsLearned["Spear Knowledge"] then
			sendMessage(player, "You don't meet the requirements for this!")
			return
		end
		if buyItem(75, player, slotData, "Basic Spear", "Weapon") then
			AttacksModule:LearnAttack(player, "Spear Jab")
		end
	elseif requestType == "BasicSword_Buy" then
		if weaponData:GetWeaponOfType(slotData.Weapons, "sword") or not table.find(slotData.Weapons, "None") then
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You already have too many weapons!")
			return
		end
		if buyItem(20, player, slotData, "Basic Sword", "Weapon") then
			AttacksModule:LearnAttack(player, "Sword Strike")
		end
	elseif requestType == "BasicShield_Buy" then
		if weaponData:GetWeaponOfType(slotData.Weapons, "shield") or not table.find(slotData.Weapons, "None") then
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You already have too many weapons!")
			return 
		end
		if buyItem(50, player, slotData, "Basic Shield", "Weapon") then
			AttacksModule:LearnAttack(player, "Shield Ram")
		end
	elseif requestType == "BasicFlintlock_Buy" then
		if weaponData:GetWeaponOfType(slotData.Weapons, "flintlock") or not table.find(slotData.Weapons, "None") then
			playSoundEffect(player, "Brokie")
			sendMessage(player, "You already have too many weapons!")
			return 
		end
		if slotData.SkillsLearned["FlintlockPermit"] and buyItem(50, player, slotData, "Basic Flintlock", "Weapon") then
			AttacksModule:LearnAttack(player, "Flintlock: Fire")
			AttacksModule:LearnAttack(player, "Flintlock: Reload")
		end
	
	
	elseif requestType == "Duster_PartyBattle" then
		if dialogueDatas["DusterBattleStarted"] then
			sendMessage(player, "There's already a battle in progress!")
			return
		end
		if not dialogueDatas["DusterParty1"] or dialogueDatas["DusterParty1"][1].Parent ~= workspace then
			dialogueDatas["DusterParty1"] = battleSystem.getPlayerParty(player)
		else
			dialogueDatas["DusterBattleStarted"] = true
			
			local battleInfo = {
				useParty = true,
				combatState = false,
				otherParty = dialogueDatas["DusterParty1"],
				party1TP = Vector3.new(-393, 66.875, 427.66),
				party2TP = Vector3.new(-393, 66.875, 411.66),
				onBattleEnd = function()
					dialogueDatas["DusterBattleStarted"] = nil
					dialogueDatas["DusterParty1"] = nil
				end,
			}
		
			startBattleEvent:Fire(player, battleInfo)
		end
	elseif requestType == "Duster_Battle" then
		if dialogueDatas["DusterBattleStarted"] then
			sendMessage(player, "There's already a battle in progress!")
			return
		end
		dialogueDatas["DusterBattleStarted"] = true
		
		local enemylist = {battleSystem.createEnemy("Duster")}
		local battleInfo = {
			useParty = true,
			combatState = false,
			otherParty = enemylist,
			party1TP = Vector3.new(-393, 66.875, 427.66),
			party2TP = Vector3.new(-393, 66.875, 411.66),
			onBattleEnd = function()
				dialogueDatas["DusterBattleStarted"] = nil
			end,
		}
		startBattleEvent:Fire(player, battleInfo)
		
	elseif requestType == "Anneliese_Battle" then
		local enemyList = {battleSystem.createEnemy("Anneliese")}
		local battleInfo = {
			useParty = true,
			combatState = true,
			otherParty = enemyList,
			party1TP = Vector3.new(-562.5, 6, -58.26),
			party2TP = Vector3.new(-582.5, 6, -58.26),
			onBattleStart = function(battleSession)
				local boss
				for i, participant in ipairs(battleSession.Participants) do
					if participant.Instance.Name == "Anneliese" then
						boss = participant
						table.remove(battleSession.Participants, i)
					end
				end
				table.insert(battleSession.Participants, 1, boss)
			end,
			onBattleEnd = function(battleSession, reason)
				if reason ~= "win" then return end
				
				for _, participant in ipairs(battleSession.Participants) do
					local participantInstance = participant.Instance
					local participantData = require(participantInstance.InstanceData)

					if participantData.EntityType == "Player" then
						participantData.QuestProgress["Anneliese"] = 1
					end
				end
			end,
		}
		startBattleEvent:Fire(player, battleInfo)
		
	elseif requestType == "Agres_Battle" then
		local enemyList = {battleSystem.createEnemy("Agres")}
		local battleInfo = {
			useParty = true,
			combatState = true,
			otherParty = enemyList,
			party1TP = Vector3.new(-393, 66.875, 427.66),
			party2TP = Vector3.new(-393, 66.875, 411.66),
			onBattleEnd = function(battleSession, reason)
				if reason ~= "win" then return end
				
				slotData.QuestProgress["Agres"] = 1
			end,
		}
		startBattleEvent:Fire(player, battleInfo)
	elseif requestType == "Agres_Genesis" then
		invSystem.AddItem(player, "Orb of Genesis", 1)

    elseif requestType == "FlogesQuest" then 
        slotData.QuestProgress["Floges"] = 1
    
    elseif requestType == "FlogesSubrace" then
        subraceSystem.ApplySubrace(slotData, "Ignited", player)
		
	elseif requestType == "StartLabRun" then
		if dialogueDatas["LabRunStarted"] then
			sendMessage(player, "There's already a party in!")
			return
		end
		dialogueDatas["LabRunStarted"] = true
		local labEntry = workspace.GameMap.TempleInside.entry:GetPivot()
		local playerParty = battleSystem.getPlayerParty(player)
		for i, v in pairs(workspace["BattleParts(dont delete)"]:GetChildren()) do
			if v:IsA("BasePart") then v.CanTouch = true end
		end		
		if not playerParty then return end
		for i, v in pairs(playerParty) do
			if not v then continue end
			v:PivotTo(labEntry)
			if not dialogueDatas["LabPlayerCount"] then dialogueDatas["LabPlayerCount"] = 1
				else
			dialogueDatas["LabPlayerCount"] += 1
			end
		end
		
	elseif requestType == "LabExitDoor" then
		if dialogueDatas["LabRunStarted"] and dialogueDatas["LabPlayerCount"] > 0 then
			if not player.Character then return end
			local exit = workspace.GameMap.FrescoIsland.Temple.Exit:GetPivot()
		player.Character:PivotTo(exit)
		dialogueDatas["LabPlayerCount"] -= 1
			if dialogueDatas["LabPlayerCount"] == 0 then
				dialogueDatas["LabRunStarted"] = false
			end
		end
	elseif requestType == "DungeonStart" then
		dungeonEvent:Fire(player, 1)
		
	elseif requestType == "Dummy_Battle" then
		if dialogueDatas["DummyBattleStarted"] then
			sendMessage(player, "There's already a battle in progress!")
			return
		end
		dialogueDatas["DummyBattleStarted"] = true
		
		local enemylist = {battleSystem.createEnemy("Dummy")}
		local battleInfo = {
			useParty = false,
			combatState = false,
			otherParty = enemylist,
			party1TP = Vector3.new(-294, 43.1, 349.75),
			party2TP = Vector3.new(-311.5, 43.1, 349.75),
			onBattleEnd = function()
				dialogueDatas["DummyBattleStarted"] = nil
			end,
		}
		startBattleEvent:Fire(player, battleInfo)
	
	elseif requestType == "Dummy_BattleGab" then
	
		local enemylist = {battleSystem.createEnemy("Dummy Gabriel")}
		local battleInfo = {
			useParty = false,
			combatState = false,
			otherParty = enemylist,
			party1TP = Vector3.new(9989.5, 1013, 9836.502),
			party2TP = Vector3.new(9989.5, 1013, 9816.5),
			onBattleEnd = function()
			end,
		}
		startBattleEvent:Fire(player, battleInfo)

	elseif requestType == "MotherTree_Battle" then
		if not dialogueDatas.treeBattleCount or dialogueDatas.treeBattleCount == 30 then dialogueDatas.treeBattleCount = 0 end
		dialogueDatas.treeBattleCount += 1

		local enemyList = {battleSystem.createEnemy("Forest Spirit")}
		local arenaTemplate = ReplicatedStorage.Templates.TreeArenaTemplate
		local arenaClone = arenaTemplate:Clone()

		local templateCFrame = arenaTemplate:GetPivot()
		
		local offset = Vector3.new(dialogueDatas.treeBattleCount * 100, 0, 0)

		arenaClone:PivotTo(templateCFrame + offset)
		
		local party1spot = arenaClone.PlayerTpSpot.Position
		local party2spot = arenaClone.EnemyTpSpot.Position
		arenaClone.Parent = workspace
		
		local battleInfo = {
			useParty = false,
			otherParty = enemyList,
			party1TP = party1spot,
			party2TP = party2spot,
			onBattleEnd = function(battleSession)
				arenaClone:Destroy()
				
				local startCharacter = player.Character
				for _, participant in ipairs(battleSession.Participants) do
					local participantInstance = participant.Instance
					local participantData = require(participantInstance.InstanceData)
					
					if participantData.EntityType == "Player" then
						participantInstance:PivotTo(CFrame.new(5715.751, 6919.025, 1430.082) * CFrame.Angles(0, math.rad(180), 0))
					end
					
					if participantInstance == startCharacter then
						participantData.T2Class = "Druid"
					end
				end
			end,
		}
		startBattleEvent:Fire(player, battleInfo)
		
	elseif requestType == "Mekolkal_Purify" then
		passivesSystem.learnPassive(slotData, "Purified", {})
		slotData.MaxHealthFromSouls += 10
		slotData.HairColor = "Color8"
		visualSystem.ApplyAppearance(player.Character, slotData)
		
	elseif requestType == "ElesigDoor" then
		if player.Character then player.Character:PivotTo(elesigisland) end
	elseif requestType == "ElesigExitDoor" then
		if player.Character then player.Character:PivotTo(elesigexit) end
	elseif requestType == "Elesig" then
		slotData.QuestProgress["Elesig"] = 1
		slotData.Souls += 10
		playSoundEffect(player, "Vanish")
		if player.Character then player.Character:PivotTo(elesigexit) end
		
	elseif requestType == "Elesig2" then
		playSoundEffect(player, "Vanish")
		if player.Character then player.Character:PivotTo(elesigexit) end

	elseif requestType == "ElesigCombat" then
		playSoundEffect(player, "Vanish")
		if player.Character then player.Character:PivotTo(elesigaretim) end



	elseif requestType == "Mendi_Heal" then
		slotData.Health = slotData.MaxHealth
	end

	updateUIEvent:FireClient(player, "Init", sessionData)
end)

resetEvent.Event:Connect(function(player)
	local sessionData = dataSystem.getData(player)
	if not sessionData then return end
	
	local currentSlotName = sessionData.LastSlot
	local slotData = sessionData.Slots[currentSlotName]
	if not slotData then return end
	
	resetSlot(player, slotData, currentSlotName, sessionData)
	slotData.Lives = 0
	
	player.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(3093.5, 3798, -5))
end)

-- 5. Dialogue Trigger
local function SendEvent(player, npcModel)
	local dialogueId = npcModel:GetAttribute("DialogueId")
	local finalId = dialogueId
	local sessionData = dataSystem.getData(player)
	if sessionData then
		local currentSlotName = sessionData.LastSlot
		local slotData = sessionData.Slots[currentSlotName]
		local logicFunc = NPCLogic.Rules[dialogueId]
		if logicFunc and slotData then finalId = logicFunc(slotData) end
	end
	dialogueEvent:FireClient(player, finalId, npcModel)
end

-- 6. Helper Functions & NPC Setup
local function setupNPC(npc)
	local function setupcd(targetPart)
		local cd = targetPart:FindFirstChildOfClass("ClickDetector") or Instance.new("ClickDetector")
		cd.MaxActivationDistance = 15
		cd.Parent = targetPart
		cd.MouseClick:Connect(function(player) 
			SendEvent(player, npc) 
		end)
	end
	if npc:IsA("BasePart") then
		setupcd(npc)
	end
	for _, child in ipairs(npc:GetDescendants()) do
		if child:IsA("BasePart") then
			setupcd(child)
		end
	end
end

for _, npc in ipairs(CollectionService:GetTagged("NPC")) do setupNPC(npc) end
CollectionService:GetInstanceAddedSignal("NPC"):Connect(setupNPC)