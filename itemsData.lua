local rS = game:GetService("ReplicatedStorage")
local inventoryModule = require(rS.Systems.InvSystem)
local damageEvent = rS.Events.DamageEvent
local dataFunction = rS.bindableFunctions.dataFunction
local visualSystem = require(rS.Systems.VisualSystem)

local Players = game:GetService("Players")

local itemsData = {}

local function insertGem(instanceModel, gem)
	local instanceData = require(instanceModel.InstanceData)
	local gemList = instanceData.Gems
	print(gemList)
	for i = 1, 4 do
		local slotName = "Slot" .. i
		local gemData = gemList[slotName]
		if gemData and gemData.gem == "None" then
			gemData.gem = gem
			visualSystem.ApplyAppearance(instanceModel, instanceData)
			break
		end
	end
end
-- might be unnecessary idk
local function removeGem(instanceModel, gem)
	local instanceData = require(instanceModel.InstanceData)
	local gemList = instanceData.Gems
	for i, v in pairs(gemList) do
		if v.gem == gem then
			v.gem = "None"
			local player = Players:GetPlayerFromCharacter(instanceModel)
			inventoryModule.AddItem(player, gem, 1)
			break
		end
	end
end

function itemsData.SpawnItemDrop(droppedItem, spawnCFrame)
		local templateName = string.lower(string.gsub(droppedItem, " ", ""))
		local template = game.ReplicatedStorage.Templates:FindFirstChild(templateName)
		if not template then 
			warn("Template " .. templateName .. " not found")
			return 
		end

		local drop = template:Clone()
		local rotation = CFrame.Angles(0, 0, math.rad(-90))

		drop:PivotTo(spawnCFrame * CFrame.new(-1,0,0))
		drop.Parent = workspace

		local hitbox = Instance.new("Part")
		hitbox.Name = "ClickHitbox"
		hitbox.Transparency = 1
		hitbox.CanCollide = false
		hitbox.Massless = true

		local skip = false

		if drop:IsA("Model") then
			local orientation, size = drop:GetBoundingBox()
			hitbox.Size = size
			hitbox.CFrame = orientation
		else
			hitbox.Size = drop.Size
			hitbox.CFrame = drop.CFrame
			skip = true
		end
		if skip	== false then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = hitbox
			weld.Part1 = drop:IsA("Model") and (drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")) or drop
			weld.Parent = hitbox
			hitbox.Parent = drop
		end

		local cd = Instance.new("ClickDetector")
		cd.MaxActivationDistance = 10
		if skip == true then
			cd.Parent = drop
		else
			cd.Parent = hitbox
		end

		local clicked = false
		cd.MouseClick:Connect(function(clickingPlayer)
			if clicked then return end



			clicked = true

			local added = inventorySystem.AddItem(clickingPlayer, droppedItem, 1)
			if added then
				debris:AddItem(drop, 0)
			end
		end)

		debris:AddItem(drop, 120) 
		chest:Destroy()
	end)
end

