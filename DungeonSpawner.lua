local cells = 100
--number of rooms^
-- dont change this
local minimumChestRooms = 0
local totalChestRooms = 0
-- do change this, number of minimum chests is number of rooms divided by chestRoomMath
local chestRoomMath = 7
-- where it spawns maybe
local dungeonSpawnLocation = Vector3.new(5000, 5000, 5000)

local rS = game:GetService("ReplicatedStorage")

local partySystem = require(rS.Systems.PartySystem)
local encounterData = require(rS.Data.EncounterData)
local battleSystem = require(rS.Systems.BattleSystem)
local dataSystem = require(rS.Systems.DataSystem)
local inventorySystem = require(rS.Systems.InvSystem)
local debris = game:GetService("Debris")
local ShardTemplate = rS:WaitForChild("Templates"):WaitForChild("EmberShardPickup")


-- bindable event
local event = game.ReplicatedStorage.Events.DungeonSpawnerEvent
local battleEvent = game.ReplicatedStorage.Events.startBattleServer
local updateUI = game.ReplicatedStorage.Events.UpdateUI

local roomTypes = {
	StartingRoom = "StartingRoom",
	FightRoom = "",
	SpecialRoom = "SpecialRoom",
	ChestRoom = "ChestRoom",
	StairsRoom = "StairsRoom",
}

local specialRooms = {
	[1] = {"weaponry"},
	[2] = {"healer", "weaponry"},
	[3] = {"healer", "weaponry"},
	[4] = {"healer", "weaponry"},
	[5] = {"healer", "weaponry"},
	[6] = {"healer", "weaponry"},
	[7] = {"healer", "weaponry"},
	[8] = {"healer", "weaponry"},
	[9] = {"healer", "weaponry"},
	[10] = {"healer", "weaponry"},
}

--dont change anything else unless you know what you are doing
-- i might have changed some things else

-- gonna try giving atributes to some rooms maybe

-- why am i even commenting so much aint no one reading this
-- if youre reading this tell me ok

local middlepos = Vector3.new(0,0,0)
local cellxsize = 53
local cellysize = 40

local function spawnEmberShards(spawnpos, floor)

	local shardMulti = floor
	local amount = 0

	if floor >= 5 then
		-- if they are at or above floor 5 then multiply random shard by 7 instead of floor number, so the max shards from a chest is 210
		shardMulti = 7
	end
	-- might need balancing lol....
	amount = math.random(5,30) * shardMulti

	local shardDrop = ShardTemplate:Clone()
	shardDrop:SetAttribute("Amount", amount)


	local bgui = Instance.new("BillboardGui")
	bgui.Name = "ShardDisplay"
	bgui.Size = UDim2.new(3, 0, 0.75, 0)
	bgui.Adornee = shardDrop
	bgui.ExtentsOffset = Vector3.new(0, 1.5, 0)
	bgui.AlwaysOnTop = true

	local label = Instance.new("TextLabel")
	label.Parent = bgui
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = tostring(amount) .. " ES"
	label.TextColor3 = Color3.new(1, 0.560784, 0.0235294)
	label.TextScaled = true
	label.Font = Enum.Font.Highway
	label.TextStrokeTransparency = 0
	label.FontFace.Bold = true


	bgui.Parent = shardDrop

	local newSize
	local newColor

	if amount < 100 then
		newSize = Vector3.new(0.8, 0.8, 0.8)
		newColor = Color3.fromRGB(255, 141, 10)
	elseif amount < 1000 then
		newSize = Vector3.new(1, 1, 1)
		newColor = Color3.fromRGB(255, 85, 0)
	elseif amount < 5001 then
		newSize = Vector3.new(1.2, 1.2, 1.2)
		newColor = Color3.fromRGB(255, 67, 42)
	else
		newSize = Vector3.new(1.4, 1.4, 1.4)
		newColor = Color3.fromRGB(170, 0, 0)
	end

	shardDrop.Size = newSize
	shardDrop.Color = newColor
	shardDrop:PivotTo(spawnpos * CFrame.new(1, 0, 0))
	shardDrop.Parent = workspace


	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = shardDrop

	clickDetector.MouseClick:Connect(function(clickingPlayer)
		local targetData = dataSystem.getData(clickingPlayer)
		if targetData then
			local targetSlot = targetData.LastSlot
			local shardAmount = shardDrop:GetAttribute("Amount")
			targetData.Slots[targetSlot].EmberShards += shardAmount
			updateUI:FireClient(clickingPlayer, "Init", targetData)
			shardDrop:Destroy()
		end
	end)

	debris:AddItem(shardDrop, 120)
end

