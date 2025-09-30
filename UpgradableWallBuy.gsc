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
#precache("xmodel","_mc_block_beacon_green");
#precache("xmodel","_mc_block_beacon");
#precache("xmodel","_mc_block_beacon_orange");
#precache("xmodel","_mc_block_beacon_purple");
#precache("xmodel","_mc_block_beacon_red");


//fx
#define FX_GREEN "custom/wallButFxGreen"
#define FX_BLUE "custom/wallButFxBlue"
#define FX_RED "custom/wallButFxRed"
#define FX_ORANGE "custom/wallButFxOrange"
#define FX_PURPLE "custom/wallButFxPurple"
#precache("fx", FX_BLUE);
#precache("fx", FX_GREEN);
#precache("fx", FX_RED);
#precache("fx", FX_ORANGE);
#precache("fx", FX_PURPLE);
//#precache("fx", "custom/wallButFxGreen");

#namespace UpgradableWallBuy;

REGISTER_SYSTEM( "UpgradableWallBuy", &Awake, undefined)
function Awake()
{
	//SetDvar("developer", 2);
  	//SetDvar("logfile", 2);

	level.costArray = [];
	level.costArray[0] = 1000;
	level.costArray[1] = 2000;
	level.costArray[2] = 3000;
	level.costArray[3] = 10000;


	
	level.fxArray = [];
	level.fxArray[0] = FX_BLUE;
	level.fxArray[1] = FX_GREEN;
	level.fxArray[2] = FX_PURPLE;
	level.fxArray[3] = FX_ORANGE;
	level.fxArray[4] = FX_RED;

	level.modelArray = [];
	level.modelArray[0] = "_mc_block_beacon";
	level.modelArray[1] = "_mc_block_beacon_green";
	level.modelArray[2] = "_mc_block_beacon_purple";
	level.modelArray[3] = "_mc_block_beacon_orange";
	level.modelArray[4] = "_mc_block_beacon_red";
	

	
	level.rarityHints = [];
	level.rarityHints[0] = "[{+activate}] To Upgrade to ^2(Uncommon)^0 [Costs: &&1]";
	level.rarityHints[1] = "[{+activate}] To Upgrade to ^6(Rare)^0 [Costs: &&1]";
	level.rarityHints[2] = "[{+activate}] To Upgrade to ^3(Epic)^0 [Costs: &&1]";
	level.rarityHints[3] = "[{+activate}] To Upgrade to ^1(Legendary)^0 [Costs: &&1]";

	
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
	foreach(player in GetPlayers())
	{
		player.score += 10000;
	}
	
	Main();

}

function Main()
{
	zm_weapons::load_weapon_spec_from_table("gamedata\weapons\zm\zm_levelcommon_weapons.csv", 1);
}

function CustomWallBuyThink()
{
	level waittill("weaponSpawned"); //waiting until WallUpgradeThink() has spawned our weapon the first time
	linkedUpgrader = GetEnt(self.target,"targetname");
	linkedWeaponName = linkedUpgrader.script_noteworthy;
	temp = GetWeapon(linkedWeaponName);
	cost = zm_weapons::get_weapon_cost(temp);
	ammoCost = zm_weapons::get_ammo_cost(temp);
	str_localized = MakeLocalizedString(temp.displayname);
	hintStr = "Press F for " + str_localized + " [Cost : " + cost + "]";
	self SetHintString(hintStr);
	thread CustomWallBuy();
	for(;;)
	{

		if(IsDefined(GetPlayerTouchingTrigger(self)))
		{
			player = GetPlayerTouchingTrigger(self);
			linkedUpgrader = GetEnt(self.target,"targetname");
			linkedWeaponName = linkedUpgrader.script_noteworthy;
			newWeapon = GetWeapon(linkedWeaponName);
			playerHasWeapon = player zm_weapons::has_weapon_or_upgrade(newWeapon);
			ammoCost = zm_weapons::get_ammo_cost(newWeapon);
			if(playerHasWeapon)
			{
				self SetHintString("Ammo [cost: &&1 ]",ammoCost);
			}
		}
		wait 0.1;
	}
}

