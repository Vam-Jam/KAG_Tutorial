//#include "CharacterCore"

int SCREEN_HEIGHT = 0;
int SCREEN_WIDTH  = 0;

mixin class Character 
{
	dictionary ResponseMap = dictionary();
	
	// Maybe you want this character to have a custom font
	string PreferedFont = "Menu";
	// Custom character name
	string CharacterName = "";
	
	// Text that is currently on the screen
	string CurrentRenderText = "";
	// The whole text that is being written to ^
	string CurrentText = "";
	// How fast should we write (needs changing)
	int WriteSpeed = 1;
	// Are we done writing?
	bool FinishedWriting = false;

	void SetName(string name)
	{
		CharacterName = name;
	}

	void AddResponse(string eventName, string text)
	{
		ResponseMap.set(eventName, text);
	}

	string getResponse(string eventName)
	{
		string text = "";
		ResponseMap.get(eventName, text);
		return text;
	}

	void GetResponse(string eventName, string &out text)
	{
		ResponseMap.get(eventName, text);
	}

	void SetCurrentResponse(string eventName, int textSpeed = 1)
	{
		FinishedWriting = false;
		CurrentText = getResponse(eventName);
		WriteSpeed = textSpeed;
	}

	void SetPreferedFont(string name)
	{
		PreferedFont = name;
	}

	const string getName()
	{
		return CharacterName;
	}

	void UpdateText()
	{
		if (getGameTime() % WriteSpeed == 0)
		{
			string char = CurrentText.substr(CurrentRenderText.length, 1);

			// Grab the full token so users dont see a part of it when reading
			if (char == '$') 
			{
				for (int a = CurrentRenderText.length + 1; a < CurrentText.length; a++)
				{
					string currentchar = CurrentText.substr(a, 1);
					char += currentchar;

					if (currentchar == "$") 
					{
						// Add in the next char so adding a token doesnt waste a text update
						char += CurrentText.substr(a + 1, 1);
						break;
					}
				}
			}
			else if (char != ' ') // TODO -> Set custom audio and sort out what we are doing with audio
			{
				Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
			}

			CurrentRenderText += char;

			if (CurrentRenderText.length == CurrentText.length)
				FinishedWriting = true;
		}
	}

	// TODO -> Sort this junk out, clear our sHeight and sWidth n stuff
	void RenderBox(Vec2f topLeft) 
	{
		GUI::SetFont(PreferedFont);
        int hardValue = 100;

        GUI::DrawFramedPane(topLeft, Vec2f(topLeft.x + hardValue, topLeft.y + hardValue));

        topLeft.x += hardValue;
        GUI::DrawRectangle(topLeft, Vec2f(topLeft.x + hardValue + 500, topLeft.y + hardValue), SColor(150,0,0,0));
        GUI::DrawText(CurrentRenderText, Vec2f(topLeft.x + 25, topLeft.y + 10), Vec2f(topLeft.x + hardValue + 475, topLeft.y + hardValue), SColor(255, 255, 255, 255), false, false, false);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
/*class GlobalCharacter : Character
{

}*/

class BlobCharacter : Character
{
	CBlob@ OwnerBlob; 
	s32 HeadIndex = 0;
	u8 testFrame = 0;
	s32 Team = 0;
	string TextureFile = "";

	BlobCharacter(CBlob@ owner, string name)
	{
		@OwnerBlob = owner;
		SetName(name);
	}

	void CustomTextUpdate()
	{
		UpdateText();

		/*if (!FinishedWriting && CurrentRenderText.substr(CurrentRenderText.length -2, 1) != " ")
			testFrame = 1;
		else
			testFrame = 0;*/
	}

	void CharacterPortrait(Vec2f topLeft)
	{
		Vec2f headpos(topLeft.x - 11, topLeft.y - 27);

		HeadIndex = OwnerBlob.get_s32("head index");
		Team = OwnerBlob.get_s32("head team");
		TextureFile = OwnerBlob.get_string("head texture");

		GUI::DrawIcon("Archer_class.png", 0, Vec2f(12, 12), Vec2f(topLeft.x + 5, topLeft.y + 5), 4.0f, Team);
		GUI::DrawIcon(TextureFile, HeadIndex + testFrame, Vec2f(16, 16), headpos , 4.0f, Team);
	}
}


class BlobCharacterHandler
{
	// List of all the blob characters in our game
	array<BlobCharacter@> BlobList;

	// Character we are going to render
	BlobCharacter@ CharacterToRender = null;
	
	// Dunno if we need this
	CMap@ map;

	BlobCharacterHandler()
	{
		@map = getMap();
	}

	void AddCharacter(BlobCharacter@ character)
	{
		BlobList.push_back(character);

		if (g_debug > 0)
		{
			print("Adding character \"" + character.getName() + "\"");
		}
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
		for (int a = 0; a < BlobList.length; a++)
		{
			BlobCharacter@ char = BlobList[a];

			if (char.OwnerBlob is blob)
			{
				@CharacterToRender = @char;
				break;
			}
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

		if (!CharacterToRender.FinishedWriting)
			CharacterToRender.CustomTextUpdate();
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

		CharacterToRender.RenderBox(topLeft);
		CharacterToRender.CharacterPortrait(topLeft);
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
