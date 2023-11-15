-- This file is sourced after the EHDB.lua file is loaded.
-- It is intended to be used to override the default EHDB database.
-- Tables are located in ns.ehdb.<TableName>
-- All tables are maps, with the key being the spellID and the value being true.
-- If you want to add an entry, set the value to true.
-- If you want to remove an entry, set the value to false.

local _, ns = ...

local overrides = {}

overrides.Spells = {
	[393444] = false, -- Spear Flurry / Gushing Wound (Refti Defender)

	[393432] = true, -- Spear Flurry (Refti Defender)
	[393444] = true, -- Gushing Wound (Refti Defender)
	[256477] = true, -- Shark Toss (Trothak, Ring of Booty)
	[183100] = true, -- Avalanche, Rocks (Mightstone Breaker)
	[411001] = true, -- Lethal Current (Lurking Tempest)

	[264698] = true, -- Rotten Expulsion (Raal the Gluttonous) (Puddle)

	[172579] = true, -- Bounding Whirl (Melded Berserker)
	[169495] = true, -- Living Leaves (Gnarlroot)
	[427513] = true, -- Noxious Discharge (Dulhu)
	[426845] = true, -- Cold Fusion (Infested Icecaller) (Initial)
	[426849] = true, -- Cold Fusion (Infested Icecaller) (Orb)
	[426982] = true, -- Spatial Disruption (Addled Arcanomancer)
	[428082] = true, -- Glacial Fusion (Archmage Sol) (Initial)
	[428084] = true, -- Glacial Fusion (Archmage Sol) (Orb)
	[426991] = true, -- Blazing Cinders (Archmage Sol)
	[428148] = true, -- Spatial Compression (Archmage Sol)
	[428834] = true, -- Verdant Eruption (Yalnu)
	[169179] = true, -- Colossal Blow (Yalnu)
	[169930] = true, -- Lumbering Swipe (Gnarled Ancient)

	-- ... add entries here
}

overrides.SpellsNoTank = {
	[382712] = false, -- Necrotic Breath, Initial (Wilted Oak)
	[382805] = false, -- Necrotic Breath, DoT (Wilted Oak)
	[226406] = false, -- Ember Swip (Emberhusk Dominator)

	[387571] = true, -- Focused Deluge (Primal Tsunami)
	[387504] = true, -- Squall Buffet (Primal Tsunami)
	[374544] = true, -- Burst of Decay (Fetid Rotsinger)
	[385833] = true, -- Bloodthirsty Charge (Rageclaw) (Knockback)
	[385834] = true, -- Bloodthirsty Charge (Rageclaw) (Dot)
	[200732] = true, -- Molten Crash (Dargrul)

	-- ... add entries here
}

overrides.Auras = {
	-- ... add entries here
}

overrides.AurasNoTank = {
	[374615] = true, -- Cheap Shot (Skulking Zealot)

	-- ... add entries here
}

overrides.MeleeHitters = {
	-- ... add entries here
}

function merge(target, override)
	for k, v in pairs(override) do
		if v == false then
			target[k] = nil
		else
			target[k] = v
		end
	end
end


for table, _ in pairs(overrides) do
	merge(ns.ehdb[table], overrides[table])
end
