local rS = game:GetService("ReplicatedStorage")

local requireStats = rS.remoteFunctions.requireStats
local messageEvent = rS.Events.LittleMessagesEvent

local statSystem = require(rS.Systems.StatsSystem)
local passivesSystem = require(rS.Systems.PassivesSystem)
local dataSystem = require(rS.Systems.DataSystem)

local gameData = dataSystem.getAllData()

local visualSystem = require(rS.Systems:WaitForChild("VisualSystem"))

local subraceSystem = {}


--[[
subracesData.Demon = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["Unholy Being"] = {type = "ElemRes", element = "light", resistance = 0.15},
		["Demonic Regeneration"] = {type = "CombatPassive"},
	},
}
]]

subraceSystem.ApplySubrace =  function (slotData, subrace, player)
	if not slotData or not player then return warn("No slotdata or player in ApplySubrace") end
	local current = slotData["SubRace"]
	if current == subrace then return warn("New subrace already equals current subrace in ApplySubrace") end
	local curdata = gameData.SubracesData[current]
	local newdata = gameData.SubracesData[subrace]
	if curdata then
		-- remover
		local removeattacks = curdata.Attacks -- didnt see a better way to do this..
		for i, atk in removeattacks do -- 
			slotData.Attacks[atk] = nil -- might mess with positioning, look into that maybe..
		end
		local removepassives = curdata.Passives
		for psv, tbl in removepassives do
			passivesSystem.forgetPassive(slotData,psv,tbl)
		end
		--[[ oopsie didnt realize passivesSystem was a thing!!
		for psv, tbl in removepassives do
			if tbl["type"] == "ElemRes" then
				slotData["ElementalRes"][tbl["element"] ] -= tbl["resistance"]
			elseif tbl["type"] == "ElemMulti" then
				slotData["ElementalMulti"][tbl["element"] ] -= tbl["multiplier"]
			elseif tbl["type"] == "CombatPassive" then
				table.remove(slotData["CombatPassives"],table.find(slotData["CombatPassives"],psv:gsub(" ","")))
			end
			slotData["SkillsLearned"][psv] = nil
		end 
		]]
	end
	if newdata then
		-- adder
		local addattacks = newdata.Attacks -- yeah still didnt see a better way.. uhmmm its fine i think..,,
		for i, atk in addattacks do
			slotData.Attacks[atk] = {
				["equipped"] = true,
				["position"] = #slotData.Attacks+1,
				["useable"] = true
			}
		end
		local addpassives = newdata.Passives
		for psv, tbl in addpassives do
			passivesSystem.learnPassive(slotData,psv,tbl)
		end
	end
	slotData["SubRace"] = subrace
	statSystem.UpdateStats(player)
end



return subraceSystem