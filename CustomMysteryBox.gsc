#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;
#using scripts\shared\clientfield_shared;
#using scripts\shared\array_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;
#using scripts\zm\_zm_equipment;
#using scripts\shared\scene_shared;
#using scripts\shared\animation_shared;
#using scripts\zm\_zm_bgb;
//My stuff
#using scripts\McCore\HorseUtil;

//fx cache
#define OPEN_GLOW_FX "custom/fx_weapon_box_open_glow_custom"
#precache("fx", OPEN_GLOW_FX);

#define CLOSE_GLOW_FX "dlc4/genesis/fx_weapon_box_closed_glow_genesis"
#precache("fx", CLOSE_GLOW_FX);

//model cache

#define MAGIC_BOX_MODEL "minecraft_magicbox"
#precache("xmodel", MAGIC_BOX_MODEL);
#define JOKER_MODEL "p7_zm_teddybear"
#precache("xmodel", JOKER_MODEL);

//anim cache

#using_animtree("minecraft_magicbox");
#define MAGIC_BOX_OPEN "minecraft_magic_box_open"
#precache("xanim", MAGIC_BOX_OPEN);
#define MAGIC_BOX_CLOSE "minecraft_magic_box_close"
#precache("xanim", MAGIC_BOX_CLOSE);
#define MAGIC_BOX_LEAVE "minecraft_magic_box_leave"
#precache("xanim", MAGIC_BOX_LEAVE);
#define MAGIC_BOX_ENTER "minecraft_magic_box_enter"
#precache("xanim", MAGIC_BOX_ENTER);




//string cache

#define BUY_MYSTERY_WEAPON_HINT "Buy random weapon [Cost : 950]"
#precache("triggerstring", BUY_MYSTERY_WEAPON_HINT);
#define GRAB_MYSTERY_WEAPON_HINT "Press [{+activate}] for &&1"
#precache("triggerstring", GRAB_MYSTERY_WEAPON_HINT);
#define BOX_NOT_ACTIVE_HINT "Box not Active"
#precache("triggerstring", BOX_NOT_ACTIVE_HINT);
#namespace CustomMysteryBox;

REGISTER_SYSTEM("CustomMysteryBox", &Awake, undefined)
function Awake()
{
    clientfield::register( "world", "playMagicBoxAnim", VERSION_SHIP, 5, "int" );
	clientfield::register( "world", "playMagicBoxAnimVar", VERSION_SHIP, 5, "int" );
    thread PrecacheAllWeaponModels();
    mysteryBox = GetEntArray("mysteryBox","targetname");
    array::thread_all(mysteryBox,&MysteryBox);
    level.relativeOpenFxPos = (0,0,-11);
    level.relativeCloseFxPos = (0,0,-11);
    thread SpawnFireSale();
    level.MagicBoxIndex = 0;
    
   
    
}

