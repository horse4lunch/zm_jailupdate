
#insert scripts\shared\shared.gsh;
#using scripts\shared\system_shared;


#namespace HorseUtil;

REGISTER_SYSTEM("HorseUtil", &Awake, undefined)
function Awake()
{

}

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
