#include "CharacterCore"

// TODO -> RENDER CHARACTER NAME
class BlobCharacter : Character
{
	string CharacterTextureFile = "";
	string HeadTextureFile = "";
	string NextInteractKey = "";
	CBlob@ OwnerBlob; 

	s32 HeadIndex = 0; 
	s32 Team = 0;

	// Not in use
	u8 testFrame = 0;

	BlobCharacter(CBlob@ owner, string name)
	{
		@OwnerBlob = owner;
		SetName(name);

		owner.set("character", @this);

		// TODO MAYBE IN THE FUTURE (effort)
		// -> Load current blob sprite if custom_body doesnt exist
		// -> get frame data from there instead of making custom body

		if (owner.exists("custom_body"))
			CharacterTextureFile = owner.get_string("custom_body");
		else
			CharacterTextureFile = owner.getName() + (owner.getSexNum() == 0 ? "_male_body.png" : "_female_body.png");
	}

	void LoadTextConfig(string configName)
	{
		ConfigFile cf = ConfigFile(CFileMatcher(configName).getFirst());
		if (cf is null)
		{
			error("AttachedTextConfig " + configName + " is null (attached to character  " + CharacterName + ")");
			return;
		}

		if (cf.exists("main")) {
			string main = cf.read_string("main");
			
			AddResponse("main", main);
			NextInteractKey = "main";
		}

		// Temp work around until cfg has a get all keys func (would be named keys, but its an illegal name >:( )
		string[] configKeys = cf.read_string("keys").split(';');

		// Todo -> error if not found
		for (int a = 0; a < configKeys.length; a++)
		{
			string text = cf.read_string(configKeys[a]);
			AddResponse(configKeys[a], text);
		}
	}

	// Called when user interacts with said target
	void ButtonPress() 
	{
		SetCurrentResponse(NextInteractKey);
	}

	void CustomUpdate()
	{
		Update();

		// Keep watch to update when the char changes head
		SetHeadData();

		// Disabled for now, looks cursed as fuck
		/*if (!FinishedWriting && CurrentRenderText.substr(CurrentRenderText.length -2, 1) != " ")
			testFrame = 1;
		else
			testFrame = 0;*/
	}

	void SetHeadData()
	{
		HeadIndex = OwnerBlob.get_s32("head index");
		Team = OwnerBlob.get_s32("head team");
		HeadTextureFile = OwnerBlob.get_string("head texture");
	}

	void CustomRender(Vec2f &in topLeft)
	{
		RenderBox(topLeft);
		CharacterPortrait(topLeft);
	}

	// TODO: Character head is empty the first few ticks
	void CharacterPortrait(Vec2f &in topLeft)
	{
		// Get character head pos
		Vec2f headpos(topLeft.x - 10, topLeft.y - 26);

		GUI::DrawIcon(CharacterTextureFile, 0, Vec2f(12, 12), Vec2f(topLeft.x + 6, topLeft.y + 6), 4.0f, Team);
		GUI::DrawIcon(HeadTextureFile, HeadIndex + testFrame, Vec2f(16, 16), headpos , 4.0f, Team);
	}

	// Todo -> Find a better way to do this maybe? It works for now i guess (unsure why i dislike this)
	void PushToGlobalHandler()
	{
		CBitStream@ cbs = CBitStream();
		cbs.write_u16(OwnerBlob.getNetworkID());

		getRules().SendCommand(getRules().getCommandID("character_bound"), cbs);
	}
}


class BlobCharacterHandler
{
	// List of all the blob characters in our game
	array<BlobCharacter@> BlobList;

	// Character we are going to render
	BlobCharacter@ CharacterToRender = null;

	BlobCharacterHandler()
	{
	}

	void AddCharacter(BlobCharacter@ character)
	{
		BlobList.push_back(character);

		if (g_debug > 0)
		{
			print("Adding character \"" + character.getName() + "\"");
		}
	}

	void RemoveCharacter(CBlob@ blob)
	{
		BlobCharacter@ character = null;
		blob.get("character", @character);

		if (character is null)
		{
			error("RemoveCharacter with blob " + blob.getName() +
				" is null, please only remove when blob has a character attached to it");
			return; 
		}

		if (CharacterToRender is character)
		{
			@CharacterToRender = null;
		}

		int index = getBlobIndex(character);
		if (index != -1)
		{
			BlobList.erase(index);
		}
	}

	int getBlobIndex(BlobCharacter@ char)
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			if (char is BlobList[a])
			{
				return a;
			}
		}

		return -1;
	}

	int getBlobIndex(CBlob@ blob)
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			BlobCharacter@ char = BlobList[a];

			if (char.OwnerBlob is blob)
			{
				return a;
			}
		}

		return -1;
	}

	void AddCharacter(CBlob@ blob)
	{
		BlobCharacter@ character = null;
		blob.get("character", @character);

		if (character is null) 
		{
			error("AddCharacter with blob " + blob.getName() + 
				" is null, please create character before hand!");

			return;
		}

		AddCharacter(character);
	}

	void SetBlobToRender(CBlob@ blob)
	{
		int index = getBlobIndex(blob);
		if (index != -1)
		{
			if (CharacterToRender !is null)
				CharacterToRender.ResetTalkVars();
			
			blob.get("character", @CharacterToRender);
			CharacterToRender.SetHeadData();
		}
	}

	bool FindAndSetToSpeak()
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			BlobCharacter@ char = BlobList[a];
			if (char.CurrentText != "")
			{
				@CharacterToRender = char;
				return true;
			}
		}
		
		return false;
	}

	void onTick()
	{
		UpdateScreenVars();

		if (CharacterToRender is null && !FindAndSetToSpeak())
			return;

		CharacterToRender.Update();

		if (CharacterToRender.FinishedTalking)
			@CharacterToRender = @null;
	}

	void UpdateScreenVars()
	{
		SCREEN_HEIGHT = getDriver().getScreenHeight();
		SCREEN_WIDTH = getDriver().getScreenWidth();
	}

	void onRender()
	{
		if (CharacterToRender is null)
			return;

		Vec2f topLeft(SCREEN_WIDTH / 6, SCREEN_HEIGHT - (SCREEN_HEIGHT / 2.5));

		CharacterToRender.CustomRender(topLeft);
	}

	// Todo: some other stuff?
	void Clear()
	{
		BlobList.clear();
	}
}

////// Quick handles for scripts to use //////
BlobCharacter@ getCharacter(CBlob@ blob)
{
	BlobCharacter@ character = null;
	blob.get("character", @character);
	return character;
}
