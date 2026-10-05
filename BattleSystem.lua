-- Services
local rS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Remotes
local rFunctionsFolder = rS:WaitForChild("remoteFunctions")
local minigameHandler = rFunctionsFolder.minigameHandler
local events = rS.Events
local updateUI = events.UpdateUI
local joinBattleEvent = events.JoinBattleEvent
local remoteChanges = events:WaitForChild("WorkspaceChangesRemote")

local enemyModels = rS.EnemyModels
local enemiesData = require(rS.Data.EnemiesData)
local summonsData = require(rS.Data.SummonsData)

local utils = require(rS.Utilities)
local invSystem = require(rS.Systems.InvSystem)
local statsSystem = require(rS.Systems.StatsSystem)
local visualSystem = require(rS.Systems.VisualSystem)
local partySystem = require(rS.Systems.PartySystem)
local aiSystem = require(rS.Systems.AISystem)
local attacksSystem = require(rS.Systems.AttacksSystem)
local effectsSystem = require(rS.Systems.EffectsSystem)
local dataSystem = require(rS.Systems.DataSystem)
local gameData = dataSystem.getAllData()

local animFolder = rS.AttackAnims
local partiesFolder = rS.ActiveParties
local joinPart = rS.Templates.JoinBattlePart

local bossMusicEvent = rS.Events.BossMusicEvent
local call = game.ServerScriptService:WaitForChild("CallBiomeEvent")

local killEnemyCounts = {"Barbarian"}

local bossesNames = {}

for i, v in pairs(game.SoundService.BossMusic:GetChildren()) do
	table.insert(bossesNames, v.Name)
end

local battleSystem = {}

battleSystem.onGoingBattles = {}

