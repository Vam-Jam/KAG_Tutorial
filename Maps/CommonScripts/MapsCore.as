/// Used so there's less duplicate code with adding a map level

#include "BlobCharacter"


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



/*CBlob@ SpawnInCharacter(string blobName, int team, Vec2f pos, string characterName, bool onInit = true, string customBody = "")
{
	CBlob@ blob = null;

	// Offer them an option to auto init or not
	// In case they want to set their own settings
	if (onInit)
	{
		@blob = server_CreateBlob(blobName, team, pos);
	}
	else 
	{
		@blob = server_CreateBlobNoInit(blobName);
		blob.setPosition(pos);
		blob.server_setTeamNum(team);
	}
	
	if (blob is null) {
		error("SpawnInCharacter creating a blob has failed!");
		return null;
	}

	if (customBody != "")
		blob.set_string("custom_body", customBody);

	blob.AddScript("InteractableCharacter");

	// Set character data
	BlobCharacter@ character = BlobCharacter(blob, characterName);
	character.PushToGlobalHandler();

	return blob;
}*/

void addCharacterToBlob(CBlob@ blob, string &in characterName, string &in textFile)
{
	if (blob.hasScript("InteractableCharacter"))
	{
		error("Trying to add a script to a blob that already has InteractableCharacter.as");
		return;
	}

	blob.AddScript("InteractableCharacter");

	// Todo -> Load file
	BlobCharacter@ character = BlobCharacter(blob, characterName);
	character.LoadTextConfig(textFile);
}