local function pickRoomType(number, room, floor)
	if number == 1 then
		room:SetAttribute("RoomType", "StartingRoom")
		-- attempt to guarantee chest rooms 
		-- maor could never
		-- uhm idk how to make the rooms actually diferent yet, but we do that when we actually make the rooms
		-- i now know and did it
	elseif number == cells then
		-- stairs to next floor, we run this code again for next floor
		-- i want alotta floors btw :fire:
		-- not just 3
		if floor ~= 10 then
			room:SetAttribute("RoomType", "StairsRoom")
		elseif floor == 10 then
			room:SetAttribute("RoomType", "BossRoom")
		end
	elseif number == cells / 2 then
		-- maybe for a boss or smt
		room:SetAttribute("RoomType", "SpecialRoom")
	elseif (cells - number) <= (minimumChestRooms - totalChestRooms) and totalChestRooms < minimumChestRooms then
		room:SetAttribute("RoomType", "ChestRoom")
		totalChestRooms += 1
	else
		local rng = math.random(1,12)
		if rng == 12 then
			room:SetAttribute("RoomType", "ChestRoom")
			totalChestRooms += 1
		else
			room:SetAttribute("RoomType", "FightRoom")
		end
	end
end

function addcell(cellnumber, floor)
	local room = Instance.new("Vector3Value")
	room.Name = "Room".. tostring(cellnumber)
	print(room.Name)
	pickRoomType(cellnumber, room, floor)
	room.Parent = script
	if script:FindFirstChild("Room".. tostring(cellnumber-1) ) then
		room.Value = script:FindFirstChild("Room".. tostring(cellnumber-1) ).Value
		local roomcollision = true
		repeat 
			task.wait()
			local roomposition = math.random(1,4)
			if roomposition == 1 then
				room.Value = room.Value+Vector3.new(-1,0,0)
			elseif roomposition == 2 then
				room.Value = room.Value+Vector3.new(0,0,-1)
			elseif roomposition == 3 then
				room.Value = room.Value+Vector3.new(1,0,0)
			else
				room.Value = room.Value+Vector3.new(0,0,1)
			end
			roomcollision = false
			for i,a in ipairs(script:GetChildren()) do
				if room ~= a then
					if a.Value == room.Value then
						roomcollision = true
					end
				end
			end
		until roomcollision == false
	else
		room.Value = middlepos
	end
end

local function setupBattle(room, boss)
	local touchPart = Instance.new("Part")
	touchPart.Size = Vector3.new(40,40,40)
	touchPart.CanCollide = false
	touchPart.Transparency = 1
	touchPart.Anchored = true
	local debounce = false
	touchPart.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			local hitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)

			if debounce == true then return end
			if hitPlayer then
				debounce = true
				touchPart.CanTouch = false
				local enemyList = {}
				if boss then
					local enemy = battleSystem.createEnemy("Karli")
					table.insert(enemyList, enemy)
				else
					local enemyNameList = encounterData.getEnemies(100, "FirePillar")

					for _, enemyName in ipairs(enemyNameList) do
						table.insert(enemyList, battleSystem.createEnemy(enemyName))
					end
				end
				battleEvent:Fire(hitPlayer, {useParty = false, otherParty = enemyList})
				debris:AddItem(touchPart, 10)
			end
		end
	end)

	touchPart.Parent = room
	touchPart.CFrame = room:GetPivot() + Vector3.new(0,3,0)

end

