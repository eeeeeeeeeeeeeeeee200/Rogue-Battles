local rS = game:GetService("ReplicatedStorage")
local attacksData = require(rS.Data.AttacksData)
local effectsSystem = require(rS.Systems.EffectsSystem)

local attacksSystem = {}

attacksSystem.RequirementsFunctions = {
	["Flintlock:Fire"] = function(attacker, defender)
		local attackerBattleData = attacker.InBattleData
		local jammed = effectsSystem.findEffect("FlintlockJammed", attackerBattleData.Effects)
		if jammed then return false end
		local effect, index = effectsSystem.findEffect("LoadedFlintlock", attackerBattleData.Effects, "passive")
		
		if effect and effect.stacks == 1 then
			effect.stacks = 0
			return true
		end
		return false
	end,
	["Flintlock:Ignite"] = function(attacker, defender)
		local attackerBattleData = attacker.InBattleData
		local jammed = effectsSystem.findEffect("FlintlockJammed", attackerBattleData.Effects)
		if jammed then return false end
		local effect, index = effectsSystem.findEffect("LoadedFlintlock", attackerBattleData.Effects)
		if effect and effect.stacks == 2 then
			effect.stacks = 0
			return true
		end
		return false
	end,
	["Lightningcast"] = function(attacker, defender)
		local defenderBattleData = defender.InBattleData
		local effect = effectsSystem.findEffect("Wet", defenderBattleData.Effects, "statChange")
		if effect then return true end
		return false
	end,
}

attacksSystem.DamageFunctions = {
	["Flintlock:Fire"] = function(attacker, defender, attackSpecs)
		local attackerBattleData = attacker.InBattleData
		local attackerData = require(attacker.Instance.InstanceData)
		local defenderBattleData = defender.InBattleData
		local calculatedDamage = (attackSpecs.baseDamage + attackSpecs.scalingAdd) * 3.5 * attackSpecs.weaponMulti * attackerData.DamageMulti
		return calculatedDamage
	end,
	["Flintlock:Ignite"] = function(attacker, defender, attackSpecs)
		local attackerBattleData = attacker.InBattleData
		local attackerData = require(attacker.Instance.InstanceData)
		local defenderBattleData = defender.InBattleData
		local calculatedDamage = (attackSpecs.baseDamage + attackSpecs.scalingAdd) * 5 * attackSpecs.weaponMulti * attackerData.DamageMulti
		return calculatedDamage
	end,
	["NoControl"] = function(attacker, defender, attackSpecs)
		local attackerBattleData = attacker.InBattleData
		local attackerData = require(attacker.Instance.InstanceData)
		local defenderBattleData = defender.InBattleData
		local calculatedDamage = (attackSpecs.baseDamage + attackSpecs.scalingAdd) * attackSpecs.weaponMulti * attackerData.DamageMulti
		calculatedDamage = math.min(calculatedDamage, attackerData.Health/2)
		return calculatedDamage
	end,
    ["magic"] = function(attacker, defender, attackSpecs)
        local attackerData = require(attacker.Instance.InstanceData)
        local damage = (attackSpecs.baseDamage + attackSpecs.scalingAdd + attackSpecs.magicAdd) * attackSpecs.elementalMulti * attackSpecs.weaponMulti * attackerData.DamageMulti
        local energyTotal = attackerData.Energy + attackSpecs.energyCost
        local calculatedDamage = damage * (1 + (energyTotal * 0.06)) -- boost of 6% per energy 
        return calculatedDamage
    end,
}

attacksSystem.EffectsFunctions = {
	["Flintlock:Fire"] = function(attacker, defender)
		local possibleInjuries = {"HeadInjury", "LegInjury", "ArmInjury", "TorsoInjury"}
		local randomInjury = possibleInjuries[math.random(1, #possibleInjuries)]
		return {{name = randomInjury, duration = 1, gave = false}}
	end,
	["Flintlock:Ignite"] = function(attacker, defender)
		local selectedInjuries = {}
		local possibleInjuries = {"HeadInjury", "LegInjury", "ArmInjury", "TorsoInjury"}
		table.insert(selectedInjuries, {name = possibleInjuries[math.random(1, #possibleInjuries)], duration = 2, gave = false})
		table.remove(possibleInjuries, 1)
		table.insert(selectedInjuries, {name = possibleInjuries[math.random(1, #possibleInjuries)], duration = 1, gave = false})
		table.insert(selectedInjuries, {name = possibleInjuries[math.random(1, #possibleInjuries)], duration = 1, gave = false})
		return selectedInjuries
	end,
	["Flintlock:Reload"] = function(attacker, defender)
		local attackerBattleData = attacker.InBattleData
		local effect, index = effectsSystem.findEffect("LoadedFlintlock", attackerBattleData.Effects)
		if effect then
			effect.stacks = math.min(effect.stacks + 1, 2)
			return {}
		end
		return {name = "LoadedFlintlock", stacks = 1, duration = 100}
	end,
}

attacksSystem.DataFunctions = {
	["PiercingShadow"] = function(attacker, defender)
		local defenderBattleData = defender.InBattleData
		
		local darkness = effectsSystem.findEffect("Darkness", defenderBattleData.Effects, "onTurn")
		if not darkness then return {ticks = 1} end
		
		local darknessStacks = darkness.duration
		local calculatedTicks = darknessStacks * 2
		
		task.spawn(function()
			task.wait(1)
			darkness.duration = 0
		end)
		
		return {ticks = calculatedTicks}
	end,
}

return attacksSystem