local chestData = {}
local itemsData = game.ReplicatedStorage.Data.ItemsData

local idToItem = {
	[1] = "Onyx",
	[2] = "Fire Scroll",
	[3] = "Tanzonite",
	[4] = "Black Rock",
	
}


chestData.Chests = {
	-- fire dungeon chest
	["BasaltChest"] = {
		["Drops"] = {
			[1] =  40,
			[2] =  20,
			[4] =  40,
		},
	},
    ["BasaltRelicChest"] = {
		["Drops"] = {
			[1] =  40,
			[2] =  20,
			[4] =  40,
		},
	},
}

function chestData.pickItem = function(chest)
	local chestTable = chestData.Chests[chest]
	local rng = math.random(1,100)
	local chestDrops = chestTable.Drops
	local weight = 0
	for item, v in pairs(chestDrops) do
		weight = weight + v
		if rng <= weight then
			return idToItem[item]
		end
	end
end

function chestData.SpawnChest = function(chest, cFrame, father)
	local item = chestData.PickItem(chest)
	local chest = game.ReplicatedStorage.Templates:FindFirstChild(chest):Clone()
	chest:PivotTo(cFrame)
	chest.Parent = father
	if not chest:FindFirstChild("ClickDetector") then local c = Instance.new("ClickDetector") c.Parent = chest end
	chest.ClickDetector.MouseClick:Connect(function(clicker)
		task.wait(1)
		itemsData.SpawnItemDrop(item)
	end)
end

return chestData
