//#include "CharacterCore"

#include "EmotesCommon"

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
	string CurrentRenderOutput = "";
	// The whole text that is being written to ^
	string CurrentText = "";
	// How fast should we write (needs changing)
	int WriteSpeed = 1;
	// Are we done writing?
	bool FinishedWriting = false;

	// CurrentRenderOutput Total length including special tokens that are not outputted
	int TextRenderLength = 0;

	void SetName(string name)
	{
		CharacterName = name;
	}

	void AddResponse(string eventName, string text)
	{
		ResponseMap.set(eventName, getTranslatedString(text));
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
		TextRenderLength = 0;
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
			string chars = CurrentText.substr(TextRenderLength, 1);
			


			// Colour tokens
			if (chars == '$') 
			{
				for (int a = TextRenderLength + 1; a < CurrentText.length; a++)
				{
					string currentChar = CurrentText.substr(a, 1);
					chars += currentChar;
					if (currentChar == "$")
					{
						string temp = CurrentText.substr(a + 1, 1);
						if (isSpecialChar(temp))
							chars = "";
						else
							chars = temp;
							
						break;
					}
				}
			}
			else if (chars == '{') // Emote/Custom text logic
			{
				// TODO -> Make more pretty
				string insides = "";

				for (int a = TextRenderLength + 1; a < CurrentText.length; a++)
				{
					string currentChar = CurrentText.substr(a, 1);
				
					if (currentChar == "}")
					{
						// Add in the next char so adding a token doesnt waste a text update
						string temp = CurrentText.substr(a + 1, 1);
						if (isSpecialChar(temp))
							chars = "";
						else
							chars = temp;

						break;
					}

					insides += currentChar;
				}

				string action = insides.substr(0, 2);
				string content = insides.substr(2, insides.length);

				if (action == "E_")
				{
					set_emote(OwnerBlob, Emotes::names.find(content));
				}
				else if (action == "S_")
				{
					WriteSpeed = parseInt(content);
				}
				else if (action == "K_")
				{
				}

				TextRenderLength += 2 + action.length + content.length;
			}
			else if (chars != ' ') // TODO -> Set custom audio and sort out what we are doing with audio
			{
				Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
			}

			CurrentRenderOutput += chars;
			TextRenderLength += chars.length;

			// Need to fix (tokens excluding colours will make this invalid)
			if (TextRenderLength == CurrentText.length)
				FinishedWriting = true;
		}
	}


	bool isSpecialChar(string input)
	{
		return (input == "{" || input == "}" || input == "$");
	}

	void ResetText()
	{
		CurrentRenderOutput = "";
	}

	void RenderBox(Vec2f &in topLeft) 
	{
		// Character pane in pixels
		const Vec2f pane = Vec2f(108, 100);
		// Text box background
		const int rectangleWidth = topLeft.x * 5;
		// Bottom right
		Vec2f botRight = Vec2f(topLeft.x + pane.x, topLeft.y + pane.y);

		// Pane to the left
		GUI::DrawFramedPane(topLeft, Vec2f(botRight.x, botRight.y + 8)); 

		// Move the rest slightly right since we got that pane
		topLeft.x += pane.x;

		// Shadowed box that sits behind the text
		GUI::DrawRectangle(topLeft, Vec2f(rectangleWidth, botRight.y + 6), SColor(150,0,0,0));

		// Render font (and make sure we set the font they want before hand)
		GUI::SetFont(PreferedFont);
		GUI::DrawText(CurrentRenderOutput, Vec2f(topLeft.x + 25, topLeft.y + 10), 
			Vec2f(rectangleWidth - 25, botRight.y + 6), SColor(255, 255, 255, 255), false, false, false);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
/*class GlobalCharacter : Character
{

}*/

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

	void CustomTextUpdate()
	{
		UpdateText();

		// We only need to update this every so often
		HeadIndex = OwnerBlob.get_s32("head index");
		Team = OwnerBlob.get_s32("head team");
		HeadTextureFile = OwnerBlob.get_string("head texture");

		// Disabled for now, looks cursed as fuck
		/*if (!FinishedWriting && CurrentRenderText.substr(CurrentRenderText.length -2, 1) != " ")
			testFrame = 1;
		else
			testFrame = 0;*/
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
				CharacterToRender.ResetText();
			
			blob.get("character", @CharacterToRender);
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
