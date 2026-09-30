local subracesData = {}

subracesData.Races = {"None", "Demon", "Archdemon"} -- mostly just for clarity checks

subracesData.None = {
	Stats = {Defence = 0, Damage = 0, Speed = 0},
	Attacks = {},
	Passives = {},
}

subracesData.Demon = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["Demonic Regeneration"] = {type = "CombatPassive"},
	},
}

subracesData.ArchdemonHide = {
	Stats = {Defence = 0, Damage = 1, Speed = 0, MaxHealth = 10, DamageReduc = 0.1,},
	Attacks = {},
	Passives = {
		["Enhanced Mind"] = {type = "CombatPassive"}, 
		["Demonic Hide"] = {type = "OtherPassive"},
		["The Soul"] = {type = "OtherPassive"},
		["Demonic Regeneration"] = {type = "CombatPassive"},
	},
}

subracesData.ArchdemonMind = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["Enhanced Mind"] = {type = "CombatPassive"}, 
		["Demonic Regeneration"] = {type = "CombatPassive"},
	},
}

subracesData.ArchdemonSoul = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["The Soul"] = {type = "OtherPassive"},
		["Demonic Regeneration"] = {type = "CombatPassive"},
	},
}

return subracesData