#include "BlobCharacter"

// In localhost, this executes before CMap onInit does
void onInit(CRules@ this)
{
	// This will be called when ever we have set a character
	// The blob network ID will need to be sent as well.
	this.addCommandID("character_bound"); 
}

void onTick(CRules@ this)
{
	
}

void onRender(CRules@ this)
{

}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("character_bound"))
	{
		u16 networkId = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(networkId);

		if (blob is null)
		{
			error("Invalid networkid character_bound : " + networkId);
			return;
		}

		// Get char data, set it and see if data syncs
		BlobCharacter@ character = null;
		blob.get("character", @character);

		print(character.characterName + '');
	}
}