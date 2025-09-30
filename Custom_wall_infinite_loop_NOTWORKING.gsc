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


#namespace test;

REGISTER_SYSTEM( "test", &Main, undefined)
function Main()
{
	level.player1 = level.player;
	thread CustomWallBuy();
	thread RarityLevel();
	//level.rarity = 0;
	
}

function CustomWallBuy()
{
	level endon( "intermission" );
	lever = GetEnt("lever","targetname");
    lever SetHintString("Press &&1 For Weap Press [{+melee}] to upgrade");
    lever SetCursorHint("HINT_NOICON");
	rarity = 0;

	common = [];
	common[0] = "pistol_standard";
	common[1] = "pistol_fullauto";
	common[2] = "pistol_burst";
	common[3] = "shotgun_pump";
	common[4] = "pistol_revolver38";
	common[5] = "ar_marksman";

	uncommon = [];
	uncommon[0] = "smg_capacity";
	uncommon[1] = "smg_burst";
	uncommon[2] = "smg_standard";
	uncommon[3] = "smg_fastfire";
	uncommon[4] = "smg_versatile";
	uncommon[5] = "sniper_powerbolt";
	uncommon[6] = "sniper_fastbolt";
	uncommon[7] = "ar_garand";

	rare = [];
	rare[0] = "smg_sten";
	rare[1] = "smg_mp40";
	rare[2] = "smg_ppsh";
	rare[3] = "smg_thompson";
	rare[4] = "pistol_energy";
	rare[5] = "ar_accurate";
	rare[6] = "ar_damage";
	rare[7] = "ar_longburst";
	rare[8] = "sniper_fastsemi";

	epic = [];
	epic[0] = "shotgun_energy";
	epic[1] = "ar_standard";
	epic[2] = "lmg_cqb";
	epic[3] = "lmg_heavy";
	epic[4] = "lmg_light";
	epic[5] = "lmg_slowfire";
	epic[6] = "ar_peacekeeper";
	epic[7] = "launcher_multi";

	legendary = [];
	legendary[0] = "ray_gun";
	legendary[1] = "raygun_mark3";
	legendary[2] = "thundergun";
	legendary[3] = "tesla_gun";


	rarities = [];
	rarities[0] = common;
	rarities[1] = uncommon;
	rarities[2] = rare;
	rarities[3] = epic;
	rarities[4] = legendary;
	for(;;)
	{
		WAIT_SERVER_FRAME;
		if(level.player1 IsTouching(lever))
		{
			IPrintLnBold("touching trigger");
			if (level.player1 meleebuttonpressed())
			{
				rarity++;
				IPrintLnBold("Rarity increased to " + level.rarity);
				wait 0.1;

			}
			else if (level.player1 UseButtonPressed())
			{
				IPrintLnBold("current rarity level " + rarity);
				cost = 1000;
				ammoCost = 500;
				randomCount = rarities[rarity].size;
				fixedRandomCount = randomCount + 1;
				newWeapon = GetWeapon(rarities[rarity][RandomInt(fixedRandomCount)]);
				playerHasWeapon = level.player1 zm_weapons::has_weapon_or_upgrade( newWeapon ); 
				IPrintLnBold("current rarity level after check " + rarity);
				if (playerHasWeapon && level.player1 zm_score::can_player_purchase(ammoCost))
				{
					IPrintLnBold("Bought ammo");
					level.player1 zm_weapons::ammo_give(newWeapon);
					level.player1.score -= ammoCost;
					level.player1 playsound("zmb_cha_ching");
					wait 0.1;
				}
				else if(level.player1 zm_score::can_player_purchase(cost))
				{
					IPrintLnBold("Bought gun");
					level.player1.score -= cost;
					level.player1 zm_weapons::weapon_give(newWeapon, false, false, false, true);
					level.player1 playsound("zmb_cha_ching");
					wait 0.1;
				}
				wait 0.1;
			}
		}
	
		/*for(;;)
		{
			lever waittill("trigger", player);
			IPrintLnBold("current rarity level " + level.rarity);
			cost = 1000;
			ammoCost = 500;
			randomCount = rarities[level.rarity].size;
			fixedRandomCount = randomCount + 1;
			newWeapon = GetWeapon(rarities[level.rarity][RandomInt(fixedRandomCount)]);
			playerHasWeapon = player zm_weapons::has_weapon_or_upgrade( newWeapon ); 
			IPrintLnBold("current rarity level after check " + level.rarity);
			if (playerHasWeapon && player zm_score::can_player_purchase(ammoCost))
			{
				IPrintLnBold("Bought ammo");
				player zm_weapons::ammo_give(newWeapon);
				player.score -= ammoCost;
				player playsound("zmb_cha_ching");
			}
			else if(player zm_score::can_player_purchase(cost))
			{
				IPrintLnBold("Bought gun");
				player.score -= cost;
				player zm_weapons::weapon_give(newWeapon, false, false, false, true);
				player playsound("zmb_cha_ching");
			}
			
		}*/
	}
}
function RarityLevel()
{
	level endon( "intermission" );

	lever1 = GetEnt("lever1","targetname");
    lever1 SetHintString("Press &&1");
    lever1 SetCursorHint("HINT_NOICON");
	for(;;)
	{
		lever1 waittill("trigger", player);
		player.score += 100000;
		//level.rarity++;
		//IPrintLnBold("Rarity increased to " + level.rarity);
	}

	/*while (1)
	{
		flag = self util::waittill_any_return("jail_flag_test", "update");

		switch(flag)
		{
			case "jail_flag_test":
				{
					rarity++;
					return rarity;
					IPrintLnBold("Increment Rarity");
				}
				break;
			case "update":
				{
					return rarity;
				}
				break;
			default:
			break;
			
		}
		
	}*/
	
}

