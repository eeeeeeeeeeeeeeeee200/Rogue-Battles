local rS = game:GetService("ReplicatedStorage")
local damageEvent = rS.Events.DamageEvent
local effectBindable = rS.bindableFunctions.effectFunction
local updateUi = rS.Events.UpdateUI
local players = game:GetService("Players")

--[[
Passive triggers and inputs

onTurn (chr), triggers at the start of a turn, maybe change to onTurnStart since onTurnEnd exists
onTurnEnd (chr), triggers at the end of a turn after the character acts
onGuard (chr), triggers on guard and at the start of the turn if the chr was guarding the previous turn, maybe add an input for guarded
onGuarded (chr), triggers on being guarded and at the start of the turn of the character guarding this character, maybe an an input for guarder or whatever sounds better than that
onBattleStart (chr), triggers at the start of a battle (and persumably upon joining one...), could maybe include participants in the fight
onBattleEnd triggers when battle ends, what else?
onDeath triggers on death 
on[state] (chr), triggers upon being attacked... could probably do with having an input for the attacker and the damage
onDamaged (chr), triggers upon taking damage, could really do with having an input for the attacker and damage taken
onDamage (chr), triggers upon dealing damage, 
onStatChange (chr, effect?), triggers at the start of a turn for each effect on the character, triggers irregardless of if the status itself is StatChange
on[Action] (chr), triggers upon the character using [Action], this is,, interesting and ill have to read more to grasp it, maybe add some additional inputs, maybe.
on[Element][Attack/Damage] (chr), triggers upon the character either attacking with an element or taking damage from an element, regardless of dodge state (so maybe add that), could do with an input for the other chr maybe

]]


local passivesData = {}

-- Combat Passives
passivesData.Default = {type = "passive"}

-- hi make absolutely sure you dont reset the revives table and dont forget to check if they actually have 0 hp
-- also i totally thought the code instantly killed you if you had 0 health but apparently the code lets you do this in time before doing it
passivesData.MaxRevive = {type = "onDeath", passiveFunction = function(bearer)
	local bearerData = require(bearer.Instance.InstanceData)
	local battleData = bearer.InBattleData
	if bearerData.Health > 0 then return end
	if not battleData.Revives then 
		battleData.Revives = {}
	end
	if not battleData.Revives.MaxRevive then
		battleData.Revives.MaxRevive = 3
	end
	if battleData.Revives.MaxRevive <= 0 then 
		return 
	end
	bearerData.Health = bearerData.MaxHealth
	battleData.Revives.MaxRevive -= 1
end}

passivesData.Regeneration = {type = "onTurn", passiveFunction = function(bearer)
	damageEvent:Fire(bearer.Instance, -3)
end}

passivesData.FireProof = {type = "passive", passiveFunction = function(bearer)
	-- just so it exists idk
end,}

passivesData.DemonicRegeneration = {type = "onTurn", passiveFunction = function(bearer)
	damageEvent:Fire(bearer.Instance, -2)
end,}

passivesData.IndomitableHumanSpirit = {type = "onTurn", passiveFunction = function(bearer)
	damageEvent:Fire(bearer.Instance, -20)
end}

passivesData.IndomitableSpirit = {type = "onTurn", passiveFunction = function(bearer)
	damageEvent:Fire(bearer.Instance, -2)
end}

passivesData.Photosynthesis = {type = "onTurn", passiveFunction = function(bearer)
	damageEvent:Fire(bearer.Instance, -1)
end}

passivesData.JungleBlessing = {type = "onTurn", passiveFunction = function(bearer)
	damageEvent:Fire(bearer.Instance, -3)
end}

passivesData.GuardianGuard = {type = "onGuard", passiveFunction = function(bearer)
	local bearerData = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

	local direction = 1
	if not bearerBattleData.IsGuarding then direction = -1 end
	bearerData.Defence += 2 * direction
end}

passivesData.StoneGuard = {type = "onGuard", passiveFunction = function(bearer)
	local bearerData = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

	local direction = 1
	if not bearerBattleData.IsGuarding then direction = -1 end
	bearerData.Defence += 2 * direction
end}

passivesData.WaterAffinity = {type = "onTurn", passiveFunction = function(bearer)
	local bearerBattleData = bearer.InBattleData

	local wetEffect = effectBindable:Invoke(bearer.Instance, "findEffect", "Wet")
	if wetEffect then
		local found = effectBindable:Invoke(bearer.Instance, "findEffect", "WaterAffinity")

		if found then found.duration = wetEffect.duration return end
		effectBindable:Invoke(bearer.Instance, "addEffect", {name = "WaterAffinity", duration = wetEffect.duration})
	end
end}

passivesData.FireAffinity = {type = "onTurn", passiveFunction = function(bearer)
	local bearerBattleData = bearer.InBattleData

	local fireEffect = false
	for _, effect in ipairs(bearerBattleData.Effects) do
		if effect.name == "Fire" then fireEffect = effect break end
	end
	if fireEffect then
		local found = effectBindable:Invoke(bearer.Instance, "findEffect", "FireAffinity")

		if found then found.duration = fireEffect.duration return end
		effectBindable:Invoke(bearer.Instance, "addEffect", {name = "FireAffinity", duration = fireEffect.duration})
	end
end}

