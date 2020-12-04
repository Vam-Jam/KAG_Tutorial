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

void UpdateHeadTexture(CBlob@ blob)
{
	s32 index = blob.get_s32("head index");
	s32 team = blob.get_s32("head team");
	int temp_index = 0;
	string texture_file = blob.get_string("head texture");

	if (Texture::exists(temp_texture_name))
		Texture::destroy(temp_texture_name);

	if (Texture::exists(texture_head))
		Texture::destroy(texture_head);

	Texture::createFromFile(temp_texture_name, texture_file);

	ImageData@ head = ImageData(16, 16);
	ImageData@ data = Texture::data(temp_texture_name);

	Vec2f pos = getPosFromIndex(index);

	for (int x = 0; x < 16; x++)
	{
		for (int y = 0; y < 16; y++)
		{
			head.put(x, y, data.get(x + pos.x, y + pos.y));
		}
	}

	Texture::createFromData(texture_head, head);
}

Vec2f getPosFromIndex(int index)
{
	// to optimize lol, done late night smooth brain
	int temp_index = 0;
	for (int x = 0; x < 32; x++)
	{
		for (int y = 0; y < 32; y++)
		{
			if (temp_index == index)
			{
				return Vec2f(y * 16, x * 16);
			}

			temp_index++;
		}
	}

	return Vec2f(0,0);
}

// onRender but also useful for character portait stuff
void NewRender(int id)
{
	if (Handler !is null)
		Handler.onRender();

	CBlob@ local = getLocalPlayerBlob();

	if (local is null)
		return;

	UpdateHeadTexture(local);
	
	int sHeight = getDriver().getScreenHeight();
	int sWidth = getDriver().getScreenWidth();

	int leftX = sWidth / 6;
	int topY = sHeight - (sHeight / 2.5);
	int hardValue = 100;

	
	/*PortraitVertex.clear();
	PortraitVertex.push_back(Vertex(leftX,  topY,      0, 0, 0,   color_white)); // top left
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY,     0, 1, 0,   color_white)); // top right
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY + hardValue,     0, 1, 1, color_white));   // bot right
	PortraitVertex.push_back(Vertex(leftX,  topY + hardValue,      0, 0, 1, color_white));   // bot left

	Render::SetTransformScreenspace();
	Render::SetAlphaBlend(true);
	Render::RawQuads("GetiTest.png", PortraitVertex);*/
	
	PortraitVertex.clear();
	
	PortraitVertex.push_back(Vertex(leftX,  topY,      						0, 0, 0,   color_white)); // top left
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY,     			0, 1, 0,   color_white)); // top right
	PortraitVertex.push_back(Vertex(leftX + hardValue, topY + hardValue,    0, 1, 1, color_white));   // bot right
	PortraitVertex.push_back(Vertex(leftX,  topY + hardValue,      			0, 0, 1, color_white));   // bot left

	Render::SetTransformScreenspace();
	Render::SetAlphaBlend(true);
	Render::RawQuads(texture_head, PortraitVertex);
}

/// First task

// -> get blob frame 
// -> find a way to calc what part of the frame we are using
// -> display one of the 3 indexs