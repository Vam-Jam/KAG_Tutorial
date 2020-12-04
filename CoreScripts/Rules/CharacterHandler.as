#include "BlobCharacter"

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
	onRestart(this);

	id = Render::addScript(Render::layer_posthud, "CharacterHandler.as", "NewRender", 10.0f);
}

void onRestart(CRules@ this)
{
	if (Handler !is null) 
		Handler.Clear();

	@Handler = BlobCharacterHandler();
}

void onReload(CRules@ this)
{
	//Render::RemoveScript(id);
	//id = Render::addScript(Render::layer_posthud, "CharacterHandler.as", "NewRender", 10.0f);
	
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

		Handler.AddCharacter(BlobCharacter(char));
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


// onRender but also useful for character portait stuff
void NewRender(int id)
{
	if (Handler !is null)
		Handler.onRender();

	CBlob@ local = getLocalPlayerBlob();

	if (local is null)
		return;

	int sHeight = getDriver().getScreenHeight();
	int sWidth = getDriver().getScreenWidth();

	int leftX = sWidth / 6;
	int topY = sHeight - (sHeight / 2.5);
	int hardValue = 100;


	s32 index = local.get_s32("head index");
	s32 team = local.get_s32("head team");
	string texture_file = local.get_string("head texture");

	GUI::DrawIcon("ArcherTest.png", 0, Vec2f(12, 12), Vec2f(leftX + 5, topY + 5), 3.8f, team);
	GUI::DrawIcon(texture_file, index, Vec2f(16, 16), Vec2f(leftX -3, topY - 25), 3.8f, team);
}