function MysteryBox()
{
    magicboxModel = GetEnt(self.target,"targetname");
    magicboxModel UseAnimTree(#animtree);
    linkedSpawnPoint = GetEnt(self.linkto, "linkname");
    closeFxEnt = undefined;
    openFxEnt = undefined;
    self.boxActive = false;
    self.hasBoxEntered = false;
    self.spawnPointIndex = undefined;
    spawnPointArray = GetSpawnPointArray();
    for(i=0; i < spawnPointArray.size;i++)
    {
        if(self.linkto == spawnPointArray[i])
        {
            self.spawnPointIndex = i;
        }
    }
    if (self.linkto == "boxSpawnLoc0")
    {
        self.boxActive = true;
    }
    self.boxHitCount = undefined;
    for(;;)
    {
        if(!self.boxActive)
        {
            self SetHintString("");
            self SetCursorHint("HINT_NOICON");
            waitrealtime(1);
            continue;
        }
        else if(!self.hasBoxEntered) //init first box
        {
            magicboxModel AnimScripted( "enterFin", magicboxModel.origin , magicboxModel.angles, MAGIC_BOX_ENTER);
            magicboxModel waittill("enterFin");

            closeFxEnt = HorseUtil::SpawnFxHelper(level.relativeCloseFxPos,linkedSpawnPoint,CLOSE_GLOW_FX); //do fx

            self.hasBoxEntered = true;
        }
        self.maxBoxHits = 2; //todo randomize max box hits
        self SetHintString(BUY_MYSTERY_WEAPON_HINT);
        self SetCursorHint("HINT_NOICON");
        
        self waittill("trigger",player);

        if( player zm_utility::in_revive_trigger() )
		{
			wait( 0.1 );
			continue;
		}
		
		if( IS_DRINKING(player.is_drinking) )
		{
			wait( 0.1 );
			continue;
		}

		if ( IS_TRUE( self.disabled ) )
		{
			wait( 0.1 );
			continue;
		}

		if( player GetCurrentWeapon() == level.weaponNone )
		{
			wait( 0.1 );
			continue;
		}

		// firesale is in the process of removing this box
		if ( IS_TRUE( self.being_removed ) )
		{
			wait( 0.1 );
			continue;
		}

        cost = 950; //todo gumballs for cost && firesales
        
        if (player zm_score::can_player_purchase(cost)) //player bought box
        {
            player.score -= cost;
            self SetHintString("");
            self SetCursorHint("HINT_NOICON");

            if(!isdefined(self.boxHitCount))
            {
                self.boxHitCount = 0;
            }
            self.boxHitCount++;

            player playsound("zmb_cha_ching");
            //linkedSpawnPoint MoveZ(40,3.5);
            modelSpawnPoint = Spawn("script_model", linkedSpawnPoint.origin);
            modelSpawnPoint.angles = linkedSpawnPoint.angles;
            modelSpawnPoint MoveZ(40,3.5);
            HorseUtil::SafeDelete(closeFxEnt);
            magicboxModel AnimScripted( "openFin", magicboxModel.origin , magicboxModel.angles, MAGIC_BOX_OPEN);
            zm_utility::play_sound_at_pos( "open_chest", self.origin );
		    zm_utility::play_sound_at_pos( "music_chest", self.origin );

            openFxEnt = HorseUtil::SpawnFxHelper(level.relativeOpenFxPos,linkedSpawnPoint,OPEN_GLOW_FX); //do fx
            level clientfield::set( "playMagicBoxAnim", 1);
            level clientfield::set( "playMagicBoxAnimVar", self.spawnPointIndex);
            
            for (i = 0; i < 36; i++) //slot machine animation todo client
            { 
                //rollWeapon = GetNewRandomBoxWeapon(player);
                //modelSpawnPoint SetModel(rollWeapon.worldmodel);
                if( i < 20 )
                {
                    WAIT_SERVER_FRAME; 
                }
                else if( i < 30 )
                {
                    waitrealtime( 0.1 ); 
                }
                else if( i < 35 )
                {
                    waitrealtime( 0.2 ); 
                }
                else if( i < 38 )
                {
                    waitrealtime( 0.3 ); 
                }
            }
           level clientfield::set( "playMagicBoxAnim", 0);
            
            if(self.boxHitCount == self.maxBoxHits) //joker
            {
                self.boxActive = false;
                self.hasBoxEntered = false;
                self.boxHitCount = 0;
                boxArray = GetEntArray("mysteryBox", "targetname");
                newBox = undefined;
                while (!isdefined(newBox) || newBox == self)
                {
                    newBox = Array::random(boxArray);
                }
                newBox.boxActive = true;
                //todo spawn a joker model and sound
                magicboxModel AnimScripted( "leavingFin", magicboxModel.origin , magicboxModel.angles, MAGIC_BOX_LEAVE);
                //modelSpawnPoint MoveZ(-40,0.01);
                HorseUtil::SafeDelete(openFxEnt);
                wait(.25);
                HorseUtil::SafeDelete(modelSpawnPoint);
                continue;
            }

            //modelSpawnPoint MoveZ(-40,0.01);//actually choose weapon
            newWeapon = GetNewRandomBoxWeapon(player);
            //newWeaponModel = zm_utility::spawn_weapon_model( newWeapon, undefined, linkedSpawnPoint.origin, linkedSpawnPoint.angles, undefined );
            modelSpawnPoint SetModel(newWeapon.worldmodel); 
            localizedWeaponName = MakeLocalizedString(newWeapon.displayname);
            self SetHintString(GRAB_MYSTERY_WEAPON_HINT, localizedWeaponName);
            self SetCursorHint("HINT_NOICON");

            self thread GiveBoxWeapon(player,newWeapon);//wait for player to get weapon || timeout
            self thread WeaponLowerAnimation(modelSpawnPoint);
            self waittill("weaponTaken");
            
            HorseUtil::SafeDelete(openFxEnt);
            HorseUtil::SafeDelete(modelSpawnPoint);
            magicboxModel AnimScripted( "closeFin", magicboxModel.origin , magicboxModel.angles, MAGIC_BOX_CLOSE);
            
            closeFxEnt = HorseUtil::SpawnFxHelper(level.relativeCloseFxPos,linkedSpawnPoint,CLOSE_GLOW_FX); //do fx

        }

    }


}
function SpawnChest()
{

}
function GetNewRandomBoxWeapon(player)//get a random box weapon the player doesnt already have
{
    weapons = player GetWeaponsList( true );
    boxWeaponArray = GetBoxWeaponArray();

    availableWeaponArray = [];

    for (i = 0; i < boxWeaponArray.size; i++)
    {
        boxWeapon = boxWeaponArray[i];
        hasWeapon = false;

        for (e = 0; e < weapons.size; e++)
        {
            playerweapon = weapons[e];
            if (playerweapon.rootWeapon.name == boxWeapon)
            {
                hasWeapon = true;
                break;
            }
        }

        if(!hasWeapon)
        {
            availableWeaponArray[availableWeaponArray.size] = boxWeapon;
        }
    }
    randomIndex = RandomInt(availableWeaponArray.size);
    boxWeapon = GetWeapon(availableWeaponArray[randomIndex]);
    return boxWeapon;
    
}

function GiveBoxWeapon(orginalPlayer,weapon) //give weapon to player
{
    self endon("weaponTaken");
    for(;;)
    {
        self waittill("trigger", player);
        current_weapon = player GetCurrentWeapon();
        if (player == orginalPlayer&& 
            zm_utility::is_player_valid( player ) && 
            !IS_DRINKING(player.is_drinking) && 
            !zm_utility::is_placeable_mine( current_weapon ) && 
            !zm_equipment::is_equipment( current_weapon ) && 
            !player zm_utility::is_player_revive_tool(current_weapon) && 
            !current_weapon.isheroweapon &&
            !current_weapon.isgadget )
        {
            player zm_weapons::weapon_give(weapon, false, false, false, true);
            self notify("weaponTaken"); 
            break;
        }
    }
}

function WeaponLowerAnimation(spawnPoint) //lower weapon back into box 
{
    //todo maybe move to client
    self endon("weaponTaken");
    waitrealtime(.75);
    spawnPoint MoveZ(-40,6.25);
    waitrealtime(4.25);
    self notify("weaponTaken");
}

function GetBoxWeaponArray() //helper func to get the zombie weapon array
{
    weaponArray = [];

    keys = GetArrayKeys( level.zombie_weapons );
    for( i=0; i < keys.size; i++ )
    {
        name = keys[i].rootWeapon.name;
        weapon = GetWeapon((name));
        if(zm_weapons::get_is_in_box(weapon))
        {
            weaponArray[weaponArray.size] = name;
        }
    }
    return weaponArray;
}
/*
function SpawnFxHelper(relativePos,spawnPoint,fx) //helper func for spawning fx
{
    if (!isdefined(relativePos))
    {
        relativePos = (0, 0, 0);
    }
        
    fxEnt = Spawn( "script_model", spawnPoint.origin + relativePos); 
    fxEnt.angles = spawnPoint.angles;
	fxEnt SetModel( "tag_origin" ); 
    PlayFXOnTag(fx, fxEnt, "tag_origin" );

    return fxEnt;
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
*/

function PrecacheAllWeaponModels() //maybe works idk I cba to figure out all the model names
{
    for(;;)
    {
        if (!isdefined(level.zombie_weapons))
        {
            wait(0.1);
            continue;
        }
        keys = GetArrayKeys( level.zombie_weapons );
        for( i=0; i < keys.size; i++ )
        {
            name = keys[i].rootWeapon.name;
            weapon = GetWeapon((name));
            if(zm_weapons::get_is_in_box(weapon))
            {
                ent = Spawn("script_model", (0,0,20));
                ent SetModel(weapon.worldmodel);
                HorseUtil::SafeDelete(ent);
            }
        }
        break;
    }
}

function TreasureChestFiresaleActive()
{
	return IS_TRUE( level.zombie_vars["zombie_powerup_fire_sale_on"] ); 
}



function SpawnFireSale() //Remove this
{
    trig = GetEnt("firesale","targetname");
    for(;;)
    {
        trig SetHintString("Give gobble gum");
        trig waittill("trigger", player);
        player bgb::give("zm_bgb_reign_drops");
    }
}

function GetSpawnPointArray()
{
    spawnArray = [];
    spawnArray[0] = "boxSpawnLoc0";
    spawnArray[1] = "boxSpawnLoc1";
    spawnArray[2] = "boxSpawnLoc2";
    spawnArray[3] = "boxSpawnLoc3";
    spawnArray[4] = "boxSpawnLoc4";
    spawnArray[5] = "boxSpawnLoc5";
    spawnArray[6] = "boxSpawnLoc6";
    spawnArray[7] = "boxSpawnLoc7";
    spawnArray[8] = "boxSpawnLoc8";
    spawnArray[9] = "boxSpawnLoc9";
    spawnArray[10] = "boxSpawnLoc10";

    return spawnArray;
}


