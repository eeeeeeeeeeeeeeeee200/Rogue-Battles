local chestData = {}

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

chestData.pickItem = function(chest)
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

return chestData
