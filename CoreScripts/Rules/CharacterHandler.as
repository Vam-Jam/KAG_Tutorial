#include "BlobCharacter"
#include "RunnerTextures"

BlobCharacterHandler@ Handler;

Vertex[] PortraitVertex;
int id = 0;

const string temp_texture_name = "ok_cool";
const string texture_head = "ok_not_cool";

// In localhost, this executes before CMap onInit does
void onInit(CRules@ this)
{
	// This will be called when ever we have set a character
	// The blob network ID will need to be sent as well.
	this.addCommandID("character_bound"); 
	// This will be called when a blob dies
	// This is required unless you want the game to crash
	this.addCommandID("character_unbound");
	// This will force the current character to become 
	// Current render target
	this.addCommandID("character_force_talk");

	onRestart(this);

	// Might get used if we want to use render:: in character rendering anywhere
	//id = Render::addScript(Render::layer_posthud, "CharacterHandler.as", "NewRender", 10.0f);
}

void onRestart(CRules@ this)
{
	if (Handler !is null) 
		Handler.Clear();

	@Handler = BlobCharacterHandler();
}

void onReload(CRules@ this)
{	
	if (Handler !is null) 
		Handler.Clear();

	@Handler = BlobCharacterHandler();

	// Only for reloads
	CBlob@[] blobs;
	getBlobs(@blobs);

	for (int a = 0; a < blobs.length; a++)
	{
		CBlob@ blob = blobs[a];
		if (blob is null)
			continue;

		BlobCharacter@ char = getCharacter(blob);

		if (char is null)
			continue;

		Handler.AddCharacter(char);
	}
	// End
}

void onTick(CRules@ this)
{
	if (Handler !is null)
		Handler.onTick();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{

	if (Handler is null)
		return;

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
	else if (cmd == this.getCommandID("character_unbound"))
	{
		u16 networkId = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(networkId);

		if (blob is null)
		{
			error("Invalid networkid character_bound : " + networkId);
			return;
		}

		Handler.RemoveCharacter(blob);
	}
	else if (cmd == this.getCommandID("character_force_talk"))
	{
		u16 networkId = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(networkId);

		Handler.SetBlobToRender(blob);
	}
}

void onRender(CRules@ this)
{
	if (Handler !is null)
		Handler.onRender();
}