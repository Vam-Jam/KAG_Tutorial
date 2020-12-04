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



CBlob@ SpawnInCharacter(string blobName, int team, Vec2f pos, string characterName, bool onInit = true)
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

	blob.AddScript("InteractableCharacter");

	// Set character data
	BlobCharacter@ character = BlobCharacter(blob, characterName);
	character.AddResponse("test", "What the fuck did you just fucking say about me, you little bitch? I’ll have you know I graduated top of my class in the Navy Seals, and I’ve been involved in numerous secret raids on Al-Quaeda, and I have over 300 confirmed kills. I am trained in gorilla warfare and I’m the top sniper in the entire US armed forces. You are nothing to me but just another target. I will wipe you the fuck out with precision the likes of which has never been seen before on this Earth, mark my fucking words. You think you can get away with saying that shit to me over the Internet? Think again, fucker. As we speak I am contacting my secret network of spies across the USA and your IP is being traced right now so you better prepare for the storm, maggot. The storm that wipes out the pathetic little thing you call your life. You’re fucking dead, kid. I can be anywhere, anytime, and I can kill you in over seven hundred ways, and that’s just with my bare hands. Not only am I extensively trained in unarmed combat, but I have access to the entire arsenal of the United States Marine Corps and I will use it to its full extent to wipe your miserable ass off the face of the continent, you little shit. If only you could have known what unholy retribution your little “clever” comment was about to bring down upon you, maybe you would have held your fucking tongue. But you couldn’t, you didn’t, and now you’re paying the price, you goddamn idiot. I will shit fury all over you and you will drown in it. You’re fucking dead, kiddo.");
	blob.set("character", character);

	//Call CRules and tell it to add Character into a global handler
	CBitStream@ cbs = CBitStream();
	CRules@ rules = getRules();

	cbs.write_u16(blob.getNetworkID());
	rules.SendCommand(rules.getCommandID("character_bound"), cbs);

	return blob;
}