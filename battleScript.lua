-- Services
local rS = game:GetService("ReplicatedStorage")
local sS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris") 
local TweenService = game:GetService("TweenService")

-- Systems
local systemsFolder = rS.Systems
local dataSystem = require(systemsFolder.DataSystem)
local battleSystem = require(systemsFolder.BattleSystem)
local aiSystem = require(systemsFolder.AISystem)
local statsSystem = require(systemsFolder.StatsSystem)
local visualSystem = require(systemsFolder.VisualSystem)
local effectsSystem = require(systemsFolder.EffectsSystem)

local gameData = dataSystem.getAllData()

-- Remote Functions
local rFunctionsFolder = rS.remoteFunctions
local animHandler = rFunctionsFolder.animationHandler
local minigameHandler = rFunctionsFolder.minigameHandler

-- Remote Events
local EventsFolder = rS.Events
local startBattleEvent = EventsFolder.startBattleServer
local battleActionEvent = EventsFolder.BattleActionEvent
local UpdateUI = EventsFolder.UpdateUI
local bossMusicEvent = rS.Events.BossMusicEvent

local function runBattle(startPlayer, battleData)
	local currentBattle = battleSystem.setupBattle(startPlayer, battleData)
	
	local onGoing = true
	while onGoing do
		local currentActor = currentBattle.Participants[currentBattle.CurrentTurn]
		if not currentActor then break end
		
		local currentActorInstance = currentActor.Instance
		local currentActorData = require(currentActorInstance.InstanceData)
		local currentActorBattleData = currentActor.InBattleData
		
		local cIsAPlayer
		
		local turnOnGoing = true
		local softLockPrevention = task.spawn(function()
			task.wait(60)
			if turnOnGoing then
				turnOnGoing = false
				currentBattle.CurrentTurn = currentBattle.CurrentTurn % #currentBattle.Participants + 1
				task.wait(0.1)
				
				currentBattle.InactiveTurns += 1
				onGoing = battleSystem.checkBattleStatus(currentBattle.battleId)
			end
		end)
		
		if currentActorBattleData.IsGuarding then
			local guardedActor = currentActorBattleData.IsGuarding
			currentActorBattleData.IsGuarding = nil
			
			currentActorData.Defence -= 5
			battleSystem.triggerPaEfOfType(currentActor, "onGuard")
			
			if guardedActor then
				local guardedActorBattleData = guardedActor.InBattleData
				guardedActorBattleData.GuardedBy = nil
				battleSystem.triggerPaEfOfType(guardedActor, "onGuarded")
			end
			
			local currentAnimator = currentActorInstance.Humanoid.Animator
			visualSystem.clearAllAnimations(currentAnimator)
			
			currentActorInstance:PivotTo(currentActor.BasePos)
		end
		
		for attackName, cooldown in pairs(currentActorBattleData.onCooldown) do
			currentActorBattleData.onCooldown[attackName] = cooldown - 1
			if currentActorBattleData.onCooldown[attackName] <= 0 then
				currentActorBattleData.onCooldown[attackName] = nil
			end
		end
		
		-- Trigger onTurn Passives and onTurn/statChange Effects
		battleSystem.triggerPaEfOfType(currentActor, "onTurn")
		for effectType, effectsList in pairs(currentActorBattleData.Effects) do
			for i, effect in ipairs(effectsList) do
				effect.duration -= 1
				
				if effectType == "statChange" then
					local effectData = gameData.EffectsData[effect.name]
					if effect.gave or effect.duration <= 0 then
						effectData.effectFunction(currentActor, effect)
						if effect.duration > 0 then effect.gave = true end
					end
				end
				
				if effect.duration <= 0 then
					visualSystem.removeEffectVFX(currentActorInstance, effect.name)
					effectsSystem.removeEffect(effect.name, currentActorBattleData, effectType)
				end
				
				battleSystem.triggerPaEfOfType(currentActor, "onStatChange", effect)
			end
		end
		local isStunned = currentActorBattleData.Effects["Stun"] and #currentActorBattleData.Effects["Stun"] > 0
		
		-- Get CurrentActor Action
		local turnCounter = 0
		while turnCounter < currentActorBattleData.Turns do
			turnCounter += 1
			
			local action
			local targets = {}
			local info
			
			if currentActorData.EntityType == "Player" and not isStunned then	
				local actorPlayer = Players:GetPlayerFromCharacter(currentActorInstance)
				
				statsSystem.UpdateStats(actorPlayer)
				
				cIsAPlayer = actorPlayer
				
				local connection = battleActionEvent.OnServerEvent:Connect(function(sender, actionR, targetR, infoR)
					if sender == actorPlayer then
						action = actionR
						targets = targetR or {}
						info = infoR
					end
				end)
				
				if actorPlayer then
				UpdateUI:FireClient(actorPlayer, "StartTurn", 10)
				end
				
				for i = 40, 1, -1 do
					if action then break end
					task.wait(0.25)
				end
				local hasEnergy = battleSystem.checkEnergyCost(currentActor, info)
				if not hasEnergy or (action == "Attack" and not info) then
				action = "Charge"
				end
				connection:Disconnect()
				UpdateUI:FireClient(actorPlayer, "EndTurn")
			elseif not isStunned then
				local sanitizedName = currentActorInstance.Name:gsub(" ", "")
				local aiFunction = aiSystem[sanitizedName]
				if aiFunction then
					local TurnInfo = aiFunction(currentBattle, currentActor)
					action = TurnInfo.action
					targets = TurnInfo.targets or {}
					info = TurnInfo.info
				end
				
				if not action then
					action = "Attack"
					info = aiSystem.chooseAttack(currentBattle, currentActor)
					info = string.gsub(info, " ", "")
				end
				
				local attackData = gameData.AttacksData:PullAttackData(info)
				if attackData then
				if (action == "Attack" and info) and (attackData.energyCost <= currentActorData.Energy) then
					currentActorData.Energy -= attackData.energyCost
					local targetNumber = attackData.targetNumber
					if targetNumber == 0 then
						targets = {currentActor.Instance}
					else
                        if type(targets) ~= "Table" then targets = {targets} end
						local targetsToGet = targetNumber - #targets
						for i = 1, targetsToGet do
							local newTarget = aiSystem.getTarget(currentBattle, currentActor)
							
							if not newTarget or table.find(targets,newTarget) then continue end
							table.insert(targets, newTarget)
						end
					end
				elseif attackData.energyCost > currentActorData.Energy or (action == "Attack" and not info) then
					action = "Charge"
				end
			end
		end
			
			-- Execute Action
			if not action then action = "Wait" end
			local actionFunctionName = action .. "Action"
			local actionFunction = battleSystem[actionFunctionName]
			if typeof(targets) == "Instance" then
				targets = {targets}
			end
			if actionFunction then
				if #targets > 0 then
					local newTargets = battleSystem.triggerPaEfOfType(currentActor, "onTargetting", targets)
					
					if #newTargets > 0 then
						for i, target in ipairs(newTargets) do
							if #targets < i then break end
							targets[i] = target
						end
					end
					
				
					local minigameState = "Win"
					
					if action == "Attack" then
					minigameState = battleSystem.minigame(currentActor, info)
					end
					
					if minigameState == "Loss" then
						actionFunction(currentActor, nil, info)
					elseif minigameState == "Win" and action ~= "Charge" then
						for _, target in ipairs(targets) do
							local targetParticipant = battleSystem.getParticipantFromInstance(target)
							if not targetParticipant then continue end			
							actionFunction(currentActor, targetParticipant, info)
						end
					elseif action == "Charge" then
						actionFunction(currentActor)
					end
				else
					actionFunction(currentActor, nil, info)
				end
			end
			battleSystem.triggerPaEfOfType(currentActor, "on" .. action)
			
			if action == "Wait" or action == "Escape" then
				currentBattle.InactiveTurns += 1
			else
				currentBattle.InactiveTurns = 0
			end
		end
		currentActorBattleData.Turns = 1
		
		-- Trigger onTurnEnd Passives and Effects
		battleSystem.triggerPaEfOfType(currentActor, "onTurnEnd")
		for i, effect in ipairs(currentActorBattleData.Effects) do
			local effectData = gameData.EffectsData[effect.name]
			if effectData.type == "statChange" and not effect.gave then
				effectData.effectFunction(currentActor, effect)
				effect.gave = true
			end
		end
		
		-- Update Stats
		if cIsAPlayer then statsSystem.UpdateStats(cIsAPlayer) end
		currentBattle.CurrentTurn = currentBattle.CurrentTurn % #currentBattle.Participants + 1
		task.wait(0.1)
		
		turnOnGoing = false
		task.cancel(softLockPrevention)
		onGoing = battleSystem.checkBattleStatus(currentBattle.battleId)
	end
end

startBattleEvent.Event:Connect(runBattle)