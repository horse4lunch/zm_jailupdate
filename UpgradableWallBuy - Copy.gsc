#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_score;
#precache("xmodel","_mc_block_acacia_door");

#namespace UpgradableWallBuy;

REGISTER_SYSTEM( "UpgradableWallBuy", &Awake, undefined)
function Awake()
{
	level.common = [];
	level.common[0] = "pistol_standard";
	level.common[1] = "pistol_fullauto";
	level.common[2] = "pistol_burst";
	level.common[3] = "shotgun_pump";
	level.common[4] = "pistol_revolver38";
	level.common[5] = "ar_marksman";

	level.uncommon = [];
	level.uncommon[0] = "smg_capacity";
	level.uncommon[1] = "smg_burst";
	level.uncommon[2] = "smg_standard";
	level.uncommon[3] = "smg_fastfire";
	level.uncommon[4] = "smg_versatile";
	level.uncommon[5] = "sniper_powerbolt";
	level.uncommon[6] = "sniper_fastbolt";
	level.uncommon[7] = "ar_garand";

	level.rare = [];
	level.rare[0] = "smg_sten";
	level.rare[1] = "smg_mp40";
	level.rare[2] = "smg_ppsh";
	level.rare[3] = "smg_thompson";
	level.rare[4] = "pistol_energy";
	level.rare[5] = "ar_accurate";
	level.rare[6] = "ar_damage";
	level.rare[7] = "ar_longburst";
	level.rare[8] = "sniper_fastsemi";

	level.epic = [];
	level.epic[0] = "shotgun_energy";
	level.epic[1] = "ar_standard";
	level.epic[2] = "lmg_cqb";
	level.epic[3] = "lmg_heavy";
	level.epic[4] = "lmg_light";
	level.epic[5] = "lmg_slowfire";
	level.epic[6] = "ar_peacekeeper";
	level.epic[7] = "launcher_multi";

	level.legendary = [];
	level.legendary[0] = "ray_gun";
	level.legendary[1] = "raygun_mark3";
	level.legendary[2] = "thundergun";
	level.legendary[3] = "tesla_gun";

	level.legendary[4] = "shotgun_fullauto";
	level.legendary[5] = "shotgun_precision";
	level.legendary[6] = "shotgun_semiauto";
	level.legendary[7] = "launcher_standard";
	level.legendary[8] = "zod_riotshield";
	level.legendary[9] = "hero_gravityspikes_melee";
	level.legendary[10] = "ar_famas";
	level.legendary[11] = "special_crossbow_dw";

	
	
	level.rarities = [];
	level.rarities[0] = level.common;
	level.rarities[1] = level.uncommon;
	level.rarities[2] = level.rare;
	level.rarities[3] = level.epic;
	level.rarities[4] = level.legendary;

	level.currentRaritySpawn1 = 0;
	level.weaponIndex = 0;
	customWallBuyEnts = GetEntArray("customWallBuyEnt", "script_parameters");
	wallUpgradeEnts = GetEntArray("wallUpgradeEnt", "script_parameters");
	array::thread_all(customWallBuyEnts, &CustomWallBuyThink);
	array::thread_all(wallUpgradeEnts, &WallUpgradeThink);
	
	Main();
}

function Main()
{
	
}

