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

//string cache
#precache("triggerstring","[{+activate}] To Upgrade to ^2(Uncommon)^0 [Costs: &&1]");
#precache("triggerstring","[{+activate}] To Upgrade to ^6(Rare)^0 [Costs: &&1]");
#precache("triggerstring","[{+activate}] To Upgrade to ^3(Epic)^0 [Costs: &&1]");
#precache("triggerstring","[{+activate}] To Upgrade to ^1(Legendary)^0 [Costs: &&1]");

#define BUY_WEAPON_HINT "Press [{+activate}] for &&1 [Cost : &&2 ]"
#precache("triggerstring", BUY_WEAPON_HINT);

#define BUY_AMMO_HINT "Ammo cost: &&1"
#precache("triggerstring", BUY_AMMO_HINT);

#define MAX_RARITY_HINT "^1 Max Rarity"
#precache("triggerstring", MAX_RARITY_HINT);




#namespace UpgradableWallBuy;

REGISTER_SYSTEM( "UpgradableWallBuy", &Awake, undefined)
function Awake()
{
	clientfield::register( "world", "playAnim", VERSION_SHIP, 5, "int" );
	clientfield::register( "world", "playAnimVar", VERSION_SHIP, 5, "int" );

	level.spawnArray = [];
	level.spawnArray[0] = "spawnLoc0";
	level.spawnArray[1] = "spawnLoc1";
	
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
	
	level.rarityHintArray = [];
	level.rarityHintArray[0] = "[{+activate}] To Upgrade to ^2(Uncommon)^0 [Costs: &&1]";
	level.rarityHintArray[1] = "[{+activate}] To Upgrade to ^6(Rare)^0 [Costs: &&1]";
	level.rarityHintArray[2] = "[{+activate}] To Upgrade to ^3(Epic)^0 [Costs: &&1]";
	level.rarityHintArray[3] = "[{+activate}] To Upgrade to ^1(Legendary)^0 [Costs: &&1]";

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
	
	level.rarityArray = [];
	level.rarityArray[0] = level.common;
	level.rarityArray[1] = level.uncommon;
	level.rarityArray[2] = level.rare;
	level.rarityArray[3] = level.epic;
	level.rarityArray[4] = level.legendary;

	customWallBuyEnts = GetEntArray("customWallBuyEnt", "script_parameters");
	wallUpgradeEnts = GetEntArray("wallUpgradeEnt", "script_parameters");

	level.relativeBeaconPos = (0,0,-65);
	level.relativeFxPos = (0,0,-35);

	array::thread_all(customWallBuyEnts, &CustomWallBuyInit);
	array::thread_all(wallUpgradeEnts, &WallUpgradeInit);
	Main();

}

function Main()
{
	
}

function CustomWallBuyInit()
{
	linkedUpgrader = GetEnt(self.target,"targetname");
	linkedUpgrader waittill("weaponSpawned"); //waiting until WallUpgradeThink() has chosen our weapon the first time

	linkedWeaponName = linkedUpgrader.script_noteworthy; //Spawning our intial weapon
	tempWeapon = GetWeapon(linkedWeaponName);
	cost = zm_weapons::get_weapon_cost(tempWeapon);
	
	tempLocalizedWeaponName = MakeLocalizedString(tempWeapon.displayname);	//setting intial hint string
	self SetHintString(BUY_WEAPON_HINT, tempLocalizedWeaponName, cost );
	self SetCursorHint("HINT_NOICON");
	
	thread CustomWallBuy();
	
	for(;;) //checking if the player already has the current wall weapon if so change the hint string to reflect that
	{

		if(IsDefined(GetPlayerTouchingTrigger(self)))
		{
			player = GetPlayerTouchingTrigger(self);
			linkedWeaponName = linkedUpgrader.script_noteworthy;
			newWeapon = GetWeapon(linkedWeaponName);
			playerHasWeapon = player zm_weapons::has_weapon_or_upgrade(newWeapon);
			ammoCost = zm_weapons::get_ammo_cost(newWeapon);
			if(playerHasWeapon)
			{
				self SetHintString(BUY_AMMO_HINT, ammocost);
				
			}
		}
		wait 0.1;
	}
	
}

function CustomWallBuy()
{
	linkedUpgrader = GetEnt(self.target,"targetname");

	for(;;)
	{
		self waittill("trigger", player);
		linkedWeaponName = linkedUpgrader.script_noteworthy;
		newWeapon = GetWeapon(linkedWeaponName);

		rarity = self.script_int;
		cost = zm_weapons::get_weapon_cost(newWeapon);
		ammoCost = zm_weapons::get_ammo_cost(newWeapon);
		playerHasWeapon = player zm_weapons::has_weapon_or_upgrade(newWeapon);

		if (playerHasWeapon && player zm_score::can_player_purchase(ammoCost)) //If player has the current weapon get ammo instead
		{
			player zm_weapons::ammo_give(newWeapon);
			player.score -= ammoCost;
			player playsound("zmb_cha_ching");
		}
		else if(player zm_score::can_player_purchase(cost)) //purchase new weapon
		{
			player.score -= cost;
			player zm_weapons::weapon_give(newWeapon, false, false, false, true);
			player playsound("zmb_cha_ching");

		}
	}
}

