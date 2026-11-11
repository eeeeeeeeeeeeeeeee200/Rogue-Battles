local subracesData = {}

subracesData.Races = {"None", "Demon", "Archdemon", "Ignited"} -- mostly just for clarity checks

subracesData.None = {
	Stats = {Defence = 0, Damage = 0, Speed = 0},
	Attacks = {},
	Passives = {},
}

subracesData.Demon = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["Demonic Appearence"] = {type = "OtherPassive"},
		["Demonic Regeneration"] = {type = "CombatPassive"},
		["Light Weakness"] = {type = "ElemRes", element = "Light", resistance = 0.1},
	},
}

subracesData.ArchdemonHide = {
	Stats = {Defence = 0, Damage = 1, Speed = 0, MaxHealth = 10, DamageReduc = 0.1, ShadowDodge = 0.5,},
	Attacks = {},
	Passives = {
		["Demonic Appearence"] = {type = "OtherPassive"},
		["Demonic Hide"] = {type = "OtherPassive"},
		["Demonic Regeneration"] = {type = "CombatPassive"},
		["Light Weakness"] = {type = "ElemRes", element = "Light", resistance = 0.2},
	},
}

subracesData.ArchdemonMind = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["Demonic Appearence"] = {type = "OtherPassive"},
		["Enhanced Mind"] = {type = "CombatPassive"}, 
		["Demonic Regeneration"] = {type = "CombatPassive"},
		["Light Weakness"] = {type = "ElemRes", element = "Light", resistance = 0.1},
	},
}

subracesData.ArchdemonSoul = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {},
	Passives = {
		["Demonic Appearence"] = {type = "OtherPassive"},
		["The Soul"] = {type = "OtherPassive"},
		["Demonic Regeneration"] = {type = "CombatPassive"},
		["Light Weakness"] = {type = "ElemRes", element = "Light", resistance = 0.1},
	},
}

subracesData.Ignited = {
	Stats = {Defence = 0, Damage = 1, Speed = 0},
	Attacks = {"Burning Soul"},
	Passives = {
		["Ignited Appearence"] = {type = "OtherPassive"},
		["FireProof"] = {type = "CombatPassive"}, -- imune to fire Dot
		["FireAffinity"] = {type = "CombatPassive"},
		["FireAttacks"]  = {type = "CombatPassive"}, -- proc fireon attacks
		["Fire Resistance"] = {type = "ElemRes", element = "Fire", resistance = 1.7}, -- i think this should work like 70% less dmg
	},
}

return subracesData