function itemsData.coconutwater(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	
	if instanceData.CurrentBattle then
		instanceData.Energy = math.min(instanceData.Energy + 2, instanceData.MaxEnergy)
	end
	damageEvent:Fire(instanceModel, -10)
	return true
end

function itemsData.healthpotion(instanceModel)
	damageEvent:Fire(instanceModel, -10)
	return true
end

function itemsData.energypotion(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	
	if instanceData.CurrentBattle then
		instanceData.Energy = math.min(instanceData.Energy + 4, instanceData.MaxEnergy)
		return true
	end
	return false
end 

function itemsData.darkpotion(instanceModel)
	local instanceData = require(instanceModel.InstanceData)

	if instanceData.CurrentBattle and instanceData.Health > 10 then
		local instanceProfile = dataFunction:Invoke(instanceModel, "GetCombatProfile")
		local inBattleData = instanceProfile.InBattleData
		
		damageEvent:Fire(instanceModel, 10)
		local found = false
		for _, currentEffect in ipairs(inBattleData.Effects) do
			if currentEffect.name == "DarkPotion" then
				currentEffect.duration += 3
				found = true
				break
			end
		end

		if found then return end
		table.insert(inBattleData.Effects, {name = "DarkPotion", duration = 3})
		
		return true
	end
	return false
end

function itemsData.corn(instanceModel)
	damageEvent:Fire(instanceModel, -15)
	return true
end

function itemsData.corruptedflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
	return false
	else
		if instanceData.Gender == "Male" then
			instanceData.Gender = "Female"
		elseif instanceData.Gender == "Female" then
			instanceData.Gender = "Male"
		end
		visualSystem.rerollHair(instanceModel, "Hair")
	return true
	end
end

function itemsData.hairyflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollHair(instanceModel, "Hair")
		return true
	end
end

function itemsData.dyedflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollHair(instanceModel, "Color")
		return true
	end
end

function itemsData.skinnedflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollSkin(instanceModel)
		return true
	end
end

function itemsData.opticflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollFace(instanceModel, "Eyes")
		return true
	end
end

function itemsData.smellyflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollFace(instanceModel, "Nose")
		return true
	end
end

function itemsData.tastyflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollFace(instanceModel, "Mouth")
		return true
	end
end

function itemsData.colorfullflask(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle then
		return false
	else
		visualSystem.rerollFace(instanceModel, "EyeColor")
		return true
	end
end

function itemsData.tanzanite(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.Race ~= "Gemling" or instanceData.CurrentBattle then return false end
	
	local freeGemSlots = 0
	for i = 1, 4 do 
		if instanceData.Gems["Slot" .. i].gem == "None" then 
			freeGemSlots += 1
		end
	end
	if freeGemSlots == 0 then return false end
	insertGem(instanceModel, "Tanzanite")
	return true
end

function itemsData.jade(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.Race ~= "Gemling" then return false end
	if instanceData.CurrentBattle then
		return false
	else
		insertGem(instanceModel, "Jade")
		return true
	end
end

function itemsData.amethyst(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.Race ~= "Gemling" then return false end
	if instanceData.CurrentBattle then
		return false
	else
		insertGem(instanceModel, "Amethyst")
		return true
	end
end

function itemsData.onyx(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.Race ~= "Gemling" then return false end
	if instanceData.CurrentBattle then
		return false
	else
		insertGem(instanceModel, "Onyx")
		return true
	end
end

function itemsData.ametrine(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.Race ~= "Gemling" then return false end
	if instanceData.CurrentBattle then
		return false
	else
		insertGem(instanceModel, "Ametrine")
		return true
	end
end

function itemsData.tourmaline(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.Race ~= "Gemling" then return false end
	if instanceData.CurrentBattle then
		return false
	else
		insertGem(instanceModel, "Tourmaline")
		return true
	end
end

function itemsData.poweredrelic(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle or instanceData.EntityType ~= "Player" then return end
	
	local player = Players:GetPlayerFromCharacter(instanceModel)
	local equipmentSystem = require(rS.Systems.EquipmentSystem)
	local success = equipmentSystem.equipItem(instanceData, "Powered Relic", player, "Relic")
	
	return success or false
end

function itemsData.boulderbodyrelic(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	if instanceData.CurrentBattle or instanceData.EntityType ~= "Player" then return end
	local player = Players:GetPlayerFromCharacter(instanceModel)
	
	local equipmentSystem = require(rS.Systems.EquipmentSystem)
	local success = equipmentSystem.equipItem(instanceData, "Boulder Body Relic", player, "Relic")
	
	return success or false
end

function itemsData.waterscroll(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	
	if instanceData.EntityType == "NPC" then table.insert(instanceData.Attacks, "Water Pistol") return end
	
	local attackName = "Water Pistol"
	if instanceData.Attacks[attackName] then return false end
	
	local attackCount = 0
	for _ in pairs(instanceData.Attacks) do attackCount += 1 end
	instanceData.Attacks[attackName] = {
		position = attackCount + 1,
		equipped = false,
		useable = true
	}
	
	return true
end

function itemsData.advancedwaterscroll(instanceModel)
	local instanceData = require(instanceModel.InstanceData)

	if instanceData.EntityType == "NPC" then table.insert(instanceData.Attacks, "Rain Cast") return end

	local attackName = "Raincast"
	if instanceData.Attacks[attackName] then return false end

	local attackCount = 0
	for _ in pairs(instanceData.Attacks) do attackCount += 1 end
	instanceData.Attacks[attackName] = {
		position = attackCount + 1,
		equipped = false,
		useable = true
	}

	return true
end

function itemsData.everlastingflameartifact(instanceModel)
	local instanceData = require(instanceModel.InstanceData)
	return false
end

function itemsData.healingscroll(instanceModel)
	local instanceData = require(instanceModel.InstanceData)

	if instanceData.EntityType == "NPC" then table.insert(instanceData.Attacks, "Heal" or "Self Heal") return end

	-- if they have both moves
	if instanceData.Attacks["Heal"] and instanceData.Attacks["Self Heal"] then return false end
	
	local attackName = "SelfHeal"
	if instanceData.Attacks[attackName] then attackName = "Heal" end

	-- rng shoudnt matter if they already have heal
	if math.random(1,2) == 2 then attackName = "Heal" end


	local attackCount = 0
	for _ in pairs(instanceData.Attacks) do attackCount += 1 end
	instanceData.Attacks[attackName] = {
		position = attackCount + 1,
		equipped = false,
		useable = true
	}

	return true
end

function itemsData.lavascroll(instanceModel)
	local instanceData = require(instanceModel.InstanceData)

	if instanceData.EntityType == "NPC" then table.insert(instanceData.Attacks, "Lava Burst") return end

	local attackName = "Lava Burst"
	if instanceData.Attacks[attackName] then return false end

	local attackCount = 0
	for _ in pairs(instanceData.Attacks) do attackCount += 1 end
	instanceData.Attacks[attackName] = {
		position = attackCount + 1,
		equipped = false,
		useable = true
	}

	return true
end

function itemsData.firescroll(instanceModel)
	local instanceData = require(instanceModel.InstanceData)

	if instanceData.EntityType == "NPC" then table.insert(instanceData.Attacks, "Fireball Throw") return end

	local attackName = "Fireball Throw"
	if instanceData.Attacks[attackName] then return false end

	local attackCount = 0
	for _ in pairs(instanceData.Attacks) do attackCount += 1 end
	instanceData.Attacks[attackName] = {
		position = attackCount + 1,
		equipped = false,
		useable = true
	}
	return true

end


return itemsData