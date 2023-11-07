-- This file is sourced after the EHDB.lua file is loaded.
-- It is intended to be used to override the default EHDB database.
-- Tables are located in ns.ehdb.<TableName>
-- All tables are maps, with the key being the spellID and the value being true.
-- If you want to add an entry, set the value to True.
-- If you want to remove an entry, set the value to Nil.

local _, ns = ...

local tables = {
	"Spells",
	"SpellsNoTank",
	"Auras",
	"AurasNoTank",
	"MeleeHitters",
}

local Spells = {
	[393444] = Nil, -- Spear Flurry / Gushing Wound (Refti Defender)

	[393432] = True, -- Spear Flurry (Refti Defender)
	[393444] = True, -- Gushing Wound (Refti Defender)
	[256477] = True, -- Shark Toss (Trothak, Ring of Booty)
	[183100] = True, -- Avalanche, Rocks (Mightstone Breaker)
	[411001] = True, -- Lethal Current (Lurking Tempest)

	-- ... add entries here
}

local SpellsNoTank = {
	[382712] = Nil, -- Necrotic Breath, Initial (Wilted Oak)
	[382805] = Nil, -- Necrotic Breath, DoT (Wilted Oak)
	[226406] = Nil, -- Ember Swip (Emberhusk Dominator)

	[387571] = True, -- Focused Deluge (Primal Tsunami)
	[387504] = True, -- Squall Buffet (Primal Tsunami)
	[374544] = True, -- Burst of Decay (Fetid Rotsinger)
	[385833] = True, -- Bloodthirsty Charge (Rageclaw) (Knockback)
	[385834] = True, -- Bloodthirsty Charge (Rageclaw) (Dot)
	[200732] = True, -- Molten Crash (Dargrul)

	-- ... add entries here
}

local Auras = {
	-- ... add entries here
}

local AurasNoTank = {
	[374615] = True, -- Cheap Shot (Skulking Zealot)

	-- ... add entries here
}

local MeleeHitters = {
	-- ... add entries here
}


function merge(target, override)
	for k, v in pairs(override) do
		target[k] = v
	end
end

for _, table in ipairs(tables) do
	merge(ns.ehdb[table], _G[table])
end