function WallUpgradeInit()
{
	
	linkedWallBuy = GetEnt(self.target, "targetname");
	spawnPointNameStr = self.script_string;
	rarity = linkedWallBuy.script_int;
	
	self SetHintString(level.rarityHintArray[rarity], level.costArray[rarity]);
	self SetCursorHint("HINT_NOICON");

	linkedSpawnPoint = GetEnt(spawnPointNameStr, "targetname");

	weaponIndex = RandomInt(level.rarityArray[rarity].size);
	newWeapon = GetWeapon(level.rarityArray[rarity][weaponIndex]);
	self.script_noteworthy = newWeapon.name;
	if(IsDefined(linkedSpawnPoint))
	{
		beaconModel = util::spawn_model(level.modelArray[rarity], linkedSpawnPoint.origin + level.relativeBeaconPos, linkedSpawnPoint.angles);

		wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
		fxEnt = Spawn( "script_model", linkedSpawnPoint.origin + level.relativeFxPos);
		fxEnt.angles = linkedSpawnPoint.angles;
		fxEnt SetModel( "tag_origin" ); 
		PlayFXOnTag(level.fxArray[rarity], fxEnt, "tag_origin" );
	}

	self notify("weaponSpawned");
	WallUpgrade(wallModel, fxEnt, beaconModel);

	
}

function WallUpgrade(wallModel, fxEnt, beaconModel)
{
	linkedWallBuy = GetEnt(self.target, "targetname");
	linkedSpawnPoint = GetEnt(self.script_string, "targetname");
	

	for (i = 0; i < level.spawnArray.size; i++)
	{
		if (self.script_string == level.spawnArray[i])
		{
			linkedSpawnPointIndex = i;
			break; //todo why tf is this here?
		}
	}

	for(;;)
	{
		self waittill("trigger",player);
		rarity = linkedWallBuy.script_int;
		upgradeCost = level.costArray[rarity];
		
		
		
		if (linkedWallBuy.script_int < level.rarityArray.size - 1 && player zm_score::can_player_purchase(upgradeCost)) //if rarity of the linked wall buy can be upgraded try
		{

			player.score -= upgradeCost;
			player playsound("zmb_cha_ching");
			linkedWallBuy.script_int++;       
			rarity = linkedWallBuy.script_int;
			
			wallModel = SafeDelete(wallModel); //check if old models and fx already exist if so delete them and set to undefined
			fxEnt = SafeDelete(fxEnt);
			beaconModel = SafeDelete(beaconModel);

			if(IsDefined(linkedSpawnPoint))
			{
				beaconModel = util::spawn_model(level.modelArray[rarity], linkedSpawnPoint.origin + level.relativeBeaconPos, linkedSpawnPoint.angles); //change box model
				
				fxEnt = Spawn( "script_model", linkedSpawnPoint.origin + level.relativeFxPos); //change fx model
				fxEnt.angles = linkedSpawnPoint.angles;
				fxEnt SetModel( "tag_origin" ); 
				PlayFXOnTag(level.fxArray[rarity], fxEnt, "tag_origin" );

				//linkedSpawnPoint MoveZ(-20, 0.01);	
				//wait 0.1;
				
				//linkedSpawnPoint MoveZ(20, 2.25);
				
				level clientfield::set( "playAnim", rarity);
				level clientfield::set( "playAnimVar", linkedSpawnPointIndex);
				waitrealtime (2.25);
				/*for (i = 0; i < 15; i++) //slot machine animation 
				{
					randomIndex = RandomInt(level.rarityArray[rarity].size);
					rollWeapon = GetWeapon(level.rarityArray[rarity][randomIndex]);
					tempWeaponModel = zm_utility::spawn_weapon_model( rollWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
					wait 0.15;
					tempWeaponModel Delete();
				}*/
				//actually choose our weapon and spawn it
				weaponIndex = RandomInt(level.rarityArray[rarity].size);
				newWeapon = GetWeapon(level.rarityArray[rarity][weaponIndex]);
				self.script_noteworthy = newWeapon.name;
				wallModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 

			}

			cost = zm_weapons::get_weapon_cost(newWeapon);
			localizedWeaponName = MakeLocalizedString(newWeapon.displayname);
			linkedWallBuy SetHintString(BUY_WEAPON_HINT, localizedWeaponName, cost); //Set linked hint string
			linkedWallBuy SetCursorHint("HINT_NOICON");
			
			self SetHintString(level.rarityHintArray[rarity], level.costArray[rarity]);	//Set upgrade lever Hint string
			if (rarity == level.rarityHintArray.size)	
			{
				self SetHintString(MAX_RARITY_HINT);
			}
		}
		else 
		{
			player.score += 100000;
			//todo maybe play a sound if player cant afford to upgrade
		}
	}
}

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

function SafeDelete(ref)
{
	if (IsDefined(ref))
    {
        ref Delete();
        ref = undefined;
    }
    return ref;
}