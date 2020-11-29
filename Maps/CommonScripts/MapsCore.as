/// Used so there's less duplicate code with adding a map level

// Add in spawns based on a blob
// Some maps might want you to spawn at a tent
// Some might want you to spawn at a shop, idk
//
// Returns true if spawning was done correctly
bool AddSpawns(CMap@ map, string markerName, string blobToSpawn, int teamNum = 0)
{
    Vec2f[] spawns;
    if (map.getMarkers(markerName, spawns))
    {
        for (int a = 0; a < spawns.length; a++)
        {
            server_CreateBlob(blobToSpawn, 0, spawns[a]);
        }

        return true;
    }
    
    return false;
}

// Same as above, but we remove all scripts attached to them
// This prevents us from using it
bool AddSpawnsCosmeticOnly(CMap@ map, string markerName, string blobToSpawn, int teamNum = 0)
{
    Vec2f[] spawns;
    if (map.getMarkers(markerName, spawns))
    {
        for (int a = 0; a < spawns.length; a++)
        {
            CBlob@ blob = server_CreateBlob(blobToSpawn, 0, spawns[a]);
            if (blob is null) 
                continue;

            // TODO-> Engine side need a way to get all scripts by name!
        }

        return true;
    }
    
    return false;
}