local function pickSpecialRoom(floor)
	if not floor or not specialRooms[floor] then floor = 1 end
	local pickedSpecialRoom = specialRooms[floor][math.random(1, #specialRooms[floor])]
	return pickedSpecialRoom
end

local function spawnDungeon(player, floor)
	local startingRoomModel = nil
	local playerParty = partySystem.playerParties[player]
	local playersToTP = {}
	totalChestRooms = 0
	if playerParty then
		for i, v in ipairs(playerParty.members) do
			if v.Character then
				v.Character.HumanoidRootPart.Anchored = true
				table.insert(playersToTP, v)
			end
		end
	else
		if player.Character then
			player.Character.HumanoidRootPart.Anchored = true
			table.insert(playersToTP, player)
		end
	end

	if not workspace:FindFirstChild("DungeonRooms") then 
		local folder = Instance.new("Folder")
		folder.Name = "DungeonRooms"
		folder.Parent = workspace
	end

	print("Despawning old dungeon")
	for i, v in ipairs(workspace.DungeonRooms:GetChildren()) do
		v:Destroy()
	end
	for i, v in ipairs(script:GetChildren()) do
		v:Destroy()
	end
	print("Spawning Dungeon")
	if floor then
		cells = floor * 10
		minimumChestRooms = cells / chestRoomMath
		minimumChestRooms = math.round(minimumChestRooms)
	end
	-- uhmm a number too low would break things so just incase
	if cells <= 10 then cells = 10 end
	-- not letting yall somehow spawn 2 billion rooms
	if cells >= 1000 then cells = 10 end

	for i = 1,cells do
		addcell(i, floor)
	end

	for i,a in ipairs(script:GetChildren()) do
		local roomname = ""
		local roomposition = a.Value
		for h,b in ipairs(script:GetChildren()) do
			if b~=a then
				if b.Value.X == a.Value.X-1 and b.Value.Z == a.Value.Z then
					roomname = roomname.."L"
				end
			end
		end
		for h,b in ipairs(script:GetChildren()) do
			if b~=a then
				if b.Value.X == a.Value.X+1 and b.Value.Z == a.Value.Z then
					roomname = roomname.."R"
				end
			end
		end
		for h,b in ipairs(script:GetChildren()) do
			if b~=a then
				if b.Value.Z == a.Value.Z-1 and b.Value.X == a.Value.X then
					roomname = roomname.."U"
				end
			end
		end
		for h,b in ipairs(script:GetChildren()) do
			if b~=a then
				if b.Value.Z == a.Value.Z+1 and b.Value.X == a.Value.X then
					roomname = roomname.."D"
				end
			end
		end
		local room = nil
		local typeOfRoom = a:GetAttribute("RoomType")
		room = game.ServerStorage.Rooms[roomname]:Clone()
		a:Clone().Parent = room
		if typeOfRoom == "StartingRoom" then startingRoomModel = room end
		room.Parent = workspace.DungeonRooms

		room:SetPrimaryPartCFrame(CFrame.new(
			(roomposition.X * cellxsize) + dungeonSpawnLocation.X,
			dungeonSpawnLocation.Y, 
			(roomposition.Z * cellysize) + dungeonSpawnLocation.Z))
		-- battle setup
		if typeOfRoom == "FightRoom" then
			setupBattle(room, false)
		elseif typeOfRoom == "StairsRoom" then
			local obelisk = game.ServerStorage.Rooms.Obeliskblue:Clone()
			obelisk:PivotTo(room:GetPivot() + Vector3.new(0,3,0))
			obelisk.ClickDetector.MouseClick:Connect(function(clicker)
				spawnDungeon(clicker, floor + 1)
			end)
			obelisk.Parent = room

		elseif typeOfRoom == "ChestRoom" then
			local chest = game.ServerStorage.Rooms.Chest:Clone()
			chest:PivotTo(room:GetPivot() + Vector3.new(0,3,0))
			chest.Parent = room
			local droppedItem = require(game.ReplicatedStorage.Data.ChestData).pickItem("Chest1")
			chest.ClickDetector.MouseClick:Connect(function(clicker)
				task.wait(1)
				local templateName = string.lower(string.gsub(droppedItem, " ", ""))
				local template = game.ReplicatedStorage.Templates:FindFirstChild(templateName)
				if not template then 
					warn("Template " .. templateName .. " not found")
					return 
				end

				local drop = template:Clone()


				local rotation = CFrame.Angles(0, 0, math.rad(-90))
				local spawnCFrame = chest:GetPivot()

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
				if math.random(1,2) == 2 then
					spawnEmberShards(spawnCFrame, floor)
				end
				chest:Destroy()
			end)
		elseif typeOfRoom == "BossRoom" then
			setupBattle(room, true)
			local obelisk = game.ServerStorage.Rooms.Obeliskblue:Clone()
			obelisk:PivotTo(room:GetPivot() + Vector3.new(0,3,0))
			obelisk.ClickDetector.MouseClick:Connect(function(clicker)
				spawnDungeon(clicker, floor + 1)
			end)
			obelisk.Parent = room
		elseif typeOfRoom == "SpecialRoom" then
			local pickedRoom = pickSpecialRoom(floor)
			if pickedRoom == "weaponry" then
				local obelisk = game.ServerStorage.Rooms.BarbarianSwordPedestal:Clone()
				obelisk:PivotTo(room:GetPivot() + Vector3.new(0,8,0))
				obelisk.Parent = room
			end
		end
	end
	local tp = startingRoomModel:GetPivot()
	for i, v in pairs(playersToTP) do 
		v.Character.HumanoidRootPart.Anchored = false
		v.Character:PivotTo(tp + Vector3.new(0,3,0))
	end
end

-- made this into a function idk 
-- so i can do another floor without re calling the event
event.Event:Connect(function(player, floor)
	spawnDungeon(player, floor)
end)
