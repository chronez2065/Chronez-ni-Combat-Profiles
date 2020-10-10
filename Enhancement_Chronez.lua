local enemies = { };
local function ActiveEnemies()
	table.wipe(enemies);
	enemies = ni.unit.enemiesinrange("target", 20);
	for k, v in ipairs(enemies) do
		if ni.player.threat(v.guid) == -1 then
			table.remove(enemies, k);
		end
	end
	return #enemies;
end

local items = {
	settingsfile = "Enhancement_Chronez.xml",
	{ type = "title", text = "Enhancement by |c0000CED1Chronez" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Main Settings" },
	{ type = "separator" },
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Offensive Settings" },
	{ type = "separator" },
	{ type = "entry", text = "\124T"..select(3, GetSpellInfo(66842))..":26:26\124t Totems (Auto)", tooltip = "Place Totems Automatic", enabled = true, key = "totempull" },
	{ type = "entry", text = "\124T"..select(3, GetSpellInfo(1535))..":26:26\124t Fire Nova AOE", tooltip = "Use Fire Nova AOE", enabled = true, key = "firenova" },	
	{ type = "separator" },
	{ type = "title", text = "|cffFFFF00Defensiv Settings" },
	{ type = "separator" },
	{ type = "entry", text = "\124T"..select(3, GetSpellInfo(8004))..":26:26\124t Healing Surge", tooltip = "When ON - Use Healing Surge on < HP %", enabled = false, value = 25, key = "hs" },
	
};   

local function GetSetting(name)
    for k, v in ipairs(items) do
        if v.type == "entry"
         and v.key ~= nil
         and v.key == name then
            return v.value, v.enabled
        end
        if v.type == "dropdown"
         and v.key ~= nil
         and v.key == name then
            for k2, v2 in pairs(v.menu) do
                if v2.selected then
                    return v2.value
                end
            end
        end
        if v.type == "input"
         and v.key ~= nil
         and v.key == name then
            return v.value
        end
    end
end;	
local function OnLoad()
	ni.GUI.AddFrame("Enhancement_Chronez", items);
end
local function OnUnLoad()  
	ni.GUI.DestroyFrame("Enhancement_Chronez");
end

local queue = { 
"check",
"WeaponEnchant",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Lightning shield",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Totems pull",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Unleash Elements",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Flame Shock",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Lava Lash",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Stormstrike",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",
-----------------------------
"Earth Shock",
"Fire Nova",
"Maelstrom Weapon",
"Maelstrom Weapon AOE",


}

local shield = GetSpellInfo(324);
local LightningBolt =GetSpellInfo(403);
local ChainLightning = GetSpellInfo(421);
local FlameShock = GetSpellInfo(8050);
local EarthShock = GetSpellInfo(8042);
local LavaLash = GetSpellInfo(60103);
local Stormstrike = GetSpellInfo(32175);
local SearingTotem = GetSpellInfo(3599);
local WindfuryWeapon = GetSpellInfo(8232);
local FlametongueWeapon = GetSpellInfo(8024);
local HealingSurge = GetSpellInfo(8004);
local callofelements = GetSpellInfo(66842); 
local FireNova = GetSpellInfo(1535);
local FeralSpirit = GetSpellInfo(51533);
local GhostWolf = GetSpellInfo(2645);
local UnleashElements = GetSpellInfo(73680)

local check = {
	mounted = false,
	coc = false,
	dog = false,
	combat = false,
};

local abilities = { 
    
    ["check"] = function()
		check.mounted = IsMounted() or false;
		check.coc = UnitCastingInfo("player") or UnitChannelInfo("player") or false;
		check.dog = UnitIsDeadOrGhost("player") or false;
		check.combat = UnitAffectingCombat("player") or false;
	end,
	["Ghost Wolf"] = function()
		local enabled = GetSetting("agw");
        if enabled
		and not ni.player.buff(GhostWolf) 
		and not check.mounted
		and not check.combat
		and ni.spell.available(GhostWolf)then
            ni.spell.cast(GhostWolf);
            return true;
        end
    end,
	["WeaponEnchant"] = function()
	local mh, _, _, oh = GetWeaponEnchantInfo()
	if mh == nil 
		and not check.mounted then
        ni.spell.cast(WindfuryWeapon)
        return true
        end
	if oh == nil 
	   and not check.mounted then
       ni.spell.cast(FlametongueWeapon)
       return true
       end
	end,
    ["Lightning shield"] = function()
        if not ni.player.buff(shield)
         and not check.mounted
         and ni.spell.available(shield) then
            ni.spell.cast(shield);
            return true;
        end
    end,
	["Maelstrom Weapon"] = function()
    local value, enabled = GetSetting("hs");
	if ni.unit.buffstacks("player", 51530) == 5
	and ActiveEnemies() < 2
    and ni.player.hp() > value
	and check.combat
    and not check.mounted
    and ni.spell.available(LightningBolt) then
			ni.spell.cast(LightningBolt, "target")
			return true
	elseif ni.unit.buffstacks("player", 51530) <= 5
	and ni.player.hp() <= value
	and enabled
	and check.combat
    and not check.mounted
	and ni.spell.available(HealingSurge) then
			ni.spell.cast(HealingSurge)
			return true
		end
	end,
	["Maelstrom Weapon AOE"] = function()
	local value, enabled = GetSetting("hs");
	if ni.unit.buffstacks("player", 51530) == 5
	and ActiveEnemies() >= 2
    and ni.player.hp() > value
	and check.combat
    and not check.mounted
    and ni.spell.available(ChainLightning) then
			ni.spell.cast(ChainLightning, "target")
			return true
	elseif ni.unit.buffstacks("player", 51530) <= 5
	and enabled
	and ni.player.hp() <= value
	and check.combat
    and not check.mounted
	and ni.spell.available(HealingSurge) then
			ni.spell.cast(HealingSurge)
			return true
        end
    end,

	["Flame Shock"] = function()
		if ni.unit.debuffremaining("target", FlameShock, "player") < 2
		and check.combat
		and not check.mounted
		and ni.spell.available(FlameShock)
		 and ni.spell.valid("target", FlameShock, true, true) then
			ni.spell.cast(FlameShock, "target")
			return true
		end
	end,
	["Earth Shock"] = function()
		if ni.unit.debuffremaining("target", FlameShock, "player") >= 6
		and check.combat
		and not check.mounted
		and ni.spell.available(EarthShock)
		 and ni.spell.valid("target", EarthShock, true, true) then
			ni.spell.cast(EarthShock, "target")
			return true
		end
	end,
	["Lava Lash"] = function()
		if ni.spell.available(LavaLash)
		and check.combat
		and not check.mounted
		and ni.spell.valid("target", LavaLash, true, true) then
			ni.spell.cast(LavaLash, "target")
			return true
		end
	end,
    ["Stormstrike"] = function()
		if ni.spell.available(Stormstrike)
		and check.combat
		and not check.mounted
		and ni.spell.valid("target", Stormstrike, true, true) then
			ni.spell.cast(Stormstrike, "target")
			return true
		end
	end,
    ["Searing Totem"] = function()
    end,
	["Totems pull"] = function()
		local _, enabled = GetSetting("totempull")
		if enabled
		 and check.combat
		 and not check.mounted
		 and not tContains(UnitName("target"), ni.IgnoreUnits) then
		 local earthTotem = select(2, GetTotemInfo(2))
		 local totem_distance = ni.unit.distance("target", "totem1")
		 local target_distance = ni.player.distance("target")
		 if	(earthTotem == ""
		 or (earthTotem ~= ""
		 and check.combat
		 and not check.mounted
		 and target_distance ~= nil
		 and target_distance < 6
		 and totem_distance ~= nil
		 and totem_distance > 20))
		 and not ni.player.ismoving() then
			ni.spell.cast(callofelements)
			return true
			end
		end
	end,
	["Fire Nova"] = function()
		local enabled = GetSetting("firenova");
		if ni.spell.available(FireNova) 
		and UnitCanAttack("player", "target") then
		 table.wipe(enemies);
		 enemies = ni.unit.enemiesinrange("player", 25)
		 local FireNovaTrue = false
		  for i = 1, #enemies do
		   local tar = enemies[i].guid; 
		    if ni.unit.debuff(tar, FireNova, "player") then
				FireNovaTrue = true
			end
		end 
		if ActiveEnemies() >= 2
		and ni.unit.debuff("target", FlameShock, "player") or FireNovaTrue
		and ni.spell.available(FireNova)
		and check.combat
		and not check.mounted then
			ni.spell.cast(FireNova, "target")
			return true
			end
		end
	end,
	["Unleash Elements"] = function()
		if ni.spell.available(UnleashElements)
		and check.combat
		and not check.mounted
		and ni.spell.valid("target", LavaLash, true, true) then
			ni.spell.cast(UnleashElements, "target")
			return true
		end
	end,


        
 
}
ni.bootstrap.profile("Enhancement_Chronez", queue, abilities, OnLoad, OnUnLoad);