local function raycast(model)
	local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if rootPart then

		local rayOrigin = rootPart.Position + Vector3.new(0, 5, 0)
		local rayDirection = Vector3.new(0, -100, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local filters = {model,}
		for i, v in pairs(workspace.Biomes:GetChildren()) do
			table.insert(filters, v)
		end
		raycastParams.FilterDescendantsInstances = filters

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		if raycastResult then
			local _, size = model:GetBoundingBox()
			local halfHeight = size.Y / 2

			local targetPosition = raycastResult.Position + Vector3.new(0, halfHeight, 0)
			model:PivotTo(CFrame.new(targetPosition) * model:GetPivot().Rotation)
		end
	end
end

function battleSystem.playMusicForParticipants(battleSession)
	if not battleSession.musicName then return end
	local participants = battleSession.Participants
	for _, participant in ipairs(participants) do
		local participantData = require(participant.Instance.InstanceData)
		if not participantData then continue end
		if participantData.EntityType == "Player" then
			local player = Players:GetPlayerFromCharacter(participant.Instance)
			bossMusicEvent:FireClient(player, "Play", battleSession.musicName)
		end
	end
end

function battleSystem.createEnemy(enemyName)
	local enemyModel = enemyModels:FindFirstChild(enemyName)
	if not enemyModel then
		warn("Enemy model not found: " .. enemyName)
		return nil
	end

	local enemyModel = enemyModel:Clone()

	enemyModel.Parent = workspace

	local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.BreakJointsOnDeath = true 
	end

	local enemyData = require(enemiesData.EnemiesList[enemyName])
	if not enemyData then
		warn("Enemy data not found: " .. enemyName)
		return nil
	end

	local InstanceData = rS.ProfilesTemplate.EnemyDataTemplate:Clone()
	InstanceData.Name = "InstanceData"
	InstanceData.Parent = enemyModel

	local requiredData = require(InstanceData)
	dataSystem.Reconcile(requiredData, enemyData)

	visualSystem.setupClickDetector(enemyModel)

	return enemyModel
end

function battleSystem.createSummon(summonInfo)
	local summonName = summonInfo.Name
	local summonModel = enemyModels:FindFirstChild(summonName)
	if not summonModel then
		warn("Summon model not found: " .. summonName)
		return nil
	end

	local summonModel = summonModel:Clone()
	summonModel.Parent = workspace

	local humanoid = summonModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.BreakJointsOnDeath = true 
	end

	if not summonsData.SummonsList[summonName] then 
		warn("Summon data not found: " .. summonName) 
		return nil end
	local summonData = require(summonsData.SummonsList[summonName])


	local InstanceData = rS.ProfilesTemplate.SummonDataTemplate:Clone()
	InstanceData.Name = "InstanceData"
	InstanceData.Parent = summonModel

	local requiredData = require(InstanceData)
	dataSystem.Reconcile(requiredData, summonData)

	requiredData.Owner = summonInfo.Owner
	requiredData.Target = summonInfo.Target

	visualSystem.setupClickDetector(summonModel)

	return summonModel
end

function battleSystem.spawnItemDrop(itemName, centerCFrame, participants)
	local templateName = string.lower(string.gsub(itemName, " ", ""))

	local template = rS.Templates:FindFirstChild(templateName)
	if not template then 
		warn("Could not find template for: " .. templateName)
		return 
	end

	local drop = template:Clone()
	-- for no steally items
	for i, person in ipairs(participants) do
		drop:SetAttribute(person.Instance.Name, true)
	end

	local offsetX = math.random(-3, 3)
	local offsetZ = math.random(-3, 3)
	local rotation = CFrame.Angles(0, 0, math.rad(-90))
	local spawnCFrame = (centerCFrame * CFrame.new(offsetX, -2.5, offsetZ)) * rotation

	drop:PivotTo(spawnCFrame)
	drop.Parent = workspace

	local hitbox = Instance.new("Part")
	hitbox.Name = "ClickHitbox"
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.Massless = true

	if drop:IsA("Model") then
		local orientation, size = drop:GetBoundingBox()
		hitbox.Size = size + Vector3.new(0.5,0.5,0.5)
		hitbox.CFrame = orientation
	else
		hitbox.Size = drop.Size + Vector3.new(0.5,0.5,0.5)
		hitbox.CFrame = drop.CFrame
	end

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hitbox
	weld.Part1 = drop:IsA("Model") and (drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")) or drop
	weld.Parent = hitbox
	hitbox.Parent = drop

	local cd = Instance.new("ClickDetector")
	cd.MaxActivationDistance = 10
	cd.Parent = hitbox

	local clicked = false
	cd.MouseClick:Connect(function(clickingPlayer)
		if clicked then return end

		if drop:GetAttribute(clickingPlayer.Name) then

			clicked = true

			local added = invSystem.AddItem(clickingPlayer, itemName, 1)
			if added then
				Debris:AddItem(drop, 0)
			end
		end
	end)

	Debris:AddItem(drop, 120) 
end

function battleSystem.handleNPCRemoval(NPC, participants)
	local NPCInstance = NPC.Instance
	if not NPCInstance then return end
	local NPCData = require(NPCInstance.InstanceData)

	local NPCName = NPCInstance.Name
	local NPCPos = NPCInstance.PrimaryPart.CFrame
	local npcBattle = NPCData.CurrentBattle

	if NPCData.Health > 0 then
		NPCInstance:Destroy()
	else
		visualSystem.destroyNPCModel(NPCInstance, NPCName)

		-- tryna make soils not able to be given to someone who didnt participate
		if not gameData.DropsData.Soulless[NPCName] then
			local soulClone = rS.Templates.Soul:Clone()
			soulClone.CFrame = NPCPos
			for i, person in ipairs(participants) do
				local player = Players:FindFirstChild(person.Instance.Name)
				if not player then continue end

				soulClone:SetAttribute(player.Name, true)
			end
			if not workspace:FindFirstChild("Souls") then local soulsFolder = Instance.new("Folder") soulsFolder.Name = "Souls" soulsFolder.Parent = workspace end
			soulClone.Parent = workspace.Souls
		end

		local drops = gameData.DropsData[NPCName]
		if drops then
			for _, dropData in ipairs(drops) do
				local roll = math.random(1, 100)
				if roll <= dropData.Chance then
					battleSystem.spawnItemDrop(dropData.Item, NPCPos, participants)
				end
			end
		end
	end
end

function battleSystem.getPlayerParty(player)
	local party = partySystem.playerParties[player]
	if party then
		local membersList = {}
		for _, member in ipairs(party.members) do
			table.insert(membersList, member.Character)
		end
		return membersList
	end
	return {player.Character}
end

function battleSystem.getEnemyParty(partyName)
	if partyName == "party1" then
		return "party2"
	else
		return "party1"
	end
end

function battleSystem.setupBattle(startPlayer, battleData)
	print("Starting battle with following info: ", battleData)

	local startParty = battleData.useParty and battleSystem.getPlayerParty(startPlayer) or {startPlayer.Character}
	local battleId = "Battle_" .. startPlayer.UserId

	local otherParty = battleData.otherParty
	if not otherParty or #otherParty == 0 then
		otherParty = {battleSystem.createEnemy("WaterElemental")}
		battleData.otherParty = otherParty
	end
	if not battleData.party2TP then
		local startPartyTp = battleData.party1TP or startPlayer.Character.PrimaryPart.Position

		local root = startPlayer.Character.PrimaryPart

		local CFrameMatrix = CFrame.fromMatrix(
			Vector3.zero,
			root.CFrame.RightVector,
			root.CFrame.UpVector,
			root.CFrame.LookVector
		)
		local finalPos = CFrame.new(startPartyTp) * CFrameMatrix * CFrame.new(0, 0, 15)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {startPlayer.Character}

		local origin = finalPos.Position + Vector3.new(0, 10, 0)
		local raycastResult = workspace:Raycast(origin, Vector3.new(0, -20, 0), raycastParams)
		if raycastResult then
			finalPos = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0)) * CFrameMatrix * CFrame.new(0, 0, 15)
		end

		battleData.party2TP = finalPos.Position
	end

	local battleSession = {
		battleData = battleData,
		Participants = {},
		CurrentTurn = 1,
		party1 = startParty,
		party2 = otherParty,
		parties = {"party1", "party2"},
		InactiveTurns = 0,
		battleId = battleId,
		Indexs = {},
		musicName = nil,
		battleEndFunction = battleData.onBattleEnd,
		startPlayer = startPlayer,
	}
	battleSystem.onGoingBattles[battleId] = battleSession

	local startPartyTp = battleData.party1TP or startParty[1].PrimaryPart.Position
	local otherPartyTp = battleData.party2TP or otherParty[1].PrimaryPart.Position

	local startPartyOffset = -((#startParty - 1) * 5)/2
	local otherPartyOffset = -((#otherParty - 1) * 5)/2

	local startPartyLookAt = CFrame.lookAt(startPartyTp, otherPartyTp).Rotation
	local otherPartyLookAt = CFrame.lookAt(otherPartyTp, startPartyTp).Rotation

	for i, participant in ipairs(startParty) do
		local participantData = require(participant.InstanceData)
		if not participantData or participantData.CurrentBattle then continue end

		local xOffset = startPartyOffset + (i - 1) * 5
		local newCFrame = CFrame.new(startPartyTp) * startPartyLookAt * CFrame.new(xOffset, 0, 0)
		local newPos = newCFrame.Position
		local _, yRotation, zRotation = newCFrame:ToOrientation()
		participant:PivotTo(CFrame.new(newPos) * CFrame.Angles(0, yRotation, zRotation))
		if not battleData.party1TP then
			raycast(participant)
		end

		battleSystem.addParticipant(battleId, participant, "party1")
	end

	for i, participant in ipairs(otherParty) do
		if type(participant) == "string" then
			participant = battleSystem.createEnemy(participant)
		end

		local participantData = require(participant.InstanceData)
		if not participantData or participantData.CurrentBattle then continue end

		local xOffset = otherPartyOffset + (i - 1) * 5
		local newCFrame = CFrame.new(otherPartyTp) * otherPartyLookAt * CFrame.new(xOffset, 0, 0)
		local newPos = newCFrame.Position
		local _, yRotation, zRotation = newCFrame:ToOrientation()
		participant:PivotTo(CFrame.new(newPos) * CFrame.Angles(0, yRotation, zRotation))
		if not battleData.party2TP then
			raycast(participant)
		end
		battleSystem.addParticipant(battleId, participant, "party2")
	end

	if battleData.onBattleStart then battleData.onBattleStart(battleSession) end
	battleSystem.playMusicForParticipants(battleSession)

	return battleSession
end

function battleSystem.endBattle(battleId, reason)
	local battleSession = battleSystem.onGoingBattles[battleId]
	if not battleSession then return end

	if battleSession.battleEndFunction then
		battleSession.battleEndFunction(battleSession, reason)
	end

	for i = #battleSession.Participants, 1, -1 do
		local participant = battleSession.Participants[i]
		battleSystem.removeParticipant(participant)
	end

	battleSystem.onGoingBattles[battleId] = nil
end

function battleSystem.checkBattleStatus(battleId)
	local battleSession = battleSystem.onGoingBattles[battleId]
	if not battleSession then return end

	local winnerParty = nil
	local function didPartyWin(partyName)
		for _, party in ipairs(battleSession.parties) do
			if party == partyName then continue end
			for _, participant in ipairs(battleSession[party]) do
				local participantData = require(participant.InstanceData)
				if participantData and participantData.Health > 0 then
					return false
				end
			end
		end
		return true
	end

	for _, party in ipairs(battleSession.parties) do
		winnerParty = didPartyWin(party) and party or nil
		if winnerParty then break end
	end

	local battleInactive = battleSession.InactiveTurns >= #battleSession.Participants

	if winnerParty or battleInactive then
		local reason = winnerParty and "win" or "inactive"
		battleSystem.endBattle(battleId, reason)
		return false
	end

	return true
end

function battleSystem.addParticipant(battleId, participantInstance, partyName)
	local battleSession = battleSystem.onGoingBattles[battleId]
	if not battleSession then return end

	local participantData = require(participantInstance.InstanceData)
	if not participantData or participantData.CurrentBattle then return end

	local participant = {
		Instance = participantInstance,
		InBattleData = {Effects = {}, IsGuarding = nil, GuardedBy = nil, onCooldown = {}, Turns = 1},
		BasePos = participantInstance.PrimaryPart.CFrame,
		CurrentParty = partyName,
		CurrentBattle = nil,
		EnemyParty = battleSystem.getEnemyParty(partyName),
	}

	table.insert(battleSession.Participants, participant)
	if not table.find(battleSession[partyName], participantInstance) then
		table.insert(battleSession[partyName], participantInstance)
	end
	participantData.CurrentBattle = battleId
	if battleSession.battleData.combatState ~= nil then
		participantData.InCombat = battleSession.battleData.combatState
	else
		participantData.InCombat = true
	end

	--gises code
	local part = joinPart:Clone()
	part.CFrame = participantInstance.PrimaryPart.CFrame
	if not workspace:FindFirstChild("JoinPartFolder") then
		local folder = Instance.new("Folder")
		folder.Name = "JoinPartFolder"
		folder.Parent = workspace
	end
	part.Parent = workspace.JoinPartFolder
	participant.JoinPart = part

	part.Touched:Connect(function(hitpart)
		if hitpart.Parent:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(hitpart.Parent)
			if player then
				if not player:IsA("Player") then return end

				local playerData = dataSystem.getData(player)
				if playerData and not playerData.Slots[playerData.LastSlot].CurrentBattle then
					local playerThatStartedTheBattle = battleSession.startPlayer
					joinBattleEvent:FireClient(player, battleId, partyName, "OpenGui", part, playerThatStartedTheBattle)
				end
			end
		end
	end)
	--gises code end

	participantInstance.PrimaryPart.Anchored = true
	if participantData.EntityType == "Player" then
		local player = Players:GetPlayerFromCharacter(participantInstance)
		local playerData = dataSystem.getData(player)
		updateUI:FireClient(player, "Init", playerData)
	end

	battleSystem.triggerPassivesOfType(participant, "onBattleStart")
	if table.find(bossesNames, participantInstance.Name) then
		battleSession["musicName"] = participantInstance.Name
		battleSystem.playMusicForParticipants(battleSession)
	end

	visualSystem.clearAllAnimations(participantInstance.Humanoid:FindFirstChildOfClass("Animator"))
end

function battleSystem.removeParticipant(participant)
	local participantInstance = participant.Instance
	local participantData = require(participantInstance.InstanceData)
	local participantBattleData = participant.InBattleData

	local currentBattleId = participantData.CurrentBattle
	if not currentBattleId then return end

	if participant.JoinPart then
		participant.JoinPart:Destroy()
	end

	local currentBattle = battleSystem.onGoingBattles[currentBattleId]

	local battleParticipants = currentBattle.Participants

	if not currentBattle then return end

	for _, effect in ipairs(participantBattleData.Effects) do
		local effectData = gameData.EffectsData[effect.name]
		if effectData and effectData.effectFunction then
			effect.duration = 0
			effectData.effectFunction(participant, effect)
		end
	end
	visualSystem.clearAllEffects(participant.Instance)
	local participantParty = currentBattle[participant.CurrentParty]

	participantData.CurrentBattle = nil 
	participantData.InCombat = false

	participantData.Energy = 0

	table.remove(participantParty, table.find(participantParty, participantInstance))
	table.remove(currentBattle.Participants, table.find(currentBattle.Participants, participant))

	visualSystem.clearAllAnimations(participantInstance.Humanoid.Animator)
	participantInstance.PrimaryPart.Anchored = false

	battleSystem.triggerPassivesOfType(participant, "onBattleEnd")

	if participantData.EntityType ~= "Player" then
		battleSystem.handleNPCRemoval(participant, battleParticipants)
	else
		local player = Players:GetPlayerFromCharacter(participantInstance)
		if not player then return end

		updateUI:FireClient(player, "Init", dataSystem.getData(player))
		updateUI:FireClient(player, "UpdateEffects", nil)
		bossMusicEvent:FireClient(player, "Stop") 
		call:Fire(player)
	end
end

function battleSystem.getParticipantFromInstance(inst)
	if not inst or not inst.InstanceData then return end
	local instData = require(inst.InstanceData)
	if not instData or not instData.CurrentBattle then return end

	local currentBattle = battleSystem.onGoingBattles[instData.CurrentBattle]
	if not currentBattle then return end

	for _, participant in ipairs(currentBattle.Participants) do
		if participant.Instance == inst then
			return participant
		end
	end

	return nil
end

function battleSystem.triggerPassivesOfType(currentInstance, passiveType, ...)
	local instanceModel = currentInstance.Instance
	local instanceData = require(instanceModel.InstanceData)

	local newData = {}
	for _, passive in ipairs(instanceData.CombatPassives) do
		local passiveName = string.gsub(passive, " ", "")
		local passiveData = gameData.PassivesData[passiveName]
		if not passiveData then passiveData = gameData.PassivesData["Default"] end
		if passiveData.type == passiveType and passiveData.passiveFunction then
			local results = passiveData.passiveFunction(currentInstance, ...)
			if results then
				for _, result in ipairs(results) do
					table.insert(newData, result) 
				end
			end
		end
	end

	return newData
end

function battleSystem.triggerEffectsOfType(currentInstance, effectType, ...)
	local instanceModel = currentInstance.Instance
	local instanceBattleData = currentInstance.InBattleData

	local effectsList = instanceBattleData.Effects[effectType] or {}

	local newData = {}
	for _, effect in ipairs(effectsList) do
		local effectName = string.gsub(effect.name, " ", "")
		local effectData = gameData.EffectsData[effectName]

		if effectData.effectFunction then
			local results = effectData.effectFunction(currentInstance, effect, ...)
			if results then
				for _, result in ipairs(results) do
					table.insert(newData, result) 
				end
			end
		end
	end

	return newData
end

function battleSystem.triggerPaEfOfType(currentInstance, currentType, ...)
	local newData = {}

	newData = battleSystem.triggerEffectsOfType(currentInstance, currentType, ...)
	for _, result in ipairs(battleSystem.triggerPassivesOfType(currentInstance, currentType, ...)) do
		table.insert(newData, result)
	end

	return newData
end

function battleSystem.calculateDamage(attacker, defender, attackName)
	if not defender or not attacker then return 0 end

	local attackerInstance = attacker.Instance
	local attackerData = require(attackerInstance.InstanceData)

	local defenderInstance = defender.Instance
	local defenderData = require(defenderInstance.InstanceData)

	local attackData = gameData.AttacksData.Attacks[attackName]
	if not attackData then return 0 end

	local baseDamage = attackData["baseDamage"] or 0
	if attackData["weapon"] ~= "none" then
		local attackerWeapons = attackerData.Weapons
		local attackerWeapon = gameData.WeaponData:GetWeaponOfType(attackerWeapons, attackData["weapon"])

		if attackerWeapon then baseDamage += gameData.WeaponData:PullBaseDamage(attackerWeapon) end
	end

	local scaling = attackData["scaling"] or 1
	local pierce = attackData["pierce"] or 0
	local magicScaling = attackData["magicScaling"] or 0

	local element = attackData["element"] or nil
	local elementalMulti = element and attackerData.ElementalMulti[element] or 1

	local weapon = attackData["weapon"] or nil
	local weaponMulti = (weapon and attackerData.WeaponMultis[weapon] or 0) + attackerData.GlobalWeaponMulti

	local scalingAdd = attackerData.Damage * scaling
	local magicAdd = attackerData.MagicPower * magicScaling

	local damage = 0

	local handlerFunction = attacksSystem.DamageFunctions[attackName]
	if handlerFunction then
		local attackSpecs = {
			baseDamage = baseDamage,
			scaling = scaling,
			pierce = pierce,
			magicScaling = magicScaling,
			elementalMulti = elementalMulti,
			weaponMulti = weaponMulti,
			scalingAdd = scalingAdd,
			magicAdd = magicAdd,
		}
		damage = handlerFunction(attacker, defender, attackSpecs)
	else
		damage = (baseDamage + scalingAdd + magicAdd) * elementalMulti * weaponMulti * attackerData.DamageMulti
	end

	if damage >= 0 then
		local defenceReduction = math.max(0, defenderData.Defence - pierce)
		damage = math.max(0, damage - defenceReduction) * defenderData.DamageRes
	end
	local elementalRes = element and defenderData.ElementalRes[element] or 1
	damage = damage * elementalRes * elementalMulti

	return math.floor(damage)
end

function battleSystem.damageInstance(defender, damage, attackerInstance)
	if not defender or defender.CurrentBattle then return end
	
	local finalDefender = defender
	-- since this doesnt have attackData and only damage this seems to not be possible without some refactoring, should be fine..
	-- local selfAttack = attackData.targetNumber == 0 or attacker == defender
	if defender.GuardedBy ~= nil then -- and not selfAttack then
		finalDefender = defender.GuardedBy
	end

	local defenderInstance = finalDefender.Instance
	local defenderInstanceData = defenderInstance:FindFirstChild("InstanceData")
	local defenderBattleData = finalDefender.InBattleData
	local attackerData = attackerInstance and require(attackerInstance.InstanceData) or nil
	if not defenderInstanceData then return end

	local defenderData = require(defenderInstance.InstanceData)
	if defenderData.Health <= 0 then return end

    local shadowDodge = defenderData.ShadowDodge or 0
    local shadowDodgeRng = shadowDodge * 10 -- leaving lowering the ammount the more you have for later i hate math
    if math.random(1,100) >= shadowDodgeRng and damage > 1 then
        damage = 0
        visualSystem.showDamageText(defenderInstance.PrimaryPart, damage)
        visualSystem.shadowDodgeAnim(defenderInstance)
    else
	defenderData.Health = math.clamp(defenderData.Health - damage, 0, defenderData.MaxHealth)
    end
	battleSystem.triggerPaEfOfType(finalDefender, "onDeath") -- passives themselves check if you have 0 hp before trying anything, so we can run this anyways i think


	if defenderData.EntityType ~= "Player" then
		local defenderName = defenderInstance.Name
		local handlerFunction = aiSystem[defenderName .. "Health"]
		if handlerFunction then
			handlerFunction(battleSystem.onGoingBattles[defenderData.CurrentBattle], finalDefender, damage)
		end
		if defenderData.Health <= 0 then
			if not attackerData.QuestProgress then return end
			for i, v in pairs(killEnemyCounts) do
				local questProgress = attackerData.QuestProgress[v]
				if questProgress then
					attackerData.QuestProgress[v] += 1
				end
			end
		end
	end
end

function battleSystem.minigame(attacker, attackName)
	local attackerData = require(attacker.Instance.InstanceData)
	local unspacedName = string.gsub(attackName, " ", "")
	local AisPlayer = attackerData.EntityType == "Player" and Players:GetPlayerFromCharacter(attacker.Instance)
	local attackData = gameData.AttacksData:PullAttackData(unspacedName)
	local attackWeapon = attackData.weapon

	if not attackData.minigameDifficulty or not attackWeapon or not AisPlayer then return "Win" end
	if AisPlayer then
		local minigameState = "Win"
		local minigameDiff = attackData.minigameDifficulty
		if minigameDiff >= 0 then 
			minigameState = minigameHandler:InvokeClient(AisPlayer, attackWeapon, minigameDiff) 
			return minigameState
		end
	end
end

function battleSystem.checkEnergyCost(attacker, attackName)
	if not attackName then return true end
	local unspacedName = string.gsub(attackName, " ", "")
	local attackData = gameData.AttacksData:PullAttackData(unspacedName)
	local attackerData = require(attacker.Instance.InstanceData)
	local energyCost = attackData.energyCost
	if not energyCost then return true end

	if attackerData.Energy < energyCost then return false end
	attackerData.Energy -= energyCost
	return true
end

function battleSystem.AttackAction(attacker, defender, attackNameSpaced)
	if not defender or not attacker then return end
	local attackName = string.gsub(attackNameSpaced, " ", "")

	local attackerInstance = attacker.Instance
	local attackerBattleData = attacker.InBattleData
	local attackerData = require(attackerInstance.InstanceData)
	local AisPlayer = attackerData.EntityType == "Player" and Players:GetPlayerFromCharacter(attackerInstance)
	local attackerAnimator = attackerInstance.Humanoid.Animator

	if attackerBattleData.onCooldown[attackName] then return end
	local attackData = gameData.AttacksData:PullAttackData(attackName)

	local requirementFunction = attacksSystem.RequirementsFunctions[attackName]
	if requirementFunction and not requirementFunction(attacker, defender) then return end

	local selfAttack = attackData.targetNumber == 0 or attacker == defender

	local attackCooldown = attackData.cooldown
	if attackCooldown then
		attackerBattleData.onCooldown[attackName] = attackCooldown
	end

	local attackWeapon = attackData.weapon
	if attackWeapon ~= "none" and attackWeapon ~= "melee" and attackWeapon ~= "magic" then
		local attackerWeapon = gameData.WeaponData:GetWeaponOfType(attackerData.Weapons, attackWeapon)
		if attackerWeapon then
			visualSystem.putWeaponInHand(attackerInstance, attackerWeapon)
		end
	end

	for _, behaviourData in ipairs(attackData.specialBehaviour) do
		local handlerFunction = battleSystem.AttackBehaviours[behaviourData.type]
		if handlerFunction then
			handlerFunction(attacker, defender, behaviourData)
		end
	end

	local finalDefender = defender
	if defender.GuardedBy ~= nil and not selfAttack then
		finalDefender = defender.GuardedBy
	end

	local defenderInstance = finalDefender.Instance
	local defenderData = require(defenderInstance.InstanceData)
	local defenderBattleData = finalDefender.InBattleData
	local DisPlayer = defenderData.EntityType == "Player" and Players:GetPlayerFromCharacter(defenderInstance)
	local defenderAnimator = defenderInstance.Humanoid.Animator

	local dodgeState = "DodgeFail"
	if attackData.dodgeable or attackData.blockable then
		if DisPlayer then
			local speedDiff = defenderData.Speed - attackerData.Speed
			speedDiff = math.clamp(speedDiff, -20, 20)

			dodgeState = minigameHandler:InvokeClient(DisPlayer, "Dodge", speedDiff)
		else
			local dodgeChance = math.clamp(defenderData.Speed - attackerData.Speed, -10, 10) * 2 + 20
			local dodgeRoll = math.random(1, 100)

			if dodgeRoll <= dodgeChance then
				dodgeState = "Block"
				if dodgeRoll//2 <= dodgeChance then
					dodgeState = "Dodge"
				end
			end
		end
		if dodgeState == "Dodge" and not attackData.dodgeable then
			dodgeState = "Block"
		end
	end

	local defenderAnimName = "TakeDamage"
	local damage = battleSystem.calculateDamage(attacker, finalDefender, attackName)
	if dodgeState == "Block" then
		damage = math.floor(damage * 0.5)
		defenderAnimName = "Block"
	elseif dodgeState == "Dodge" then
		damage = nil
		defenderAnimName = "Dodge1"
	end

	local attackDataFunction = attacksSystem.DataFunctions[attackName]
	if attackDataFunction then
		local attackData = utils.CopyTable(attackData)
		utils.Reconcile(attackData, attackDataFunction(attacker, defender))
	end

	local initialCFrame = attackerInstance.PrimaryPart.CFrame
	if defenderInstance and not selfAttack then
		if attackData.tp then
			local tpPos = visualSystem.getPosInFrontOfModel(attackerInstance, defenderInstance)
			local tpCFrame = CFrame.lookAt(tpPos, defenderInstance.PrimaryPart.Position)
			visualSystem.tpEntity(attackerInstance, tpCFrame)
		else
			visualSystem.rotateEntity(attackerInstance, defenderInstance)
		end
	end

	local attackerAnimInst = animFolder:FindFirstChild(attackName)
	if not attackerAnimInst then
		attackerAnimInst = selfAttack and animFolder.SelfAttack or animFolder.Default
	end

	local defenderAnim = defenderAnimator:LoadAnimation(animFolder[defenderAnimName])
	local attackerAnim: AnimationTrack = attackerAnimator:LoadAnimation(attackerAnimInst)

	local VFXFunction = visualSystem.AttacksVFX[attackName]
	if VFXFunction then
		task.spawn(function() VFXFunction(attacker, finalDefender) end)
	end

	visualSystem.clearAnimations(attackerAnimator)
	attackerAnim:Play()

	for i = 1, attackData.ticks do
		if not attackerData.CurrentBattle or not defenderData.CurrentBattle then
			print("Attempt to perform an attacking action to an entity that is not in the battle.")
			break 
		end
		if (attackerAnimInst.Name ~= "Default" and attackerAnimInst.Name ~= "SelfAttack") or i == 1 then
			attackerAnim:GetMarkerReachedSignal("Fire"):Wait(5)
			if not selfAttack then
				visualSystem.clearAnimations(defenderAnimator)
				defenderAnim:Play()
			end
		else
			if not selfAttack then
				visualSystem.clearAnimations(defenderAnimator)
				defenderAnim:Play()
			end
		end

		if damage and defenderInstance.Parent == workspace and defenderData.Health > 0 then
			battleSystem.damageInstance(finalDefender, damage, attackerInstance)
		end

		if dodgeState ~= "Dodge" and defenderInstance.Parent == workspace and defenderData.Health > 0 then
			local effectFunction = attacksSystem.EffectsFunctions[attackName]
			local attackEffects = effectFunction and effectFunction(attacker, finalDefender) or attackData.effects

			for _, effect in ipairs(attackEffects) do
				effectsSystem.addEffect(effect, defenderBattleData)

				visualSystem.applyEffectVFX(defenderInstance, effect)
				if DisPlayer then
					updateUI:FireClient(DisPlayer, "UpdateEffects", defenderBattleData.Effects)
				end
			end
		end

		if defenderData.EntityType ~= "Player" and defenderData.Health <= 0 and defenderData.CurrentBattle then
			battleSystem.removeParticipant(finalDefender)
		end
	end

	if attackerAnim.IsPlaying then 
		task.wait(0.2)
		attackerAnim:Stop()
	end

	local attackElement = attackData.element
	if attackElement then
		battleSystem.triggerPaEfOfType(attacker, "on" .. attackElement .. "Attack")
		battleSystem.triggerPaEfOfType(finalDefender, "on" .. attackElement .. "Damage")
	end
	if dodgeState ~= "Dodge" then
		battleSystem.triggerPaEfOfType(finalDefender, "onDamaged", damage)
		battleSystem.triggerPaEfOfType(attacker, "onDamage", finalDefender, damage) 
	end
	battleSystem.triggerPaEfOfType(finalDefender, "on" .. dodgeState)

	task.wait(0.5)

	if not selfAttack then visualSystem.tpEntity(attackerInstance, initialCFrame) end
	visualSystem.withdrawWeapons(attackerInstance)
end

function battleSystem.ChargeAction(user)
	local userInstance = user.Instance
	local userData = require(userInstance.InstanceData)

	local userAnimator = userInstance.Humanoid.Animator

	visualSystem.clearAnimations(userAnimator)

	local playingAnim = userAnimator:LoadAnimation(animFolder.Charge)
	playingAnim:Play()

	playingAnim:GetMarkerReachedSignal("Fire"):Wait()
	userData.Energy = math.min(userData.Energy + 1, userData.MaxEnergy)

	if userData.EntityType == "Player" then
		local player = Players:GetPlayerFromCharacter(userInstance)
		statsSystem.UpdateStats(player)
	end

	playingAnim.Ended:Wait()
end

function battleSystem.GuardAction(user, target)
	local userInstance = user.Instance
	local userData = require(userInstance.InstanceData)
	local userBattleData = user.InBattleData
	local userAnimator = userInstance.Humanoid.Animator

	local targetInstance = target.Instance
	local targetData = require(targetInstance.InstanceData)
	local targetBattleData = target.InBattleData

	if targetBattleData.GuardedBy ~= nil then return end

	targetBattleData.GuardedBy = user
	userBattleData.IsGuarding = target

	userData.Defence += 5
	if user ~= target then
		local tpPos = visualSystem.getPosInFrontOfModel(userInstance, targetInstance)
		local tpCFrame = CFrame.lookAt(tpPos, targetInstance.PrimaryPart.Position) * CFrame.Angles(0, math.rad(180), 0)
		visualSystem.tpEntity(userInstance, tpCFrame)
	end

	visualSystem.clearAnimations(userAnimator)
	local playingAnim = userAnimator:LoadAnimation(animFolder.Guard)
	playingAnim:Play()

	battleSystem.triggerPaEfOfType(target, "onGuarded")
end

function battleSystem.EscapeAction(user)
	local userInstance = user.Instance
	local userData = require(userInstance.InstanceData)

	local battleSession = battleSystem.onGoingBattles[userData.CurrentBattle]
	if not battleSession then return end

	local escapeState = "Loss"
	for _, participant in ipairs(battleSession.Participants) do
		if participant == user then continue end

		local participantData = require(participant.Instance.InstanceData)
		local speedDiff = math.clamp(userData.Speed - participantData.Speed, -10, 10)

		local escapeChance = 50 - (speedDiff * 5)
		if math.random(1, 100) >= escapeChance then
			escapeState = "Success"
			break
		end
	end
	if escapeState ~= "Success" then return end

	battleSystem.removeParticipant(user)
end

function battleSystem.ItemAction(user, target, item)
	local userInstance = user.Instance
	local userData = require(userInstance.InstanceData)
	local uIsAPlayer = userData.EntityType == "Player" and Players:GetPlayerFromCharacter(userInstance)

	local targetInstance = target.Instance

	local itemName = string.lower(string.gsub(item, " ", ""))
	local handlerFunction = gameData.ItemsData[itemName]
	if handlerFunction then
		local success = handlerFunction(targetInstance)
		if success and uIsAPlayer then
			invSystem.RemoveItem(uIsAPlayer, item, 1)
		end
	end
end

battleSystem.AttackBehaviours = {
	["Summon"] = function(user, target, summonData)
		local summonName = summonData.entity

		local userInstance = user.Instance
		local userData = require(userInstance.InstanceData)

		local summonInfo = {Name = summonName, Owner = user, Target = target}
		local summonModel = battleSystem.createSummon(summonInfo)

		summonModel:PivotTo(userInstance.PrimaryPart.CFrame * CFrame.new(2, 0, 5))
		battleSystem.addParticipant(userData.CurrentBattle, summonModel, user.CurrentParty)
	end,

	["SelfEffect"] = function(user, target, effectData)
		local instanceBattleData = user.InBattleData
		effectsSystem.addEffect(effectData, instanceBattleData)

		local userInstance = user.Instance
		local userData = require(userInstance.InstanceData)
		local uPlayer = userData.EntityType == "Player" and Players:GetPlayerFromCharacter(userInstance)
		if uPlayer then
			local effectsList = user.InBattleData.Effects
			updateUI:FireClient(uPlayer, "UpdateEffects", effectsList)
		end
	end,

	["ExtraTurn"] = function(user, target, extraTurnData)
		local userInstance = user.Instance
		local userData = require(userInstance.InstanceData)

		local battleSession = battleSystem.onGoingBattles[userData.CurrentBattle]
		battleSession.CurrentTurn -= 1
		if battleSession.CurrentTurn < 1 then
			battleSession.CurrentTurn = #battleSession.Participants
		end
	end,

	["BonusTurn"] = function(user, target, bonusTurnData)
		local userInstance = user.Instance
		local userBattleData = user.InBattleData

		userBattleData.Turns = bonusTurnData.amount or 1
	end,

	["StanceChange"] = function(user, target, stanceData)
		local userInstance = user.Instance
		local userData = require(userInstance.InstanceData)
		local userBattleData = user.InBattleData
		local userEffects = userBattleData.Effects
		local stance = userBattleData.Stance

		if not stance then stance = 1 end
		if stanceData.name == "Barbarian" then
			stance = (stance - 2)^2 + 1
			userBattleData.Stance = stance
			local index = nil
			local name = nil
			for i, v in pairs(userEffects) do
				if v.name == "SoulModeHealth" or v.name == "SoulModeDamage" then
					index = i
					name = v.name
					break
				end
			end

			if not index or not name then return end

			table.remove(userEffects, index)
			if name == "SoulModeHealth" then 
				local regen = nil
				for i, v in pairs(userEffects) do
					if v.name == "SoulModeDamageRegen" then
						regen = i
						break
					end
				end
				table.remove(userEffects, regen)
			end

			local oppositeName = (name == "SoulModeHealth") and "SoulModeDamage" or "SoulModeHealth"

			table.insert(userEffects, {
				name = oppositeName,
				duration = 100
			})
			-- uhmmm
			if name == "SoulModeDamage" then
				userData.Damage -= 4
				userData.WeaponMultis.sword -= 0.2
				table.insert(userEffects, {
					name = "SoulModeHealthRegen",
					duration = 100
				})
			end

			-- ok seems to work unless you end battle because then it lets you keep the weapon multis
		end
	end,

	-- in attack data, time is seconds until undo the camera, cameraPos is the offset from the characters rootpart
	["Cutscene"] = function(user, target, Data)
		local character = user.Instance
		local userData = require(character.InstanceData)
		local userBattleData = user.InBattleData
		local battleSession = battleSystem.onGoingBattles[userData.CurrentBattle]
		local battleParticipants = battleSession.Participants

		local root = character.HumanoidRootPart
		local cameraPart = Instance.new("Part")
		cameraPart.Anchored = true
		cameraPart.CanCollide = false
		local lookAt = CFrame.lookAt(root.Position + Data.cameraPos, character.HumanoidRootPart.Position )
		cameraPart:PivotTo(lookAt)
		cameraPart.Parent = workspace

		for i, v in pairs(battleParticipants) do
			local player = game.Players:GetPlayerFromCharacter(v.Instance)
			if not player then continue end
			remoteChanges:FireClient(player, "BattleCutscene", cameraPart, Data.time)
		end
		task.spawn(function()
			task.wait(Data.time)
			cameraPart:Destroy()
		end)
		-- seems to work
	end,
}

return battleSystem