function CustomWallBuyThink()
{
	//self endon ("intermission");
	
	rarity = self.script_int;
	weaponIndex = RandomInt(level.rarities[rarity].size); 
	newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
	self.script_string = newWeapon.name;
			
	//target_struct = struct::get(self.target, "targetname");
	//util::spawn_model("_mc_block_acacia_door", struct.origin, struct.angles);
	//weaponHint = _zm_weapons::get_weapon_hint(newWeapon);



	cost = zm_weapons::get_weapon_cost(newWeapon);
    ammoCost = zm_weapons::get_ammo_cost(newWeapon);
	//hintStr = "Press F for " + newWeapon.displayname + " [Cost = " + cost + "]"
	//self SetHintString("Press F for " + newWeapon.displayname + " [Cost = " + cost + "]");
	self SetHintString(level.zombie_weapons[newWeapon].hint);
	self SetCursorHint("HINT_NOICON");
/*
	target_struct = struct::get(self.target, "targetname");
	for (i = 0; i < 10; i++)
	{
		randomIndex = RandomInt(level.rarities[rarity].size);
		rollWeapon = GetWeapon(level.rarities[rarity][randomIndex]);
		tempModel = zm_utility::spawn_weapon_model( rollWeapon, undefined, target_struct.origin, target_struct.angles, undefined ); 
		wait 0.2;
		tempModel Delete();
	}
	wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, target_struct.origin, target_struct.angles, undefined ); */
	for(;;)
	{
		self waittill("trigger", player);

		if (rarity != self.script_int)
		{
			
			rarity = self.script_int;
			weaponIndex = RandomInt(level.rarities[rarity].size); 
			newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);

			
			
			//struct = struct::get(self.target, "targetname");
			//util::spawn_model("_mc_block_acacia_door", struct.origin, struct.angles);
			/*
			if(isdefined(wallModel))
			{
				wallModel Delete();
				wallModel = undefined;
			}
			target_struct = struct::get(self.target, "targetname");
			for (i = 0; i < 10; i++)
			{
				randomIndex = RandomInt(level.rarities[rarity].size);
				rollWeapon = GetWeapon(level.rarities[rarity][randomIndex]);
				tempModel = zm_utility::spawn_weapon_model( rollWeapon, undefined, target_struct.origin, target_struct.angles, undefined ); 
				wait 0.2;
				tempModel Delete();
			}
			*/
			//wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, target_struct.origin, target_struct.angles, undefined ); 


			cost = zm_weapons::get_weapon_cost(newWeapon);
    		ammoCost = zm_weapons::get_ammo_cost(newWeapon);
			//hintStr = "Press F for " , newWeapon.displayname , " [Cost = " , cost , "]"
			self SetHintString(level.zombie_weapons[newWeapon].hint);
			self SetCursorHint("HINT_NOICON");
        	playerhasWeapon = player zm_weapons::has_weapon_or_upgrade(newWeapon);

			if (playerhasWeapon && player zm_score::can_player_purchase(ammoCost))
			{
				IPrintLnBold("Bought ammo");
				player zm_weapons::ammo_give(newWeapon);
				player.score -= ammoCost;
				player playsound("zmb_cha_ching");
			}
			else if(player zm_score::can_player_purchase(cost))
			{
				IPrintLnBold("Bought gun ",newWeapon.name );
				player.score -= cost;
				player zm_weapons::weapon_give(newWeapon, false, false, false, true);
				player playsound("zmb_cha_ching");

			}
		}else
		{
			newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
			
			//struct = struct::get(self.target, "targetname");
			//util::spawn_model("_mc_block_acacia_door", struct.origin, struct.angles);
			cost = zm_weapons::get_weapon_cost(newWeapon);
    		ammoCost = zm_weapons::get_ammo_cost(newWeapon);
			//hintStr = "Press F for " , newWeapon.displayname , " [Cost = " , cost , "]"
			self SetHintString(level.zombie_weapons[newWeapon].hint);
			self SetCursorHint("HINT_NOICON");
        	playerhasWeapon = player zm_weapons::has_weapon_or_upgrade(newWeapon);

			if (playerhasWeapon && player zm_score::can_player_purchase(ammoCost))
			{
				IPrintLnBold("Bought ammo");
				player zm_weapons::ammo_give(newWeapon);
				player.score -= ammoCost;
				player playsound("zmb_cha_ching");
			}
			else if(player zm_score::can_player_purchase(cost))
			{
				IPrintLnBold("Bought gun", newWeapon.name);
				player.score -= cost;
				player zm_weapons::weapon_give(newWeapon, false, false, false, true);
				player playsound("zmb_cha_ching");
			}
			 
		}
	}
}
function WallUpgradeThink()
{
	//self endon ("intermission");
	

	self SetHintString("Press &&1 for upgrade");
	self SetCursorHint("HINT_NOICON");
	wallModel = undefined;

	linkedWallBuy = GetEnt(self.target, "targetname");
	spawnStructName = self.script_string;
	linkedSpawnPoint = struct::get(spawnStructName);

	if(linkedWallBuy.script_int <= 0) // spawn a gun on start
	{
		rarity = linkedWallBuy.script_int;
		weaponIndex = RandomInt(level.rarities[rarity].size);
		newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
		self.script_noteworthy = newWeapon.name;
		wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
	}
	

	for(;;)
	{
		//get our ents/structs
		self waittill("trigger",player);
		linkedWallBuy = GetEnt(self.target, "targetname");
		spawnStructName = self.script_string;
		linkedSpawnPoint = struct::get(spawnStructName);

		rarity = linkedWallBuy.script_int;
		
		if (rarity < level.rarities.size - 1) //if rarity of the linked wall buy can be upgraded do so
		{
			
			linkedWallBuy.script_int++;       
			//rarity = linkedWallBuy.script_int;
			//weaponName = linkedWallBuy.script_string;
			
			//wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined );
			if(IsDefined(wallModel))
			{
				wallModel Delete();
				wallModel = undefined;
			}
			for (i = 0; i < 10; i++) //slot machine animation 
			{
				randomIndex = RandomInt(level.rarities[rarity].size);
				rollWeapon = GetWeapon(level.rarities[rarity][randomIndex]);
				tempModel = zm_utility::spawn_weapon_model( rollWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
				wait 0.2;
				tempModel Delete();
			}
			//actually choose our weapon and spawn it
			weaponIndex = RandomInt(level.rarities[rarity].size);
			newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
			self.script_noteworthy = newWeapon.name;
			wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
				

		}
		else
		{
			IPrintLnBold("Wallbuy already max rarity!");
		}
		

	}

	
}

/*function RandomWeaponIndex()
{
	level.weaponIndex = RandomInt(level.rarities[level.rarity].size);
	IPrintLnBold("weapon index " , level.weaponIndex);
	
}