passivesData.Energetic = {type = "onBattleStart", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)

	bearerStats.Energy = math.min(bearerStats.Energy + 1, bearerStats.MaxEnergy)
end}

passivesData.AdvancedCharge = {type = "onCharge", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)

	bearerStats.Energy = math.min(bearerStats.Energy + 1, bearerStats.MaxEnergy)
end}

passivesData.Purified = {type = "onBattleStart", passiveFunction = function(bearer)
	print("Purified passive TBA.")
end}

passivesData.FlowingMana = {type = "onTurn", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)

	local roll = math.random(1,3)
	if roll == 1 then
		bearerStats.Energy = math.min(bearerStats.Energy + 1, bearerStats.MaxEnergy)
	end
end}

passivesData.ReganRage = {type = "onBattleStart", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

	effectBindable:Invoke(bearer.Instance, "addEffect", {name = "ReganRage", duration = 1000, gave = 0})
end}

passivesData.Insanity = {type = "onBattleStart", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData
	effectBindable:Invoke(bearer.Instance, "addEffect", {name = "Sanity", duration = 1000})

	if bearer.Instance:IsA("Player") then
		updateUi:FireClient(bearer.Instance, "UpdateEffects", bearerBattleData.Effects)
	elseif bearer.Instance:IsA("Model") then
		local player = players:GetPlayerFromCharacter(bearer.Instance)
		if player then
			updateUi:FireClient(player, "UpdateEffects", bearerBattleData.Effects)
		end
	end

end}

passivesData.PazaronAgilityUpside = {type = "onDodge", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

	local found, index = effectBindable:Invoke(bearer.Instance, "findEffect", "PazaronAgility")
	if found then effectBindable:Invoke(bearer.Instance, "removeEffect", "PazaronAgility") end

	local effect = found or {name = "PazaronAgility", duration = 1000, stacks = 0, gave = 0}
	effectBindable:Invoke(bearer.Instance, "addEffect", effect)
	effect.stacks = math.min(3, effect.stacks + 1)
end}

passivesData.PazaronAgilityDownside = {type = "onDamaged", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

	local found = effectBindable:Invoke(bearer.Instance, "findEffect", "PazaronAgility")
	if not found then return end

	found.duration = 0
end}

passivesData.Bloodlust = {type = "onDamage", passiveFunction = function(bearer,defender,damage)
	if not damage then return end

	local lifestealmult = 0.5
	damageEvent:Fire(bearer.Instance, lifestealmult*-damage)
end}

passivesData.SoulMode = {type = "onBattleStart", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData
	if not bearerBattleData.Stance then bearerBattleData["Stance"] = 1 end
	effectBindable:Invoke(bearer.Instance, "addEffect", {name = "SoulModeHealth", duration = 100})
	effectBindable:Invoke(bearer.Instance, "addEffect", {name = "SoulModeHealthRegen", duration = 100})
end}

passivesData.RegenerativeSoul = {type = "onBattleEnd", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData
	local calculatedMaxHp = 20 + bearerStats.HealthFromSouls + bearerStats.StatPassives.MaxHealth
	bearerStats.MaxHealth = calculatedMaxHp
	bearerStats.Health = calculatedMaxHp
end}

passivesData.DemonicHide = {type = "OnDamaged", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

end,}

passivesData.BattleReady = {type = "onBattleStart", passiveFunction = function(bearer)
	local bearerStats = require(bearer.Instance.InstanceData)
	local bearerBattleData = bearer.InBattleData

	effectBindable:Invoke(bearer.Instance, "addEffect", {name = "LoadedFlintlock", duration = 1000, stacks = 1})
end,}

passivesData.KarliRevive = {type = "onDeath", passiveFunction = function(bearer)
	local bearerData = require(bearer.Instance.InstanceData)
	local battleData = bearer.InBattleData
	if bearerData.Health > 0 then return end
	if not battleData.Revives then 
		battleData.Revives = {}
	end
	if not battleData.Revives.KarliRevive then
		battleData.Revives.KarliRevive = 3
	end
	if battleData.Revives.KarliRevive <= 0 then 
		return 
	end
	battleData.Revives.KarliRevive -= 1
	bearerData.Health = 100

	if battleData.Revives.KarliRevive == 0 then
		bearerData.Speed = 10
		bearerData.Defence = 0
		bearerData.Damage = 20
	elseif battleData.Revives.KarliRevive == 1 then
		bearerData.Speed = 1
		bearerData.Defence = 20
		bearerData.Damage = 9
	elseif battleData.Revives.KarliRevive == 2 then
		bearerData.Speed = 19
		bearerData.Defence = 0
		bearerData.Damage = 11
	end
end,}

return passivesData