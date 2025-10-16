#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\math_shared;

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
#using scripts\zm\_zm_unitrigger;
#insert scripts\zm\_zm_powerups.gsh;
//My stuff
#using scripts\McCore\HorseUtil;

#precache( "triggerstring", "ZOMBIE_TRADE_WEAPON_FILL" );

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
#define FIRESALE_BUY_MYSTERY_WEAPON_HINT "Buy random weapon [Cost : 10]"
#precache("triggerstring", FIRESALE_BUY_MYSTERY_WEAPON_HINT);
#define GRAB_MYSTERY_WEAPON_HINT "Press [{+activate}] for &&1"
#precache("triggerstring", GRAB_MYSTERY_WEAPON_HINT);
#define BOX_NOT_ACTIVE_HINT "Box not Active"
#precache("triggerstring", BOX_NOT_ACTIVE_HINT);
#namespace CustomMysteryBox;


//gobble gums respin cycle, unbearable
REGISTER_SYSTEM("CustomMysteryBox", &Awake, undefined)
function Awake()
{
    clientfield::register( "world", "playMagicBoxAnim", VERSION_SHIP, 5, "int" );
	clientfield::register( "world", "playMagicBoxAnimVar", VERSION_SHIP, 5, "int" );
    thread PrecacheAllWeaponModels();
    level.mysteryBoxArray = GetEntArray("mysteryBox","targetname");
    array::thread_all(level.mysteryBoxArray,&MysteryBox);
    level.relativeOpenFxPos = (0,0,-11);
    level.relativeCloseFxPos = (0,0,-11);
    thread SpawnFireSale();
    level.MagicBoxIndex = 0; //unused probably remove
    FireSaleHandler();
    
}

