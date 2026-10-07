local rS = game:GetService("ReplicatedStorage")
local ArmorsData = require(rS.Data.ArmorData)
local racesData = require(rS.Data.RacesData)
local subraceData = require(rS.Data.SubracesData)

--[[local function AddStats(before, increment)
	for statName, value in pairs(increment) do
		before[statName] = (before[statName] or 0) + value
	end
end]]
local function AddStats(before, increment)
	for statName, value in pairs(increment) do
		before[statName] = (before[statName] or 0) + value
	end
end

local statsSystem = {}

statsSystem.showingStats = {}

function statsSystem.CalculateStats(slotData)
	local newStats = {
		Speed = 0,
		Damage = 0,
		Defence = 0,
		MaxHealth = 20,
		MaxEnergy = 6,
		MagicPower = 0,
		DamageMulti = 1,
		DamageReduc = 1,
	}

	newStats.MaxHealth += slotData.HealthFromSouls

	local currentRaceData = racesData[slotData.Race] or racesData.Default
	local currentRaceStats = currentRaceData.Stats or {}

	local currentSubraceData = subraceData[slotData.SubRace] or subraceData.None
	local currentSubraceStats = currentSubraceData.Stats or {}

	AddStats(newStats, currentRaceStats)
	AddStats(newStats, currentSubraceStats)
	AddStats(newStats, slotData.StatPassives)


	local armor, helmet = slotData.Armor, slotData.Helmet
	if armor ~= "None" and armor ~= nil then
		local armorData = ArmorsData:PullArmorData(slotData.Armor)
		AddStats(newStats, armorData)
	end
	if helmet ~= "None" and helmet ~= nil then
		local helmetData = ArmorsData:PullArmorData(slotData.Helmet)
		AddStats(newStats, helmetData)
	end

	return newStats
end

function statsSystem.UpdateStats(player)
	if statsSystem.showingStats[player] then return end
	if not player then return end -- added this incase the line bellow has no player so it wont crash
	local character = player.Character
	if not character then return end

	local instanceData: Instance = character:WaitForChild("InstanceData", 5)
	if not instanceData then return end

	local slotData = require(instanceData)
	if not slotData then return end

	if not slotData.CurrentBattle then
		for statName, value in pairs(statsSystem.CalculateStats(slotData)) do
			slotData[statName] = value
		end
	end

	-- Update UI
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	local playerStatsGui = playerGui.PlayerStatsGui
	local main = playerStatsGui.Main

	main.NameFrame.PlayerName.Text = player.Name
	for _, stat in ipairs(main.Stats:GetChildren()) do
		if stat:IsA("TextLabel") then
			local statName = string.gsub(stat.Name, "Label", "")
			stat.Text = statName .. ": " ..slotData[statName]
			if statName == "Health"  or statName == "Energy" then
				stat.Text = stat.Text .. " / " .. slotData["Max" ..statName]
				if statName == "Energy" and slotData[statName] <= 6 then
					stat.UIGradient.Color = rS.Templates.EnergyGradients[slotData[statName]].Color
				elseif statName == "Energy" and slotData[statName] > 6 then
					stat.UIGradient.Color = rS.Templates.EnergyGradients[6].Color
				end
			end
		end
	end
end

function statsSystem.ShowStats(player, entity, entityStats)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	statsSystem.showingStats[player] = entity

	local playerStatsGui = playerGui.PlayerStatsGui
	local main = playerStatsGui.Main

	main.NameFrame.PlayerName.Text = entity.Name
	for _, stat in ipairs(main.Stats:GetChildren()) do
		if stat:IsA("TextLabel") then
			local statName = string.gsub(stat.Name, "Label", "")
			stat.Text = statName .. ": " ..entityStats[statName]
			if statName == "Health"  or statName == "Energy" then
				stat.Text = stat.Text .. " / " .. entityStats["Max" ..statName]
			end
		end
	end
end

return statsSystem