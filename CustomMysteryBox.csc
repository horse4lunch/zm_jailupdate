#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#using scripts\shared\clientfield_shared;
#insert scripts\shared\version.gsh;
#using scripts\zm\_zm_weapons;
#using scripts\shared\array_shared;
#insert scripts\zm\_zm_weapons.gsh;

#define WEAPON_TABLE "gamedata/weapons/zm/zm_levelcommon_weapons.csv"

#namespace CustomMysteryBox;

REGISTER_SYSTEM( "CustomMysteryBox", &Awake, undefined)
function Awake()
{
    clientfield::register( "world", "playMagicBoxAnim", VERSION_SHIP, 5, "int", &PlayMagicBoxAnim, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "playMagicBoxAnimVar", VERSION_SHIP, 5, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    wait 1;
    thread GetWeaponsInBoxFromTable(WEAPON_TABLE);
    
}

function PlayMagicBoxAnim( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    index = clientfield::get("playMagicBoxAnimVar");
    linkedSpawnPoint = GetEnt(localClientNum,"boxSpawnLoc" + index,"targetname");

    if (newVal == 1&& isdefined(linkedSpawnPoint))
    {
        modelSpawnPoint = spawn(localClientNum, linkedSpawnPoint.origin, "script_model");
        modelSpawnPoint.angles = linkedSpawnPoint.angles;
        modelSpawnPoint MoveZ(40,3.5);
             
        if(isdefined(modelSpawnPoint))
        {
            for (i = 0; i < 40; i++) //slot machine animation
            { 
                randomIndex = RandomInt(level.includedZombieWeapons.size);
                rollWeaponName = level.includedZombieWeapons[randomIndex];
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

function GetWeaponsInBoxFromTable( table )
{
    index = 1; 

    row = TableLookupRow( table, index );

    while ( isdefined( row ) )
    {
        weaponName = row[WEAPON_TABLE_COL_NAME];
        inBox = ( ToLower( row[ WEAPON_TABLE_COL_IN_BOX ] ) == "true" );
        AddZombieWeapons(weaponName,inBox);
        
        index++;
        row = TableLookupRow( table, index );
    }
}

function AddZombieWeapons(weaponName, inBox)
{
    weapon = GetWeapon(weaponName);

    struct = SpawnStruct();

    if ( !IsDefined( level.zombieWeapons ) )
	{
		level.zombieWeapons = [];
	}
    
    struct.weapon = weapon;
    struct.inBox = inBox;
    struct.name = weaponName;

    level.zombieWeapons[weapon] = struct;
    IncludeZombieWeapon();
}

function IncludeZombieWeapon() 
{
    level.includedZombieWeapons = [];

    keys = GetArrayKeys( level.zombieWeapons );
    for( i=0; i < keys.size; i++ )
    {
        weapon = keys[i];
        
        if(isdefined(level.zombieWeapons[weapon].inBox) && level.zombieWeapons[weapon].inBox)
        {
            level.includedZombieWeapons[level.includedZombieWeapons.size] = weapon.name;
            stinky = GetWeapon(weapon.name); //remove
            localizedWeaponName = MakeLocalizedString(stinky.displayname); //remove
            IPrintLnBold("Press F for " + localizedWeaponName); //remove
        }
    }
}