function MysteryBox()
{
    self.magicboxModel = GetEnt(self.target,"targetname");
    self.magicboxModel UseAnimTree(#animtree);
    self.linkedSpawnPoint = GetEnt(self.linkto, "linkname");
    self.closeFxEnt = undefined;
    self.openFxEnt = undefined; 
    self.boxActive = false; //the real box / not activated by firesale
    self.hasBoxEntered = false; //has the box been placed
    self.spawnPointIndex = undefined; //which spawn point to pass to the clientfield
    self.boxHitCount = undefined; // how many times the box has been used
    self.cost = 950; // default cost
    self.tempBox = false; //tempBox is an active firesale box
    self.boxOpen = false; //If the box is open we cant move it
    spawnPointArray = GetSpawnPointArray();
    if (self.linkto == "boxSpawnLoc0") //init first box
    {
        self.boxActive = true;
    }
    for(i=0; i < spawnPointArray.size;i++)
    {
        if(self.linkto == spawnPointArray[i])
        {
            self.spawnPointIndex = i;
        }
    }

    for(;;)
    {
        if(!self.boxActive && !self.tempBox)
        {
            self SetHintString("");
            self SetCursorHint("HINT_NOICON");
            waitrealtime(1);
            continue;
        }
        if(self.boxActive && !self.tempBox && !self.hasBoxEntered)
        {
            thread SpawnChest();
        }
        self SetHintString(BUY_MYSTERY_WEAPON_HINT);
        self SetCursorHint("HINT_NOICON");
        self.modelSpawnPoint = Spawn("script_model", self.linkedSpawnPoint.origin);
        self.modelSpawnPoint.angles = self.linkedSpawnPoint.angles;
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

         
        
        if (player zm_score::can_player_purchase(self.cost)) //player bought box
        {
            player zm_score::minus_to_player_score(self.cost);
            self.boxOpen = true;
            self SetHintString("");
            self SetCursorHint("HINT_NOICON");

            if(!isdefined(self.boxHitCount))
            {
                self.boxHitCount = 0;
            }
            if(!TreasureChestFiresaleActive())
            {
               self.boxHitCount++; 
               IPrintLnBold("increased bot hit count to " + self.boxHitCount);
            }
            

            player playsound("zmb_cha_ching");
            self.modelSpawnPoint MoveZ(40,3.5);
            HorseUtil::SafeDelete(self.closeFxEnt);
            self.magicboxModel AnimScripted( "openFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_OPEN);
            zm_utility::play_sound_at_pos( "open_chest", self.origin );
		    zm_utility::play_sound_at_pos( "music_chest", self.origin );

            self.openFxEnt = HorseUtil::SpawnFxHelper(level.relativeOpenFxPos,self.linkedSpawnPoint,OPEN_GLOW_FX); //do fx
            self.newWeapon = thread GetNewRandomBoxWeapon(player); //getting the random weapon to actually give the player, doing it early to avoid lag
            level clientfield::set( "playMagicBoxAnim", 1);
            level clientfield::set( "playMagicBoxAnimVar", self.spawnPointIndex);
            waitrealtime(0.05);
            level clientfield::set( "playMagicBoxAnim", 0);
            
            
            for (i = 0; i < 40; i++) //slot machine animation wait
            { 
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
           
            
            if(self.boxHitCount >= self.maxBoxHits) //joker
            {
                if(!TreasureChestFiresaleActive() && player bgb::is_enabled( "zm_bgb_unbearable" ))
                {
                    player TakeBgb();
                    
                    self.boxHitCount = 0;
                    HorseUtil::SafeDelete(self.openFxEnt);
                    HorseUtil::SafeDelete(self.modelSpawnPoint);
                   
                    self.magicboxModel AnimScripted( "closeFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_CLOSE);
                    
                    self.magicboxModel waittill("closeFin");
                    self.closeFxEnt = HorseUtil::SpawnFxHelper(level.relativeCloseFxPos,self.linkedSpawnPoint,CLOSE_GLOW_FX); //do fx
                    waitrealtime(1);
                    continue;
                }

                boxArray = GetEntArray("mysteryBox", "targetname"); //setting up a new real box
                newBox = undefined;
                while (!isdefined(newBox) || newBox == self)
                {
                    newBox = Array::random(boxArray);
                }
                newBox.boxActive = true;

                //self.magicboxModel AnimScripted( "closeFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_CLOSE);
                //self.magicboxModel waittill("closeFin");
                self.boxOpen = false;
                RemoveChest(player); //remove player from this when we find a better solution
                continue;
                
            }

            //modelSpawnPoint MoveZ(-40,0.01);//actually choose weapon
            self.modelSpawnPoint useweaponmodel(self.newWeapon); 

            if(isdefined(self.newWeapon))
            {
                self SetCursorHint( "HINT_WEAPON", self.newWeapon ); 
            }

            self thread GiveBoxWeapon(player,self.newWeapon);//wait for player to get weapon || timeout
            self thread WeaponLowerAnimation(self.modelSpawnPoint);
            self waittill("weaponTaken");
            
            HorseUtil::SafeDelete(self.openFxEnt);
            HorseUtil::SafeDelete(self.modelSpawnPoint);
            
            self.magicboxModel AnimScripted( "closeFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_CLOSE);
            self.magicboxModel waittill("closeFin");
            self.closeFxEnt = HorseUtil::SpawnFxHelper(level.relativeCloseFxPos,self.linkedSpawnPoint,CLOSE_GLOW_FX); //do fx
            self.boxOpen = false;
            self notify("boxClosed");
            waitrealtime(1);

        }

    }


}
function SpawnChest()
{
    
    self.linkedSpawnPoint = GetEnt(self.linkto, "linkname");
    if(!self.hasBoxEntered || TreasureChestFiresaleActive())
    {
        self.magicboxModel AnimScripted( "enterFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_ENTER);
        self.magicboxModel waittill("enterFin");
        self SetVisibleToAll();


        self.closeFxEnt = HorseUtil::SpawnFxHelper(level.relativeCloseFxPos,self.linkedSpawnPoint,CLOSE_GLOW_FX); //do fx
        waitrealtime(2); //testing fx shit maybe remove
        self.hasBoxEntered = true;
    }
    self.boxHitCount = 0;
    self.maxBoxHits = 3; //todo randomize max box hits
    self SetHintString(BUY_MYSTERY_WEAPON_HINT);
    self SetCursorHint("HINT_NOICON");
}
function RemoveChest(player)
{
    if (TreasureChestFiresaleActive() && self.boxActive) //if the box should be leaving but a fire sale activates reduce its hitcount by 1
    {                                                    //todo find a better solution to this because it doesnt really fix the issue
    
        self.boxHitCount--;
        self.modelSpawnPoint useweaponmodel(self.newWeapon); 

        if(isdefined(self.newWeapon))
        {
            self SetCursorHint( "HINT_WEAPON", self.newWeapon ); 
        }

        self thread GiveBoxWeapon(player,self.newWeapon);//wait for player to get weapon || timeout
        self thread WeaponLowerAnimation(self.modelSpawnPoint);
        self waittill("weaponTaken");
        
        HorseUtil::SafeDelete(self.openFxEnt);
        HorseUtil::SafeDelete(self.modelSpawnPoint);
        
        self.magicboxModel AnimScripted( "closeFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_CLOSE);
        self.magicboxModel waittill("closeFin");
        self.closeFxEnt = HorseUtil::SpawnFxHelper(level.relativeCloseFxPos,self.linkedSpawnPoint,CLOSE_GLOW_FX); //do fx
        self.boxOpen = false;
        self notify("boxClosed");
        waitrealtime(1);
        return undefined;
    }
    if(self.boxOpen)
    {
        self waittill("boxclosed");
    }
    self SetInvisibleToAll();
    self.boxActive = false;
    self.hasBoxEntered = false;
    self.boxHitCount = 0;
    
    //todo spawn a joker model and sound
    self.magicboxModel AnimScripted( "leavingFin", self.magicboxModel.origin , self.magicboxModel.angles, MAGIC_BOX_LEAVE);
    //modelSpawnPoint MoveZ(-40,0.01);
    HorseUtil::SafeDelete(self.openFxEnt);
    HorseUtil::SafeDelete(self.closeFxEnt);
    wait(.25);
    HorseUtil::SafeDelete(self.modelSpawnPoint);
    
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
            if( player bgb::is_enabled( "zm_bgb_crate_power" ) )
            {
                weapon = zm_weapons::get_upgrade_weapon( weapon );
                player zm_weapons::weapon_give(weapon, false, false, false, true);
			    player notify( "zm_bgb_crate_power_used" );
            }
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
    wait(.75);
    spawnPoint MoveZ(-40,6.25);
    wait(4.25);
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

function PrecacheAllWeaponModels() //Spawn all weapon models in 
{
    
    for(;;)
    {
        if (!isdefined(level.zombie_weapons))
        {
            wait(0.1);
            continue;
        }

        mysteryBox = GetEnt("boxSpawnLoc0","linkname");
        if (!isdefined(mysteryBox))
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
                ent useweaponmodel(weapon);
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

function FireSaleHandler()
{
    for(;;)
    {
        level waittill("powerup fire sale");
        IPrintLnBold("firesale");
        for(i=0;i < level.mysteryBoxArray.size;i++)
        {
            if(!level.mysteryBoxArray[i].boxActive)
            {
                level.mysteryBoxArray[i].tempBox = true;
                level.mysteryBoxArray[i] thread SpawnChest();
            }
            
        }

        level waittill("fire_sale_off");
        for(i=0;i < level.mysteryBoxArray.size;i++)
        {
            if(level.mysteryBoxArray[i].tempBox)
            {
                level.mysteryBoxArray[i] thread RemoveChest();
                level.mysteryBoxArray[i].tempBox = false;
            }
            
        }
        
        
    }
}




function TakeBgb()
{
    if( "none" == self.bgb ) {
        return;
    }
    self SetActionSlot( 1, "" );
    if( isdefined( level.bgb[self.bgb].disable_func ) ) {
        self thread [[level.bgb[self.bgb].disable_func]]();
    }
    self notify( "bgb_limit_monitor" );
    self notify( "bgb_activation_monitor" );
    self clientfield::set_player_uimodel( "bgb_display", 0 );
    self clientfield::set_player_uimodel( "bgb_activations_remaining", 0 );
    self bgb_set_timer_clientfield(0);
    self notify( "bgb_run_timer" );
    self notify( "bgb_update", "none", self.bgb );
    self notify( "bgb_update_take_" + self.bgb );
    self.bgb = "none";
}

function private bgb_set_timer_clientfield( percent )
{
    self notify( "hash_f9fad8b3" );
    var_eeab9300 = self clientfield::get_player_uimodel( "bgb_timer" );
    if( percent < var_eeab9300 && 0.1 <= ( var_eeab9300 - percent ) ) {
        self thread function_f9fad8b3( var_eeab9300, percent );
    }
    else {
        self clientfield::set_player_uimodel( "bgb_timer", percent );
    }
}

function private function_f9fad8b3( var_eeab9300, percent )
{
    self endon( "disconnect" );
    self endon( "hash_f9fad8b3" );
    start_time = GetTime();
    end_time = start_time + 1000;
    momsspaghetti = var_eeab9300;
    while( momsspaghetti > percent ) {
        momsspaghetti = LerpFloat( percent, var_eeab9300, calc_remaining_duration_lerp( start_time, end_time ) );
        self clientfield::set_player_uimodel( "bgb_timer", momsspaghetti );
        wait 0.05;
    }
}

function private calc_remaining_duration_lerp( start_time, end_time )
{
    if( 0 >= ( end_time - start_time ) ) {
        return 0;
    }
    now = GetTime();
    frac = ( Float( end_time - now ) ) / ( Float( end_time - start_time ) );
    return math::clamp( frac, 0, 1 );
}
