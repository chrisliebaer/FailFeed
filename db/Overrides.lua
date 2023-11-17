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
	[169930] = true, -- Lumbering Swipe (Gnarled Ancient)

	[255372] = true, -- Tail (Rezan)
	[255373] = true, -- Tail (Rezan)

	-- actually always hits tank?
	[198376] = false, -- Primal Rampage (Archdruid Glaidalis)
	[198386] = false, -- Primal Rampage (Archdruid Glaidalis)

	[191326] = true, -- Breath of Corruption (Dresaron)
	[199460] = true, -- Falling Rocks (Dresaron)
	[200329] = true, -- Overwhelming Terror (Shade of Xavius)
	[200111] = true, -- Apocalyptic Fire (Shade of Xavius)

	[194960] = true, -- Soul Echos (Lord Etheldrin Ravencrest)

	[194956] = true, -- Reap Soul (Amalgam of Souls)
	[200261] = true, -- Bonebreaking Strike (Soul-Torn Champion)
	[200344] = true, -- Arrow Barrage (Risen Archer) (Channel)
	[197974] = true, -- Bonecrushing Strike (Illysanna Ravencrest) (Add)
	[201175] = true, -- Throw Priceless Artifact (Wyrmtongue Scavenger)
	[214002] = true, -- Raven's Dive (Risen Lancer)


	[426727] = true, -- Acid Barrage (Naz'jar Ravager)
	[426645] = true, -- Acid Barrage (Naz'jar Ravager)
	[426688] = true, -- Volatile Acid (Naz'jar Ravager)
	[427769] = true, -- Geyser (Lady Naz'jar)
	[428294] = true, -- Trident Flurry (Honor Guard)

	[427672] = true, -- Bubbling Fissure (Commander Ulthok) (Initial)
	[427565] = true, -- Bubbling Fissure (Commander Ulthok) (AoE)
	[427559] = true, -- Bubbling Ooze (Commander Ulthok) (Moving AoE)
	[426681] = true, -- Electric Jaws (Electrified Behemoth)
	[76590] = true, -- Shadow Smash (Faceless Watcher)
	[426808] = true, -- Null Blast (Faceless Seer)
	[429172] = true, -- Terrifying Vision (Erunak Stonespeaker)
	

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

	[198386] = true, -- Primal Rampage (Archdruid Glaidalis)
	[198376] = true, -- Primal Rampage (Archdruid Glaidalis)
	[204667] = true, -- Nightmare Breath (Oakheart)

	[428530] = true, -- Murk Spew (Ink of Ozumat)
	[428616] = true, -- Deluge of Filth (Ozumat)


	-- ... add entries here
}

overrides.Auras = {
	-- ... add entries here

	[200273] = true, -- Cowardice (Shade of Xavious)

	[194960] = true, -- Soul Echos (Lord Etheldrin Ravencrest)
	[199097] = true, -- Cloud of Hypnosis (Dantalionax)
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
