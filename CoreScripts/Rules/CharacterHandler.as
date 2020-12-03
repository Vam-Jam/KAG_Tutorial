#include "BlobCharacter"

BlobCharacterHandler@ Handler;

Vertex[] PortraitVertex;
int id = 0;

// In localhost, this executes before CMap onInit does
void onInit(CRules@ this)
{
	// This will be called when ever we have set a character
	// The blob network ID will need to be sent as well.
	this.addCommandID("character_bound"); 
	onRestart(this);

	id = Render::addScript(Render::layer_posthud, "CharacterHandler.as", "newRender", 10.0f);
}

void onRestart(CRules@ this)
{
	if (Handler !is null) 
		Handler.Clear();

	@Handler = BlobCharacterHandler();
}

void onReload(CRules@ this)
{
	Render::RemoveScript(id);

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

	id = Render::addScript(Render::layer_posthud, "CharacterHandler.as", "newRender", 10.0f);
	
}

void SetUp()
{
	CBlob@ local = getLocalPlayerBlob();
	if (local !is null && !Texture::exists("owohead"))
	{
		CSpriteLayer@ layer = local.getSprite().getSpriteLayer("head");
		if (layer is null)
		{
			print("hi");
			return;
		}

		ImageData@ data = Texture::dataFromSpriteLayer(null);

		if (data !is null)
				Texture::createFromData("owohead", data);
	}
}

void onTick(CRules@ this)
{
	SetUp();

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
void newRender(int id)
{
	if (Handler !is null)
		Handler.onRender();

	CBlob@ local = getLocalPlayerBlob();

	if (local is null || local.getSprite() is null)
		return;


	s32 index = local.get_s32("head index");
	s32 team = local.get_s32("head team");
	string texture_file = local.get_string("head texture");

	
	int sHeight = getDriver().getScreenHeight();
	int sWidth = getDriver().getScreenWidth();

	int leftX = sWidth / 6;
	int topY = sHeight - (sHeight / 2.5);
	int hardValue = 100;

	int something = 0.035;
	int pos = 0.035 * index;
	
	PortraitVertex.clear();
	PortraitVertex.push_back(Vertex(leftX,  topY,      0, 0, 0,   color_white)); // top left
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY,     0, 1, 0,   color_white)); // top right
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY + hardValue,     0, 1, 1, color_white));   // bot right
	PortraitVertex.push_back(Vertex(leftX,  topY + hardValue,      0, 0, 1, color_white));   // bot left

	Render::SetTransformScreenspace();
	Render::SetAlphaBlend(true);
	Render::RawQuads("GetiTest.png", PortraitVertex);
	
	PortraitVertex.clear();
	
	PortraitVertex.push_back(Vertex(leftX,  topY,      						0, 0, 0,   color_white)); // top left
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY,     			0, 1, 0,   color_white)); // top right
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY + hardValue,    0, 1, 1, color_white));   // bot right
	PortraitVertex.push_back(Vertex(leftX,  topY + hardValue,      			0, 0, 1, color_white));   // bot left

	Render::SetTransformScreenspace();
	Render::SetAlphaBlend(true);
	Render::RawQuads("owohead", PortraitVertex);
}

/// First task

// -> get blob frame 
// -> find a way to calc what part of the frame we are using
// -> display one of the 3 indexs