function CustomWallBuy()
{
	for(;;)
	{
		self waittill("trigger", player);
		linkedUpgrader = GetEnt(self.target,"targetname");
		linkedWeaponName = linkedUpgrader.script_noteworthy;
		newWeapon = GetWeapon(linkedWeaponName);

		rarity = self.script_int;
		cost = zm_weapons::get_weapon_cost(newWeapon);
		ammoCost = zm_weapons::get_ammo_cost(newWeapon);
		playerHasWeapon = player zm_weapons::has_weapon_or_upgrade(newWeapon);

		if (playerHasWeapon && player zm_score::can_player_purchase(ammoCost))
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
	}
}

function WallUpgradeThink()
{
	
	wallModel = undefined;
	fxEnt = undefined;
	beaconModel = undefined;
	linkedWallBuy = GetEnt(self.target, "targetname");
	spawnStructName = self.script_string;
	rarity = linkedWallBuy.script_int;
	
	self SetHintString(level.rarityHints[rarity], level.costArray[rarity]);
	self SetCursorHint("HINT_NOICON");

	linkedSpawnPoint = GetEnt(spawnStructName, "targetname");
	beaconSpawnPoint.origin = linkedSpawnPoint.origin;
	fxSpawnPoint.origin = linkedSpawnPoint.origin;
	


	weaponIndex = RandomInt(level.rarities[rarity].size);
	newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
	self.script_noteworthy = newWeapon.name;
	if(IsDefined(linkedSpawnPoint))
	{
		



		wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
		fxEnt = Spawn( "script_model", linkedSpawnPoint.origin );
		fxEnt.angles = linkedSpawnPoint.angles;
		fxEnt SetModel( "tag_origin" ); 
		PlayFXOnTag(level.fxArray[rarity], fxEnt, "tag_origin" );
		fxEnt MoveZ(-70, 0);
		beaconModel = util::spawn_model(level.modelArray[rarity], linkedSpawnPoint.origin + (0,0,-65), beaconSpawnPoint.angles);
		//beaconModel MoveZ(-70, 0);
	}

	
	

	cost = zm_weapons::get_weapon_cost(newWeapon);
	ammoCost = zm_weapons::get_ammo_cost(newWeapon);
	str_localized = MakeLocalizedString(newWeapon.displayname);

	
	
	level notify("weaponSpawned");
	for(;;)
	{
		//get our ents/structs
		self waittill("trigger",player);
		linkedWallBuy = GetEnt(self.target, "targetname");
		spawnStructName = self.script_string;
		linkedSpawnPoint = GetEnt(spawnStructName, "targetname");
		upgradeCost = level.costArray[rarity];
		
		
		
		if (linkedWallBuy.script_int < level.rarities.size - 1 && player zm_score::can_player_purchase(upgradeCost)) //if rarity of the linked wall buy can be upgraded try
		{

			player.score -= upgradeCost;
			linkedWallBuy.script_int++;       
			rarity = linkedWallBuy.script_int;
			
			if(IsDefined(wallModel))
			{
				wallModel Delete();
				wallModel = undefined;
			}

			if(IsDefined(fxEnt))
			{
				fxEnt Delete();
				fxEnt = undefined;
			}
			
			if(IsDefined(beaconModel))
			{
				beaconModel Delete();
				beaconModel = undefined;
			}

			if(IsDefined(linkedSpawnPoint))
			{
				beaconModel = util::spawn_model(level.modelArray[rarity], linkedSpawnPoint.origin + (0,0,-65), linkedSpawnPoint.angles);
				linkedSpawnPoint MoveZ(-20, 0.01);
				wait 0.1;
				
				fxEnt = Spawn( "script_model", linkedSpawnPoint.origin );
				fxEnt.angles = linkedSpawnPoint.angles;
				fxEnt SetModel( "tag_origin" ); 
				PlayFXOnTag(level.fxArray[rarity], fxEnt, "tag_origin" );
				fxEnt MoveZ(-50, 0);
				self SetHintString(level.rarityHints[rarity], level.costArray[rarity]);
				if (rarity == level.rarityHints.size)
				{
					self SetHintString("^1 Max Rarity");
				}
				//beaconModel MoveZ(-50, 0);
				
				wait 0.1;
				linkedSpawnPoint MoveZ(20, 2.25);
			
				for (i = 0; i < 15; i++) //slot machine animation 
				{
					
					//PlaySoundAtPosition("mc_bell", linkedSpawnPoint.origin);
					randomIndex = RandomInt(level.rarities[rarity].size);
					rollWeapon = GetWeapon(level.rarities[rarity][randomIndex]);
					tempWeaponModel = zm_utility::spawn_weapon_model( rollWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
					wait 0.15;
					tempWeaponModel Delete();
				}
				//PlaySoundAtPosition("mc_bit", linkedSpawnPoint.origin);
				//actually choose our weapon and spawn it
				weaponIndex = RandomInt(level.rarities[rarity].size);
				newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
				self.script_noteworthy = newWeapon.name;
				wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 

			}
			cost = zm_weapons::get_weapon_cost(newWeapon);
			ammoCost = zm_weapons::get_ammo_cost(newWeapon);
			str_localized = MakeLocalizedString(newWeapon.displayname);
			hintStr = "Press F for " + str_localized + " [Cost : " + cost + "]";
			//hintStr = zm_utility::get_hint_string(LinkedWallBuy, str_localized, cost );
			linkedWallBuy SetHintString(hintStr);

		}
		else
		{
			IPrintLnBold("Wallbuy already max rarity!");
		}
		

	}

	
}

/*function WallUpgrade(ent,ent)
{
//todo
	linkedWallBuy = GetEnt(self.target, "targetname");
	spawnStructName = self.script_string;
	//linkedSpawnPoint = struct::get(spawnStructName);
	linkedSpawnPoint = GetEnt(spawnStructName, "targetname");

	
	
	if (linkedWallBuy.script_int < level.rarities.size - 1) //if rarity of the linked wall buy can be upgraded try
	{

		
		linkedWallBuy.script_int++;       
		rarity = linkedWallBuy.script_int;
		
		if(IsDefined(wallModel))
		{
			wallModel Delete();
			wallModel = undefined;
		}
		if(IsDefined(linkedSpawnPoint))
		{
			linkedSpawnPoint MoveZ(-20, 0.01);
			wait 0.1;
			linkedSpawnPoint MoveZ(20, 2.25);
		
			for (i = 0; i < 15; i++) //slot machine animation 
			{
				randomIndex = RandomInt(level.rarities[rarity].size);
				rollWeapon = GetWeapon(level.rarities[rarity][randomIndex]);
				tempWeaponModel = zm_utility::spawn_weapon_model( rollWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
				wait 0.15;
				tempWeaponModel Delete();
			}
		
			//actually choose our weapon and spawn it
			weaponIndex = RandomInt(level.rarities[rarity].size);
			newWeapon = GetWeapon(level.rarities[rarity][weaponIndex]);
			self.script_noteworthy = newWeapon.name;
			wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
		}
		cost = zm_weapons::get_weapon_cost(newWeapon);
		ammoCost = zm_weapons::get_ammo_cost(newWeapon);
		str_localized = MakeLocalizedString(newWeapon.displayname);
		hintStr = "Press F for " + str_localized + " [Cost : " + cost + "]";
		//hintStr = zm_utility::get_hint_string(LinkedWallBuy, str_localized, cost );
		linkedWallBuy SetHintString(hintStr);

	}
	else
	{
		IPrintLnBold("Wallbuy already max rarity!");
	}
}*/

function GetPlayerTouchingTrigger(trigger)
{
  foreach(player in GetPlayers())
  {
    if(player IsTouching(trigger))
	{
		return player;
	}
      
  }
  return undefined;
}


