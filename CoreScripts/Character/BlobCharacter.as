//#include "CharacterCore"


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
	void RenderBox() 
	{
		GUI::SetFont(PreferedFont);
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
        GUI::DrawFramedPane(Vec2f(leftX, topY), Vec2f(leftX + hardValue, topY + hardValue));

        leftX += hardValue;
        GUI::DrawRectangle(Vec2f(leftX, topY), Vec2f(leftX + hardValue + 500, topY + hardValue), SColor(150,0,0,0));
        GUI::DrawText(CurrentRenderText, Vec2f(leftX + 25, topY + 10), Vec2f(leftX + hardValue + 475, topY + hardValue), SColor(255, 255, 255, 255), false, false, false);
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

	Vertex[] PortraitVertex;

	BlobCharacter(CBlob@ owner, string name)
	{
		@OwnerBlob = owner;
		SetName(name);
	}

	void TempCharacterBind()
	{
		return;
		int sHeight = getDriver().getScreenHeight();
        int sWidth = getDriver().getScreenWidth();

        int leftX = sWidth / 6;
        int topY = sHeight - (sHeight / 2.5);
        int hardValue = 100;
		
		PortraitVertex.clear();
		
		PortraitVertex.push_back(Vertex(leftX,  topY,      0, 0, 0,   color_white)); // top left
		PortraitVertex.push_back(Vertex(leftX + hardValue, topY,     0, 1, 0,   color_white)); // top right
		PortraitVertex.push_back(Vertex(leftX + hardValue, topY + hardValue,     0, 1, 1, color_white));   // bot right
		PortraitVertex.push_back(Vertex(leftX,  topY + hardValue,      0, 0, 1, color_white));   // bot left

		Render::SetTransformScreenspace();
		Render::SetAlphaBlend(true);
		Render::RawQuads("GetiTest.png", PortraitVertex);
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
		if (CharacterToRender is null && !FindAndSetToSpeak())
			return;

		if (!CharacterToRender.FinishedWriting)
			CharacterToRender.UpdateText();
	}

	void onRender()
	{
		if (CharacterToRender is null)
			return;

		CharacterToRender.RenderBox();
		CharacterToRender.TempCharacterBind();
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
