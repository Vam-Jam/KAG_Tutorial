#include "BlobCharacter"

BlobCharacterHandler@ Handler;

// In localhost, this executes before CMap onInit does
void onInit(CRules@ this)
{
	// This will be called when ever we have set a character
	// The blob network ID will need to be sent as well.
	this.addCommandID("character_bound"); 
	onRestart(this);
}

void onRestart(CRules@ this)
{
	onReload(this);
}

void onReload(CRules@ this)
{
	if (Handler !is null) 
		Handler.Clear();

	@Handler = BlobCharacterHandler();
}

void onTick(CRules@ this)
{
	if (Handler !is null)
		Handler.onTick();
}

void onRender(CRules@ this)
{
	if (Handler !is null)
		Handler.onRender();
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

		Handler.AddCharacter(blob);
	}
}