#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#using scripts\shared\clientfield_shared;
#insert scripts\shared\version.gsh;
#using scripts\zm\_zm_weapons;
#using scripts\shared\array_shared;

#namespace CustomMysteryBox;

REGISTER_SYSTEM( "CustomMysteryBox", &Awake, undefined)
function Awake()
{
    clientfield::register( "world", "playMagicBoxAnim", VERSION_SHIP, 5, "int", &PlayMagicBoxAnim, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "playMagicBoxAnimVar", VERSION_SHIP, 5, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    wait 1;
    
    
}

function PlayMagicBoxAnim( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    index = clientfield::get("playMagicBoxAnimVar");
    IPrintLnBold(index);
    linkedSpawnPoint = GetEnt(localClientNum,"boxSpawnLoc" + index,"targetname");
    IPrintLnBold(isdefined(linkedSpawnPoint));

    if (newVal == 1&& isdefined(linkedSpawnPoint))
    {
        modelSpawnPoint = spawn(localClientNum, linkedSpawnPoint.origin, "script_model");
        modelSpawnPoint.angles = linkedSpawnPoint.angles;
        IPrintLnBold("model spawn point" + isdefined(modelSpawnPoint));
        modelSpawnPoint MoveZ(40,3.5);
        weaponArray = GetBoxWeaponArray();
        //IPrintLnBold("weapon array"+isdefined(weaponArray));
        
        
        if(isdefined(modelSpawnPoint))
        {
            for (i = 0; i < 40; i++) //slot machine animation todo client
            { 
                //rollWeapon = GetNewRandomBoxWeapon(player);
                weaponArray = GetBoxWeaponArray();
                randomIndex = RandomInt(weaponArray.size);
                rollWeaponName = weaponArray[randomIndex];
                //IPrintLnBold("roll weapon name" + rollWeaponName);
                if(isdefined(rollWeaponName))
                {
                    rollWeapon = GetWeapon(rollWeaponName);
                    modelSpawnPoint useweaponmodel(rollWeapon, rollWeapon.worldmodel);
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
            }
            waitrealtime( 0.3 );
            modelSpawnPoint Delete();
        }
    }
}

function GetSpawnPoint(index)
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

    return spawnArray[index];
}

function GetBoxWeaponArray() //helper func to get the zombie weapon array
{
    weaponArray = [];

    keys = GetArrayKeys( level.zombie_weapons_upgraded );
    IPrintLnBold("keys "+ isdefined(keys));
    IPrintLnBold("key size "+ keys.size);
    for( i=0; i < keys.size; i++ )
    {
        name = keys[i].rootWeapon.name;
        weapon = GetWeapon(name);
        
            if(StrEndsWith( name, "_upgraded" ))
            {
                name = GetSubStr( name, 0, name.size - 9 );
            }
            //IPrintLnBold(name);
            weaponArray[weaponArray.size] = name;
        
        
        weaponArray[weaponArray.size] = name;
            
        
    }
    return weaponArray;
}

function get_is_in_box( weapon )
{
	assert( IsDefined( level.zombie_weapons_upgraded[weapon] ), weapon.name + " was not included or is not part of the zombie weapon list." );
	
	return level.zombie_weapons_upgraded[weapon].is_in_box;
}
/*
function GetNewRandomBoxWeapon(localClientNum)//get a random box weapon the player doesnt already have
{
    player = GetLocalPlayer(localClientNum);
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
*/