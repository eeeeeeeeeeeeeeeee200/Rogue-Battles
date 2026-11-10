local dataFolder = game:GetService("ReplicatedStorage"):WaitForChild("Data")
local TrainingData = require(dataFolder:WaitForChild("TrainingData"))
local weaponData = require(dataFolder:WaitForChild("WeaponData"))

local NPCLogic = {}

local function isMaxed(slotData, skillList)
	for _, skillName in ipairs(skillList) do
		if not slotData.SkillsLearned[skillName] then
			return false
		end
	end
	return true
end

NPCLogic.Rules = {
	["Aretim"] = function(slotData)
		local lives = slotData.Lives
		if lives == -1 then return "Aretim_NewPlayer" end
		if lives == 0  then return "Aretim_Wiped" end
		return "Aretim_Alive"
	end,

	["Agres"] = function(slotData)
		if slotData.QuestProgress["Agres"] and slotData.QuestProgress["Agres"] >= 2 then
			return "Agres_Reward"
		elseif slotData.Karma >= 1 then
			return "Agres_Fight"
		end
		return "Agres"
	end,

	["Robbie"] = function(slotData)
		local progression = TrainingData.RobbieProgression

		-- 1. If they aren't a swordsman
		if not table.find(slotData.T1Classes, "Swordsman") then
			-- 2. If they don't have a compatible class
			if not TrainingData.GetCompatibility("Swordsman", slotData.T1Classes) then
				return "Robbie_WrongClass"
				-- 3. If they don't have a sword
			elseif not weaponData:GetWeaponOfType(slotData.Weapons, "sword") then
				return "Robbie_NoSword"
			end
			return "Robbie"
			-- 4. If they have the class but don't have a sword
		elseif not weaponData:GetWeaponOfType(slotData.Weapons, "sword") then
			return "Robbie_NoSword"
			-- 5. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			return "RobbieLearning"
			-- 6. Otherwise
		else
			return "Robbie_Trained"
		end
	end,

	["Noelle"] = function(slotData)
		local progression = TrainingData.NoelleProgression

		-- 1. If they aren't a spearfighter
		if not table.find(slotData.T1Classes, "Spearfighter") then
			-- 2. If they don't have a compatible class
			if not TrainingData.GetCompatibility("Spearfighter", slotData.T1Classes) then
				return "Noelle_WrongClass"
			end
			return "Noelle"
			-- 3. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			-- 4. If they have a spear
			if weaponData:GetWeaponOfType(slotData.Weapons, "spear") then
				return "NoelleLearning"
			else
				return "NoelleNotLearning"
			end
			-- 5. Otherwise
		else
			return "Noelle_Trained"
		end
	end,

	["Faye"] = function(slotData)
		local progression = TrainingData.FayeProgression

		-- 1. If they aren't a martial artist but have 35 max health
		if not table.find(slotData.T1Classes, "Martial Artist") then
			-- 2. If they can't get the class
			if not TrainingData.GetCompatibility("Martial Artist", slotData.T1Classes) or slotData.MaxHealth < 35 then
				return "Faye_Trained"
			else
				return "Faye"
			end
			-- 3. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			return "FayeLearning"
			-- 4. Otherwise
		else
			return "Faye_Trained"
		end
	end,

	["Zylies"] = function(slotData)
		local progression = TrainingData.ZyliesProgression

		-- 1. If they aren't a wizard
		if not table.find(slotData.T1Classes, "Wizard") then
			-- 2. If they have a non-compatible class
			if not TrainingData.GetCompatibility("Wizard", slotData.T1Classes) then
				return "ZyliesWrongClass"
			end
			return "Zylies"
			-- 3. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			return "ZyliesLearning"
			-- 4. Otherwise
		else
			return "Zylies_Trained"
		end
	end,


	["Keo"] = function(slotData)
		local progression = TrainingData.KeoProgression

		if not table.find(slotData.T1Classes, "Defender") then
			if not TrainingData.GetCompatibility("Defender", slotData.T1Classes) then
				return "Keo_Other"
			end
			if not weaponData:GetWeaponOfType(slotData.Weapons, "shield") then
				return "Keo"
			end

			return "Keo_ShieldEquipped"
			-- 3. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			return "KeoLearning"
			-- 5. Otherwise
		else
			return "Keo_Other"
		end
	end,

	["Teks"] = function(slotData)
		local progression = TrainingData.TeksProgression

		if not slotData.SkillsLearned["FlintlockPermit"] and not slotData.SkillsLearned["RevolverPermit"] then
			return "Teks_Permit"
		elseif slotData.SkillsLearned["FlintlockPermit"] then
			if not table.find(slotData.T1Classes, "Buccaneer") then
				if not TrainingData.GetCompatibility("Buccaneer", slotData.T1Classes) then
					return "Teks"
				end
				if slotData.QuestProgress["Teks"] < 1 then
					return "Teks"
				end
				return "Teks_QuestCompleted"
			elseif not isMaxed(slotData, progression) then
				return "Teks_Training"
			else
				return "Teks_Trained"
			end
		end
	end,

	["Kaint"] = function(slotData)
		local progression = TrainingData.KaintProgression

		-- 1. If they have a non-compatible class
		if not table.find(slotData.T1Classes, "Defender") or not table.find(slotData.T1Classes, "Swordsman") then
			return "Kaint_Other"
			-- 2. If they don't have a sword or a shield
		elseif not weaponData:GetWeaponOfType(slotData.Weapons, "sword") or not weaponData:GetWeaponOfType(slotData.Weapons, "shield") then
			return "Kaint_Other"
		elseif slotData.T2Class ~= "None" and slotData.T2Class ~= "Guardian" then
			return "Kaint_Other"
			-- 3. If they aren't a Defender yet
		elseif slotData.T2Class == "None" then
			return "Kaint_Recruit"
			-- 4. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			return "Kaint_Learning"
			-- 5. If they are maxed
		elseif isMaxed(slotData, progression) then
			return "Kaint_Trained"
			-- 6. Otherwise
		else
			return "Kaint_Other"
		end
	end,


	["MotherTree"] = function(slotData)
		local progression = TrainingData.MotherTreeProgression

		-- 1. If they don't have a T2 yet and are a wizard
		if slotData.T2Class == "None" and table.find(slotData.T1Classes, "Wizard") then
			if slotData.Race ~= "Mekolkal" or slotData.SkillsLearned["Purified"] then
				return "MotherTreeWizard"
			elseif not slotData.SkillsLearned["Corrupted"] then
				return "MotherTreeWizardMekolkal"
			else
				return "MotherTreeCorrupted"
			end
			-- 2. If they already are a Druid
		elseif slotData.T2Class == "Druid" then
			-- 3. If they're not maxed
			if not isMaxed(slotData, progression) then
				if slotData.Race ~= "Mekolkal" or slotData.SkillsLearned["Purified"] then
					return "MotherTreeTraining"
				else
					return "MotherTreeMekolkalTraining"
				end
				-- 4. If they are
			else
				if slotData.Race ~= "Mekolkal" or slotData.SkillsLearned["Purified"] then
					return "MotherTreeTrained"
				elseif not slotData.SkillsLearned["Corrupted"] then
					return "MotherTreeTrainedMekolkal"
				else
					return "MotherTreeCorrupted"
				end
			end
			-- 5. Otherwise (Not a wizard/Other T2)
		else
			if slotData.Race ~= "Mekolkal" or slotData.SkillsLearned["Purified"] then
				return "MotherTree"
			elseif not slotData.SkillsLearned["Corrupted"] then
				return "MotherTreeMekolkal"
			else
				return "MotherTreeCorrupted"
			end
		end
	end,

	["Edgar"] = function(slotData)
		local progression = TrainingData.EdgarProgression

		-- 1. If they have a non-compatible class
		if not table.find(slotData.T1Classes, "Spearfighter") then
			return "Edgar_WrongClass"
			-- 2. If they don't have a spear
		elseif not weaponData:GetWeaponOfType(slotData.Weapons, "spear") then
			return "EdgarNotLearning"
			-- 3. If they aren't the class yet
		elseif slotData.T2Class == "None" then
			return "Edgar"
			-- 4. If they aren't maxed
		elseif not isMaxed(slotData, progression) then
			return "EdgarLearning"
			-- 5. If they are maxed
		elseif isMaxed(slotData, progression) then
			return "Edgar_Trained"
			-- 6. Otherwise
		else
			return "Edgar_WrongClass"
		end
	end,

	["Jin"] = function(slotData)
		local progression = TrainingData.JinProgression

		-- 1. If they have a non-compatible class
		if not table.find(slotData.T1Classes, "Swordsman") then
			return "Jin_WrongClass"
			-- 2. If they don't have a sword
		elseif not weaponData:GetWeaponOfType(slotData.Weapons, "sword") then
			return "JinNotLearning"
			-- 3. If they aren't the class yet and did the quest
		elseif slotData.QuestProgress["Jin"] == 1 then
			if not isMaxed(slotData, progression) then
				return "JinLearning" end
			-- 4. if they arent maxed but didnt do the quest or smt idk
		elseif slotData.T2Class == "None" and not slotData.QuestProgress["Jin"] then
			return "JinRecruit"

			-- 5. If they are maxed
		elseif isMaxed(slotData, progression) then
			return "Jin_Trained"
			-- 6. Otherwise
		else
			return "Jin_WrongClass"
		end
	end,

	["SwordPedestal"] = function(slotData)
		if table.find(slotData.T1Classes, "Swordsman") and slotData.T2Class == "None" then
			return "BarbarianSwordPedestal"
		end
		return "SwordPedestal"
	end,

	["Elesig"] = function(slotData)
		local progress = slotData.QuestProgress["Elesig"] or 0
		if progress == 1 then 
			return "Elesig2"
		else 
			return "Elesig"
		end
	end,

	["KipDoor"] = function(slotData)
		local progress = slotData.QuestProgress["Clein"] or 0
		if progress == 1 then 
			return "KipDoorPassword"
		else 
			return "KipDoor"
		end
	end,

	["Clein"] = function(slotData)
		local progress = slotData.QuestProgress["Clein"] or 0
		if progress == 1 then 
			return "CleinQuestDone"
		else 
			return "Clein"
		end
	end,


	["Kate"] = function(slotData)
		local progress = slotData.QuestProgress["Nate"] or 0
		if progress == 1 then 
			return "KateQuest"
		else 
			return "Kate"
		end
	end,




	["Nate"] = function(slotData)
		local progress = slotData.QuestProgress["Nate"] or 0
		if progress == 2 then 
			return "NateUndoneQuest"
		elseif progress == 1 then
			return "NateQuest"
		elseif progress == 3 then
			return "NateHasShards"
		else 
			return "Nate"
		end
	end,

	["Rex"] = function(slotData)
		local progress = slotData.QuestProgress["Rex"] or 0
		if progress == 1 then 
			return "RexQuest"
		elseif progress == 2 then
			return "RexIngredients"
		elseif progress == 3 then
			return "RexQuestDone"
		else 
			return "Rex"
		end
	end,

	["Sergi"] = function(slotData)
		local progress = slotData.QuestProgress["Sergi"]
		if not progress then
			return "Sergi"
		elseif progress == 0 then
			return "SergiQuest"
		else
			return "SergiQuestDone"
		end
	end,

	["BeachOrb"] = function(slotData)
		local progress = slotData.UnlockedFastTravels["Beach"] or false
		if progress == true then
			return "Orb"
		else
			return "BeachOrb"
		end
	end,

	["LuneOrb"] = function(slotData)
		local progress = slotData.UnlockedFastTravels["Lune"] or false
		if progress == true then
			return "Orb"
		else
			return "LuneOrb"
		end
	end,

	["VolcanoOrb"] = function(slotData)
		local progress = slotData.UnlockedFastTravels["Volcano"] or false
		if progress == true then
			return "Orb"
		else
			return "VolcanoOrb"
		end
	end,

	["IslandOrb"] = function(slotData)
		local progress = slotData.UnlockedFastTravels["Island"] or false
		if progress == true then
			return "Orb"
		else
			return "IslandOrb"
		end
	end,


	["Denis"] = function(slotData)
		local progress = slotData.QuestProgress["Rex"] or 0
		if progress == 1 then 
			return "DenisQuest"
		else 
			return "Denis"
		end
	end,

	["Anneliese"] = function(slotData)
		local progress = slotData.QuestProgress["Anneliese"] or 0
		if progress == 1 then
			return "AnnelieseBeat"
		end
		return "Anneliese"
	end,

	["FlogesSigil"] = function(slotData)
		local prog = slotData.QuestProgress["Floges"] or 0
		if slotData.SubRace == "Ignited" then return "FlogesSigilRace" 
		elseif prog == 0 then return "FlogesSigil"
		elseif slotData.Subrace ~= "Ignited" and slotData.SubRace ~= "None" then return "FlogesSigilWrongRace" end
			return "FlogesSigilQuest"
	end,
}

return NPCLogic