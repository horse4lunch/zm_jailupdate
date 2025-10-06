#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#using scripts\shared\array_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_score;

#namespace UpgradableWallBuy;

REGISTER_SYSTEM( "UpgradableWallBuy", &Awake, undefined)
function Awake()
{
	clientfield::register( "world", "playAnim", VERSION_SHIP, 5, "int", &PlayAnim, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "playAnimVar", VERSION_SHIP, 5, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	wait 1;

	level.spawnArray = [];
	level.spawnArray[0] = "spawnLoc0";
	level.spawnArray[1] = "spawnLoc1";

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
}



function PlayAnim( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	index = clientfield::get("playAnimVar");
	linkedSpawnPoint = GetEnt(localClientNum,level.spawnArray[index],"targetname");
	
		if(newVal > 0)
		{
			
			linkedSpawnPoint MoveTo(linkedSpawnPoint.origin + (0,0,-20), 0.01);
			waitrealtime (0.1);
			linkedSpawnPoint MoveTo(linkedSpawnPoint.origin + (0,0,20), 2);
			for (i = 0; i < 20; i++) //slot machine animation 
			{
				randomIndex = RandomInt(level.rarityArray[newVal].size);
				
				rollWeapon = GetWeapon(level.rarityArray[newVal][randomIndex]);
				tempWeaponModel = zm_utility::spawn_weapon_model( localClientNum, rollWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined ); 
				waitrealtime (0.1);
				
				tempWeaponModel Delete();
				
				
			}
		}
		
	
}

